// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadItem {

 String get id; String get url; String get fileName; DownloadType get type; DownloadStatus get status; double get progress;// 0.0 to 1.0
 int get bytesDownloaded; int get totalBytes; String? get savePath; String? get errorMessage; DateTime? get startedAt; DateTime? get completedAt;
/// Create a copy of DownloadItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadItemCopyWith<DownloadItem> get copyWith => _$DownloadItemCopyWithImpl<DownloadItem>(this as DownloadItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadItem&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.bytesDownloaded, bytesDownloaded) || other.bytesDownloaded == bytesDownloaded)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.savePath, savePath) || other.savePath == savePath)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,url,fileName,type,status,progress,bytesDownloaded,totalBytes,savePath,errorMessage,startedAt,completedAt);

@override
String toString() {
  return 'DownloadItem(id: $id, url: $url, fileName: $fileName, type: $type, status: $status, progress: $progress, bytesDownloaded: $bytesDownloaded, totalBytes: $totalBytes, savePath: $savePath, errorMessage: $errorMessage, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $DownloadItemCopyWith<$Res>  {
  factory $DownloadItemCopyWith(DownloadItem value, $Res Function(DownloadItem) _then) = _$DownloadItemCopyWithImpl;
@useResult
$Res call({
 String id, String url, String fileName, DownloadType type, DownloadStatus status, double progress, int bytesDownloaded, int totalBytes, String? savePath, String? errorMessage, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class _$DownloadItemCopyWithImpl<$Res>
    implements $DownloadItemCopyWith<$Res> {
  _$DownloadItemCopyWithImpl(this._self, this._then);

  final DownloadItem _self;
  final $Res Function(DownloadItem) _then;

/// Create a copy of DownloadItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? fileName = null,Object? type = null,Object? status = null,Object? progress = null,Object? bytesDownloaded = null,Object? totalBytes = null,Object? savePath = freezed,Object? errorMessage = freezed,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DownloadType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,bytesDownloaded: null == bytesDownloaded ? _self.bytesDownloaded : bytesDownloaded // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,savePath: freezed == savePath ? _self.savePath : savePath // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadItem].
extension DownloadItemPatterns on DownloadItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadItem value)  $default,){
final _that = this;
switch (_that) {
case _DownloadItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadItem value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String fileName,  DownloadType type,  DownloadStatus status,  double progress,  int bytesDownloaded,  int totalBytes,  String? savePath,  String? errorMessage,  DateTime? startedAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadItem() when $default != null:
return $default(_that.id,_that.url,_that.fileName,_that.type,_that.status,_that.progress,_that.bytesDownloaded,_that.totalBytes,_that.savePath,_that.errorMessage,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String fileName,  DownloadType type,  DownloadStatus status,  double progress,  int bytesDownloaded,  int totalBytes,  String? savePath,  String? errorMessage,  DateTime? startedAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _DownloadItem():
return $default(_that.id,_that.url,_that.fileName,_that.type,_that.status,_that.progress,_that.bytesDownloaded,_that.totalBytes,_that.savePath,_that.errorMessage,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String fileName,  DownloadType type,  DownloadStatus status,  double progress,  int bytesDownloaded,  int totalBytes,  String? savePath,  String? errorMessage,  DateTime? startedAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _DownloadItem() when $default != null:
return $default(_that.id,_that.url,_that.fileName,_that.type,_that.status,_that.progress,_that.bytesDownloaded,_that.totalBytes,_that.savePath,_that.errorMessage,_that.startedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc


class _DownloadItem extends DownloadItem {
  const _DownloadItem({required this.id, required this.url, required this.fileName, required this.type, this.status = DownloadStatus.queued, this.progress = 0.0, this.bytesDownloaded = 0, this.totalBytes = 0, this.savePath, this.errorMessage, this.startedAt, this.completedAt}): super._();
  

@override final  String id;
@override final  String url;
@override final  String fileName;
@override final  DownloadType type;
@override@JsonKey() final  DownloadStatus status;
@override@JsonKey() final  double progress;
// 0.0 to 1.0
@override@JsonKey() final  int bytesDownloaded;
@override@JsonKey() final  int totalBytes;
@override final  String? savePath;
@override final  String? errorMessage;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;

/// Create a copy of DownloadItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadItemCopyWith<_DownloadItem> get copyWith => __$DownloadItemCopyWithImpl<_DownloadItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadItem&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.bytesDownloaded, bytesDownloaded) || other.bytesDownloaded == bytesDownloaded)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.savePath, savePath) || other.savePath == savePath)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,url,fileName,type,status,progress,bytesDownloaded,totalBytes,savePath,errorMessage,startedAt,completedAt);

@override
String toString() {
  return 'DownloadItem(id: $id, url: $url, fileName: $fileName, type: $type, status: $status, progress: $progress, bytesDownloaded: $bytesDownloaded, totalBytes: $totalBytes, savePath: $savePath, errorMessage: $errorMessage, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$DownloadItemCopyWith<$Res> implements $DownloadItemCopyWith<$Res> {
  factory _$DownloadItemCopyWith(_DownloadItem value, $Res Function(_DownloadItem) _then) = __$DownloadItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String fileName, DownloadType type, DownloadStatus status, double progress, int bytesDownloaded, int totalBytes, String? savePath, String? errorMessage, DateTime? startedAt, DateTime? completedAt
});




}
/// @nodoc
class __$DownloadItemCopyWithImpl<$Res>
    implements _$DownloadItemCopyWith<$Res> {
  __$DownloadItemCopyWithImpl(this._self, this._then);

  final _DownloadItem _self;
  final $Res Function(_DownloadItem) _then;

/// Create a copy of DownloadItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? fileName = null,Object? type = null,Object? status = null,Object? progress = null,Object? bytesDownloaded = null,Object? totalBytes = null,Object? savePath = freezed,Object? errorMessage = freezed,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_DownloadItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DownloadType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,bytesDownloaded: null == bytesDownloaded ? _self.bytesDownloaded : bytesDownloaded // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,savePath: freezed == savePath ? _self.savePath : savePath // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
