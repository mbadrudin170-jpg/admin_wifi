// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dompet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DompetModel {

 String get id; String get namaDompet; double get saldo; DateTime? get diperbarui; bool get isDeleted; DateTime? get diarsipkan;
/// Create a copy of DompetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DompetModelCopyWith<DompetModel> get copyWith => _$DompetModelCopyWithImpl<DompetModel>(this as DompetModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DompetModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DompetModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.namaDompet, _this.namaDompet) || other.namaDompet == _this.namaDompet)&&(identical(other.saldo, _this.saldo) || other.saldo == _this.saldo)&&(identical(other.diperbarui, _this.diperbarui) || other.diperbarui == _this.diperbarui)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&(identical(other.diarsipkan, _this.diarsipkan) || other.diarsipkan == _this.diarsipkan));
}


@override
int get hashCode {
  final _this = this as DompetModel;
  return Object.hash(runtimeType,_this.id,_this.namaDompet,_this.saldo,_this.diperbarui,_this.isDeleted,_this.diarsipkan);
}

@override
String toString() {
  final _this = this as DompetModel;
  return 'DompetModel(id: ${_this.id}, namaDompet: ${_this.namaDompet}, saldo: ${_this.saldo}, diperbarui: ${_this.diperbarui}, isDeleted: ${_this.isDeleted}, diarsipkan: ${_this.diarsipkan})';
}


}

/// @nodoc
abstract mixin class $DompetModelCopyWith<$Res>  {
  factory $DompetModelCopyWith(DompetModel value, $Res Function(DompetModel) _then) = _$DompetModelCopyWithImpl;
@useResult
$Res call({
 String id, String namaDompet, double saldo, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class _$DompetModelCopyWithImpl<$Res>
    implements $DompetModelCopyWith<$Res> {
  _$DompetModelCopyWithImpl(this._self, this._then);

  final DompetModel _self;
  final $Res Function(DompetModel) _then;

/// Create a copy of DompetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? namaDompet = null,Object? saldo = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(DompetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,namaDompet: null == namaDompet ? _self.namaDompet : namaDompet // ignore: cast_nullable_to_non_nullable
as String,saldo: null == saldo ? _self.saldo : saldo // ignore: cast_nullable_to_non_nullable
as double,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DompetModel].
extension DompetModelPatterns on DompetModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DompetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DompetModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DompetModel value)  $default,){
final _that = this;
switch (_that) {
case _DompetModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DompetModel value)?  $default,){
final _that = this;
switch (_that) {
case _DompetModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String namaDompet,  double saldo,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DompetModel() when $default != null:
return $default(_that.id,_that.namaDompet,_that.saldo,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String namaDompet,  double saldo,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)  $default,) {final _that = this;
switch (_that) {
case _DompetModel():
return $default(_that.id,_that.namaDompet,_that.saldo,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String namaDompet,  double saldo,  DateTime? diperbarui,  bool isDeleted,  DateTime? diarsipkan)?  $default,) {final _that = this;
switch (_that) {
case _DompetModel() when $default != null:
return $default(_that.id,_that.namaDompet,_that.saldo,_that.diperbarui,_that.isDeleted,_that.diarsipkan);case _:
  return null;

}
}

}

/// @nodoc


class _DompetModel extends DompetModel {
  const _DompetModel({required this.id, required this.namaDompet, required this.saldo, this.diperbarui, this.isDeleted = false, this.diarsipkan}): super._();
  

@override final  String id;
@override final  String namaDompet;
@override final  double saldo;
@override final  DateTime? diperbarui;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime? diarsipkan;

/// Create a copy of DompetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DompetModelCopyWith<_DompetModel> get copyWith => __$DompetModelCopyWithImpl<_DompetModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DompetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.namaDompet, namaDompet) || other.namaDompet == namaDompet)&&(identical(other.saldo, saldo) || other.saldo == saldo)&&(identical(other.diperbarui, diperbarui) || other.diperbarui == diperbarui)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.diarsipkan, diarsipkan) || other.diarsipkan == diarsipkan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,namaDompet,saldo,diperbarui,isDeleted,diarsipkan);
}

@override
String toString() {
    return 'DompetModel(id: $id, namaDompet: $namaDompet, saldo: $saldo, diperbarui: $diperbarui, isDeleted: $isDeleted, diarsipkan: $diarsipkan)';
}


}

/// @nodoc
abstract mixin class _$DompetModelCopyWith<$Res> implements $DompetModelCopyWith<$Res> {
  factory _$DompetModelCopyWith(_DompetModel value, $Res Function(_DompetModel) _then) = __$DompetModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String namaDompet, double saldo, DateTime? diperbarui, bool isDeleted, DateTime? diarsipkan
});




}
/// @nodoc
class __$DompetModelCopyWithImpl<$Res>
    implements _$DompetModelCopyWith<$Res> {
  __$DompetModelCopyWithImpl(this._self, this._then);

  final _DompetModel _self;
  final $Res Function(_DompetModel) _then;

/// Create a copy of DompetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? namaDompet = null,Object? saldo = null,Object? diperbarui = freezed,Object? isDeleted = null,Object? diarsipkan = freezed,}) {
  return _then(_DompetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,namaDompet: null == namaDompet ? _self.namaDompet : namaDompet // ignore: cast_nullable_to_non_nullable
as String,saldo: null == saldo ? _self.saldo : saldo // ignore: cast_nullable_to_non_nullable
as double,diperbarui: freezed == diperbarui ? _self.diperbarui : diperbarui // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,diarsipkan: freezed == diarsipkan ? _self.diarsipkan : diarsipkan // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
