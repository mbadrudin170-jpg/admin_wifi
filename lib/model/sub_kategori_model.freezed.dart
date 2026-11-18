// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_kategori_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubKategoriModel {

 String get id; String get nama; String get idKategori; DateTime? get diperbarui; bool get isDeleted; DateTime? get diarsipkan;
/// Create a copy of SubKategoriModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubKategoriModelCopyWith<SubKategoriModel> get copyWith => _$SubKategoriModelCopyWithImpl<SubKategoriModel>(this as SubKategoriModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SubKategoriModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubKategoriModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nama, _this.nama) || other.nama == _this.nama)&&(identical(other.idKategori, _this.idKategori) || other.idKategori == _this.idKategori)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&(identical(other.diarsipkan, _this.diarsipkan) || other.diarsipkan == _this.diarsipkan));
}


@override
int get hashCode {
  final _this = this as SubKategoriModel;
  return Object.hash(runtimeType,_this.id,_this.nama,_this.idKategori,_this.diperbarui,_this.isDeleted,_this.diarsipkan);
}

@override
String toString() {
  final _this = this as SubKategoriModel;
  return 'SubKategoriModel(id: ${_this.id}, nama: ${_this.nama}, idKategori: ${_this.idKategori}, diperbarui: ${_this.diperbarui}, isDeleted: ${_this.isDeleted}, diarsipkan: ${_this.diarsipkan})';
}


}

/// @nodoc
abstract mixin class $SubKategoriModelCopyWith<$Res>  {
  factory $SubKategoriModelCopyWith(SubKategoriModel value, $Res Function(SubKategoriModel) _then) = _$SubKategoriModelCopyWithImpl;
@useResult
$Res call({
 String id, String nama, String idKategori, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class _$SubKategoriModelCopyWithImpl<$Res>
    implements $SubKategoriModelCopyWith<$Res> {
  _$SubKategoriModelCopyWithImpl(this._self, this._then);

  final SubKategoriModel _self;
  final $Res Function(SubKategoriModel) _then;

/// Create a copy of SubKategoriModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nama = null,Object? idKategori = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(SubKategoriModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,idKategori: null == idKategori ? _self.idKategori : idKategori // ignore: cast_nullable_to_non_nullable
as String,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubKategoriModel].
extension SubKategoriModelPatterns on SubKategoriModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubKategoriModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubKategoriModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubKategoriModel value)  $default,){
final _that = this;
switch (_that) {
case _SubKategoriModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubKategoriModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubKategoriModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nama,  String idKategori,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubKategoriModel() when $default != null:
return $default(_that.id,_that.nama,_that.idKategori,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nama,  String idKategori,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)  $default,) {final _that = this;
switch (_that) {
case _SubKategoriModel():
return $default(_that.id,_that.nama,_that.idKategori,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nama,  String idKategori,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,) {final _that = this;
switch (_that) {
case _SubKategoriModel() when $default != null:
return $default(_that.id,_that.nama,_that.idKategori,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
  return null;

}
}

}

/// @nodoc


class _SubKategoriModel extends SubKategoriModel {
  const _SubKategoriModel({required this.id, required this.nama, required this.idKategori, this.diperbarui, this.isDeleted = false, this.diarsipkan}): super._();
  

@override final  String id;
@override final  String nama;
@override final  String idKategori;
@override final  DateTime? diperbarui;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime? diarsipkan;

/// Create a copy of SubKategoriModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubKategoriModelCopyWith<_SubKategoriModel> get copyWith => __$SubKategoriModelCopyWithImpl<_SubKategoriModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubKategoriModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.idKategori, idKategori) || other.idKategori == idKategori)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.diarsipkan, diarsipkan) || other.diarsipkan == diarsipkan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,nama,idKategori,diperbarui,isDeleted,diarsipkan);
}

@override
String toString() {
    return 'SubKategoriModel(id: $id, nama: $nama, idKategori: $idKategori, diperbarui: $diperbarui, isDeleted: $isDeleted, diarsipkan: $diarsipkan)';
}


}

/// @nodoc
abstract mixin class _$SubKategoriModelCopyWith<$Res> implements $SubKategoriModelCopyWith<$Res> {
  factory _$SubKategoriModelCopyWith(_SubKategoriModel value, $Res Function(_SubKategoriModel) _then) = __$SubKategoriModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String nama, String idKategori, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class __$SubKategoriModelCopyWithImpl<$Res>
    implements _$SubKategoriModelCopyWith<$Res> {
  __$SubKategoriModelCopyWithImpl(this._self, this._then);

  final _SubKategoriModel _self;
  final $Res Function(_SubKategoriModel) _then;

/// Create a copy of SubKategoriModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nama = null,Object? idKategori = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(_SubKategoriModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,idKategori: null == idKategori ? _self.idKategori : idKategori // ignore: cast_nullable_to_non_nullable
as String,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
