// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paket_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaketState {

 List<PaketModel> get listPaket; int get jumlahPaket;
/// Create a copy of PaketState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaketStateCopyWith<PaketState> get copyWith => _$PaketStateCopyWithImpl<PaketState>(this as PaketState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaketState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaketState&&const DeepCollectionEquality().equals(other.listPaket, _this.listPaket)&&(identical(other.jumlahPaket, _this.jumlahPaket) || other.jumlahPaket == _this.jumlahPaket));
}


@override
int get hashCode {
  final _this = this as PaketState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listPaket),_this.jumlahPaket);
}

@override
String toString() {
  final _this = this as PaketState;
  return 'PaketState(listPaket: ${_this.listPaket}, jumlahPaket: ${_this.jumlahPaket})';
}


}

/// @nodoc
abstract mixin class $PaketStateCopyWith<$Res>  {
  factory $PaketStateCopyWith(PaketState value, $Res Function(PaketState) _then) = _$PaketStateCopyWithImpl;
@useResult
$Res call({
 List<PaketModel> listPaket, int jumlahPaket
});




}
/// @nodoc
class _$PaketStateCopyWithImpl<$Res>
    implements $PaketStateCopyWith<$Res> {
  _$PaketStateCopyWithImpl(this._self, this._then);

  final PaketState _self;
  final $Res Function(PaketState) _then;

/// Create a copy of PaketState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listPaket = null,Object? jumlahPaket = null,}) {
  return _then(PaketState(
listPaket: null == listPaket ? _self.listPaket : listPaket // ignore: cast_nullable_to_non_nullable
as List<PaketModel>,jumlahPaket: null == jumlahPaket ? _self.jumlahPaket : jumlahPaket // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaketState].
extension PaketStatePatterns on PaketState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaketState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaketState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaketState value)  $default,){
final _that = this;
switch (_that) {
case _PaketState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaketState value)?  $default,){
final _that = this;
switch (_that) {
case _PaketState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PaketModel> listPaket,  int jumlahPaket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaketState() when $default != null:
return $default(_that.listPaket,_that.jumlahPaket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PaketModel> listPaket,  int jumlahPaket)  $default,) {final _that = this;
switch (_that) {
case _PaketState():
return $default(_that.listPaket,_that.jumlahPaket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PaketModel> listPaket,  int jumlahPaket)?  $default,) {final _that = this;
switch (_that) {
case _PaketState() when $default != null:
return $default(_that.listPaket,_that.jumlahPaket);case _:
  return null;

}
}

}

/// @nodoc


class _PaketState extends PaketState {
  const _PaketState({ List<PaketModel> listPaket = const <PaketModel>[], this.jumlahPaket = 0}): _listPaket = listPaket,super._();
  

 final  List<PaketModel> _listPaket;
@override@JsonKey() List<PaketModel> get listPaket {
  if (_listPaket is EqualUnmodifiableListView) return _listPaket;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listPaket);
}

@override@JsonKey() final  int jumlahPaket;

/// Create a copy of PaketState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaketStateCopyWith<_PaketState> get copyWith => __$PaketStateCopyWithImpl<_PaketState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaketState&&const DeepCollectionEquality().equals(other.listPaket, _listPaket)&&(identical(other.jumlahPaket, jumlahPaket) || other.jumlahPaket == jumlahPaket));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listPaket),jumlahPaket);
}

@override
String toString() {
    return 'PaketState(listPaket: $listPaket, jumlahPaket: $jumlahPaket)';
}


}

/// @nodoc
abstract mixin class _$PaketStateCopyWith<$Res> implements $PaketStateCopyWith<$Res> {
  factory _$PaketStateCopyWith(_PaketState value, $Res Function(_PaketState) _then) = __$PaketStateCopyWithImpl;
@override @useResult
$Res call({
 List<PaketModel> listPaket, int jumlahPaket
});




}
/// @nodoc
class __$PaketStateCopyWithImpl<$Res>
    implements _$PaketStateCopyWith<$Res> {
  __$PaketStateCopyWithImpl(this._self, this._then);

  final _PaketState _self;
  final $Res Function(_PaketState) _then;

/// Create a copy of PaketState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listPaket = null,Object? jumlahPaket = null,}) {
  return _then(_PaketState(
listPaket: null == listPaket ? _self._listPaket : listPaket // ignore: cast_nullable_to_non_nullable
as List<PaketModel>,jumlahPaket: null == jumlahPaket ? _self.jumlahPaket : jumlahPaket // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
