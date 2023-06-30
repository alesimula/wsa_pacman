import 'dart:async';

extension FutureOrUtils<T> on FutureOr<T> {
  Future<R> thenOr<R>(FutureOr<R> Function(T value) onValue) {
    if (this is Future<T>) {
      return (this as Future<T>).then(onValue);
    } else {
      return Future<R>.value(onValue(this as T));
    }
  }
}

extension FutureIterableUtils<T> on Iterable<FutureOr<T?>> {
  FutureOr<T?> foldFuturesSkipNulls(T Function(T previousValue, T element) combine) {
    return fold(Future.value(null), (f1, f2) => f1.thenOr((e1)=>f2.thenOr((e2) => Future.value(e1 == null ? e2 : e2 == null ? e1 : combine(e1, e2)))));
  }
}