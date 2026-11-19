// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_unggah_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StatusUnggahState {

 List<StatusUnggahModel> get listStatusUnggah; int get jumlahStatusUnggah;
/// Create a copy of StatusUnggahState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusUnggahStateCopyWith<StatusUnggahState> get copyWith => _$StatusUnggahStateCopyWithImpl<StatusUnggahState>(this as StatusUnggahState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StatusUnggahState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusUnggahState&&const DeepCollectionEquality().equals(other.listStatusUnggah, _this.listStatusUnggah)&&(identical(other.jumlahStatusUnggah, _this.jumlahStatusUnggah) || other.jumlahStatusUnggah == _this.jumlahStatusUnggah));
}


@override
int get hashCode {
  final _this = this as StatusUnggahState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listStatusUnggah),_this.jumlahStatusUnggah);
}

@override
String toString() {
  final _this = this as StatusUnggahState;
  return 'StatusUnggahState(listStatusUnggah: ${_this.listStatusUnggah}, jumlahStatusUnggah: ${_this.jumlahStatusUnggah})';
}


}

/// @nodoc
abstract mixin class $StatusUnggahStateCopyWith<$Res>  {
  factory $StatusUnggahStateCopyWith(StatusUnggahState value, $Res Function(StatusUnggahState) _then) = _$StatusUnggahStateCopyWithImpl;
@useResult
$Res call({
 List<StatusUnggahModel> listStatusUnggah, int jumlahStatusUnggah
});




}
/// @nodoc
class _$StatusUnggahStateCopyWithImpl<$Res>
    implements $StatusUnggahStateCopyWith<$Res> {
  _$StatusUnggahStateCopyWithImpl(this._self, this._then);

  final StatusUnggahState _self;
  final $Res Function(StatusUnggahState) _then;

/// Create a copy of StatusUnggahState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listStatusUnggah = null,Object? jumlahStatusUnggah = null,}) {
  return _then(StatusUnggahState(
listStatusUnggah: null == listStatusUnggah ? _self.listStatusUnggah : listStatusUnggah // ignore: cast_nullable_to_non_nullable
as List<StatusUnggahModel>,jumlahStatusUnggah: null == jumlahStatusUnggah ? _self.jumlahStatusUnggah : jumlahStatusUnggah // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusUnggahState].
extension StatusUnggahStatePatterns on StatusUnggahState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusUnggahState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusUnggahState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusUnggahState value)  $default,){
final _that = this;
switch (_that) {
case _StatusUnggahState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusUnggahState value)?  $default,){
final _that = this;
switch (_that) {
case _StatusUnggahState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<StatusUnggahModel> listStatusUnggah,  int jumlahStatusUnggah)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusUnggahState() when $default != null:
return $default(_that.listStatusUnggah,_that.jumlahStatusUnggah);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<StatusUnggahModel> listStatusUnggah,  int jumlahStatusUnggah)  $default,) {final _that = this;
switch (_that) {
case _StatusUnggahState():
return $default(_that.listStatusUnggah,_that.jumlahStatusUnggah);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<StatusUnggahModel> listStatusUnggah,  int jumlahStatusUnggah)?  $default,) {final _that = this;
switch (_that) {
case _StatusUnggahState() when $default != null:
return $default(_that.listStatusUnggah,_that.jumlahStatusUnggah);case _:
  return null;

}
}

}

/// @nodoc


class _StatusUnggahState extends StatusUnggahState {
  const _StatusUnggahState({ List<StatusUnggahModel> listStatusUnggah = const [], this.jumlahStatusUnggah = 0}): _listStatusUnggah = listStatusUnggah,super._();
  

 final  List<StatusUnggahModel> _listStatusUnggah;
@override@JsonKey() List<StatusUnggahModel> get listStatusUnggah {
  if (_listStatusUnggah is EqualUnmodifiableListView) return _listStatusUnggah;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listStatusUnggah);
}

@override@JsonKey() final  int jumlahStatusUnggah;

/// Create a copy of StatusUnggahState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusUnggahStateCopyWith<_StatusUnggahState> get copyWith => __$StatusUnggahStateCopyWithImpl<_StatusUnggahState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusUnggahState&&const DeepCollectionEquality().equals(other.listStatusUnggah, _listStatusUnggah)&&(identical(other.jumlahStatusUnggah, jumlahStatusUnggah) || other.jumlahStatusUnggah == jumlahStatusUnggah));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listStatusUnggah),jumlahStatusUnggah);
}

@override
String toString() {
    return 'StatusUnggahState(listStatusUnggah: $listStatusUnggah, jumlahStatusUnggah: $jumlahStatusUnggah)';
}


}

/// @nodoc
abstract mixin class _$StatusUnggahStateCopyWith<$Res> implements $StatusUnggahStateCopyWith<$Res> {
  factory _$StatusUnggahStateCopyWith(_StatusUnggahState value, $Res Function(_StatusUnggahState) _then) = __$StatusUnggahStateCopyWithImpl;
@override @useResult
$Res call({
 List<StatusUnggahModel> listStatusUnggah, int jumlahStatusUnggah
});




}
/// @nodoc
class __$StatusUnggahStateCopyWithImpl<$Res>
    implements _$StatusUnggahStateCopyWith<$Res> {
  __$StatusUnggahStateCopyWithImpl(this._self, this._then);

  final _StatusUnggahState _self;
  final $Res Function(_StatusUnggahState) _then;

/// Create a copy of StatusUnggahState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listStatusUnggah = null,Object? jumlahStatusUnggah = null,}) {
  return _then(_StatusUnggahState(
listStatusUnggah: null == listStatusUnggah ? _self._listStatusUnggah : listStatusUnggah // ignore: cast_nullable_to_non_nullable
as List<StatusUnggahModel>,jumlahStatusUnggah: null == jumlahStatusUnggah ? _self.jumlahStatusUnggah : jumlahStatusUnggah // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
