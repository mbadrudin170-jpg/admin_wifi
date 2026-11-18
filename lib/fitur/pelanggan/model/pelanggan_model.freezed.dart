// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pelanggan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PelangganModel {

 String get id; String get nama; String get telepon; String get alamat; String get password; String get macAddress; bool get isDeleted; DateTime? get diperbarui; DateTime? get diarsipkan;
/// Create a copy of PelangganModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PelangganModelCopyWith<PelangganModel> get copyWith => _$PelangganModelCopyWithImpl<PelangganModel>(this as PelangganModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PelangganModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PelangganModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nama, _this.nama) || other.nama == _this.nama)&&(identical(other.telepon, _this.telepon) || other.telepon == _this.telepon)&&(identical(other.alamat, _this.alamat) || other.alamat == _this.alamat)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.macAddress, _this.macAddress) || other.macAddress == _this.macAddress)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui)&&(identical(other.diarsipkan, _this.diarsipkan) || other.diarsipkan == _this.diarsipkan));
}


@override
int get hashCode {
  final _this = this as PelangganModel;
  return Object.hash(runtimeType,_this.id,_this.nama,_this.telepon,_this.alamat,_this.password,_this.macAddress,_this.isDeleted,_this.diperbarui,_this.diarsipkan);
}

@override
String toString() {
  final _this = this as PelangganModel;
  return 'PelangganModel(id: ${_this.id}, nama: ${_this.nama}, telepon: ${_this.telepon}, alamat: ${_this.alamat}, password: ${_this.password}, macAddress: ${_this.macAddress}, isDeleted: ${_this.isDeleted}, diperbarui: ${_this.diperbarui}, diarsipkan: ${_this.diarsipkan})';
}


}

/// @nodoc
abstract mixin class $PelangganModelCopyWith<$Res>  {
  factory $PelangganModelCopyWith(PelangganModel value, $Res Function(PelangganModel) _then) = _$PelangganModelCopyWithImpl;
@useResult
$Res call({
 String id, String nama, String telepon, String alamat, String password, String macAddress, bool isDeleted, DateTime? diperbarui, DateTime? diarsipkan
});




}
/// @nodoc
class _$PelangganModelCopyWithImpl<$Res>
    implements $PelangganModelCopyWith<$Res> {
  _$PelangganModelCopyWithImpl(this._self, this._then);

  final PelangganModel _self;
  final $Res Function(PelangganModel) _then;

/// Create a copy of PelangganModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nama = null,Object? telepon = null,Object? alamat = null,Object? password = null,Object? macAddress = null,Object? isDeleted = null,Object? diperbarui = freezed,Object? diarsipkan = freezed,}) {
  return _then(PelangganModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,telepon: null == telepon ? _self.telepon : telepon // ignore: cast_nullable_to_non_nullable
as String,alamat: null == alamat ? _self.alamat : alamat // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,macAddress: null == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PelangganModel].
extension PelangganModelPatterns on PelangganModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PelangganModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PelangganModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PelangganModel value)  $default,){
final _that = this;
switch (_that) {
case _PelangganModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PelangganModel value)?  $default,){
final _that = this;
switch (_that) {
case _PelangganModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nama,  String telepon,  String alamat,  String password,  String macAddress,  bool isDeleted,  DateTime? diperbarui,  DateTime? diarsipkan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PelangganModel() when $default != null:
return $default(_that.id,_that.nama,_that.telepon,_that.alamat,_that.password,_that.macAddress,_that.isDeleted,_that.diperbarui,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nama,  String telepon,  String alamat,  String password,  String macAddress,  bool isDeleted,  DateTime? diperbarui,  DateTime? diarsipkan)  $default,) {final _that = this;
switch (_that) {
case _PelangganModel():
return $default(_that.id,_that.nama,_that.telepon,_that.alamat,_that.password,_that.macAddress,_that.isDeleted,_that.diperbarui,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nama,  String telepon,  String alamat,  String password,  String macAddress,  bool isDeleted,  DateTime? diperbarui,  DateTime? diarsipkan)?  $default,) {final _that = this;
switch (_that) {
case _PelangganModel() when $default != null:
return $default(_that.id,_that.nama,_that.telepon,_that.alamat,_that.password,_that.macAddress,_that.isDeleted,_that.diperbarui,_that.diarsipkan);case _:
  return null;

}
}

}

/// @nodoc


class _PelangganModel extends PelangganModel {
  const _PelangganModel({required this.id, required this.nama, required this.telepon, required this.alamat, required this.password, this.macAddress = '', this.isDeleted = false, this.diperbarui, this.diarsipkan}): super._();
  

@override final  String id;
@override final  String nama;
@override final  String telepon;
@override final  String alamat;
@override final  String password;
@override@JsonKey() final  String macAddress;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime? diperbarui;
@override final  DateTime? diarsipkan;

/// Create a copy of PelangganModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PelangganModelCopyWith<_PelangganModel> get copyWith => __$PelangganModelCopyWithImpl<_PelangganModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PelangganModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nama, nama) || other.nama == nama)&&(identical(other.telepon, telepon) || other.telepon == telepon)&&(identical(other.alamat, alamat) || other.alamat == alamat)&&(identical(other.password, password) || other.password == password)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui)&&(identical(other.diarsipkan, diarsipkan) || other.diarsipkan == diarsipkan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,nama,telepon,alamat,password,macAddress,isDeleted,diperbarui,diarsipkan);
}

@override
String toString() {
    return 'PelangganModel(id: $id, nama: $nama, telepon: $telepon, alamat: $alamat, password: $password, macAddress: $macAddress, isDeleted: $isDeleted, diperbarui: $diperbarui, diarsipkan: $diarsipkan)';
}


}

/// @nodoc
abstract mixin class _$PelangganModelCopyWith<$Res> implements $PelangganModelCopyWith<$Res> {
  factory _$PelangganModelCopyWith(_PelangganModel value, $Res Function(_PelangganModel) _then) = __$PelangganModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String nama, String telepon, String alamat, String password, String macAddress, bool isDeleted, DateTime? diperbarui, DateTime? diarsipkan
});




}
/// @nodoc
class __$PelangganModelCopyWithImpl<$Res>
    implements _$PelangganModelCopyWith<$Res> {
  __$PelangganModelCopyWithImpl(this._self, this._then);

  final _PelangganModel _self;
  final $Res Function(_PelangganModel) _then;

/// Create a copy of PelangganModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nama = null,Object? telepon = null,Object? alamat = null,Object? password = null,Object? macAddress = null,Object? isDeleted = null,Object? diperbarui = freezed,Object? diarsipkan = freezed,}) {
  return _then(_PelangganModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nama: null == nama ? _self.nama : nama // ignore: cast_nullable_to_non_nullable
as String,telepon: null == telepon ? _self.telepon : telepon // ignore: cast_nullable_to_non_nullable
as String,alamat: null == alamat ? _self.alamat : alamat // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,macAddress: null == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
