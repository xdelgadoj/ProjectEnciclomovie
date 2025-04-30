import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:enciclomovie/domain/entities/push_message.dart';
import 'package:enciclomovie/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  //print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc() : super( const NotificationsState() ) {

    on<NotificationStatusChanged>( _notificationStatusChanged );
    on<NotificationReceived>( _onPushMessageReceived );
    on<NotificationDeleted>(_onNotificationDeleted);
    on<MarkAllNotificationsRead>(_onMarkAllNotificationsRead);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);



    // Verificar estado de las notificaciones
    _initialStatusCheck();

    // Listener para notificaciones en Foreground
    _onForegroundMessage();

    // recoge el mensaje inicial al abrir la app desde la notificación
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        handleRemoteMessage(message);
      }
    });

    // escucha si el usuario abre una notificación en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleRemoteMessage(message);
    });
  }

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationStatusChanged( NotificationStatusChanged event, Emitter<NotificationsState> emit ) {
    emit(
      state.copyWith(
        status: event.status
      )
    );
    _getFCMToken();
  }
  
  void _onPushMessageReceived( NotificationReceived event, Emitter<NotificationsState> emit ) {
    emit(
      state.copyWith(
        notifications: [ event.pushMessage, ...state.notifications ]
      )
    );
  }

  void _onNotificationDeleted(NotificationDeleted event, Emitter<NotificationsState> emit) {
    final updatedList = state.notifications
        .where((n) => n.messageId != event.messageId)
        .toList();

    emit(state.copyWith(notifications: updatedList));
  }

  void _onMarkAllNotificationsRead(MarkAllNotificationsRead event, Emitter<NotificationsState> emit) {
    final updatedList = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    emit(state.copyWith(notifications: updatedList));
  }

  void _onMarkNotificationAsRead(MarkNotificationAsRead event, Emitter<NotificationsState> emit) {
    final updatedList = state.notifications.map((n) {
      if (n.messageId == event.messageId && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    emit(state.copyWith(notifications: updatedList));
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add( NotificationStatusChanged(settings.authorizationStatus) );
  }

  void _getFCMToken() async {
    
    if ( state.status != AuthorizationStatus.authorized ) return;
  
    final token = await messaging.getToken();
    print('FCM Token: $token');
  }

  void handleRemoteMessage( RemoteMessage message ) {
    
    if (message.notification == null) return;    
    
    final notification = PushMessage(
      messageId: message.messageId
        ?.replaceAll(':', '').replaceAll('%', '')
        ?? '',
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
        ? message.notification!.android?.imageUrl
        : message.notification!.apple?.imageUrl,
      isRead: false
    );

    add( NotificationReceived(notification) );
    
  }

  void _onForegroundMessage(){ 
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermission() async {
    
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    add( NotificationStatusChanged(settings.authorizationStatus) );
  }

  PushMessage? getMessageById( String pushMessageId ) {
    final exist = state.notifications.any((element) => element.messageId == pushMessageId );
    if ( !exist ) return null;

    return state.notifications.firstWhere((element) => element.messageId == pushMessageId );
  }

}