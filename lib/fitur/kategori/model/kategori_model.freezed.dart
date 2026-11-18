// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kategori_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KategoriModel {

 String get id; String get nama; TipeKategori get tipe; List<SubKategoriModel> get subKategori; DateTime? get diperbarui; bool get isDeleted; DateTime? get diarsipkan;
/// Create a copy of KategoriModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KategoriModelCopyWith<KategoriModel> get copyWith => _$KategoriModelCopyWithImpl<KategoriModel>(this as KategoriModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as KategoriModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KategoriModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nama, _this.nama) || other.nama == _this.nama)&&(identical(other.tipe, _this.tipe) || other.tipe == _this.tipe)&&const DeepCollectionEquality().equals(other.subKategori, _this.subKategori)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&(identical(other.diarsipkan, _this.diarsipkan) || other.diarsipkan == _this.diarsipkan));
}


@override
int get hashCode {
  final _this = this as KategoriModel;
  return Object.hash(runtimeType,_this.id,_this.nama,_this.tipe,const DeepCollectionEquality().hash(_this.subKategori),_this.diperbarui,_this.isDeleted,_this.diarsipkan);
}

@override
String toString() {
  final _this = this as KategoriModel;
  return 'KategoriModel(id: ${_this.id}, nama: ${_this.nama}, tipe: ${_this.tipe}, subKategori: ${_this.subKategori}, diperbarui: ${_this.diperbarui}, isDeleted: ${_this.isDeleted}, diarsipkan: ${_this.diarsipkan})';
}


}

/// @nodoc
abstract mixin class $KategoriModelCopyWith<$Res>  {
  factory $KategoriModelCopyWith(KategoriModel value, $Res Function(KategoriModel) _then) = _$KategoriModelCopyWithImpl;
@useResult
$Res call({
 String id, String nama, TipeKategori tipe, List<SubKategoriModel> subKategori, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class _$KategoriModelCopyWithImpl<$Res>
    implements $KategoriModelCopyWith<$Res> {
  _$KategoriModelCopyWithImpl(this._self, this._then);

  final KategoriModel _self;
  final $Res Function(KategoriModel) _then;

/// Create a copy of KategoriModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nama = null,Object? tipe = null,Object? subKategori = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(KategoriModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as TipeKategori,subKategori: null == subKategori ? _self.subKategori : subKategori // ignore: cast_nullable_to_non_nullable
as List<SubKategoriModel>,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [KategoriModel].
extension KategoriModelPatterns on KategoriModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KategoriModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KategoriModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KategoriModel value)  $default,){
final _that = this;
switch (_that) {
case _KategoriModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KategoriModel value)?  $default,){
final _that = this;
switch (_that) {
case _KategoriModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nama,  TipeKategori tipe,  List<SubKategoriModel> subKategori,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KategoriModel() when $default != null:
return $default(_that.id,_that.nama,_that.tipe,_that.subKategori,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nama,  TipeKategori tipe,  List<SubKategoriModel> subKategori,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)  $default,) {final _that = this;
switch (_that) {
case _KategoriModel():
return $default(_that.id,_that.nama,_that.tipe,_that.subKategori,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nama,  TipeKategori tipe,  List<SubKategoriModel> subKategori,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,) {final _that = this;
switch (_that) {
case _KategoriModel() when $default != null:
return $default(_that.id,_that.nama,_that.tipe,_that.subKategori,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
  return null;

}
}

}

/// @nodoc


class _KategoriModel extends KategoriModel {
  const _KategoriModel({required this.id, required this.nama, required this.tipe,  List<SubKategoriModel> subKategori = const <SubKategoriModel>[], this.diperbarui, this.isDeleted = false, this.diarsipkan}): _subKategori = subKategori,super._();
  

@override final  String id;
@override final  String nama;
@override final  TipeKategori tipe;
 final  List<SubKategoriModel> _subKategori;
@override@JsonKey() List<SubKategoriModel> get subKategori {
  if (_subKategori is EqualUnmodifiableListView) return _subKategori;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subKategori);
}

@override final  DateTime? diperbarui;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime? diarsipkan;

/// Create a copy of KategoriModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KategoriModelCopyWith<_KategoriModel> get copyWith => __$KategoriModelCopyWithImpl<_KategoriModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KategoriModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.tipe, tipe) || other.tipe == tipe)&&const DeepCollectionEquality().equals(other.subKategori, _subKategori)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.diarsipkan, diarsipkan) || other.diarsipkan == diarsipkan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,nama,tipe,const DeepCollectionEquality().hash(_subKategori),diperbarui,isDeleted,diarsipkan);
}

@override
String toString() {
    return 'KategoriModel(id: $id, nama: $nama, tipe: $tipe, subKategori: $subKategori, diperbarui: $diperbarui, isDeleted: $isDeleted, diarsipkan: $diarsipkan)';
}


}

/// @nodoc
abstract mixin class _$KategoriModelCopyWith<$Res> implements $KategoriModelCopyWith<$Res> {
  factory _$KategoriModelCopyWith(_KategoriModel value, $Res Function(_KategoriModel) _then) = __$KategoriModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String nama, TipeKategori tipe, List<SubKategoriModel> subKategori, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class __$KategoriModelCopyWithImpl<$Res>
    implements _$KategoriModelCopyWith<$Res> {
  __$KategoriModelCopyWithImpl(this._self, this._then);

  final _KategoriModel _self;
  final $Res Function(_KategoriModel) _then;

/// Create a copy of KategoriModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nama = null,Object? tipe = null,Object? subKategori = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(_KategoriModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,tipe: null == tipe ? _self.tipe : tipe // ignore: cast_nullable_to_non_nullable
as TipeKategori,subKategori: null == subKategori ? _self._subKategori : subKategori // ignore: cast_nullable_to_non_nullable
as List<SubKategoriModel>,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
