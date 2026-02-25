// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lazy_video_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LazyVideoState implements DiagnosticableTreeMixin {

/// Map of video ID to controller
 Map<String, VideoPlayerController> get controllers;/// Videos currently in viewport
 Set<String> get visibleVideos;/// Videos that should be playing
 Set<String> get playingVideos;/// Global mute state
 bool get isMuted;
/// Create a copy of LazyVideoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LazyVideoStateCopyWith<LazyVideoState> get copyWith => _$LazyVideoStateCopyWithImpl<LazyVideoState>(this as LazyVideoState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'LazyVideoState'))
    ..add(DiagnosticsProperty('controllers', controllers))..add(DiagnosticsProperty('visibleVideos', visibleVideos))..add(DiagnosticsProperty('playingVideos', playingVideos))..add(DiagnosticsProperty('isMuted', isMuted));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LazyVideoState&&const DeepCollectionEquality().equals(other.controllers, controllers)&&const DeepCollectionEquality().equals(other.visibleVideos, visibleVideos)&&const DeepCollectionEquality().equals(other.playingVideos, playingVideos)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(controllers),const DeepCollectionEquality().hash(visibleVideos),const DeepCollectionEquality().hash(playingVideos),isMuted);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'LazyVideoState(controllers: $controllers, visibleVideos: $visibleVideos, playingVideos: $playingVideos, isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class $LazyVideoStateCopyWith<$Res>  {
  factory $LazyVideoStateCopyWith(LazyVideoState value, $Res Function(LazyVideoState) _then) = _$LazyVideoStateCopyWithImpl;
@useResult
$Res call({
 Map<String, VideoPlayerController> controllers, Set<String> visibleVideos, Set<String> playingVideos, bool isMuted
});




}
/// @nodoc
class _$LazyVideoStateCopyWithImpl<$Res>
    implements $LazyVideoStateCopyWith<$Res> {
  _$LazyVideoStateCopyWithImpl(this._self, this._then);

  final LazyVideoState _self;
  final $Res Function(LazyVideoState) _then;

/// Create a copy of LazyVideoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? controllers = null,Object? visibleVideos = null,Object? playingVideos = null,Object? isMuted = null,}) {
  return _then(_self.copyWith(
controllers: null == controllers ? _self.controllers : controllers // ignore: cast_nullable_to_non_nullable
as Map<String, VideoPlayerController>,visibleVideos: null == visibleVideos ? _self.visibleVideos : visibleVideos // ignore: cast_nullable_to_non_nullable
as Set<String>,playingVideos: null == playingVideos ? _self.playingVideos : playingVideos // ignore: cast_nullable_to_non_nullable
as Set<String>,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LazyVideoState].
extension LazyVideoStatePatterns on LazyVideoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LazyVideoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LazyVideoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LazyVideoState value)  $default,){
final _that = this;
switch (_that) {
case _LazyVideoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LazyVideoState value)?  $default,){
final _that = this;
switch (_that) {
case _LazyVideoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, VideoPlayerController> controllers,  Set<String> visibleVideos,  Set<String> playingVideos,  bool isMuted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LazyVideoState() when $default != null:
return $default(_that.controllers,_that.visibleVideos,_that.playingVideos,_that.isMuted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, VideoPlayerController> controllers,  Set<String> visibleVideos,  Set<String> playingVideos,  bool isMuted)  $default,) {final _that = this;
switch (_that) {
case _LazyVideoState():
return $default(_that.controllers,_that.visibleVideos,_that.playingVideos,_that.isMuted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, VideoPlayerController> controllers,  Set<String> visibleVideos,  Set<String> playingVideos,  bool isMuted)?  $default,) {final _that = this;
switch (_that) {
case _LazyVideoState() when $default != null:
return $default(_that.controllers,_that.visibleVideos,_that.playingVideos,_that.isMuted);case _:
  return null;

}
}

}

/// @nodoc


class _LazyVideoState with DiagnosticableTreeMixin implements LazyVideoState {
  const _LazyVideoState({final  Map<String, VideoPlayerController> controllers = const {}, final  Set<String> visibleVideos = const {}, final  Set<String> playingVideos = const {}, this.isMuted = false}): _controllers = controllers,_visibleVideos = visibleVideos,_playingVideos = playingVideos;
  

/// Map of video ID to controller
 final  Map<String, VideoPlayerController> _controllers;
/// Map of video ID to controller
@override@JsonKey() Map<String, VideoPlayerController> get controllers {
  if (_controllers is EqualUnmodifiableMapView) return _controllers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_controllers);
}

/// Videos currently in viewport
 final  Set<String> _visibleVideos;
/// Videos currently in viewport
@override@JsonKey() Set<String> get visibleVideos {
  if (_visibleVideos is EqualUnmodifiableSetView) return _visibleVideos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_visibleVideos);
}

/// Videos that should be playing
 final  Set<String> _playingVideos;
/// Videos that should be playing
@override@JsonKey() Set<String> get playingVideos {
  if (_playingVideos is EqualUnmodifiableSetView) return _playingVideos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_playingVideos);
}

/// Global mute state
@override@JsonKey() final  bool isMuted;

/// Create a copy of LazyVideoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LazyVideoStateCopyWith<_LazyVideoState> get copyWith => __$LazyVideoStateCopyWithImpl<_LazyVideoState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'LazyVideoState'))
    ..add(DiagnosticsProperty('controllers', controllers))..add(DiagnosticsProperty('visibleVideos', visibleVideos))..add(DiagnosticsProperty('playingVideos', playingVideos))..add(DiagnosticsProperty('isMuted', isMuted));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LazyVideoState&&const DeepCollectionEquality().equals(other._controllers, _controllers)&&const DeepCollectionEquality().equals(other._visibleVideos, _visibleVideos)&&const DeepCollectionEquality().equals(other._playingVideos, _playingVideos)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_controllers),const DeepCollectionEquality().hash(_visibleVideos),const DeepCollectionEquality().hash(_playingVideos),isMuted);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'LazyVideoState(controllers: $controllers, visibleVideos: $visibleVideos, playingVideos: $playingVideos, isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class _$LazyVideoStateCopyWith<$Res> implements $LazyVideoStateCopyWith<$Res> {
  factory _$LazyVideoStateCopyWith(_LazyVideoState value, $Res Function(_LazyVideoState) _then) = __$LazyVideoStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, VideoPlayerController> controllers, Set<String> visibleVideos, Set<String> playingVideos, bool isMuted
});




}
/// @nodoc
class __$LazyVideoStateCopyWithImpl<$Res>
    implements _$LazyVideoStateCopyWith<$Res> {
  __$LazyVideoStateCopyWithImpl(this._self, this._then);

  final _LazyVideoState _self;
  final $Res Function(_LazyVideoState) _then;

/// Create a copy of LazyVideoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? controllers = null,Object? visibleVideos = null,Object? playingVideos = null,Object? isMuted = null,}) {
  return _then(_LazyVideoState(
controllers: null == controllers ? _self._controllers : controllers // ignore: cast_nullable_to_non_nullable
as Map<String, VideoPlayerController>,visibleVideos: null == visibleVideos ? _self._visibleVideos : visibleVideos // ignore: cast_nullable_to_non_nullable
as Set<String>,playingVideos: null == playingVideos ? _self._playingVideos : playingVideos // ignore: cast_nullable_to_non_nullable
as Set<String>,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
