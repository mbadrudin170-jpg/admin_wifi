// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_unggah_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StatusUnggahModel {

/// ID unik untuk baris ini, biasanya akan selalu 1.
 int get id;/// Bendera yang menandakan status. `true` jika ada data untuk diunggah,
/// `false` jika tidak.
 bool get perluUnggah;
/// Create a copy of StatusUnggahModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusUnggahModelCopyWith<StatusUnggahModel> get copyWith => _$StatusUnggahModelCopyWithImpl<StatusUnggahModel>(this as StatusUnggahModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StatusUnggahModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusUnggahModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.perluUnggah, _this.perluUnggah) || other.perluUnggah == _this.perluUnggah));
}


@override
int get hashCode {
  final _this = this as StatusUnggahModel;
  return Object.hash(runtimeType,_this.id,_this.perluUnggah);
}

@override
String toString() {
  final _this = this as StatusUnggahModel;
  return 'StatusUnggahModel(id: ${_this.id}, perluUnggah: ${_this.perluUnggah})';
}


}

/// @nodoc
abstract mixin class $StatusUnggahModelCopyWith<$Res>  {
  factory $StatusUnggahModelCopyWith(StatusUnggahModel value, $Res Function(StatusUnggahModel) _then) = _$StatusUnggahModelCopyWithImpl;
@useResult
$Res call({
 int id, bool perluUnggah
});




}
/// @nodoc
class _$StatusUnggahModelCopyWithImpl<$Res>
    implements $StatusUnggahModelCopyWith<$Res> {
  _$StatusUnggahModelCopyWithImpl(this._self, this._then);

  final StatusUnggahModel _self;
  final $Res Function(StatusUnggahModel) _then;

/// Create a copy of StatusUnggahModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? perluUnggah = null,}) {
  return _then(StatusUnggahModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,perluUnggah: null == perluUnggah ? _self.perluUnggah : perluUnggah // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusUnggahModel].
extension StatusUnggahModelPatterns on StatusUnggahModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusUnggahModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusUnggahModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusUnggahModel value)  $default,){
final _that = this;
switch (_that) {
case _StatusUnggahModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusUnggahModel value)?  $default,){
final _that = this;
switch (_that) {
case _StatusUnggahModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  bool perluUnggah)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusUnggahModel() when $default != null:
return $default(_that.id,_that.perluUnggah);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  bool perluUnggah)  $default,) {final _that = this;
switch (_that) {
case _StatusUnggahModel():
return $default(_that.id,_that.perluUnggah);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  bool perluUnggah)?  $default,) {final _that = this;
switch (_that) {
case _StatusUnggahModel() when $default != null:
return $default(_that.id,_that.perluUnggah);case _:
  return null;

}
}

}

/// @nodoc


class _StatusUnggahModel extends StatusUnggahModel {
  const _StatusUnggahModel({required this.id, required this.perluUnggah}): super._();
  

/// ID unik untuk baris ini, biasanya akan selalu 1.
@override final  int id;
/// Bendera yang menandakan status. `true` jika ada data untuk diunggah,
/// `false` jika tidak.
@override final  bool perluUnggah;

/// Create a copy of StatusUnggahModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusUnggahModelCopyWith<_StatusUnggahModel> get copyWith => __$StatusUnggahModelCopyWithImpl<_StatusUnggahModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusUnggahModel&&(identical(other.id, id) || other.id == id)&&(identical(other.perluUnggah, perluUnggah) || other.perluUnggah == perluUnggah));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,perluUnggah);
}

@override
String toString() {
    return 'StatusUnggahModel(id: $id, perluUnggah: $perluUnggah)';
}


}

/// @nodoc
abstract mixin class _$StatusUnggahModelCopyWith<$Res> implements $StatusUnggahModelCopyWith<$Res> {
  factory _$StatusUnggahModelCopyWith(_StatusUnggahModel value, $Res Function(_StatusUnggahModel) _then) = __$StatusUnggahModelCopyWithImpl;
@override @useResult
$Res call({
 int id, bool perluUnggah
});




}
/// @nodoc
class __$StatusUnggahModelCopyWithImpl<$Res>
    implements _$StatusUnggahModelCopyWith<$Res> {
  __$StatusUnggahModelCopyWithImpl(this._self, this._then);

  final _StatusUnggahModel _self;
  final $Res Function(_StatusUnggahModel) _then;

/// Create a copy of StatusUnggahModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? perluUnggah = null,}) {
  return _then(_StatusUnggahModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,perluUnggah: null == perluUnggah ? _self.perluUnggah : perluUnggah // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
