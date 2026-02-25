// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationEntry {

 String get id; String? get title; String? get body; String? get imageUrl; String? get deepLink; String get type; String get channelId; Map<String, dynamic> get data; DateTime get receivedAt; bool get isRead;
/// Create a copy of NotificationEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationEntryCopyWith<NotificationEntry> get copyWith => _$NotificationEntryCopyWithImpl<NotificationEntry>(this as NotificationEntry, _$identity);

  /// Serializes this NotificationEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink)&&(identical(other.type, type) || other.type == type)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,imageUrl,deepLink,type,channelId,const DeepCollectionEquality().hash(data),receivedAt,isRead);

@override
String toString() {
  return 'NotificationEntry(id: $id, title: $title, body: $body, imageUrl: $imageUrl, deepLink: $deepLink, type: $type, channelId: $channelId, data: $data, receivedAt: $receivedAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $NotificationEntryCopyWith<$Res>  {
  factory $NotificationEntryCopyWith(NotificationEntry value, $Res Function(NotificationEntry) _then) = _$NotificationEntryCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? body, String? imageUrl, String? deepLink, String type, String channelId, Map<String, dynamic> data, DateTime receivedAt, bool isRead
});




}
/// @nodoc
class _$NotificationEntryCopyWithImpl<$Res>
    implements $NotificationEntryCopyWith<$Res> {
  _$NotificationEntryCopyWithImpl(this._self, this._then);

  final NotificationEntry _self;
  final $Res Function(NotificationEntry) _then;

/// Create a copy of NotificationEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? body = freezed,Object? imageUrl = freezed,Object? deepLink = freezed,Object? type = null,Object? channelId = null,Object? data = null,Object? receivedAt = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationEntry].
extension NotificationEntryPatterns on NotificationEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationEntry value)  $default,){
final _that = this;
switch (_that) {
case _NotificationEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationEntry value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? body,  String? imageUrl,  String? deepLink,  String type,  String channelId,  Map<String, dynamic> data,  DateTime receivedAt,  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationEntry() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.imageUrl,_that.deepLink,_that.type,_that.channelId,_that.data,_that.receivedAt,_that.isRead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? body,  String? imageUrl,  String? deepLink,  String type,  String channelId,  Map<String, dynamic> data,  DateTime receivedAt,  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _NotificationEntry():
return $default(_that.id,_that.title,_that.body,_that.imageUrl,_that.deepLink,_that.type,_that.channelId,_that.data,_that.receivedAt,_that.isRead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? body,  String? imageUrl,  String? deepLink,  String type,  String channelId,  Map<String, dynamic> data,  DateTime receivedAt,  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _NotificationEntry() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.imageUrl,_that.deepLink,_that.type,_that.channelId,_that.data,_that.receivedAt,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationEntry extends NotificationEntry {
  const _NotificationEntry({required this.id, this.title, this.body, this.imageUrl, this.deepLink, this.type = 'general', this.channelId = 'general', final  Map<String, dynamic> data = const {}, required this.receivedAt, this.isRead = false}): _data = data,super._();
  factory _NotificationEntry.fromJson(Map<String, dynamic> json) => _$NotificationEntryFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? body;
@override final  String? imageUrl;
@override final  String? deepLink;
@override@JsonKey() final  String type;
@override@JsonKey() final  String channelId;
 final  Map<String, dynamic> _data;
@override@JsonKey() Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}

@override final  DateTime receivedAt;
@override@JsonKey() final  bool isRead;

/// Create a copy of NotificationEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationEntryCopyWith<_NotificationEntry> get copyWith => __$NotificationEntryCopyWithImpl<_NotificationEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink)&&(identical(other.type, type) || other.type == type)&&(identical(other.channelId, channelId) || other.channelId == channelId)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,imageUrl,deepLink,type,channelId,const DeepCollectionEquality().hash(_data),receivedAt,isRead);

@override
String toString() {
  return 'NotificationEntry(id: $id, title: $title, body: $body, imageUrl: $imageUrl, deepLink: $deepLink, type: $type, channelId: $channelId, data: $data, receivedAt: $receivedAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$NotificationEntryCopyWith<$Res> implements $NotificationEntryCopyWith<$Res> {
  factory _$NotificationEntryCopyWith(_NotificationEntry value, $Res Function(_NotificationEntry) _then) = __$NotificationEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? body, String? imageUrl, String? deepLink, String type, String channelId, Map<String, dynamic> data, DateTime receivedAt, bool isRead
});




}
/// @nodoc
class __$NotificationEntryCopyWithImpl<$Res>
    implements _$NotificationEntryCopyWith<$Res> {
  __$NotificationEntryCopyWithImpl(this._self, this._then);

  final _NotificationEntry _self;
  final $Res Function(_NotificationEntry) _then;

/// Create a copy of NotificationEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? body = freezed,Object? imageUrl = freezed,Object? deepLink = freezed,Object? type = null,Object? channelId = null,Object? data = null,Object? receivedAt = null,Object? isRead = null,}) {
  return _then(_NotificationEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
