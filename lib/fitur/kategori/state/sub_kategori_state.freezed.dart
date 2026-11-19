// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_kategori_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubKategoriState {

 List<SubKategoriModel> get listSubKategori; int get jumlahSubKategori;
/// Create a copy of SubKategoriState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubKategoriStateCopyWith<SubKategoriState> get copyWith => _$SubKategoriStateCopyWithImpl<SubKategoriState>(this as SubKategoriState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SubKategoriState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubKategoriState&&const DeepCollectionEquality().equals(other.listSubKategori, _this.listSubKategori)&&(identical(other.jumlahSubKategori, _this.jumlahSubKategori) || other.jumlahSubKategori == _this.jumlahSubKategori));
}


@override
int get hashCode {
  final _this = this as SubKategoriState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listSubKategori),_this.jumlahSubKategori);
}

@override
String toString() {
  final _this = this as SubKategoriState;
  return 'SubKategoriState(listSubKategori: ${_this.listSubKategori}, jumlahSubKategori: ${_this.jumlahSubKategori})';
}


}

/// @nodoc
abstract mixin class $SubKategoriStateCopyWith<$Res>  {
  factory $SubKategoriStateCopyWith(SubKategoriState value, $Res Function(SubKategoriState) _then) = _$SubKategoriStateCopyWithImpl;
@useResult
$Res call({
 List<SubKategoriModel> listSubKategori, int jumlahSubKategori
});




}
/// @nodoc
class _$SubKategoriStateCopyWithImpl<$Res>
    implements $SubKategoriStateCopyWith<$Res> {
  _$SubKategoriStateCopyWithImpl(this._self, this._then);

  final SubKategoriState _self;
  final $Res Function(SubKategoriState) _then;

/// Create a copy of SubKategoriState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listSubKategori = null,Object? jumlahSubKategori = null,}) {
  return _then(SubKategoriState(
listSubKategori: null == listSubKategori ? _self.listSubKategori : listSubKategori // ignore: cast_nullable_to_non_nullable
as List<SubKategoriModel>,jumlahSubKategori: null == jumlahSubKategori ? _self.jumlahSubKategori : jumlahSubKategori // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SubKategoriState].
extension SubKategoriStatePatterns on SubKategoriState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubKategoriState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubKategoriState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubKategoriState value)  $default,){
final _that = this;
switch (_that) {
case _SubKategoriState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubKategoriState value)?  $default,){
final _that = this;
switch (_that) {
case _SubKategoriState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SubKategoriModel> listSubKategori,  int jumlahSubKategori)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubKategoriState() when $default != null:
return $default(_that.listSubKategori,_that.jumlahSubKategori);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SubKategoriModel> listSubKategori,  int jumlahSubKategori)  $default,) {final _that = this;
switch (_that) {
case _SubKategoriState():
return $default(_that.listSubKategori,_that.jumlahSubKategori);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SubKategoriModel> listSubKategori,  int jumlahSubKategori)?  $default,) {final _that = this;
switch (_that) {
case _SubKategoriState() when $default != null:
return $default(_that.listSubKategori,_that.jumlahSubKategori);case _:
  return null;

}
}

}

/// @nodoc


class _SubKategoriState extends SubKategoriState {
  const _SubKategoriState({ List<SubKategoriModel> listSubKategori = const [], this.jumlahSubKategori = 0}): _listSubKategori = listSubKategori,super._();
  

 final  List<SubKategoriModel> _listSubKategori;
@override@JsonKey() List<SubKategoriModel> get listSubKategori {
  if (_listSubKategori is EqualUnmodifiableListView) return _listSubKategori;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listSubKategori);
}

@override@JsonKey() final  int jumlahSubKategori;

/// Create a copy of SubKategoriState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubKategoriStateCopyWith<_SubKategoriState> get copyWith => __$SubKategoriStateCopyWithImpl<_SubKategoriState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubKategoriState&&const DeepCollectionEquality().equals(other.listSubKategori, _listSubKategori)&&(identical(other.jumlahSubKategori, jumlahSubKategori) || other.jumlahSubKategori == jumlahSubKategori));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listSubKategori),jumlahSubKategori);
}

@override
String toString() {
    return 'SubKategoriState(listSubKategori: $listSubKategori, jumlahSubKategori: $jumlahSubKategori)';
}


}

/// @nodoc
abstract mixin class _$SubKategoriStateCopyWith<$Res> implements $SubKategoriStateCopyWith<$Res> {
  factory _$SubKategoriStateCopyWith(_SubKategoriState value, $Res Function(_SubKategoriState) _then) = __$SubKategoriStateCopyWithImpl;
@override @useResult
$Res call({
 List<SubKategoriModel> listSubKategori, int jumlahSubKategori
});




}
/// @nodoc
class __$SubKategoriStateCopyWithImpl<$Res>
    implements _$SubKategoriStateCopyWith<$Res> {
  __$SubKategoriStateCopyWithImpl(this._self, this._then);

  final _SubKategoriState _self;
  final $Res Function(_SubKategoriState) _then;

/// Create a copy of SubKategoriState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listSubKategori = null,Object? jumlahSubKategori = null,}) {
  return _then(_SubKategoriState(
listSubKategori: null == listSubKategori ? _self._listSubKategori : listSubKategori // ignore: cast_nullable_to_non_nullable
as List<SubKategoriModel>,jumlahSubKategori: null == jumlahSubKategori ? _self.jumlahSubKategori : jumlahSubKategori // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
