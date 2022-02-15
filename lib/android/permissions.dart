// All permissions available at https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/res/AndroidManifest.xml

import 'dart:collection';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:mdi/mdi.dart';
import 'package:wsa_pacman/utils/locale_utils.dart';
import 'package:collection/collection.dart';

enum AndroidPermission {
  NONE,
  X_ADMIN_BRICK,
  X_ADMIN_LOCK,
  ADMIN,
  STORAGE,
  MICROPHONE,
  CAMERA,
  LOCATION,
  PHONE,
  CALL_LOG,
  SMS,
  CONTACTS,
  CALENDAR,
  ACTIVITY_RECOGNITION,
  X_SENSORS_BODY,
  SENSORS,
  NEARBY_DEVICES, // ?
}

extension AndroidPermissionList on AndroidPermission {

  static Set<AndroidPermission> fromNames(Iterable<String> names) {
    final permissions = SplayTreeSet<AndroidPermission>((a,b)=> a.index - b.index)
        ..addAll(names.map((perm) => AndroidPermissionList.get(perm)).whereNotNull());
    if (permissions.isEmpty) permissions.add(AndroidPermission.NONE);
    return permissions;
  }

  static AndroidPermission? get(String name) => _permissions[name];


  Icon get icon {switch (this) {
    case AndroidPermission.NONE: return const Icon(Mdi.gitlab);
    case AndroidPermission.X_ADMIN_BRICK: return const Icon(Mdi.bugOutline);
    case AndroidPermission.X_ADMIN_LOCK: return const Icon(Mdi.shieldLockOutline);
    case AndroidPermission.ADMIN: return const Icon(Mdi.shieldAccountOutline);
    case AndroidPermission.STORAGE: return const Icon(Mdi.folderOutline);
    case AndroidPermission.MICROPHONE: return const Icon(Mdi.microphoneOutline);
    case AndroidPermission.CAMERA: return const Icon(Mdi.cameraOutline);
    case AndroidPermission.LOCATION: return const Icon(Mdi.mapMarkerOutline);
    case AndroidPermission.PHONE: return const Icon(Mdi.phoneOutline);
    case AndroidPermission.CALL_LOG: return const Icon(Mdi.phoneLogOutline);
    case AndroidPermission.SMS: return const Icon(Mdi.messageProcessingOutline);
    case AndroidPermission.CONTACTS: return const Icon(Mdi.contactsOutline);
    case AndroidPermission.CALENDAR: return const Icon(Mdi.calendarMonthOutline);
    case AndroidPermission.ACTIVITY_RECOGNITION: return const Icon(Mdi.run);
    case AndroidPermission.X_SENSORS_BODY: return const Icon(Mdi.heartSettingsOutline);
    case AndroidPermission.SENSORS: return const Icon(Mdi.fingerprint);
    case AndroidPermission.NEARBY_DEVICES: return const Icon(Mdi.accessPointNetwork);
  }}

  String description(AppLocalizations lang) {switch (this) {
    case AndroidPermission.NONE: return lang.android_permission_none;
    case AndroidPermission.X_ADMIN_BRICK: return lang.android_permission_admin_brick;
    case AndroidPermission.X_ADMIN_LOCK: return lang.android_permission_admin_lock;
    case AndroidPermission.ADMIN: return lang.android_permission_admin;
    case AndroidPermission.STORAGE: return lang.android_permission_storage;
    case AndroidPermission.MICROPHONE: return lang.android_permission_microphone;
    case AndroidPermission.CAMERA: return lang.android_permission_camera;
    case AndroidPermission.LOCATION: return lang.android_permission_location;
    case AndroidPermission.PHONE: return lang.android_permission_phone;
    case AndroidPermission.CALL_LOG: return lang.android_permission_call_log;
    case AndroidPermission.SMS: return lang.android_permission_sms;
    case AndroidPermission.CONTACTS: return lang.android_permission_contacts;
    case AndroidPermission.CALENDAR: return lang.android_permission_calendar;
    case AndroidPermission.ACTIVITY_RECOGNITION: return lang.android_permission_activity_recognition;
    case AndroidPermission.X_SENSORS_BODY: return lang.android_permission_sensors_body;
    case AndroidPermission.SENSORS: return lang.android_permission_sensors;
    case AndroidPermission.NEARBY_DEVICES: return lang.android_permission_nearby_devices;
  }}
 
  static final _permissions = {
    "android.permission.BRICK": AndroidPermission.X_ADMIN_BRICK,
    "android.permission.LOCK_DEVICE": AndroidPermission.X_ADMIN_LOCK,
    "android.permission.BIND_DEVICE_ADMIN": AndroidPermission.ADMIN,
    "android.permission.MANAGE_DEVICE_ADMINS": AndroidPermission.ADMIN,
    "android.permission.RESET_PASSWORD": AndroidPermission.ADMIN,

    "android.permission.READ_CONTACTS": AndroidPermission.CONTACTS,
    "android.permission.WRITE_CONTACTS": AndroidPermission.CONTACTS,

    "android.permission.READ_CALENDAR": AndroidPermission.CALENDAR,
    "android.permission.WRITE_CALENDAR": AndroidPermission.CALENDAR,

    "android.permission.ACCESS_MESSAGES_ON_ICC": AndroidPermission.SMS,
    "android.permission.SEND_SMS": AndroidPermission.SMS,
    "android.permission.RECEIVE_SMS": AndroidPermission.SMS,
    "android.permission.READ_SMS": AndroidPermission.SMS,
    "android.permission.RECEIVE_WAP_PUSH": AndroidPermission.SMS,
    "android.permission.RECEIVE_MMS": AndroidPermission.SMS,
    "android.permission.BIND_CELL_BROADCAST_SERVICE": AndroidPermission.SMS,
    "android.permission.READ_CELL_BROADCASTS": AndroidPermission.SMS,
    "android.permission.WRITE_SMS": AndroidPermission.SMS,
    "android.permission.SEND_RESPOND_VIA_MESSAGE": AndroidPermission.SMS,
    "android.permission.SEND_SMS_NO_CONFIRMATION": AndroidPermission.SMS,
    "android.permission.CARRIER_FILTER_SMS": AndroidPermission.SMS,
    "android.permission.RECEIVE_EMERGENCY_BROADCAST": AndroidPermission.SMS,
    "android.permission.MODIFY_CELL_BROADCASTS": AndroidPermission.SMS,

    "android.permission.READ_EXTERNAL_STORAGE": AndroidPermission.STORAGE,
    "android.permission.WRITE_EXTERNAL_STORAGE": AndroidPermission.STORAGE,
    "android.permission.ACCESS_MEDIA_LOCATION": AndroidPermission.STORAGE,
    "android.permission.WRITE_OBB": AndroidPermission.STORAGE,
    "android.permission.MANAGE_EXTERNAL_STORAGE": AndroidPermission.STORAGE,
    "android.permission.MANAGE_MEDIA": AndroidPermission.STORAGE,
    "android.permission.WRITE_MEDIA_STORAGE": AndroidPermission.STORAGE,
    "android.permission.MANAGE_DOCUMENTS": AndroidPermission.STORAGE,

    "android.permission.ACCESS_FINE_LOCATION": AndroidPermission.LOCATION,
    "android.permission.ACCESS_COARSE_LOCATION": AndroidPermission.LOCATION,
    "android.permission.ACCESS_BACKGROUND_LOCATION": AndroidPermission.LOCATION,
    "android.permission.ACCESS_LOCATION_EXTRA_COMMANDS": AndroidPermission.LOCATION,
    "android.permission.INSTALL_LOCATION_PROVIDER": AndroidPermission.LOCATION,
    "android.permission.INSTALL_LOCATION_TIME_ZONE_PROVIDER_SERVICE": AndroidPermission.LOCATION,
    "android.permission.BIND_TIME_ZONE_PROVIDER_SERVICE": AndroidPermission.LOCATION,
    "android.permission.LOCATION_HARDWARE": AndroidPermission.LOCATION,

    "android.permission.ACCESS_IMS_CALL_SERVICE": AndroidPermission.CALL_LOG,
    "android.permission.PERFORM_IMS_SINGLE_REGISTRATION": AndroidPermission.CALL_LOG,
    "android.permission.READ_CALL_LOG": AndroidPermission.CALL_LOG,
    "android.permission.WRITE_CALL_LOG": AndroidPermission.CALL_LOG,
    "android.permission.PROCESS_OUTGOING_CALLS": AndroidPermission.CALL_LOG,

    "android.permission.READ_PHONE_STATE": AndroidPermission.PHONE,
    "android.permission.READ_PHONE_NUMBERS": AndroidPermission.PHONE,
    "android.permission.CALL_PHONE": AndroidPermission.PHONE,
    "com.android.voicemail.permission.ADD_VOICEMAIL": AndroidPermission.PHONE,
    "android.permission.USE_SIP": AndroidPermission.PHONE,
    "android.permission.ANSWER_PHONE_CALLS": AndroidPermission.PHONE,
    "android.permission.MANAGE_OWN_CALLS": AndroidPermission.PHONE,
    "android.permission.CALL_COMPANION_APP": AndroidPermission.PHONE,
    "android.permission.EXEMPT_FROM_AUDIO_RECORD_RESTRICTIONS": AndroidPermission.PHONE,
    "android.permission.ACCEPT_HANDOVER": AndroidPermission.PHONE,
    "com.android.voicemail.permission.WRITE_VOICEMAIL": AndroidPermission.PHONE,
    "com.android.voicemail.permission.READ_VOICEMAIL": AndroidPermission.PHONE,

    "android.permission.RECORD_AUDIO": AndroidPermission.MICROPHONE,
    "android.permission.RECORD_BACKGROUND_AUDIO": AndroidPermission.MICROPHONE,

    "android.permission.ACTIVITY_RECOGNITION": AndroidPermission.ACTIVITY_RECOGNITION,

    "android.permission.CAMERA": AndroidPermission.CAMERA,
    "android.permission.BACKGROUND_CAMERA": AndroidPermission.CAMERA,
    "android.permission.SYSTEM_CAMERA": AndroidPermission.CAMERA,
    "android.permission.CAMERA_OPEN_CLOSE_LISTENER": AndroidPermission.CAMERA,

    "android.permission.HIGH_SAMPLING_RATE_SENSORS": AndroidPermission.SENSORS,
    "android.permission.BODY_SENSORS": AndroidPermission.X_SENSORS_BODY,
    "android.permission.USE_FINGERPRINT": AndroidPermission.SENSORS,
    "android.permission.USE_BIOMETRIC": AndroidPermission.SENSORS,
  };
}