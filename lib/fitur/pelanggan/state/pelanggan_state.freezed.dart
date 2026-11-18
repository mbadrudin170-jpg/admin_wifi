// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pelanggan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PelangganState {

 List<PelangganModel> get listPelanggan; int get jumlahPelanggan;
/// Create a copy of PelangganState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PelangganStateCopyWith<PelangganState> get copyWith => _$PelangganStateCopyWithImpl<PelangganState>(this as PelangganState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PelangganState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PelangganState&&const DeepCollectionEquality().equals(other.listPelanggan, _this.listPelanggan)&&(identical(other.jumlahPelanggan, _this.jumlahPelanggan) || other.jumlahPelanggan == _this.jumlahPelanggan));
}


@override
int get hashCode {
  final _this = this as PelangganState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listPelanggan),_this.jumlahPelanggan);
}

@override
String toString() {
  final _this = this as PelangganState;
  return 'PelangganState(listPelanggan: ${_this.listPelanggan}, jumlahPelanggan: ${_this.jumlahPelanggan})';
}


}

/// @nodoc
abstract mixin class $PelangganStateCopyWith<$Res>  {
  factory $PelangganStateCopyWith(PelangganState value, $Res Function(PelangganState) _then) = _$PelangganStateCopyWithImpl;
@useResult
$Res call({
 List<PelangganModel> listPelanggan, int jumlahPelanggan
});




}
/// @nodoc
class _$PelangganStateCopyWithImpl<$Res>
    implements $PelangganStateCopyWith<$Res> {
  _$PelangganStateCopyWithImpl(this._self, this._then);

  final PelangganState _self;
  final $Res Function(PelangganState) _then;

/// Create a copy of PelangganState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listPelanggan = null,Object? jumlahPelanggan = null,}) {
  return _then(PelangganState(
listPelanggan: null == listPelanggan ? _self.listPelanggan : listPelanggan // ignore: cast_nullable_to_non_nullable
as List<PelangganModel>,jumlahPelanggan: null == jumlahPelanggan ? _self.jumlahPelanggan : jumlahPelanggan // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PelangganState].
extension PelangganStatePatterns on PelangganState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PelangganState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PelangganState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PelangganState value)  $default,){
final _that = this;
switch (_that) {
case _PelangganState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PelangganState value)?  $default,){
final _that = this;
switch (_that) {
case _PelangganState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PelangganModel> listPelanggan,  int jumlahPelanggan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PelangganState() when $default != null:
return $default(_that.listPelanggan,_that.jumlahPelanggan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PelangganModel> listPelanggan,  int jumlahPelanggan)  $default,) {final _that = this;
switch (_that) {
case _PelangganState():
return $default(_that.listPelanggan,_that.jumlahPelanggan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PelangganModel> listPelanggan,  int jumlahPelanggan)?  $default,) {final _that = this;
switch (_that) {
case _PelangganState() when $default != null:
return $default(_that.listPelanggan,_that.jumlahPelanggan);case _:
  return null;

}
}

}

/// @nodoc


class _PelangganState extends PelangganState {
  const _PelangganState({ List<PelangganModel> listPelanggan = const <PelangganModel>[], this.jumlahPelanggan = 0}): _listPelanggan = listPelanggan,super._();
  

 final  List<PelangganModel> _listPelanggan;
@override@JsonKey() List<PelangganModel> get listPelanggan {
  if (_listPelanggan is EqualUnmodifiableListView) return _listPelanggan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listPelanggan);
}

@override@JsonKey() final  int jumlahPelanggan;

/// Create a copy of PelangganState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PelangganStateCopyWith<_PelangganState> get copyWith => __$PelangganStateCopyWithImpl<_PelangganState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PelangganState&&const DeepCollectionEquality().equals(other.listPelanggan, _listPelanggan)&&(identical(other.jumlahPelanggan, jumlahPelanggan) || other.jumlahPelanggan == jumlahPelanggan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listPelanggan),jumlahPelanggan);
}

@override
String toString() {
    return 'PelangganState(listPelanggan: $listPelanggan, jumlahPelanggan: $jumlahPelanggan)';
}


}

/// @nodoc
abstract mixin class _$PelangganStateCopyWith<$Res> implements $PelangganStateCopyWith<$Res> {
  factory _$PelangganStateCopyWith(_PelangganState value, $Res Function(_PelangganState) _then) = __$PelangganStateCopyWithImpl;
@override @useResult
$Res call({
 List<PelangganModel> listPelanggan, int jumlahPelanggan
});




}
/// @nodoc
class __$PelangganStateCopyWithImpl<$Res>
    implements _$PelangganStateCopyWith<$Res> {
  __$PelangganStateCopyWithImpl(this._self, this._then);

  final _PelangganState _self;
  final $Res Function(_PelangganState) _then;

/// Create a copy of PelangganState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listPelanggan = null,Object? jumlahPelanggan = null,}) {
  return _then(_PelangganState(
listPelanggan: null == listPelanggan ? _self._listPelanggan : listPelanggan // ignore: cast_nullable_to_non_nullable
as List<PelangganModel>,jumlahPelanggan: null == jumlahPelanggan ? _self.jumlahPelanggan : jumlahPelanggan // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
