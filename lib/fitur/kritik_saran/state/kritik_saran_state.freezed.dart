// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kritik_saran_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KritikSaranState {

 List<KritikSaranModel> get listKritikSaran; int get jumlahKritikSaran;
/// Create a copy of KritikSaranState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KritikSaranStateCopyWith<KritikSaranState> get copyWith => _$KritikSaranStateCopyWithImpl<KritikSaranState>(this as KritikSaranState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as KritikSaranState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KritikSaranState&&const DeepCollectionEquality().equals(other.listKritikSaran, _this.listKritikSaran)&&(identical(other.jumlahKritikSaran, _this.jumlahKritikSaran) || other.jumlahKritikSaran == _this.jumlahKritikSaran));
}


@override
int get hashCode {
  final _this = this as KritikSaranState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listKritikSaran),_this.jumlahKritikSaran);
}

@override
String toString() {
  final _this = this as KritikSaranState;
  return 'KritikSaranState(listKritikSaran: ${_this.listKritikSaran}, jumlahKritikSaran: ${_this.jumlahKritikSaran})';
}


}

/// @nodoc
abstract mixin class $KritikSaranStateCopyWith<$Res>  {
  factory $KritikSaranStateCopyWith(KritikSaranState value, $Res Function(KritikSaranState) _then) = _$KritikSaranStateCopyWithImpl;
@useResult
$Res call({
 List<KritikSaranModel> listKritikSaran, int jumlahKritikSaran
});




}
/// @nodoc
class _$KritikSaranStateCopyWithImpl<$Res>
    implements $KritikSaranStateCopyWith<$Res> {
  _$KritikSaranStateCopyWithImpl(this._self, this._then);

  final KritikSaranState _self;
  final $Res Function(KritikSaranState) _then;

/// Create a copy of KritikSaranState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listKritikSaran = null,Object? jumlahKritikSaran = null,}) {
  return _then(KritikSaranState(
listKritikSaran: null == listKritikSaran ? _self.listKritikSaran : listKritikSaran // ignore: cast_nullable_to_non_nullable
as List<KritikSaranModel>,jumlahKritikSaran: null == jumlahKritikSaran ? _self.jumlahKritikSaran : jumlahKritikSaran // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [KritikSaranState].
extension KritikSaranStatePatterns on KritikSaranState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KritikSaranState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KritikSaranState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KritikSaranState value)  $default,){
final _that = this;
switch (_that) {
case _KritikSaranState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KritikSaranState value)?  $default,){
final _that = this;
switch (_that) {
case _KritikSaranState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<KritikSaranModel> listKritikSaran,  int jumlahKritikSaran)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KritikSaranState() when $default != null:
return $default(_that.listKritikSaran,_that.jumlahKritikSaran);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<KritikSaranModel> listKritikSaran,  int jumlahKritikSaran)  $default,) {final _that = this;
switch (_that) {
case _KritikSaranState():
return $default(_that.listKritikSaran,_that.jumlahKritikSaran);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<KritikSaranModel> listKritikSaran,  int jumlahKritikSaran)?  $default,) {final _that = this;
switch (_that) {
case _KritikSaranState() when $default != null:
return $default(_that.listKritikSaran,_that.jumlahKritikSaran);case _:
  return null;

}
}

}

/// @nodoc


class _KritikSaranState extends KritikSaranState {
  const _KritikSaranState({ List<KritikSaranModel> listKritikSaran = const [], this.jumlahKritikSaran = 0}): _listKritikSaran = listKritikSaran,super._();
  

 final  List<KritikSaranModel> _listKritikSaran;
@override@JsonKey() List<KritikSaranModel> get listKritikSaran {
  if (_listKritikSaran is EqualUnmodifiableListView) return _listKritikSaran;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listKritikSaran);
}

@override@JsonKey() final  int jumlahKritikSaran;

/// Create a copy of KritikSaranState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KritikSaranStateCopyWith<_KritikSaranState> get copyWith => __$KritikSaranStateCopyWithImpl<_KritikSaranState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KritikSaranState&&const DeepCollectionEquality().equals(other.listKritikSaran, _listKritikSaran)&&(identical(other.jumlahKritikSaran, jumlahKritikSaran) || other.jumlahKritikSaran == jumlahKritikSaran));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listKritikSaran),jumlahKritikSaran);
}

@override
String toString() {
    return 'KritikSaranState(listKritikSaran: $listKritikSaran, jumlahKritikSaran: $jumlahKritikSaran)';
}


}

/// @nodoc
abstract mixin class _$KritikSaranStateCopyWith<$Res> implements $KritikSaranStateCopyWith<$Res> {
  factory _$KritikSaranStateCopyWith(_KritikSaranState value, $Res Function(_KritikSaranState) _then) = __$KritikSaranStateCopyWithImpl;
@override @useResult
$Res call({
 List<KritikSaranModel> listKritikSaran, int jumlahKritikSaran
});




}
/// @nodoc
class __$KritikSaranStateCopyWithImpl<$Res>
    implements _$KritikSaranStateCopyWith<$Res> {
  __$KritikSaranStateCopyWithImpl(this._self, this._then);

  final _KritikSaranState _self;
  final $Res Function(_KritikSaranState) _then;

/// Create a copy of KritikSaranState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listKritikSaran = null,Object? jumlahKritikSaran = null,}) {
  return _then(_KritikSaranState(
listKritikSaran: null == listKritikSaran ? _self._listKritikSaran : listKritikSaran // ignore: cast_nullable_to_non_nullable
as List<KritikSaranModel>,jumlahKritikSaran: null == jumlahKritikSaran ? _self.jumlahKritikSaran : jumlahKritikSaran // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
