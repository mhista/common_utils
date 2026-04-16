// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mk_lazy_video_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MkLazyVideoState implements DiagnosticableTreeMixin {

/// Map of video ID → media_kit [Player] instance.
 Map<String, Player> get players;/// Map of video ID → [VideoController] for rendering via [Video] widget.
 Map<String, VideoController> get controllers;/// IDs of videos whose player is currently playing.
 Set<String> get playingVideos;/// IDs of videos currently in the viewport (fraction > threshold).
 Set<String> get visibleVideos;/// Global mute state — applied to all players.
 bool get isMuted;
/// Create a copy of MkLazyVideoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MkLazyVideoStateCopyWith<MkLazyVideoState> get copyWith => _$MkLazyVideoStateCopyWithImpl<MkLazyVideoState>(this as MkLazyVideoState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MkLazyVideoState'))
    ..add(DiagnosticsProperty('players', players))..add(DiagnosticsProperty('controllers', controllers))..add(DiagnosticsProperty('playingVideos', playingVideos))..add(DiagnosticsProperty('visibleVideos', visibleVideos))..add(DiagnosticsProperty('isMuted', isMuted));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MkLazyVideoState&&const DeepCollectionEquality().equals(other.players, players)&&const DeepCollectionEquality().equals(other.controllers, controllers)&&const DeepCollectionEquality().equals(other.playingVideos, playingVideos)&&const DeepCollectionEquality().equals(other.visibleVideos, visibleVideos)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(players),const DeepCollectionEquality().hash(controllers),const DeepCollectionEquality().hash(playingVideos),const DeepCollectionEquality().hash(visibleVideos),isMuted);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MkLazyVideoState(players: $players, controllers: $controllers, playingVideos: $playingVideos, visibleVideos: $visibleVideos, isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class $MkLazyVideoStateCopyWith<$Res>  {
  factory $MkLazyVideoStateCopyWith(MkLazyVideoState value, $Res Function(MkLazyVideoState) _then) = _$MkLazyVideoStateCopyWithImpl;
@useResult
$Res call({
 Map<String, Player> players, Map<String, VideoController> controllers, Set<String> playingVideos, Set<String> visibleVideos, bool isMuted
});




}
/// @nodoc
class _$MkLazyVideoStateCopyWithImpl<$Res>
    implements $MkLazyVideoStateCopyWith<$Res> {
  _$MkLazyVideoStateCopyWithImpl(this._self, this._then);

  final MkLazyVideoState _self;
  final $Res Function(MkLazyVideoState) _then;

/// Create a copy of MkLazyVideoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? players = null,Object? controllers = null,Object? playingVideos = null,Object? visibleVideos = null,Object? isMuted = null,}) {
  return _then(_self.copyWith(
players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as Map<String, Player>,controllers: null == controllers ? _self.controllers : controllers // ignore: cast_nullable_to_non_nullable
as Map<String, VideoController>,playingVideos: null == playingVideos ? _self.playingVideos : playingVideos // ignore: cast_nullable_to_non_nullable
as Set<String>,visibleVideos: null == visibleVideos ? _self.visibleVideos : visibleVideos // ignore: cast_nullable_to_non_nullable
as Set<String>,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MkLazyVideoState].
extension MkLazyVideoStatePatterns on MkLazyVideoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MkLazyVideoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MkLazyVideoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MkLazyVideoState value)  $default,){
final _that = this;
switch (_that) {
case _MkLazyVideoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MkLazyVideoState value)?  $default,){
final _that = this;
switch (_that) {
case _MkLazyVideoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, Player> players,  Map<String, VideoController> controllers,  Set<String> playingVideos,  Set<String> visibleVideos,  bool isMuted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MkLazyVideoState() when $default != null:
return $default(_that.players,_that.controllers,_that.playingVideos,_that.visibleVideos,_that.isMuted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, Player> players,  Map<String, VideoController> controllers,  Set<String> playingVideos,  Set<String> visibleVideos,  bool isMuted)  $default,) {final _that = this;
switch (_that) {
case _MkLazyVideoState():
return $default(_that.players,_that.controllers,_that.playingVideos,_that.visibleVideos,_that.isMuted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, Player> players,  Map<String, VideoController> controllers,  Set<String> playingVideos,  Set<String> visibleVideos,  bool isMuted)?  $default,) {final _that = this;
switch (_that) {
case _MkLazyVideoState() when $default != null:
return $default(_that.players,_that.controllers,_that.playingVideos,_that.visibleVideos,_that.isMuted);case _:
  return null;

}
}

}

/// @nodoc


class _MkLazyVideoState with DiagnosticableTreeMixin implements MkLazyVideoState {
  const _MkLazyVideoState({final  Map<String, Player> players = const {}, final  Map<String, VideoController> controllers = const {}, final  Set<String> playingVideos = const {}, final  Set<String> visibleVideos = const {}, this.isMuted = false}): _players = players,_controllers = controllers,_playingVideos = playingVideos,_visibleVideos = visibleVideos;
  

/// Map of video ID → media_kit [Player] instance.
 final  Map<String, Player> _players;
/// Map of video ID → media_kit [Player] instance.
@override@JsonKey() Map<String, Player> get players {
  if (_players is EqualUnmodifiableMapView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_players);
}

/// Map of video ID → [VideoController] for rendering via [Video] widget.
 final  Map<String, VideoController> _controllers;
/// Map of video ID → [VideoController] for rendering via [Video] widget.
@override@JsonKey() Map<String, VideoController> get controllers {
  if (_controllers is EqualUnmodifiableMapView) return _controllers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_controllers);
}

/// IDs of videos whose player is currently playing.
 final  Set<String> _playingVideos;
/// IDs of videos whose player is currently playing.
@override@JsonKey() Set<String> get playingVideos {
  if (_playingVideos is EqualUnmodifiableSetView) return _playingVideos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_playingVideos);
}

/// IDs of videos currently in the viewport (fraction > threshold).
 final  Set<String> _visibleVideos;
/// IDs of videos currently in the viewport (fraction > threshold).
@override@JsonKey() Set<String> get visibleVideos {
  if (_visibleVideos is EqualUnmodifiableSetView) return _visibleVideos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_visibleVideos);
}

/// Global mute state — applied to all players.
@override@JsonKey() final  bool isMuted;

/// Create a copy of MkLazyVideoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MkLazyVideoStateCopyWith<_MkLazyVideoState> get copyWith => __$MkLazyVideoStateCopyWithImpl<_MkLazyVideoState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MkLazyVideoState'))
    ..add(DiagnosticsProperty('players', players))..add(DiagnosticsProperty('controllers', controllers))..add(DiagnosticsProperty('playingVideos', playingVideos))..add(DiagnosticsProperty('visibleVideos', visibleVideos))..add(DiagnosticsProperty('isMuted', isMuted));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MkLazyVideoState&&const DeepCollectionEquality().equals(other._players, _players)&&const DeepCollectionEquality().equals(other._controllers, _controllers)&&const DeepCollectionEquality().equals(other._playingVideos, _playingVideos)&&const DeepCollectionEquality().equals(other._visibleVideos, _visibleVideos)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_players),const DeepCollectionEquality().hash(_controllers),const DeepCollectionEquality().hash(_playingVideos),const DeepCollectionEquality().hash(_visibleVideos),isMuted);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MkLazyVideoState(players: $players, controllers: $controllers, playingVideos: $playingVideos, visibleVideos: $visibleVideos, isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class _$MkLazyVideoStateCopyWith<$Res> implements $MkLazyVideoStateCopyWith<$Res> {
  factory _$MkLazyVideoStateCopyWith(_MkLazyVideoState value, $Res Function(_MkLazyVideoState) _then) = __$MkLazyVideoStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, Player> players, Map<String, VideoController> controllers, Set<String> playingVideos, Set<String> visibleVideos, bool isMuted
});




}
/// @nodoc
class __$MkLazyVideoStateCopyWithImpl<$Res>
    implements _$MkLazyVideoStateCopyWith<$Res> {
  __$MkLazyVideoStateCopyWithImpl(this._self, this._then);

  final _MkLazyVideoState _self;
  final $Res Function(_MkLazyVideoState) _then;

/// Create a copy of MkLazyVideoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? players = null,Object? controllers = null,Object? playingVideos = null,Object? visibleVideos = null,Object? isMuted = null,}) {
  return _then(_MkLazyVideoState(
players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as Map<String, Player>,controllers: null == controllers ? _self._controllers : controllers // ignore: cast_nullable_to_non_nullable
as Map<String, VideoController>,playingVideos: null == playingVideos ? _self._playingVideos : playingVideos // ignore: cast_nullable_to_non_nullable
as Set<String>,visibleVideos: null == visibleVideos ? _self._visibleVideos : visibleVideos // ignore: cast_nullable_to_non_nullable
as Set<String>,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
