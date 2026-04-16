// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mk_video_preload_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MkVideoPreloadState<T> implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MkVideoPreloadState<$T>'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MkVideoPreloadState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MkVideoPreloadState<$T>()';
}


}

/// @nodoc
class $MkVideoPreloadStateCopyWith<T,$Res>  {
$MkVideoPreloadStateCopyWith(MkVideoPreloadState<T> _, $Res Function(MkVideoPreloadState<T>) __);
}


/// Adds pattern-matching-related methods to [MkVideoPreloadState].
extension MkVideoPreloadStatePatterns<T> on MkVideoPreloadState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _MkInitial<T> value)?  initial,TResult Function( _MkLoading<T> value)?  loading,TResult Function( _MkReady<T> value)?  ready,TResult Function( _MkError<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MkInitial() when initial != null:
return initial(_that);case _MkLoading() when loading != null:
return loading(_that);case _MkReady() when ready != null:
return ready(_that);case _MkError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _MkInitial<T> value)  initial,required TResult Function( _MkLoading<T> value)  loading,required TResult Function( _MkReady<T> value)  ready,required TResult Function( _MkError<T> value)  error,}){
final _that = this;
switch (_that) {
case _MkInitial():
return initial(_that);case _MkLoading():
return loading(_that);case _MkReady():
return ready(_that);case _MkError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _MkInitial<T> value)?  initial,TResult? Function( _MkLoading<T> value)?  loading,TResult? Function( _MkReady<T> value)?  ready,TResult? Function( _MkError<T> value)?  error,}){
final _that = this;
switch (_that) {
case _MkInitial() when initial != null:
return initial(_that);case _MkLoading() when loading != null:
return loading(_that);case _MkReady() when ready != null:
return ready(_that);case _MkError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( int currentIndex)?  loading,TResult Function( int currentIndex,  String currentItemId,  Map<String, Player> players,  Map<String, VideoController> controllers,  List<MkVideoItem<T>> items,  bool isPlaying,  bool isMuted,  bool isExpanded)?  ready,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MkInitial() when initial != null:
return initial();case _MkLoading() when loading != null:
return loading(_that.currentIndex);case _MkReady() when ready != null:
return ready(_that.currentIndex,_that.currentItemId,_that.players,_that.controllers,_that.items,_that.isPlaying,_that.isMuted,_that.isExpanded);case _MkError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( int currentIndex)  loading,required TResult Function( int currentIndex,  String currentItemId,  Map<String, Player> players,  Map<String, VideoController> controllers,  List<MkVideoItem<T>> items,  bool isPlaying,  bool isMuted,  bool isExpanded)  ready,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _MkInitial():
return initial();case _MkLoading():
return loading(_that.currentIndex);case _MkReady():
return ready(_that.currentIndex,_that.currentItemId,_that.players,_that.controllers,_that.items,_that.isPlaying,_that.isMuted,_that.isExpanded);case _MkError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( int currentIndex)?  loading,TResult? Function( int currentIndex,  String currentItemId,  Map<String, Player> players,  Map<String, VideoController> controllers,  List<MkVideoItem<T>> items,  bool isPlaying,  bool isMuted,  bool isExpanded)?  ready,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _MkInitial() when initial != null:
return initial();case _MkLoading() when loading != null:
return loading(_that.currentIndex);case _MkReady() when ready != null:
return ready(_that.currentIndex,_that.currentItemId,_that.players,_that.controllers,_that.items,_that.isPlaying,_that.isMuted,_that.isExpanded);case _MkError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _MkInitial<T> with DiagnosticableTreeMixin implements MkVideoPreloadState<T> {
  const _MkInitial();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MkVideoPreloadState<$T>.initial'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MkInitial<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MkVideoPreloadState<$T>.initial()';
}


}




/// @nodoc


class _MkLoading<T> with DiagnosticableTreeMixin implements MkVideoPreloadState<T> {
  const _MkLoading({required this.currentIndex});
  

 final  int currentIndex;

/// Create a copy of MkVideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MkLoadingCopyWith<T, _MkLoading<T>> get copyWith => __$MkLoadingCopyWithImpl<T, _MkLoading<T>>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MkVideoPreloadState<$T>.loading'))
    ..add(DiagnosticsProperty('currentIndex', currentIndex));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MkLoading<T>&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,currentIndex);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MkVideoPreloadState<$T>.loading(currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class _$MkLoadingCopyWith<T,$Res> implements $MkVideoPreloadStateCopyWith<T, $Res> {
  factory _$MkLoadingCopyWith(_MkLoading<T> value, $Res Function(_MkLoading<T>) _then) = __$MkLoadingCopyWithImpl;
@useResult
$Res call({
 int currentIndex
});




}
/// @nodoc
class __$MkLoadingCopyWithImpl<T,$Res>
    implements _$MkLoadingCopyWith<T, $Res> {
  __$MkLoadingCopyWithImpl(this._self, this._then);

  final _MkLoading<T> _self;
  final $Res Function(_MkLoading<T>) _then;

/// Create a copy of MkVideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentIndex = null,}) {
  return _then(_MkLoading<T>(
currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _MkReady<T> with DiagnosticableTreeMixin implements MkVideoPreloadState<T> {
  const _MkReady({required this.currentIndex, required this.currentItemId, required final  Map<String, Player> players, required final  Map<String, VideoController> controllers, required final  List<MkVideoItem<T>> items, this.isPlaying = true, this.isMuted = false, this.isExpanded = true}): _players = players,_controllers = controllers,_items = items;
  

 final  int currentIndex;
 final  String currentItemId;
/// Active media_kit [Player] instances keyed by item ID.
 final  Map<String, Player> _players;
/// Active media_kit [Player] instances keyed by item ID.
 Map<String, Player> get players {
  if (_players is EqualUnmodifiableMapView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_players);
}

/// [VideoController] instances for rendering — keyed by item ID.
 final  Map<String, VideoController> _controllers;
/// [VideoController] instances for rendering — keyed by item ID.
 Map<String, VideoController> get controllers {
  if (_controllers is EqualUnmodifiableMapView) return _controllers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_controllers);
}

 final  List<MkVideoItem<T>> _items;
 List<MkVideoItem<T>> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@JsonKey() final  bool isPlaying;
@JsonKey() final  bool isMuted;
@JsonKey() final  bool isExpanded;

/// Create a copy of MkVideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MkReadyCopyWith<T, _MkReady<T>> get copyWith => __$MkReadyCopyWithImpl<T, _MkReady<T>>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MkVideoPreloadState<$T>.ready'))
    ..add(DiagnosticsProperty('currentIndex', currentIndex))..add(DiagnosticsProperty('currentItemId', currentItemId))..add(DiagnosticsProperty('players', players))..add(DiagnosticsProperty('controllers', controllers))..add(DiagnosticsProperty('items', items))..add(DiagnosticsProperty('isPlaying', isPlaying))..add(DiagnosticsProperty('isMuted', isMuted))..add(DiagnosticsProperty('isExpanded', isExpanded));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MkReady<T>&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.currentItemId, currentItemId) || other.currentItemId == currentItemId)&&const DeepCollectionEquality().equals(other._players, _players)&&const DeepCollectionEquality().equals(other._controllers, _controllers)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isExpanded, isExpanded) || other.isExpanded == isExpanded));
}


@override
int get hashCode => Object.hash(runtimeType,currentIndex,currentItemId,const DeepCollectionEquality().hash(_players),const DeepCollectionEquality().hash(_controllers),const DeepCollectionEquality().hash(_items),isPlaying,isMuted,isExpanded);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MkVideoPreloadState<$T>.ready(currentIndex: $currentIndex, currentItemId: $currentItemId, players: $players, controllers: $controllers, items: $items, isPlaying: $isPlaying, isMuted: $isMuted, isExpanded: $isExpanded)';
}


}

/// @nodoc
abstract mixin class _$MkReadyCopyWith<T,$Res> implements $MkVideoPreloadStateCopyWith<T, $Res> {
  factory _$MkReadyCopyWith(_MkReady<T> value, $Res Function(_MkReady<T>) _then) = __$MkReadyCopyWithImpl;
@useResult
$Res call({
 int currentIndex, String currentItemId, Map<String, Player> players, Map<String, VideoController> controllers, List<MkVideoItem<T>> items, bool isPlaying, bool isMuted, bool isExpanded
});




}
/// @nodoc
class __$MkReadyCopyWithImpl<T,$Res>
    implements _$MkReadyCopyWith<T, $Res> {
  __$MkReadyCopyWithImpl(this._self, this._then);

  final _MkReady<T> _self;
  final $Res Function(_MkReady<T>) _then;

/// Create a copy of MkVideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentIndex = null,Object? currentItemId = null,Object? players = null,Object? controllers = null,Object? items = null,Object? isPlaying = null,Object? isMuted = null,Object? isExpanded = null,}) {
  return _then(_MkReady<T>(
currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,currentItemId: null == currentItemId ? _self.currentItemId : currentItemId // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as Map<String, Player>,controllers: null == controllers ? _self._controllers : controllers // ignore: cast_nullable_to_non_nullable
as Map<String, VideoController>,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MkVideoItem<T>>,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isExpanded: null == isExpanded ? _self.isExpanded : isExpanded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _MkError<T> with DiagnosticableTreeMixin implements MkVideoPreloadState<T> {
  const _MkError(this.message);
  

 final  String message;

/// Create a copy of MkVideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MkErrorCopyWith<T, _MkError<T>> get copyWith => __$MkErrorCopyWithImpl<T, _MkError<T>>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MkVideoPreloadState<$T>.error'))
    ..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MkError<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MkVideoPreloadState<$T>.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$MkErrorCopyWith<T,$Res> implements $MkVideoPreloadStateCopyWith<T, $Res> {
  factory _$MkErrorCopyWith(_MkError<T> value, $Res Function(_MkError<T>) _then) = __$MkErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$MkErrorCopyWithImpl<T,$Res>
    implements _$MkErrorCopyWith<T, $Res> {
  __$MkErrorCopyWithImpl(this._self, this._then);

  final _MkError<T> _self;
  final $Res Function(_MkError<T>) _then;

/// Create a copy of MkVideoPreloadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_MkError<T>(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
