// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:meta/meta.dart';

class _IsolateMessage<E extends Enum> {
  final E flag;
  final bool value;
  _IsolateMessage(this.flag, this.value);
}

class _IsolateData<O, FLAGS extends Enum> {
  O? data;
  final Completer<SendPort> _uiToIsolatePortCompleter;
  SendPort? _uiToIsolatePort;
  final SendPort _isolateToUiPort;
  
  _IsolateData._withCompleter(this.data, final Completer<SendPort> portCompleter) : _uiToIsolatePortCompleter = portCompleter, _isolateToUiPort = (ReceivePort()..listen((message) {
    if (message is VoidCallback) {message();}
    else if (message is SendPort) {portCompleter.complete(message);}
  })).sendPort;

  _IsolateData(O data) : this._withCompleter(data, Completer());

  //Listener has to execute this in the main thread
  void _executeInUi(VoidCallback callback) {
    _isolateToUiPort.send(callback);
  }
  void _sendToIsolate(_IsolateMessage<FLAGS> a) async {
    (_uiToIsolatePort ?? (_uiToIsolatePort = await _uiToIsolatePortCompleter.future)).send(a);
  }
}

class IsolateRef<O, FLAGS extends Enum> {
  final _IsolateData<O, FLAGS> _data;
  IsolateRef._(this._data);

  void sendFlag(FLAGS flag, bool value) => _data._sendToIsolate(_IsolateMessage(flag, value));
}

/// Simplifies running an isolate
/// Allows running a callback in the UI thread
/// Allows waiting for a signal from the UI thread
/// Most fields are static not to be caught up in the executeInUi method
abstract class IsolateRunner<O, FLAGS extends Enum> {
  static late final _flags = <Enum, Completer<bool>>{};
  static late final _flagsLock = Lock();
  static late final dynamic _data;
  static late final _IsolateData _pData;

  /// Data passed to the start method
  @nonVirtual O get data => _data;
  /// Main runner, must be overridden
  @visibleForOverriding FutureOr<void> run();
  /// Executed in the UI thread after starting the isolate
  FutureOr<void> postStartCallback(IsolateRef<O, FLAGS> isolate) {}
  /// Waits for a flag from the UI thread, may stay locked indefinitely
  @nonVirtual Future<bool> waitFlag(FLAGS flag) async => await (await _flagsLock.synchronized(()=>_flags.putIfAbsent(flag, ()=>Completer()))).future;
  /// Executes a callback in the UI thread
  /// Will load all local variables in the current scope if one is referenced, therefore use carefully
  @nonVirtual void executeInUi(VoidCallback callback) => _pData._executeInUi(callback);

  void _runInitIsolate(_IsolateData<O, FLAGS> pData) async {
    (_pData = pData)._isolateToUiPort.send((ReceivePort()..listen((message) {
      if (message is _IsolateMessage<FLAGS>) _flagsLock.synchronized(() {
        _flags.putIfAbsent(message.flag, ()=>Completer()).complete(message.value);
      });
    })).sendPort);
    _data = pData.data;
    // Should prevent this data from beins sent when launching executeInUi
    pData.data = null;
    await run();
  }

  @nonVirtual
  IsolateRef<O, FLAGS> start(O data) => IsolateRunner._start(this, data);

  /// Starts a process to read apk data
  static IsolateRef<O, FLAGS> _start<O, FLAGS extends Enum>(IsolateRunner<O, FLAGS> runner, O data) {
    //APK_FILE = fileName;
    //Recheck installation type when connected
    final isolateRef = IsolateRef._(_IsolateData<O, FLAGS>(data));
    compute(runner._runInitIsolate, isolateRef._data);
    runner.postStartCallback(isolateRef);
    return isolateRef;
  }
}