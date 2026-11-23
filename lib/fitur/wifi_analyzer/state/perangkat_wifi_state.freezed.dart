// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perangkat_wifi_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PerangkatWifiState {

 bool get isLoading; List<PerangkatWifiModel> get perangkat; int? get progress; String? get error;
/// Create a copy of PerangkatWifiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerangkatWifiStateCopyWith<PerangkatWifiState> get copyWith => _$PerangkatWifiStateCopyWithImpl<PerangkatWifiState>(this as PerangkatWifiState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PerangkatWifiState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerangkatWifiState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&const DeepCollectionEquality().equals(other.perangkat, _this.perangkat)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as PerangkatWifiState;
  return Object.hash(runtimeType,_this.isLoading,const DeepCollectionEquality().hash(_this.perangkat),_this.progress,_this.error);
}

@override
String toString() {
  final _this = this as PerangkatWifiState;
  return 'PerangkatWifiState(isLoading: ${_this.isLoading}, perangkat: ${_this.perangkat}, progress: ${_this.progress}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $PerangkatWifiStateCopyWith<$Res>  {
  factory $PerangkatWifiStateCopyWith(PerangkatWifiState value, $Res Function(PerangkatWifiState) _then) = _$PerangkatWifiStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<PerangkatWifiModel> perangkat, int? progress, String? error
});




}
/// @nodoc
class _$PerangkatWifiStateCopyWithImpl<$Res>
    implements $PerangkatWifiStateCopyWith<$Res> {
  _$PerangkatWifiStateCopyWithImpl(this._self, this._then);

  final PerangkatWifiState _self;
  final $Res Function(PerangkatWifiState) _then;

/// Create a copy of PerangkatWifiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? perangkat = null,Object? progress = freezed,Object? error = freezed,}) {
  return _then(PerangkatWifiState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,perangkat: null == perangkat ? _self.perangkat : perangkat // ignore: cast_nullable_to_non_nullable
as List<PerangkatWifiModel>,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PerangkatWifiState].
extension PerangkatWifiStatePatterns on PerangkatWifiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerangkatWifiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerangkatWifiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerangkatWifiState value)  $default,){
final _that = this;
switch (_that) {
case _PerangkatWifiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerangkatWifiState value)?  $default,){
final _that = this;
switch (_that) {
case _PerangkatWifiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<PerangkatWifiModel> perangkat,  int? progress,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerangkatWifiState() when $default != null:
return $default(_that.isLoading,_that.perangkat,_that.progress,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<PerangkatWifiModel> perangkat,  int? progress,  String? error)  $default,) {final _that = this;
switch (_that) {
case _PerangkatWifiState():
return $default(_that.isLoading,_that.perangkat,_that.progress,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<PerangkatWifiModel> perangkat,  int? progress,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _PerangkatWifiState() when $default != null:
return $default(_that.isLoading,_that.perangkat,_that.progress,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _PerangkatWifiState extends PerangkatWifiState {
  const _PerangkatWifiState({this.isLoading = false,  List<PerangkatWifiModel> perangkat = const <PerangkatWifiModel>[], this.progress, this.error}): _perangkat = perangkat,super._();
  

@override@JsonKey() final  bool isLoading;
 final  List<PerangkatWifiModel> _perangkat;
@override@JsonKey() List<PerangkatWifiModel> get perangkat {
  if (_perangkat is EqualUnmodifiableListView) return _perangkat;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_perangkat);
}

@override final  int? progress;
@override final  String? error;

/// Create a copy of PerangkatWifiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerangkatWifiStateCopyWith<_PerangkatWifiState> get copyWith => __$PerangkatWifiStateCopyWithImpl<_PerangkatWifiState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerangkatWifiState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.perangkat, _perangkat)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_perangkat),progress,error);
}

@override
String toString() {
    return 'PerangkatWifiState(isLoading: $isLoading, perangkat: $perangkat, progress: $progress, error: $error)';
}


}

/// @nodoc
abstract mixin class _$PerangkatWifiStateCopyWith<$Res> implements $PerangkatWifiStateCopyWith<$Res> {
  factory _$PerangkatWifiStateCopyWith(_PerangkatWifiState value, $Res Function(_PerangkatWifiState) _then) = __$PerangkatWifiStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<PerangkatWifiModel> perangkat, int? progress, String? error
});




}
/// @nodoc
class __$PerangkatWifiStateCopyWithImpl<$Res>
    implements _$PerangkatWifiStateCopyWith<$Res> {
  __$PerangkatWifiStateCopyWithImpl(this._self, this._then);

  final _PerangkatWifiState _self;
  final $Res Function(_PerangkatWifiState) _then;

/// Create a copy of PerangkatWifiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? perangkat = null,Object? progress = freezed,Object? error = freezed,}) {
  return _then(_PerangkatWifiState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,perangkat: null == perangkat ? _self._perangkat : perangkat // ignore: cast_nullable_to_non_nullable
as List<PerangkatWifiModel>,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
