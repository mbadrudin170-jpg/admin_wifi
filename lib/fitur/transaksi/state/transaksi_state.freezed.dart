// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaksi_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransaksiState {

 List<TransaksiModel> get listTransaksi; int get jumlahTransaksi;
/// Create a copy of TransaksiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransaksiStateCopyWith<TransaksiState> get copyWith => _$TransaksiStateCopyWithImpl<TransaksiState>(this as TransaksiState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransaksiState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransaksiState&&const DeepCollectionEquality().equals(other.listTransaksi, _this.listTransaksi)&&(identical(other.jumlahTransaksi, _this.jumlahTransaksi) || other.jumlahTransaksi == _this.jumlahTransaksi));
}


@override
int get hashCode {
  final _this = this as TransaksiState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listTransaksi),_this.jumlahTransaksi);
}

@override
String toString() {
  final _this = this as TransaksiState;
  return 'TransaksiState(listTransaksi: ${_this.listTransaksi}, jumlahTransaksi: ${_this.jumlahTransaksi})';
}


}

/// @nodoc
abstract mixin class $TransaksiStateCopyWith<$Res>  {
  factory $TransaksiStateCopyWith(TransaksiState value, $Res Function(TransaksiState) _then) = _$TransaksiStateCopyWithImpl;
@useResult
$Res call({
 List<TransaksiModel> listTransaksi, int jumlahTransaksi
});




}
/// @nodoc
class _$TransaksiStateCopyWithImpl<$Res>
    implements $TransaksiStateCopyWith<$Res> {
  _$TransaksiStateCopyWithImpl(this._self, this._then);

  final TransaksiState _self;
  final $Res Function(TransaksiState) _then;

/// Create a copy of TransaksiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listTransaksi = null,Object? jumlahTransaksi = null,}) {
  return _then(TransaksiState(
listTransaksi: null == listTransaksi ? _self.listTransaksi : listTransaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,jumlahTransaksi: null == jumlahTransaksi ? _self.jumlahTransaksi : jumlahTransaksi // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TransaksiState].
extension TransaksiStatePatterns on TransaksiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransaksiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransaksiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransaksiState value)  $default,){
final _that = this;
switch (_that) {
case _TransaksiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransaksiState value)?  $default,){
final _that = this;
switch (_that) {
case _TransaksiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TransaksiModel> listTransaksi,  int jumlahTransaksi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransaksiState() when $default != null:
return $default(_that.listTransaksi,_that.jumlahTransaksi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TransaksiModel> listTransaksi,  int jumlahTransaksi)  $default,) {final _that = this;
switch (_that) {
case _TransaksiState():
return $default(_that.listTransaksi,_that.jumlahTransaksi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TransaksiModel> listTransaksi,  int jumlahTransaksi)?  $default,) {final _that = this;
switch (_that) {
case _TransaksiState() when $default != null:
return $default(_that.listTransaksi,_that.jumlahTransaksi);case _:
  return null;

}
}

}

/// @nodoc


class _TransaksiState extends TransaksiState {
  const _TransaksiState({ List<TransaksiModel> listTransaksi = const <TransaksiModel>[], this.jumlahTransaksi = 0}): _listTransaksi = listTransaksi,super._();
  

 final  List<TransaksiModel> _listTransaksi;
@override@JsonKey() List<TransaksiModel> get listTransaksi {
  if (_listTransaksi is EqualUnmodifiableListView) return _listTransaksi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listTransaksi);
}

@override@JsonKey() final  int jumlahTransaksi;

/// Create a copy of TransaksiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransaksiStateCopyWith<_TransaksiState> get copyWith => __$TransaksiStateCopyWithImpl<_TransaksiState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransaksiState&&const DeepCollectionEquality().equals(other.listTransaksi, _listTransaksi)&&(identical(other.jumlahTransaksi, jumlahTransaksi) || other.jumlahTransaksi == jumlahTransaksi));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listTransaksi),jumlahTransaksi);
}

@override
String toString() {
    return 'TransaksiState(listTransaksi: $listTransaksi, jumlahTransaksi: $jumlahTransaksi)';
}


}

/// @nodoc
abstract mixin class _$TransaksiStateCopyWith<$Res> implements $TransaksiStateCopyWith<$Res> {
  factory _$TransaksiStateCopyWith(_TransaksiState value, $Res Function(_TransaksiState) _then) = __$TransaksiStateCopyWithImpl;
@override @useResult
$Res call({
 List<TransaksiModel> listTransaksi, int jumlahTransaksi
});




}
/// @nodoc
class __$TransaksiStateCopyWithImpl<$Res>
    implements _$TransaksiStateCopyWith<$Res> {
  __$TransaksiStateCopyWithImpl(this._self, this._then);

  final _TransaksiState _self;
  final $Res Function(_TransaksiState) _then;

/// Create a copy of TransaksiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listTransaksi = null,Object? jumlahTransaksi = null,}) {
  return _then(_TransaksiState(
listTransaksi: null == listTransaksi ? _self._listTransaksi : listTransaksi // ignore: cast_nullable_to_non_nullable
as List<TransaksiModel>,jumlahTransaksi: null == jumlahTransaksi ? _self.jumlahTransaksi : jumlahTransaksi // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
