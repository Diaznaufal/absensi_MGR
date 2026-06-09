// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_qrcode_checkin_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GetQrcodeCheckinEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is GetQrcodeCheckinEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'GetQrcodeCheckinEvent()';
  }
}

/// @nodoc
class $GetQrcodeCheckinEventCopyWith<$Res> {
  $GetQrcodeCheckinEventCopyWith(
      GetQrcodeCheckinEvent _, $Res Function(GetQrcodeCheckinEvent) __);
}

/// Adds pattern-matching-related methods to [GetQrcodeCheckinEvent].
extension GetQrcodeCheckinEventPatterns on GetQrcodeCheckinEvent {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_GetQrcodeCheckin value)? getQrcodeCheckin,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _GetQrcodeCheckin() when getQrcodeCheckin != null:
        return getQrcodeCheckin(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_GetQrcodeCheckin value) getQrcodeCheckin,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started(_that);
      case _GetQrcodeCheckin():
        return getQrcodeCheckin(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_GetQrcodeCheckin value)? getQrcodeCheckin,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _GetQrcodeCheckin() when getQrcodeCheckin != null:
        return getQrcodeCheckin(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String barcode, bool isCheckedIn)? getQrcodeCheckin,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _GetQrcodeCheckin() when getQrcodeCheckin != null:
        return getQrcodeCheckin(_that.barcode, _that.isCheckedIn);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String barcode, bool isCheckedIn)
        getQrcodeCheckin,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started();
      case _GetQrcodeCheckin():
        return getQrcodeCheckin(_that.barcode, _that.isCheckedIn);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String barcode, bool isCheckedIn)? getQrcodeCheckin,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _GetQrcodeCheckin() when getQrcodeCheckin != null:
        return getQrcodeCheckin(_that.barcode, _that.isCheckedIn);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Started implements GetQrcodeCheckinEvent {
  const _Started();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Started);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'GetQrcodeCheckinEvent.started()';
  }
}

/// @nodoc

class _GetQrcodeCheckin implements GetQrcodeCheckinEvent {
  const _GetQrcodeCheckin(this.barcode, this.isCheckedIn);

  final String barcode;
  final bool isCheckedIn;

  /// Create a copy of GetQrcodeCheckinEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GetQrcodeCheckinCopyWith<_GetQrcodeCheckin> get copyWith =>
      __$GetQrcodeCheckinCopyWithImpl<_GetQrcodeCheckin>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GetQrcodeCheckin &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.isCheckedIn, isCheckedIn) ||
                other.isCheckedIn == isCheckedIn));
  }

  @override
  int get hashCode => Object.hash(runtimeType, barcode, isCheckedIn);

  @override
  String toString() {
    return 'GetQrcodeCheckinEvent.getQrcodeCheckin(barcode: $barcode, isCheckedIn: $isCheckedIn)';
  }
}

/// @nodoc
abstract mixin class _$GetQrcodeCheckinCopyWith<$Res>
    implements $GetQrcodeCheckinEventCopyWith<$Res> {
  factory _$GetQrcodeCheckinCopyWith(
          _GetQrcodeCheckin value, $Res Function(_GetQrcodeCheckin) _then) =
      __$GetQrcodeCheckinCopyWithImpl;
  @useResult
  $Res call({String barcode, bool isCheckedIn});
}

/// @nodoc
class __$GetQrcodeCheckinCopyWithImpl<$Res>
    implements _$GetQrcodeCheckinCopyWith<$Res> {
  __$GetQrcodeCheckinCopyWithImpl(this._self, this._then);

  final _GetQrcodeCheckin _self;
  final $Res Function(_GetQrcodeCheckin) _then;

  /// Create a copy of GetQrcodeCheckinEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? barcode = null,
    Object? isCheckedIn = null,
  }) {
    return _then(_GetQrcodeCheckin(
      null == barcode
          ? _self.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String,
      null == isCheckedIn
          ? _self.isCheckedIn
          : isCheckedIn // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$GetQrcodeCheckinState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is GetQrcodeCheckinState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'GetQrcodeCheckinState()';
  }
}

/// @nodoc
class $GetQrcodeCheckinStateCopyWith<$Res> {
  $GetQrcodeCheckinStateCopyWith(
      GetQrcodeCheckinState _, $Res Function(GetQrcodeCheckinState) __);
}

/// Adds pattern-matching-related methods to [GetQrcodeCheckinState].
extension GetQrcodeCheckinStatePatterns on GetQrcodeCheckinState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Loading() when loading != null:
        return loading(_that);
      case _Success() when success != null:
        return success(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case _Loading():
        return loading(_that);
      case _Success():
        return success(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Loading() when loading != null:
        return loading(_that);
      case _Success() when success != null:
        return success(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String barcode, bool isCheckedIn)? success,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _Success() when success != null:
        return success(_that.barcode, _that.isCheckedIn);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String barcode, bool isCheckedIn) success,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Loading():
        return loading();
      case _Success():
        return success(_that.barcode, _that.isCheckedIn);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String barcode, bool isCheckedIn)? success,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _Success() when success != null:
        return success(_that.barcode, _that.isCheckedIn);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements GetQrcodeCheckinState {
  const _Initial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'GetQrcodeCheckinState.initial()';
  }
}

/// @nodoc

class _Loading implements GetQrcodeCheckinState {
  const _Loading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Loading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'GetQrcodeCheckinState.loading()';
  }
}

/// @nodoc

class _Success implements GetQrcodeCheckinState {
  const _Success(this.barcode, this.isCheckedIn);

  final String barcode;
  final bool isCheckedIn;

  /// Create a copy of GetQrcodeCheckinState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SuccessCopyWith<_Success> get copyWith =>
      __$SuccessCopyWithImpl<_Success>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Success &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.isCheckedIn, isCheckedIn) ||
                other.isCheckedIn == isCheckedIn));
  }

  @override
  int get hashCode => Object.hash(runtimeType, barcode, isCheckedIn);

  @override
  String toString() {
    return 'GetQrcodeCheckinState.success(barcode: $barcode, isCheckedIn: $isCheckedIn)';
  }
}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res>
    implements $GetQrcodeCheckinStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) =
      __$SuccessCopyWithImpl;
  @useResult
  $Res call({String barcode, bool isCheckedIn});
}

/// @nodoc
class __$SuccessCopyWithImpl<$Res> implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

  /// Create a copy of GetQrcodeCheckinState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? barcode = null,
    Object? isCheckedIn = null,
  }) {
    return _then(_Success(
      null == barcode
          ? _self.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String,
      null == isCheckedIn
          ? _self.isCheckedIn
          : isCheckedIn // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
