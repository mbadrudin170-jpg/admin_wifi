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

/// Nama tabel yang dilacak; kolom `tabel` (PRIMARY KEY).
 String get namaTabel;/// Status sinkronisasi (integer; 0 = sinkron, selain itu ada perubahan).
 int get status;/// Daftar ID baris yang perlu diunggah, dipisahkan koma.
 String get ids;/// Waktu terakhir baris diperbarui.
 DateTime? get diperbarui;
/// Create a copy of StatusUnggahModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusUnggahModelCopyWith<StatusUnggahModel> get copyWith => _$StatusUnggahModelCopyWithImpl<StatusUnggahModel>(this as StatusUnggahModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StatusUnggahModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusUnggahModel&&(identical(other.namaTabel, _this.namaTabel) || other.namaTabel == _this.namaTabel)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.ids, _this.ids) || other.ids == _this.ids)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui));
}


@override
int get hashCode {
  final _this = this as StatusUnggahModel;
  return Object.hash(runtimeType,_this.namaTabel,_this.status,_this.ids,_this.diperbarui);
}

@override
String toString() {
  final _this = this as StatusUnggahModel;
  return 'StatusUnggahModel(namaTabel: ${_this.namaTabel}, status: ${_this.status}, ids: ${_this.ids}, diperbarui: ${_this.diperbarui})';
}


}

/// @nodoc
abstract mixin class $StatusUnggahModelCopyWith<$Res>  {
  factory $StatusUnggahModelCopyWith(StatusUnggahModel value, $Res Function(StatusUnggahModel) _then) = _$StatusUnggahModelCopyWithImpl;
@useResult
$Res call({
 String namaTabel, int status, String ids, DateTime? diperbarui
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
@pragma('vm:prefer-inline') @override $Res call({Object? namaTabel = null,Object? status = null,Object? ids = null,Object? diperbarui = freezed,}) {
  return _then(StatusUnggahModel(
namaTabel: null == namaTabel ? _self.namaTabel : namaTabel // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,ids: null == ids ? _self.ids : ids // ignore: cast_nullable_to_non_nullable
as String,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String namaTabel,  int status,  String ids,  DateTime? diperbarui)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusUnggahModel() when $default != null:
return $default(_that.namaTabel,_that.status,_that.ids,_that.diperbarui);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String namaTabel,  int status,  String ids,  DateTime? diperbarui)  $default,) {final _that = this;
switch (_that) {
case _StatusUnggahModel():
return $default(_that.namaTabel,_that.status,_that.ids,_that.diperbarui);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String namaTabel,  int status,  String ids,  DateTime? diperbarui)?  $default,) {final _that = this;
switch (_that) {
case _StatusUnggahModel() when $default != null:
return $default(_that.namaTabel,_that.status,_that.ids,_that.diperbarui);case _:
  return null;

}
}

}

/// @nodoc


class _StatusUnggahModel extends StatusUnggahModel {
  const _StatusUnggahModel({required this.namaTabel, required this.status, required this.ids, this.diperbarui}): super._();
  

/// Nama tabel yang dilacak; kolom `tabel` (PRIMARY KEY).
@override final  String namaTabel;
/// Status sinkronisasi (integer; 0 = sinkron, selain itu ada perubahan).
@override final  int status;
/// Daftar ID baris yang perlu diunggah, dipisahkan koma.
@override final  String ids;
/// Waktu terakhir baris diperbarui.
@override final  DateTime? diperbarui;

/// Create a copy of StatusUnggahModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusUnggahModelCopyWith<_StatusUnggahModel> get copyWith => __$StatusUnggahModelCopyWithImpl<_StatusUnggahModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusUnggahModel&&(identical(other.namaTabel, namaTabel) || other.namaTabel == namaTabel)&&(identical(other.status, status) || other.status == status)&&(identical(other.ids, ids) || other.ids == ids)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui));
}


@override
int get hashCode {
    return Object.hash(runtimeType,namaTabel,status,ids,diperbarui);
}

@override
String toString() {
    return 'StatusUnggahModel(namaTabel: $namaTabel, status: $status, ids: $ids, diperbarui: $diperbarui)';
}


}

/// @nodoc
abstract mixin class _$StatusUnggahModelCopyWith<$Res> implements $StatusUnggahModelCopyWith<$Res> {
  factory _$StatusUnggahModelCopyWith(_StatusUnggahModel value, $Res Function(_StatusUnggahModel) _then) = __$StatusUnggahModelCopyWithImpl;
@override @useResult
$Res call({
 String namaTabel, int status, String ids, DateTime? diperbarui
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
@override @pragma('vm:prefer-inline') $Res call({Object? namaTabel = null,Object? status = null,Object? ids = null,Object? diperbarui = freezed,}) {
  return _then(_StatusUnggahModel(
namaTabel: null == namaTabel ? _self.namaTabel : namaTabel // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,ids: null == ids ? _self.ids : ids // ignore: cast_nullable_to_non_nullable
as String,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
