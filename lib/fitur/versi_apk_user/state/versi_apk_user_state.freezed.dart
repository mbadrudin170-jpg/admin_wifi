// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'versi_apk_user_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VersiApkUserState {

 List<VersiApkUserModel> get listVersiApkUser; int get jumlahVersiApkUser;
/// Create a copy of VersiApkUserState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersiApkUserStateCopyWith<VersiApkUserState> get copyWith => _$VersiApkUserStateCopyWithImpl<VersiApkUserState>(this as VersiApkUserState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VersiApkUserState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VersiApkUserState&&const DeepCollectionEquality().equals(other.listVersiApkUser, _this.listVersiApkUser)&&(identical(other.jumlahVersiApkUser, _this.jumlahVersiApkUser) || other.jumlahVersiApkUser == _this.jumlahVersiApkUser));
}


@override
int get hashCode {
  final _this = this as VersiApkUserState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listVersiApkUser),_this.jumlahVersiApkUser);
}

@override
String toString() {
  final _this = this as VersiApkUserState;
  return 'VersiApkUserState(listVersiApkUser: ${_this.listVersiApkUser}, jumlahVersiApkUser: ${_this.jumlahVersiApkUser})';
}


}

/// @nodoc
abstract mixin class $VersiApkUserStateCopyWith<$Res>  {
  factory $VersiApkUserStateCopyWith(VersiApkUserState value, $Res Function(VersiApkUserState) _then) = _$VersiApkUserStateCopyWithImpl;
@useResult
$Res call({
 List<VersiApkUserModel> listVersiApkUser, int jumlahVersiApkUser
});




}
/// @nodoc
class _$VersiApkUserStateCopyWithImpl<$Res>
    implements $VersiApkUserStateCopyWith<$Res> {
  _$VersiApkUserStateCopyWithImpl(this._self, this._then);

  final VersiApkUserState _self;
  final $Res Function(VersiApkUserState) _then;

/// Create a copy of VersiApkUserState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listVersiApkUser = null,Object? jumlahVersiApkUser = null,}) {
  return _then(VersiApkUserState(
listVersiApkUser: null == listVersiApkUser ? _self.listVersiApkUser : listVersiApkUser // ignore: cast_nullable_to_non_nullable
as List<VersiApkUserModel>,jumlahVersiApkUser: null == jumlahVersiApkUser ? _self.jumlahVersiApkUser : jumlahVersiApkUser // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VersiApkUserState].
extension VersiApkUserStatePatterns on VersiApkUserState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VersiApkUserState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VersiApkUserState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VersiApkUserState value)  $default,){
final _that = this;
switch (_that) {
case _VersiApkUserState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VersiApkUserState value)?  $default,){
final _that = this;
switch (_that) {
case _VersiApkUserState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VersiApkUserModel> listVersiApkUser,  int jumlahVersiApkUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VersiApkUserState() when $default != null:
return $default(_that.listVersiApkUser,_that.jumlahVersiApkUser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VersiApkUserModel> listVersiApkUser,  int jumlahVersiApkUser)  $default,) {final _that = this;
switch (_that) {
case _VersiApkUserState():
return $default(_that.listVersiApkUser,_that.jumlahVersiApkUser);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VersiApkUserModel> listVersiApkUser,  int jumlahVersiApkUser)?  $default,) {final _that = this;
switch (_that) {
case _VersiApkUserState() when $default != null:
return $default(_that.listVersiApkUser,_that.jumlahVersiApkUser);case _:
  return null;

}
}

}

/// @nodoc


class _VersiApkUserState extends VersiApkUserState {
  const _VersiApkUserState({ List<VersiApkUserModel> listVersiApkUser = const [], this.jumlahVersiApkUser = 0}): _listVersiApkUser = listVersiApkUser,super._();
  

 final  List<VersiApkUserModel> _listVersiApkUser;
@override@JsonKey() List<VersiApkUserModel> get listVersiApkUser {
  if (_listVersiApkUser is EqualUnmodifiableListView) return _listVersiApkUser;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listVersiApkUser);
}

@override@JsonKey() final  int jumlahVersiApkUser;

/// Create a copy of VersiApkUserState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VersiApkUserStateCopyWith<_VersiApkUserState> get copyWith => __$VersiApkUserStateCopyWithImpl<_VersiApkUserState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VersiApkUserState&&const DeepCollectionEquality().equals(other.listVersiApkUser, _listVersiApkUser)&&(identical(other.jumlahVersiApkUser, jumlahVersiApkUser) || other.jumlahVersiApkUser == jumlahVersiApkUser));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listVersiApkUser),jumlahVersiApkUser);
}

@override
String toString() {
    return 'VersiApkUserState(listVersiApkUser: $listVersiApkUser, jumlahVersiApkUser: $jumlahVersiApkUser)';
}


}

/// @nodoc
abstract mixin class _$VersiApkUserStateCopyWith<$Res> implements $VersiApkUserStateCopyWith<$Res> {
  factory _$VersiApkUserStateCopyWith(_VersiApkUserState value, $Res Function(_VersiApkUserState) _then) = __$VersiApkUserStateCopyWithImpl;
@override @useResult
$Res call({
 List<VersiApkUserModel> listVersiApkUser, int jumlahVersiApkUser
});




}
/// @nodoc
class __$VersiApkUserStateCopyWithImpl<$Res>
    implements _$VersiApkUserStateCopyWith<$Res> {
  __$VersiApkUserStateCopyWithImpl(this._self, this._then);

  final _VersiApkUserState _self;
  final $Res Function(_VersiApkUserState) _then;

/// Create a copy of VersiApkUserState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listVersiApkUser = null,Object? jumlahVersiApkUser = null,}) {
  return _then(_VersiApkUserState(
listVersiApkUser: null == listVersiApkUser ? _self._listVersiApkUser : listVersiApkUser // ignore: cast_nullable_to_non_nullable
as List<VersiApkUserModel>,jumlahVersiApkUser: null == jumlahVersiApkUser ? _self.jumlahVersiApkUser : jumlahVersiApkUser // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
