// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadState implements DiagnosticableTreeMixin {

 Map<String, DownloadItem> get downloads; List<String> get queue;// IDs in queue order
 int get maxConcurrent;
/// Create a copy of DownloadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadStateCopyWith<DownloadState> get copyWith => _$DownloadStateCopyWithImpl<DownloadState>(this as DownloadState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DownloadState'))
    ..add(DiagnosticsProperty('downloads', downloads))..add(DiagnosticsProperty('queue', queue))..add(DiagnosticsProperty('maxConcurrent', maxConcurrent));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadState&&const DeepCollectionEquality().equals(other.downloads, downloads)&&const DeepCollectionEquality().equals(other.queue, queue)&&(identical(other.maxConcurrent, maxConcurrent) || other.maxConcurrent == maxConcurrent));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(downloads),const DeepCollectionEquality().hash(queue),maxConcurrent);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DownloadState(downloads: $downloads, queue: $queue, maxConcurrent: $maxConcurrent)';
}


}

/// @nodoc
abstract mixin class $DownloadStateCopyWith<$Res>  {
  factory $DownloadStateCopyWith(DownloadState value, $Res Function(DownloadState) _then) = _$DownloadStateCopyWithImpl;
@useResult
$Res call({
 Map<String, DownloadItem> downloads, List<String> queue, int maxConcurrent
});




}
/// @nodoc
class _$DownloadStateCopyWithImpl<$Res>
    implements $DownloadStateCopyWith<$Res> {
  _$DownloadStateCopyWithImpl(this._self, this._then);

  final DownloadState _self;
  final $Res Function(DownloadState) _then;

/// Create a copy of DownloadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? downloads = null,Object? queue = null,Object? maxConcurrent = null,}) {
  return _then(_self.copyWith(
downloads: null == downloads ? _self.downloads : downloads // ignore: cast_nullable_to_non_nullable
as Map<String, DownloadItem>,queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<String>,maxConcurrent: null == maxConcurrent ? _self.maxConcurrent : maxConcurrent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadState].
extension DownloadStatePatterns on DownloadState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadState value)  $default,){
final _that = this;
switch (_that) {
case _DownloadState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadState value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, DownloadItem> downloads,  List<String> queue,  int maxConcurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadState() when $default != null:
return $default(_that.downloads,_that.queue,_that.maxConcurrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, DownloadItem> downloads,  List<String> queue,  int maxConcurrent)  $default,) {final _that = this;
switch (_that) {
case _DownloadState():
return $default(_that.downloads,_that.queue,_that.maxConcurrent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, DownloadItem> downloads,  List<String> queue,  int maxConcurrent)?  $default,) {final _that = this;
switch (_that) {
case _DownloadState() when $default != null:
return $default(_that.downloads,_that.queue,_that.maxConcurrent);case _:
  return null;

}
}

}

/// @nodoc


class _DownloadState extends DownloadState with DiagnosticableTreeMixin {
  const _DownloadState({final  Map<String, DownloadItem> downloads = const {}, final  List<String> queue = const [], this.maxConcurrent = 3}): _downloads = downloads,_queue = queue,super._();
  

 final  Map<String, DownloadItem> _downloads;
@override@JsonKey() Map<String, DownloadItem> get downloads {
  if (_downloads is EqualUnmodifiableMapView) return _downloads;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_downloads);
}

 final  List<String> _queue;
@override@JsonKey() List<String> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

// IDs in queue order
@override@JsonKey() final  int maxConcurrent;

/// Create a copy of DownloadState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadStateCopyWith<_DownloadState> get copyWith => __$DownloadStateCopyWithImpl<_DownloadState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DownloadState'))
    ..add(DiagnosticsProperty('downloads', downloads))..add(DiagnosticsProperty('queue', queue))..add(DiagnosticsProperty('maxConcurrent', maxConcurrent));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadState&&const DeepCollectionEquality().equals(other._downloads, _downloads)&&const DeepCollectionEquality().equals(other._queue, _queue)&&(identical(other.maxConcurrent, maxConcurrent) || other.maxConcurrent == maxConcurrent));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_downloads),const DeepCollectionEquality().hash(_queue),maxConcurrent);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DownloadState(downloads: $downloads, queue: $queue, maxConcurrent: $maxConcurrent)';
}


}

/// @nodoc
abstract mixin class _$DownloadStateCopyWith<$Res> implements $DownloadStateCopyWith<$Res> {
  factory _$DownloadStateCopyWith(_DownloadState value, $Res Function(_DownloadState) _then) = __$DownloadStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, DownloadItem> downloads, List<String> queue, int maxConcurrent
});




}
/// @nodoc
class __$DownloadStateCopyWithImpl<$Res>
    implements _$DownloadStateCopyWith<$Res> {
  __$DownloadStateCopyWithImpl(this._self, this._then);

  final _DownloadState _self;
  final $Res Function(_DownloadState) _then;

/// Create a copy of DownloadState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? downloads = null,Object? queue = null,Object? maxConcurrent = null,}) {
  return _then(_DownloadState(
downloads: null == downloads ? _self._downloads : downloads // ignore: cast_nullable_to_non_nullable
as Map<String, DownloadItem>,queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<String>,maxConcurrent: null == maxConcurrent ? _self.maxConcurrent : maxConcurrent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
