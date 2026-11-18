// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dompet_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DompetState {

 List<DompetModel> get listDompet; int get jumlahDompet;
/// Create a copy of DompetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DompetStateCopyWith<DompetState> get copyWith => _$DompetStateCopyWithImpl<DompetState>(this as DompetState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DompetState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DompetState&&const DeepCollectionEquality().equals(other.listDompet, _this.listDompet)&&(identical(other.jumlahDompet, _this.jumlahDompet) || other.jumlahDompet == _this.jumlahDompet));
}


@override
int get hashCode {
  final _this = this as DompetState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.listDompet),_this.jumlahDompet);
}

@override
String toString() {
  final _this = this as DompetState;
  return 'DompetState(listDompet: ${_this.listDompet}, jumlahDompet: ${_this.jumlahDompet})';
}


}

/// @nodoc
abstract mixin class $DompetStateCopyWith<$Res>  {
  factory $DompetStateCopyWith(DompetState value, $Res Function(DompetState) _then) = _$DompetStateCopyWithImpl;
@useResult
$Res call({
 List<DompetModel> listDompet, int jumlahDompet
});




}
/// @nodoc
class _$DompetStateCopyWithImpl<$Res>
    implements $DompetStateCopyWith<$Res> {
  _$DompetStateCopyWithImpl(this._self, this._then);

  final DompetState _self;
  final $Res Function(DompetState) _then;

/// Create a copy of DompetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listDompet = null,Object? jumlahDompet = null,}) {
  return _then(DompetState(
listDompet: null == listDompet ? _self.listDompet : listDompet // ignore: cast_nullable_to_non_nullable
as List<DompetModel>,jumlahDompet: null == jumlahDompet ? _self.jumlahDompet : jumlahDompet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DompetState].
extension DompetStatePatterns on DompetState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DompetState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DompetState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DompetState value)  $default,){
final _that = this;
switch (_that) {
case _DompetState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DompetState value)?  $default,){
final _that = this;
switch (_that) {
case _DompetState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DompetModel> listDompet,  int jumlahDompet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DompetState() when $default != null:
return $default(_that.listDompet,_that.jumlahDompet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DompetModel> listDompet,  int jumlahDompet)  $default,) {final _that = this;
switch (_that) {
case _DompetState():
return $default(_that.listDompet,_that.jumlahDompet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DompetModel> listDompet,  int jumlahDompet)?  $default,) {final _that = this;
switch (_that) {
case _DompetState() when $default != null:
return $default(_that.listDompet,_that.jumlahDompet);case _:
  return null;

}
}

}

/// @nodoc


class _DompetState extends DompetState {
  const _DompetState({ List<DompetModel> listDompet = const <DompetModel>[], this.jumlahDompet = 0}): _listDompet = listDompet,super._();
  

 final  List<DompetModel> _listDompet;
@override@JsonKey() List<DompetModel> get listDompet {
  if (_listDompet is EqualUnmodifiableListView) return _listDompet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listDompet);
}

@override@JsonKey() final  int jumlahDompet;

/// Create a copy of DompetState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DompetStateCopyWith<_DompetState> get copyWith => __$DompetStateCopyWithImpl<_DompetState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DompetState&&const DeepCollectionEquality().equals(other.listDompet, _listDompet)&&(identical(other.jumlahDompet, jumlahDompet) || other.jumlahDompet == jumlahDompet));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_listDompet),jumlahDompet);
}

@override
String toString() {
    return 'DompetState(listDompet: $listDompet, jumlahDompet: $jumlahDompet)';
}


}

/// @nodoc
abstract mixin class _$DompetStateCopyWith<$Res> implements $DompetStateCopyWith<$Res> {
  factory _$DompetStateCopyWith(_DompetState value, $Res Function(_DompetState) _then) = __$DompetStateCopyWithImpl;
@override @useResult
$Res call({
 List<DompetModel> listDompet, int jumlahDompet
});




}
/// @nodoc
class __$DompetStateCopyWithImpl<$Res>
    implements _$DompetStateCopyWith<$Res> {
  __$DompetStateCopyWithImpl(this._self, this._then);

  final _DompetState _self;
  final $Res Function(_DompetState) _then;

/// Create a copy of DompetState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listDompet = null,Object? jumlahDompet = null,}) {
  return _then(_DompetState(
listDompet: null == listDompet ? _self._listDompet : listDompet // ignore: cast_nullable_to_non_nullable
as List<DompetModel>,jumlahDompet: null == jumlahDompet ? _self.jumlahDompet : jumlahDompet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
