// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pesanan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PesananState {

 List<PesananModel> get listPesanan; int get jumlahPesanan;
/// Create a copy of PesananState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PesananStateCopyWith<PesananState> get copyWith => _$PesananStateCopyWithImpl<PesananState>(this as PesananState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PesananState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PesananState&&const DeepCollectionEquality().equals(other.listPesanan, _this.listPesanan)&&(identical(other.jumlahPesanan, _this.jumlahPesanan) || other.jumlahPesanan == _this.jumlahPesanan));
}


@override
int get hashCode {
  final _this = this as PesananState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listPesanan),_this.jumlahPesanan);
}

@override
String toString() {
  final _this = this as PesananState;
  return 'PesananState(listPesanan: ${_this.listPesanan}, jumlahPesanan: ${_this.jumlahPesanan})';
}


}

/// @nodoc
abstract mixin class $PesananStateCopyWith<$Res>  {
  factory $PesananStateCopyWith(PesananState value, $Res Function(PesananState) _then) = _$PesananStateCopyWithImpl;
@useResult
$Res call({
 List<PesananModel> listPesanan, int jumlahPesanan
});




}
/// @nodoc
class _$PesananStateCopyWithImpl<$Res>
    implements $PesananStateCopyWith<$Res> {
  _$PesananStateCopyWithImpl(this._self, this._then);

  final PesananState _self;
  final $Res Function(PesananState) _then;

/// Create a copy of PesananState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listPesanan = null,Object? jumlahPesanan = null,}) {
  return _then(PesananState(
listPesanan: null == listPesanan ? _self.listPesanan : listPesanan // ignore: cast_nullable_to_non_nullable
as List<PesananModel>,jumlahPesanan: null == jumlahPesanan ? _self.jumlahPesanan : jumlahPesanan // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PesananState].
extension PesananStatePatterns on PesananState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PesananState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PesananState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PesananState value)  $default,){
final _that = this;
switch (_that) {
case _PesananState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PesananState value)?  $default,){
final _that = this;
switch (_that) {
case _PesananState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PesananModel> listPesanan,  int jumlahPesanan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PesananState() when $default != null:
return $default(_that.listPesanan,_that.jumlahPesanan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PesananModel> listPesanan,  int jumlahPesanan)  $default,) {final _that = this;
switch (_that) {
case _PesananState():
return $default(_that.listPesanan,_that.jumlahPesanan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PesananModel> listPesanan,  int jumlahPesanan)?  $default,) {final _that = this;
switch (_that) {
case _PesananState() when $default != null:
return $default(_that.listPesanan,_that.jumlahPesanan);case _:
  return null;

}
}

}

/// @nodoc


class _PesananState extends PesananState {
  const _PesananState({ List<PesananModel> listPesanan = const [], this.jumlahPesanan = 0}): _listPesanan = listPesanan,super._();
  

 final  List<PesananModel> _listPesanan;
@override@JsonKey() List<PesananModel> get listPesanan {
  if (_listPesanan is EqualUnmodifiableListView) return _listPesanan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listPesanan);
}

@override@JsonKey() final  int jumlahPesanan;

/// Create a copy of PesananState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PesananStateCopyWith<_PesananState> get copyWith => __$PesananStateCopyWithImpl<_PesananState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PesananState&&const DeepCollectionEquality().equals(other.listPesanan, _listPesanan)&&(identical(other.jumlahPesanan, jumlahPesanan) || other.jumlahPesanan == jumlahPesanan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listPesanan),jumlahPesanan);
}

@override
String toString() {
    return 'PesananState(listPesanan: $listPesanan, jumlahPesanan: $jumlahPesanan)';
}


}

/// @nodoc
abstract mixin class _$PesananStateCopyWith<$Res> implements $PesananStateCopyWith<$Res> {
  factory _$PesananStateCopyWith(_PesananState value, $Res Function(_PesananState) _then) = __$PesananStateCopyWithImpl;
@override @useResult
$Res call({
 List<PesananModel> listPesanan, int jumlahPesanan
});




}
/// @nodoc
class __$PesananStateCopyWithImpl<$Res>
    implements _$PesananStateCopyWith<$Res> {
  __$PesananStateCopyWithImpl(this._self, this._then);

  final _PesananState _self;
  final $Res Function(_PesananState) _then;

/// Create a copy of PesananState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listPesanan = null,Object? jumlahPesanan = null,}) {
  return _then(_PesananState(
listPesanan: null == listPesanan ? _self._listPesanan : listPesanan // ignore: cast_nullable_to_non_nullable
as List<PesananModel>,jumlahPesanan: null == jumlahPesanan ? _self.jumlahPesanan : jumlahPesanan // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
