// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kategori_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KategoriState {

 List<KategoriModel> get listKategori; int get jumlahKategori;
/// Create a copy of KategoriState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KategoriStateCopyWith<KategoriState> get copyWith => _$KategoriStateCopyWithImpl<KategoriState>(this as KategoriState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as KategoriState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KategoriState&&const DeepCollectionEquality().equals(other.listKategori, _this.listKategori)&&(identical(other.jumlahKategori, _this.jumlahKategori) || other.jumlahKategori == _this.jumlahKategori));
}


@override
int get hashCode {
  final _this = this as KategoriState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listKategori),_this.jumlahKategori);
}

@override
String toString() {
  final _this = this as KategoriState;
  return 'KategoriState(listKategori: ${_this.listKategori}, jumlahKategori: ${_this.jumlahKategori})';
}


}

/// @nodoc
abstract mixin class $KategoriStateCopyWith<$Res>  {
  factory $KategoriStateCopyWith(KategoriState value, $Res Function(KategoriState) _then) = _$KategoriStateCopyWithImpl;
@useResult
$Res call({
 List<KategoriModel> listKategori, int jumlahKategori
});




}
/// @nodoc
class _$KategoriStateCopyWithImpl<$Res>
    implements $KategoriStateCopyWith<$Res> {
  _$KategoriStateCopyWithImpl(this._self, this._then);

  final KategoriState _self;
  final $Res Function(KategoriState) _then;

/// Create a copy of KategoriState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listKategori = null,Object? jumlahKategori = null,}) {
  return _then(KategoriState(
listKategori: null == listKategori ? _self.listKategori : listKategori // ignore: cast_nullable_to_non_nullable
as List<KategoriModel>,jumlahKategori: null == jumlahKategori ? _self.jumlahKategori : jumlahKategori // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [KategoriState].
extension KategoriStatePatterns on KategoriState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KategoriState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KategoriState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KategoriState value)  $default,){
final _that = this;
switch (_that) {
case _KategoriState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KategoriState value)?  $default,){
final _that = this;
switch (_that) {
case _KategoriState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<KategoriModel> listKategori,  int jumlahKategori)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KategoriState() when $default != null:
return $default(_that.listKategori,_that.jumlahKategori);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<KategoriModel> listKategori,  int jumlahKategori)  $default,) {final _that = this;
switch (_that) {
case _KategoriState():
return $default(_that.listKategori,_that.jumlahKategori);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<KategoriModel> listKategori,  int jumlahKategori)?  $default,) {final _that = this;
switch (_that) {
case _KategoriState() when $default != null:
return $default(_that.listKategori,_that.jumlahKategori);case _:
  return null;

}
}

}

/// @nodoc


class _KategoriState extends KategoriState {
  const _KategoriState({ List<KategoriModel> listKategori = const <KategoriModel>[], this.jumlahKategori = 0}): _listKategori = listKategori,super._();
  

 final  List<KategoriModel> _listKategori;
@override@JsonKey() List<KategoriModel> get listKategori {
  if (_listKategori is EqualUnmodifiableListView) return _listKategori;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listKategori);
}

@override@JsonKey() final  int jumlahKategori;

/// Create a copy of KategoriState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KategoriStateCopyWith<_KategoriState> get copyWith => __$KategoriStateCopyWithImpl<_KategoriState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KategoriState&&const DeepCollectionEquality().equals(other.listKategori, _listKategori)&&(identical(other.jumlahKategori, jumlahKategori) || other.jumlahKategori == jumlahKategori));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listKategori),jumlahKategori);
}

@override
String toString() {
    return 'KategoriState(listKategori: $listKategori, jumlahKategori: $jumlahKategori)';
}


}

/// @nodoc
abstract mixin class _$KategoriStateCopyWith<$Res> implements $KategoriStateCopyWith<$Res> {
  factory _$KategoriStateCopyWith(_KategoriState value, $Res Function(_KategoriState) _then) = __$KategoriStateCopyWithImpl;
@override @useResult
$Res call({
 List<KategoriModel> listKategori, int jumlahKategori
});




}
/// @nodoc
class __$KategoriStateCopyWithImpl<$Res>
    implements _$KategoriStateCopyWith<$Res> {
  __$KategoriStateCopyWithImpl(this._self, this._then);

  final _KategoriState _self;
  final $Res Function(_KategoriState) _then;

/// Create a copy of KategoriState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listKategori = null,Object? jumlahKategori = null,}) {
  return _then(_KategoriState(
listKategori: null == listKategori ? _self._listKategori : listKategori // ignore: cast_nullable_to_non_nullable
as List<KategoriModel>,jumlahKategori: null == jumlahKategori ? _self.jumlahKategori : jumlahKategori // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
