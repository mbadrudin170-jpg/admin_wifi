// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kritik_saran_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KritikSaranModel {

 String get id; String get isi; DateTime get tanggal; String get userId; DateTime? get diperbarui;
/// Create a copy of KritikSaranModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KritikSaranModelCopyWith<KritikSaranModel> get copyWith => _$KritikSaranModelCopyWithImpl<KritikSaranModel>(this as KritikSaranModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as KritikSaranModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KritikSaranModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.isi, _this.isi) || other.isi == _this.isi)&&(identical(other.tanggal, _this.tanggal) || other.tanggal == _this.tanggal)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui));
}


@override
int get hashCode {
  final _this = this as KritikSaranModel;
  return Object.hash(runtimeType,_this.id,_this.isi,_this.tanggal,_this.userId,_this.diperbarui);
}

@override
String toString() {
  final _this = this as KritikSaranModel;
  return 'KritikSaranModel(id: ${_this.id}, isi: ${_this.isi}, tanggal: ${_this.tanggal}, userId: ${_this.userId}, diperbarui: ${_this.diperbarui})';
}


}

/// @nodoc
abstract mixin class $KritikSaranModelCopyWith<$Res>  {
  factory $KritikSaranModelCopyWith(KritikSaranModel value, $Res Function(KritikSaranModel) _then) = _$KritikSaranModelCopyWithImpl;
@useResult
$Res call({
 String id, String isi, DateTime tanggal, String userId, DateTime? diperbarui
});




}
/// @nodoc
class _$KritikSaranModelCopyWithImpl<$Res>
    implements $KritikSaranModelCopyWith<$Res> {
  _$KritikSaranModelCopyWithImpl(this._self, this._then);

  final KritikSaranModel _self;
  final $Res Function(KritikSaranModel) _then;

/// Create a copy of KritikSaranModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isi = null,Object? tanggal = null,Object? userId = null,Object? diperbarui = freezed,}) {
  return _then(KritikSaranModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isi: null == isi ? _self.isi : isi // ignore: cast_nullable_to_non_nullable
as String,tanggal: null == tanggal ? _self.tanggal : tanggal // ignore: cast_nullable_to_non_nullable
as DateTime,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [KritikSaranModel].
extension KritikSaranModelPatterns on KritikSaranModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KritikSaranModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KritikSaranModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KritikSaranModel value)  $default,){
final _that = this;
switch (_that) {
case _KritikSaranModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KritikSaranModel value)?  $default,){
final _that = this;
switch (_that) {
case _KritikSaranModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String isi,  DateTime tanggal,  String userId,  DateTime? diperbarui)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KritikSaranModel() when $default != null:
return $default(_that.id,_that.isi,_that.tanggal,_that.userId,_that.diperbarui);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String isi,  DateTime tanggal,  String userId,  DateTime? diperbarui)  $default,) {final _that = this;
switch (_that) {
case _KritikSaranModel():
return $default(_that.id,_that.isi,_that.tanggal,_that.userId,_that.diperbarui);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String isi,  DateTime tanggal,  String userId,  DateTime? diperbarui)?  $default,) {final _that = this;
switch (_that) {
case _KritikSaranModel() when $default != null:
return $default(_that.id,_that.isi,_that.tanggal,_that.userId,_that.diperbarui);case _:
  return null;

}
}

}

/// @nodoc


class _KritikSaranModel extends KritikSaranModel {
  const _KritikSaranModel({required this.id, required this.isi, required this.tanggal, required this.userId, this.diperbarui}): super._();
  

@override final  String id;
@override final  String isi;
@override final  DateTime tanggal;
@override final  String userId;
@override final  DateTime? diperbarui;

/// Create a copy of KritikSaranModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KritikSaranModelCopyWith<_KritikSaranModel> get copyWith => __$KritikSaranModelCopyWithImpl<_KritikSaranModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KritikSaranModel&&(identical(other.id, id) || other.id == id)&&(identical(other.isi, isi) || other.isi == isi)&&(identical(other.tanggal, tanggal) || other.tanggal == tanggal)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,isi,tanggal,userId,diperbarui);
}

@override
String toString() {
    return 'KritikSaranModel(id: $id, isi: $isi, tanggal: $tanggal, userId: $userId, diperbarui: $diperbarui)';
}


}

/// @nodoc
abstract mixin class _$KritikSaranModelCopyWith<$Res> implements $KritikSaranModelCopyWith<$Res> {
  factory _$KritikSaranModelCopyWith(_KritikSaranModel value, $Res Function(_KritikSaranModel) _then) = __$KritikSaranModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String isi, DateTime tanggal, String userId, DateTime? diperbarui
});




}
/// @nodoc
class __$KritikSaranModelCopyWithImpl<$Res>
    implements _$KritikSaranModelCopyWith<$Res> {
  __$KritikSaranModelCopyWithImpl(this._self, this._then);

  final _KritikSaranModel _self;
  final $Res Function(_KritikSaranModel) _then;

/// Create a copy of KritikSaranModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isi = null,Object? tanggal = null,Object? userId = null,Object? diperbarui = freezed,}) {
  return _then(_KritikSaranModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isi: null == isi ? _self.isi : isi // ignore: cast_nullable_to_non_nullable
as String,tanggal: null == tanggal ? _self.tanggal : tanggal // ignore: cast_nullable_to_non_nullable
as DateTime,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
