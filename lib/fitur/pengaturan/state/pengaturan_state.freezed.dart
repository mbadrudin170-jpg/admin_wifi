// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pengaturan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PengaturanState {

 PengaturanModel? get pengaturan;
/// Create a copy of PengaturanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PengaturanStateCopyWith<PengaturanState> get copyWith => _$PengaturanStateCopyWithImpl<PengaturanState>(this as PengaturanState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PengaturanState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PengaturanState&&(identical(other.pengaturan, _this.pengaturan) || other.pengaturan == _this.pengaturan));
}


@override
int get hashCode {
  final _this = this as PengaturanState;
  return Object.hash(runtimeType,_this.pengaturan);
}

@override
String toString() {
  final _this = this as PengaturanState;
  return 'PengaturanState(pengaturan: ${_this.pengaturan})';
}


}

/// @nodoc
abstract mixin class $PengaturanStateCopyWith<$Res>  {
  factory $PengaturanStateCopyWith(PengaturanState value, $Res Function(PengaturanState) _then) = _$PengaturanStateCopyWithImpl;
@useResult
$Res call({
 PengaturanModel? pengaturan
});


$PengaturanModelCopyWith<$Res>? get pengaturan;

}
/// @nodoc
class _$PengaturanStateCopyWithImpl<$Res>
    implements $PengaturanStateCopyWith<$Res> {
  _$PengaturanStateCopyWithImpl(this._self, this._then);

  final PengaturanState _self;
  final $Res Function(PengaturanState) _then;

/// Create a copy of PengaturanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pengaturan = freezed,}) {
  return _then(PengaturanState(
pengaturan: freezed == pengaturan ? _self.pengaturan : pengaturan // ignore: cast_nullable_to_non_nullable
as PengaturanModel?,
  ));
}
/// Create a copy of PengaturanState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PengaturanModelCopyWith<$Res>? get pengaturan {
    if (_self.pengaturan == null) {
    return null;
  }

  return $PengaturanModelCopyWith<$Res>(_self.pengaturan!, (value) {
    return _then(_self.copyWith(pengaturan: value));
  });
}
}


/// Adds pattern-matching-related methods to [PengaturanState].
extension PengaturanStatePatterns on PengaturanState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PengaturanState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PengaturanState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PengaturanState value)  $default,){
final _that = this;
switch (_that) {
case _PengaturanState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PengaturanState value)?  $default,){
final _that = this;
switch (_that) {
case _PengaturanState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PengaturanModel? pengaturan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PengaturanState() when $default != null:
return $default(_that.pengaturan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PengaturanModel? pengaturan)  $default,) {final _that = this;
switch (_that) {
case _PengaturanState():
return $default(_that.pengaturan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PengaturanModel? pengaturan)?  $default,) {final _that = this;
switch (_that) {
case _PengaturanState() when $default != null:
return $default(_that.pengaturan);case _:
  return null;

}
}

}

/// @nodoc


class _PengaturanState extends PengaturanState {
  const _PengaturanState({this.pengaturan}): super._();
  

@override final  PengaturanModel? pengaturan;

/// Create a copy of PengaturanState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PengaturanStateCopyWith<_PengaturanState> get copyWith => __$PengaturanStateCopyWithImpl<_PengaturanState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PengaturanState&&(identical(other.pengaturan, pengaturan) || other.pengaturan == pengaturan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pengaturan);
}

@override
String toString() {
    return 'PengaturanState(pengaturan: $pengaturan)';
}


}

/// @nodoc
abstract mixin class _$PengaturanStateCopyWith<$Res> implements $PengaturanStateCopyWith<$Res> {
  factory _$PengaturanStateCopyWith(_PengaturanState value, $Res Function(_PengaturanState) _then) = __$PengaturanStateCopyWithImpl;
@override @useResult
$Res call({
 PengaturanModel? pengaturan
});


@override $PengaturanModelCopyWith<$Res>? get pengaturan;

}
/// @nodoc
class __$PengaturanStateCopyWithImpl<$Res>
    implements _$PengaturanStateCopyWith<$Res> {
  __$PengaturanStateCopyWithImpl(this._self, this._then);

  final _PengaturanState _self;
  final $Res Function(_PengaturanState) _then;

/// Create a copy of PengaturanState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pengaturan = freezed,}) {
  return _then(_PengaturanState(
pengaturan: freezed == pengaturan ? _self.pengaturan : pengaturan // ignore: cast_nullable_to_non_nullable
as PengaturanModel?,
  ));
}

/// Create a copy of PengaturanState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PengaturanModelCopyWith<$Res>? get pengaturan {
    if (_self.pengaturan == null) {
    return null;
  }

  return $PengaturanModelCopyWith<$Res>(_self.pengaturan!, (value) {
    return _then(_self.copyWith(pengaturan: value));
  });
}
}

// dart format on
