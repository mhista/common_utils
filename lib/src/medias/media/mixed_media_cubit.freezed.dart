// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mixed_media_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MixedMediaState<T> {

 List<MediaItem<T>> get items; Set<int> get preloadedIndices; bool get isLoading; String? get error;
/// Create a copy of MixedMediaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MixedMediaStateCopyWith<T, MixedMediaState<T>> get copyWith => _$MixedMediaStateCopyWithImpl<T, MixedMediaState<T>>(this as MixedMediaState<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MixedMediaState<T>&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.preloadedIndices, preloadedIndices)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(preloadedIndices),isLoading,error);

@override
String toString() {
  return 'MixedMediaState<$T>(items: $items, preloadedIndices: $preloadedIndices, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $MixedMediaStateCopyWith<T,$Res>  {
  factory $MixedMediaStateCopyWith(MixedMediaState<T> value, $Res Function(MixedMediaState<T>) _then) = _$MixedMediaStateCopyWithImpl;
@useResult
$Res call({
 List<MediaItem<T>> items, Set<int> preloadedIndices, bool isLoading, String? error
});




}
/// @nodoc
class _$MixedMediaStateCopyWithImpl<T,$Res>
    implements $MixedMediaStateCopyWith<T, $Res> {
  _$MixedMediaStateCopyWithImpl(this._self, this._then);

  final MixedMediaState<T> _self;
  final $Res Function(MixedMediaState<T>) _then;

/// Create a copy of MixedMediaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? preloadedIndices = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MediaItem<T>>,preloadedIndices: null == preloadedIndices ? _self.preloadedIndices : preloadedIndices // ignore: cast_nullable_to_non_nullable
as Set<int>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MixedMediaState].
extension MixedMediaStatePatterns<T> on MixedMediaState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MixedMediaState<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MixedMediaState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MixedMediaState<T> value)  $default,){
final _that = this;
switch (_that) {
case _MixedMediaState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MixedMediaState<T> value)?  $default,){
final _that = this;
switch (_that) {
case _MixedMediaState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MediaItem<T>> items,  Set<int> preloadedIndices,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MixedMediaState() when $default != null:
return $default(_that.items,_that.preloadedIndices,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MediaItem<T>> items,  Set<int> preloadedIndices,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _MixedMediaState():
return $default(_that.items,_that.preloadedIndices,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MediaItem<T>> items,  Set<int> preloadedIndices,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _MixedMediaState() when $default != null:
return $default(_that.items,_that.preloadedIndices,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _MixedMediaState<T> implements MixedMediaState<T> {
  const _MixedMediaState({final  List<MediaItem<T>> items = const [], final  Set<int> preloadedIndices = const {}, this.isLoading = false, this.error}): _items = items,_preloadedIndices = preloadedIndices;
  

 final  List<MediaItem<T>> _items;
@override@JsonKey() List<MediaItem<T>> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  Set<int> _preloadedIndices;
@override@JsonKey() Set<int> get preloadedIndices {
  if (_preloadedIndices is EqualUnmodifiableSetView) return _preloadedIndices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_preloadedIndices);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of MixedMediaState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MixedMediaStateCopyWith<T, _MixedMediaState<T>> get copyWith => __$MixedMediaStateCopyWithImpl<T, _MixedMediaState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MixedMediaState<T>&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._preloadedIndices, _preloadedIndices)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_preloadedIndices),isLoading,error);

@override
String toString() {
  return 'MixedMediaState<$T>(items: $items, preloadedIndices: $preloadedIndices, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$MixedMediaStateCopyWith<T,$Res> implements $MixedMediaStateCopyWith<T, $Res> {
  factory _$MixedMediaStateCopyWith(_MixedMediaState<T> value, $Res Function(_MixedMediaState<T>) _then) = __$MixedMediaStateCopyWithImpl;
@override @useResult
$Res call({
 List<MediaItem<T>> items, Set<int> preloadedIndices, bool isLoading, String? error
});




}
/// @nodoc
class __$MixedMediaStateCopyWithImpl<T,$Res>
    implements _$MixedMediaStateCopyWith<T, $Res> {
  __$MixedMediaStateCopyWithImpl(this._self, this._then);

  final _MixedMediaState<T> _self;
  final $Res Function(_MixedMediaState<T>) _then;

/// Create a copy of MixedMediaState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? preloadedIndices = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_MixedMediaState<T>(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MediaItem<T>>,preloadedIndices: null == preloadedIndices ? _self._preloadedIndices : preloadedIndices // ignore: cast_nullable_to_non_nullable
as Set<int>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
