// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_preload_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoPreloadState<T> implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'VideoPreloadState<$T>'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoPreloadState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'VideoPreloadState<$T>()';
}


}

/// @nodoc
class $VideoPreloadStateCopyWith<T,$Res>  {
$VideoPreloadStateCopyWith(VideoPreloadState<T> _, $Res Function(VideoPreloadState<T>) __);
}


/// Adds pattern-matching-related methods to [VideoPreloadState].
extension VideoPreloadStatePatterns<T> on VideoPreloadState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial<T> value)?  initial,TResult Function( _Loading<T> value)?  loading,TResult Function( _Ready<T> value)?  ready,TResult Function( _Error<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Ready() when ready != null:
return ready(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial<T> value)  initial,required TResult Function( _Loading<T> value)  loading,required TResult Function( _Ready<T> value)  ready,required TResult Function( _Error<T> value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Ready():
return ready(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial<T> value)?  initial,TResult? Function( _Loading<T> value)?  loading,TResult? Function( _Ready<T> value)?  ready,TResult? Function( _Error<T> value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Ready() when ready != null:
return ready(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( int currentIndex)?  loading,TResult Function( int currentIndex,  String currentItemId,  Map<String, VideoPlayerController> controllers,  List<VideoItem<T>> items,  bool isPlaying,  bool isMuted,  bool isExpanded)?  ready,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading(_that.currentIndex);case _Ready() when ready != null:
return ready(_that.currentIndex,_that.currentItemId,_that.controllers,_that.items,_that.isPlaying,_that.isMuted,_that.isExpanded);case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( int currentIndex)  loading,required TResult Function( int currentIndex,  String currentItemId,  Map<String, VideoPlayerController> controllers,  List<VideoItem<T>> items,  bool isPlaying,  bool isMuted,  bool isExpanded)  ready,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading(_that.currentIndex);case _Ready():
return ready(_that.currentIndex,_that.currentItemId,_that.controllers,_that.items,_that.isPlaying,_that.isMuted,_that.isExpanded);case _Error():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( int currentIndex)?  loading,TResult? Function( int currentIndex,  String currentItemId,  Map<String, VideoPlayerController> controllers,  List<VideoItem<T>> items,  bool isPlaying,  bool isMuted,  bool isExpanded)?  ready,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading(_that.currentIndex);case _Ready() when ready != null:
return ready(_that.currentIndex,_that.currentItemId,_that.controllers,_that.items,_that.isPlaying,_that.isMuted,_that.isExpanded);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial<T> with DiagnosticableTreeMixin implements VideoPreloadState<T> {
  const _Initial();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'VideoPreloadState<$T>.initial'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'VideoPreloadState<$T>.initial()';
}


}




/// @nodoc


class _Loading<T> with DiagnosticableTreeMixin implements VideoPreloadState<T> {
  const _Loading({required this.currentIndex});
  

 final  int currentIndex;

/// Create a copy of VideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadingCopyWith<T, _Loading<T>> get copyWith => __$LoadingCopyWithImpl<T, _Loading<T>>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'VideoPreloadState<$T>.loading'))
    ..add(DiagnosticsProperty('currentIndex', currentIndex));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading<T>&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,currentIndex);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'VideoPreloadState<$T>.loading(currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class _$LoadingCopyWith<T,$Res> implements $VideoPreloadStateCopyWith<T, $Res> {
  factory _$LoadingCopyWith(_Loading<T> value, $Res Function(_Loading<T>) _then) = __$LoadingCopyWithImpl;
@useResult
$Res call({
 int currentIndex
});




}
/// @nodoc
class __$LoadingCopyWithImpl<T,$Res>
    implements _$LoadingCopyWith<T, $Res> {
  __$LoadingCopyWithImpl(this._self, this._then);

  final _Loading<T> _self;
  final $Res Function(_Loading<T>) _then;

/// Create a copy of VideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentIndex = null,}) {
  return _then(_Loading<T>(
currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Ready<T> with DiagnosticableTreeMixin implements VideoPreloadState<T> {
  const _Ready({required this.currentIndex, required this.currentItemId, required final  Map<String, VideoPlayerController> controllers, required final  List<VideoItem<T>> items, this.isPlaying = true, this.isMuted = false, this.isExpanded = true}): _controllers = controllers,_items = items;
  

 final  int currentIndex;
 final  String currentItemId;
 final  Map<String, VideoPlayerController> _controllers;
 Map<String, VideoPlayerController> get controllers {
  if (_controllers is EqualUnmodifiableMapView) return _controllers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_controllers);
}

 final  List<VideoItem<T>> _items;
 List<VideoItem<T>> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@JsonKey() final  bool isPlaying;
@JsonKey() final  bool isMuted;
@JsonKey() final  bool isExpanded;

/// Create a copy of VideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadyCopyWith<T, _Ready<T>> get copyWith => __$ReadyCopyWithImpl<T, _Ready<T>>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'VideoPreloadState<$T>.ready'))
    ..add(DiagnosticsProperty('currentIndex', currentIndex))..add(DiagnosticsProperty('currentItemId', currentItemId))..add(DiagnosticsProperty('controllers', controllers))..add(DiagnosticsProperty('items', items))..add(DiagnosticsProperty('isPlaying', isPlaying))..add(DiagnosticsProperty('isMuted', isMuted))..add(DiagnosticsProperty('isExpanded', isExpanded));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ready<T>&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.currentItemId, currentItemId) || other.currentItemId == currentItemId)&&const DeepCollectionEquality().equals(other._controllers, _controllers)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isExpanded, isExpanded) || other.isExpanded == isExpanded));
}


@override
int get hashCode => Object.hash(runtimeType,currentIndex,currentItemId,const DeepCollectionEquality().hash(_controllers),const DeepCollectionEquality().hash(_items),isPlaying,isMuted,isExpanded);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'VideoPreloadState<$T>.ready(currentIndex: $currentIndex, currentItemId: $currentItemId, controllers: $controllers, items: $items, isPlaying: $isPlaying, isMuted: $isMuted, isExpanded: $isExpanded)';
}


}

/// @nodoc
abstract mixin class _$ReadyCopyWith<T,$Res> implements $VideoPreloadStateCopyWith<T, $Res> {
  factory _$ReadyCopyWith(_Ready<T> value, $Res Function(_Ready<T>) _then) = __$ReadyCopyWithImpl;
@useResult
$Res call({
 int currentIndex, String currentItemId, Map<String, VideoPlayerController> controllers, List<VideoItem<T>> items, bool isPlaying, bool isMuted, bool isExpanded
});




}
/// @nodoc
class __$ReadyCopyWithImpl<T,$Res>
    implements _$ReadyCopyWith<T, $Res> {
  __$ReadyCopyWithImpl(this._self, this._then);

  final _Ready<T> _self;
  final $Res Function(_Ready<T>) _then;

/// Create a copy of VideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentIndex = null,Object? currentItemId = null,Object? controllers = null,Object? items = null,Object? isPlaying = null,Object? isMuted = null,Object? isExpanded = null,}) {
  return _then(_Ready<T>(
currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,currentItemId: null == currentItemId ? _self.currentItemId : currentItemId // ignore: cast_nullable_to_non_nullable
as String,controllers: null == controllers ? _self._controllers : controllers // ignore: cast_nullable_to_non_nullable
as Map<String, VideoPlayerController>,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<VideoItem<T>>,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isExpanded: null == isExpanded ? _self.isExpanded : isExpanded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _Error<T> with DiagnosticableTreeMixin implements VideoPreloadState<T> {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of VideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<T, _Error<T>> get copyWith => __$ErrorCopyWithImpl<T, _Error<T>>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'VideoPreloadState<$T>.error'))
    ..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'VideoPreloadState<$T>.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<T,$Res> implements $VideoPreloadStateCopyWith<T, $Res> {
  factory _$ErrorCopyWith(_Error<T> value, $Res Function(_Error<T>) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<T,$Res>
    implements _$ErrorCopyWith<T, $Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error<T> _self;
  final $Res Function(_Error<T>) _then;

/// Create a copy of VideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error<T>(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
