// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VM2<A,B> {

 A get a; B get b;
/// Create a copy of VM2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VM2CopyWith<A, B, VM2<A, B>> get copyWith => _$VM2CopyWithImpl<A, B, VM2<A, B>>(this as VM2<A, B>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VM2<A, B>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b));

@override
String toString() {
  return 'VM2<$A, $B>(a: $a, b: $b)';
}


}

/// @nodoc
abstract mixin class $VM2CopyWith<A,B,$Res>  {
  factory $VM2CopyWith(VM2<A, B> value, $Res Function(VM2<A, B>) _then) = _$VM2CopyWithImpl;
@useResult
$Res call({
 A a, B b
});




}
/// @nodoc
class _$VM2CopyWithImpl<A,B,$Res>
    implements $VM2CopyWith<A, B, $Res> {
  _$VM2CopyWithImpl(this._self, this._then);

  final VM2<A, B> _self;
  final $Res Function(VM2<A, B>) _then;

/// Create a copy of VM2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? a = freezed,Object? b = freezed,}) {
  return _then(_self.copyWith(
a: freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,
  ));
}

}


/// Adds pattern-matching-related methods to [VM2].
extension VM2Patterns<A,B> on VM2<A, B> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VM2<A, B> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VM2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VM2<A, B> value)  $default,){
final _that = this;
switch (_that) {
case _VM2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VM2<A, B> value)?  $default,){
final _that = this;
switch (_that) {
case _VM2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( A a,  B b)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VM2() when $default != null:
return $default(_that.a,_that.b);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( A a,  B b)  $default,) {final _that = this;
switch (_that) {
case _VM2():
return $default(_that.a,_that.b);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( A a,  B b)?  $default,) {final _that = this;
switch (_that) {
case _VM2() when $default != null:
return $default(_that.a,_that.b);case _:
  return null;

}
}

}

/// @nodoc


class _VM2<A,B> implements VM2<A, B> {
  const _VM2(this.a, this.b);
  

@override final  A a;
@override final  B b;

/// Create a copy of VM2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VM2CopyWith<A, B, _VM2<A, B>> get copyWith => __$VM2CopyWithImpl<A, B, _VM2<A, B>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VM2<A, B>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b));

@override
String toString() {
  return 'VM2<$A, $B>(a: $a, b: $b)';
}


}

/// @nodoc
abstract mixin class _$VM2CopyWith<A,B,$Res> implements $VM2CopyWith<A, B, $Res> {
  factory _$VM2CopyWith(_VM2<A, B> value, $Res Function(_VM2<A, B>) _then) = __$VM2CopyWithImpl;
@override @useResult
$Res call({
 A a, B b
});




}
/// @nodoc
class __$VM2CopyWithImpl<A,B,$Res>
    implements _$VM2CopyWith<A, B, $Res> {
  __$VM2CopyWithImpl(this._self, this._then);

  final _VM2<A, B> _self;
  final $Res Function(_VM2<A, B>) _then;

/// Create a copy of VM2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? a = freezed,Object? b = freezed,}) {
  return _then(_VM2<A, B>(
freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,
  ));
}


}

/// @nodoc
mixin _$VM3<A,B,C> {

 A get a; B get b; C get c;
/// Create a copy of VM3
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VM3CopyWith<A, B, C, VM3<A, B, C>> get copyWith => _$VM3CopyWithImpl<A, B, C, VM3<A, B, C>>(this as VM3<A, B, C>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VM3<A, B, C>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b)&&const DeepCollectionEquality().equals(other.c, c));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b),const DeepCollectionEquality().hash(c));

@override
String toString() {
  return 'VM3<$A, $B, $C>(a: $a, b: $b, c: $c)';
}


}

/// @nodoc
abstract mixin class $VM3CopyWith<A,B,C,$Res>  {
  factory $VM3CopyWith(VM3<A, B, C> value, $Res Function(VM3<A, B, C>) _then) = _$VM3CopyWithImpl;
@useResult
$Res call({
 A a, B b, C c
});




}
/// @nodoc
class _$VM3CopyWithImpl<A,B,C,$Res>
    implements $VM3CopyWith<A, B, C, $Res> {
  _$VM3CopyWithImpl(this._self, this._then);

  final VM3<A, B, C> _self;
  final $Res Function(VM3<A, B, C>) _then;

/// Create a copy of VM3
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? a = freezed,Object? b = freezed,Object? c = freezed,}) {
  return _then(_self.copyWith(
a: freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,c: freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as C,
  ));
}

}


/// Adds pattern-matching-related methods to [VM3].
extension VM3Patterns<A,B,C> on VM3<A, B, C> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VM3<A, B, C> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VM3() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VM3<A, B, C> value)  $default,){
final _that = this;
switch (_that) {
case _VM3():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VM3<A, B, C> value)?  $default,){
final _that = this;
switch (_that) {
case _VM3() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( A a,  B b,  C c)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VM3() when $default != null:
return $default(_that.a,_that.b,_that.c);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( A a,  B b,  C c)  $default,) {final _that = this;
switch (_that) {
case _VM3():
return $default(_that.a,_that.b,_that.c);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( A a,  B b,  C c)?  $default,) {final _that = this;
switch (_that) {
case _VM3() when $default != null:
return $default(_that.a,_that.b,_that.c);case _:
  return null;

}
}

}

/// @nodoc


class _VM3<A,B,C> implements VM3<A, B, C> {
  const _VM3(this.a, this.b, this.c);
  

@override final  A a;
@override final  B b;
@override final  C c;

/// Create a copy of VM3
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VM3CopyWith<A, B, C, _VM3<A, B, C>> get copyWith => __$VM3CopyWithImpl<A, B, C, _VM3<A, B, C>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VM3<A, B, C>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b)&&const DeepCollectionEquality().equals(other.c, c));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b),const DeepCollectionEquality().hash(c));

@override
String toString() {
  return 'VM3<$A, $B, $C>(a: $a, b: $b, c: $c)';
}


}

/// @nodoc
abstract mixin class _$VM3CopyWith<A,B,C,$Res> implements $VM3CopyWith<A, B, C, $Res> {
  factory _$VM3CopyWith(_VM3<A, B, C> value, $Res Function(_VM3<A, B, C>) _then) = __$VM3CopyWithImpl;
@override @useResult
$Res call({
 A a, B b, C c
});




}
/// @nodoc
class __$VM3CopyWithImpl<A,B,C,$Res>
    implements _$VM3CopyWith<A, B, C, $Res> {
  __$VM3CopyWithImpl(this._self, this._then);

  final _VM3<A, B, C> _self;
  final $Res Function(_VM3<A, B, C>) _then;

/// Create a copy of VM3
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? a = freezed,Object? b = freezed,Object? c = freezed,}) {
  return _then(_VM3<A, B, C>(
freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as C,
  ));
}


}

/// @nodoc
mixin _$CommonMessage {

 String get id; String get text; Duration get duration; MessageActionState? get actionState;
/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommonMessageCopyWith<CommonMessage> get copyWith => _$CommonMessageCopyWithImpl<CommonMessage>(this as CommonMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommonMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.actionState, actionState) || other.actionState == actionState));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,duration,actionState);

@override
String toString() {
  return 'CommonMessage(id: $id, text: $text, duration: $duration, actionState: $actionState)';
}


}

/// @nodoc
abstract mixin class $CommonMessageCopyWith<$Res>  {
  factory $CommonMessageCopyWith(CommonMessage value, $Res Function(CommonMessage) _then) = _$CommonMessageCopyWithImpl;
@useResult
$Res call({
 String id, String text, Duration duration, MessageActionState? actionState
});


$MessageActionStateCopyWith<$Res>? get actionState;

}
/// @nodoc
class _$CommonMessageCopyWithImpl<$Res>
    implements $CommonMessageCopyWith<$Res> {
  _$CommonMessageCopyWithImpl(this._self, this._then);

  final CommonMessage _self;
  final $Res Function(CommonMessage) _then;

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? duration = null,Object? actionState = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,actionState: freezed == actionState ? _self.actionState : actionState // ignore: cast_nullable_to_non_nullable
as MessageActionState?,
  ));
}
/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageActionStateCopyWith<$Res>? get actionState {
    if (_self.actionState == null) {
    return null;
  }

  return $MessageActionStateCopyWith<$Res>(_self.actionState!, (value) {
    return _then(_self.copyWith(actionState: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommonMessage].
extension CommonMessagePatterns on CommonMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommonMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommonMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommonMessage value)  $default,){
final _that = this;
switch (_that) {
case _CommonMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommonMessage value)?  $default,){
final _that = this;
switch (_that) {
case _CommonMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  Duration duration,  MessageActionState? actionState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommonMessage() when $default != null:
return $default(_that.id,_that.text,_that.duration,_that.actionState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  Duration duration,  MessageActionState? actionState)  $default,) {final _that = this;
switch (_that) {
case _CommonMessage():
return $default(_that.id,_that.text,_that.duration,_that.actionState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  Duration duration,  MessageActionState? actionState)?  $default,) {final _that = this;
switch (_that) {
case _CommonMessage() when $default != null:
return $default(_that.id,_that.text,_that.duration,_that.actionState);case _:
  return null;

}
}

}

/// @nodoc


class _CommonMessage implements CommonMessage {
  const _CommonMessage({required this.id, required this.text, this.duration = const Duration(seconds: 3), this.actionState});
  

@override final  String id;
@override final  String text;
@override@JsonKey() final  Duration duration;
@override final  MessageActionState? actionState;

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommonMessageCopyWith<_CommonMessage> get copyWith => __$CommonMessageCopyWithImpl<_CommonMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommonMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.actionState, actionState) || other.actionState == actionState));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,duration,actionState);

@override
String toString() {
  return 'CommonMessage(id: $id, text: $text, duration: $duration, actionState: $actionState)';
}


}

/// @nodoc
abstract mixin class _$CommonMessageCopyWith<$Res> implements $CommonMessageCopyWith<$Res> {
  factory _$CommonMessageCopyWith(_CommonMessage value, $Res Function(_CommonMessage) _then) = __$CommonMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, Duration duration, MessageActionState? actionState
});


@override $MessageActionStateCopyWith<$Res>? get actionState;

}
/// @nodoc
class __$CommonMessageCopyWithImpl<$Res>
    implements _$CommonMessageCopyWith<$Res> {
  __$CommonMessageCopyWithImpl(this._self, this._then);

  final _CommonMessage _self;
  final $Res Function(_CommonMessage) _then;

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? duration = null,Object? actionState = freezed,}) {
  return _then(_CommonMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,actionState: freezed == actionState ? _self.actionState : actionState // ignore: cast_nullable_to_non_nullable
as MessageActionState?,
  ));
}

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageActionStateCopyWith<$Res>? get actionState {
    if (_self.actionState == null) {
    return null;
  }

  return $MessageActionStateCopyWith<$Res>(_self.actionState!, (value) {
    return _then(_self.copyWith(actionState: value));
  });
}
}

/// @nodoc
mixin _$MessageActionState {

 String get actionText; VoidCallback get action;
/// Create a copy of MessageActionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageActionStateCopyWith<MessageActionState> get copyWith => _$MessageActionStateCopyWithImpl<MessageActionState>(this as MessageActionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageActionState&&(identical(other.actionText, actionText) || other.actionText == actionText)&&(identical(other.action, action) || other.action == action));
}


@override
int get hashCode => Object.hash(runtimeType,actionText,action);

@override
String toString() {
  return 'MessageActionState(actionText: $actionText, action: $action)';
}


}

/// @nodoc
abstract mixin class $MessageActionStateCopyWith<$Res>  {
  factory $MessageActionStateCopyWith(MessageActionState value, $Res Function(MessageActionState) _then) = _$MessageActionStateCopyWithImpl;
@useResult
$Res call({
 String actionText, VoidCallback action
});




}
/// @nodoc
class _$MessageActionStateCopyWithImpl<$Res>
    implements $MessageActionStateCopyWith<$Res> {
  _$MessageActionStateCopyWithImpl(this._self, this._then);

  final MessageActionState _self;
  final $Res Function(MessageActionState) _then;

/// Create a copy of MessageActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actionText = null,Object? action = null,}) {
  return _then(_self.copyWith(
actionText: null == actionText ? _self.actionText : actionText // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as VoidCallback,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageActionState].
extension MessageActionStatePatterns on MessageActionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageActionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageActionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageActionState value)  $default,){
final _that = this;
switch (_that) {
case _MessageActionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageActionState value)?  $default,){
final _that = this;
switch (_that) {
case _MessageActionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String actionText,  VoidCallback action)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageActionState() when $default != null:
return $default(_that.actionText,_that.action);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String actionText,  VoidCallback action)  $default,) {final _that = this;
switch (_that) {
case _MessageActionState():
return $default(_that.actionText,_that.action);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String actionText,  VoidCallback action)?  $default,) {final _that = this;
switch (_that) {
case _MessageActionState() when $default != null:
return $default(_that.actionText,_that.action);case _:
  return null;

}
}

}

/// @nodoc


class _MessageActionState implements MessageActionState {
  const _MessageActionState({required this.actionText, required this.action});
  

@override final  String actionText;
@override final  VoidCallback action;

/// Create a copy of MessageActionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageActionStateCopyWith<_MessageActionState> get copyWith => __$MessageActionStateCopyWithImpl<_MessageActionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageActionState&&(identical(other.actionText, actionText) || other.actionText == actionText)&&(identical(other.action, action) || other.action == action));
}


@override
int get hashCode => Object.hash(runtimeType,actionText,action);

@override
String toString() {
  return 'MessageActionState(actionText: $actionText, action: $action)';
}


}

/// @nodoc
abstract mixin class _$MessageActionStateCopyWith<$Res> implements $MessageActionStateCopyWith<$Res> {
  factory _$MessageActionStateCopyWith(_MessageActionState value, $Res Function(_MessageActionState) _then) = __$MessageActionStateCopyWithImpl;
@override @useResult
$Res call({
 String actionText, VoidCallback action
});




}
/// @nodoc
class __$MessageActionStateCopyWithImpl<$Res>
    implements _$MessageActionStateCopyWith<$Res> {
  __$MessageActionStateCopyWithImpl(this._self, this._then);

  final _MessageActionState _self;
  final $Res Function(_MessageActionState) _then;

/// Create a copy of MessageActionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actionText = null,Object? action = null,}) {
  return _then(_MessageActionState(
actionText: null == actionText ? _self.actionText : actionText // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as VoidCallback,
  ));
}


}

/// @nodoc
mixin _$AppBarState {

 List<Widget> get actions; AppBarSearchState? get searchState; AppBarEditState? get editState;
/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBarStateCopyWith<AppBarState> get copyWith => _$AppBarStateCopyWithImpl<AppBarState>(this as AppBarState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBarState&&const DeepCollectionEquality().equals(other.actions, actions)&&(identical(other.searchState, searchState) || other.searchState == searchState)&&(identical(other.editState, editState) || other.editState == editState));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(actions),searchState,editState);

@override
String toString() {
  return 'AppBarState(actions: $actions, searchState: $searchState, editState: $editState)';
}


}

/// @nodoc
abstract mixin class $AppBarStateCopyWith<$Res>  {
  factory $AppBarStateCopyWith(AppBarState value, $Res Function(AppBarState) _then) = _$AppBarStateCopyWithImpl;
@useResult
$Res call({
 List<Widget> actions, AppBarSearchState? searchState, AppBarEditState? editState
});


$AppBarSearchStateCopyWith<$Res>? get searchState;$AppBarEditStateCopyWith<$Res>? get editState;

}
/// @nodoc
class _$AppBarStateCopyWithImpl<$Res>
    implements $AppBarStateCopyWith<$Res> {
  _$AppBarStateCopyWithImpl(this._self, this._then);

  final AppBarState _self;
  final $Res Function(AppBarState) _then;

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actions = null,Object? searchState = freezed,Object? editState = freezed,}) {
  return _then(_self.copyWith(
actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<Widget>,searchState: freezed == searchState ? _self.searchState : searchState // ignore: cast_nullable_to_non_nullable
as AppBarSearchState?,editState: freezed == editState ? _self.editState : editState // ignore: cast_nullable_to_non_nullable
as AppBarEditState?,
  ));
}
/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppBarSearchStateCopyWith<$Res>? get searchState {
    if (_self.searchState == null) {
    return null;
  }

  return $AppBarSearchStateCopyWith<$Res>(_self.searchState!, (value) {
    return _then(_self.copyWith(searchState: value));
  });
}/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppBarEditStateCopyWith<$Res>? get editState {
    if (_self.editState == null) {
    return null;
  }

  return $AppBarEditStateCopyWith<$Res>(_self.editState!, (value) {
    return _then(_self.copyWith(editState: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppBarState].
extension AppBarStatePatterns on AppBarState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppBarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppBarState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppBarState value)  $default,){
final _that = this;
switch (_that) {
case _AppBarState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppBarState value)?  $default,){
final _that = this;
switch (_that) {
case _AppBarState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Widget> actions,  AppBarSearchState? searchState,  AppBarEditState? editState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBarState() when $default != null:
return $default(_that.actions,_that.searchState,_that.editState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Widget> actions,  AppBarSearchState? searchState,  AppBarEditState? editState)  $default,) {final _that = this;
switch (_that) {
case _AppBarState():
return $default(_that.actions,_that.searchState,_that.editState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Widget> actions,  AppBarSearchState? searchState,  AppBarEditState? editState)?  $default,) {final _that = this;
switch (_that) {
case _AppBarState() when $default != null:
return $default(_that.actions,_that.searchState,_that.editState);case _:
  return null;

}
}

}

/// @nodoc


class _AppBarState implements AppBarState {
  const _AppBarState({final  List<Widget> actions = const [], this.searchState, this.editState}): _actions = actions;
  

 final  List<Widget> _actions;
@override@JsonKey() List<Widget> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

@override final  AppBarSearchState? searchState;
@override final  AppBarEditState? editState;

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBarStateCopyWith<_AppBarState> get copyWith => __$AppBarStateCopyWithImpl<_AppBarState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBarState&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.searchState, searchState) || other.searchState == searchState)&&(identical(other.editState, editState) || other.editState == editState));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_actions),searchState,editState);

@override
String toString() {
  return 'AppBarState(actions: $actions, searchState: $searchState, editState: $editState)';
}


}

/// @nodoc
abstract mixin class _$AppBarStateCopyWith<$Res> implements $AppBarStateCopyWith<$Res> {
  factory _$AppBarStateCopyWith(_AppBarState value, $Res Function(_AppBarState) _then) = __$AppBarStateCopyWithImpl;
@override @useResult
$Res call({
 List<Widget> actions, AppBarSearchState? searchState, AppBarEditState? editState
});


@override $AppBarSearchStateCopyWith<$Res>? get searchState;@override $AppBarEditStateCopyWith<$Res>? get editState;

}
/// @nodoc
class __$AppBarStateCopyWithImpl<$Res>
    implements _$AppBarStateCopyWith<$Res> {
  __$AppBarStateCopyWithImpl(this._self, this._then);

  final _AppBarState _self;
  final $Res Function(_AppBarState) _then;

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actions = null,Object? searchState = freezed,Object? editState = freezed,}) {
  return _then(_AppBarState(
actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<Widget>,searchState: freezed == searchState ? _self.searchState : searchState // ignore: cast_nullable_to_non_nullable
as AppBarSearchState?,editState: freezed == editState ? _self.editState : editState // ignore: cast_nullable_to_non_nullable
as AppBarEditState?,
  ));
}

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppBarSearchStateCopyWith<$Res>? get searchState {
    if (_self.searchState == null) {
    return null;
  }

  return $AppBarSearchStateCopyWith<$Res>(_self.searchState!, (value) {
    return _then(_self.copyWith(searchState: value));
  });
}/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppBarEditStateCopyWith<$Res>? get editState {
    if (_self.editState == null) {
    return null;
  }

  return $AppBarEditStateCopyWith<$Res>(_self.editState!, (value) {
    return _then(_self.copyWith(editState: value));
  });
}
}

/// @nodoc
mixin _$AppBarSearchState {

  Function(String) get onSearch; bool get autoAddSearch; String? get query;
/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBarSearchStateCopyWith<AppBarSearchState> get copyWith => _$AppBarSearchStateCopyWithImpl<AppBarSearchState>(this as AppBarSearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBarSearchState&&(identical(other.onSearch, onSearch) || other.onSearch == onSearch)&&(identical(other.autoAddSearch, autoAddSearch) || other.autoAddSearch == autoAddSearch)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,onSearch,autoAddSearch,query);

@override
String toString() {
  return 'AppBarSearchState(onSearch: $onSearch, autoAddSearch: $autoAddSearch, query: $query)';
}


}

/// @nodoc
abstract mixin class $AppBarSearchStateCopyWith<$Res>  {
  factory $AppBarSearchStateCopyWith(AppBarSearchState value, $Res Function(AppBarSearchState) _then) = _$AppBarSearchStateCopyWithImpl;
@useResult
$Res call({
  Function(String) onSearch, bool autoAddSearch, String? query
});




}
/// @nodoc
class _$AppBarSearchStateCopyWithImpl<$Res>
    implements $AppBarSearchStateCopyWith<$Res> {
  _$AppBarSearchStateCopyWithImpl(this._self, this._then);

  final AppBarSearchState _self;
  final $Res Function(AppBarSearchState) _then;

/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? onSearch = null,Object? autoAddSearch = null,Object? query = freezed,}) {
  return _then(_self.copyWith(
onSearch: null == onSearch ? _self.onSearch : onSearch // ignore: cast_nullable_to_non_nullable
as  Function(String),autoAddSearch: null == autoAddSearch ? _self.autoAddSearch : autoAddSearch // ignore: cast_nullable_to_non_nullable
as bool,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppBarSearchState].
extension AppBarSearchStatePatterns on AppBarSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppBarSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppBarSearchState value)  $default,){
final _that = this;
switch (_that) {
case _AppBarSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppBarSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(  Function(String) onSearch,  bool autoAddSearch,  String? query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
return $default(_that.onSearch,_that.autoAddSearch,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(  Function(String) onSearch,  bool autoAddSearch,  String? query)  $default,) {final _that = this;
switch (_that) {
case _AppBarSearchState():
return $default(_that.onSearch,_that.autoAddSearch,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(  Function(String) onSearch,  bool autoAddSearch,  String? query)?  $default,) {final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
return $default(_that.onSearch,_that.autoAddSearch,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _AppBarSearchState implements AppBarSearchState {
  const _AppBarSearchState({required this.onSearch, this.autoAddSearch = true, this.query = null});
  

@override final   Function(String) onSearch;
@override@JsonKey() final  bool autoAddSearch;
@override@JsonKey() final  String? query;

/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBarSearchStateCopyWith<_AppBarSearchState> get copyWith => __$AppBarSearchStateCopyWithImpl<_AppBarSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBarSearchState&&(identical(other.onSearch, onSearch) || other.onSearch == onSearch)&&(identical(other.autoAddSearch, autoAddSearch) || other.autoAddSearch == autoAddSearch)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,onSearch,autoAddSearch,query);

@override
String toString() {
  return 'AppBarSearchState(onSearch: $onSearch, autoAddSearch: $autoAddSearch, query: $query)';
}


}

/// @nodoc
abstract mixin class _$AppBarSearchStateCopyWith<$Res> implements $AppBarSearchStateCopyWith<$Res> {
  factory _$AppBarSearchStateCopyWith(_AppBarSearchState value, $Res Function(_AppBarSearchState) _then) = __$AppBarSearchStateCopyWithImpl;
@override @useResult
$Res call({
  Function(String) onSearch, bool autoAddSearch, String? query
});




}
/// @nodoc
class __$AppBarSearchStateCopyWithImpl<$Res>
    implements _$AppBarSearchStateCopyWith<$Res> {
  __$AppBarSearchStateCopyWithImpl(this._self, this._then);

  final _AppBarSearchState _self;
  final $Res Function(_AppBarSearchState) _then;

/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? onSearch = null,Object? autoAddSearch = null,Object? query = freezed,}) {
  return _then(_AppBarSearchState(
onSearch: null == onSearch ? _self.onSearch : onSearch // ignore: cast_nullable_to_non_nullable
as  Function(String),autoAddSearch: null == autoAddSearch ? _self.autoAddSearch : autoAddSearch // ignore: cast_nullable_to_non_nullable
as bool,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AppBarEditState {

 int get editCount;  Function() get onExit;
/// Create a copy of AppBarEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBarEditStateCopyWith<AppBarEditState> get copyWith => _$AppBarEditStateCopyWithImpl<AppBarEditState>(this as AppBarEditState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBarEditState&&(identical(other.editCount, editCount) || other.editCount == editCount)&&(identical(other.onExit, onExit) || other.onExit == onExit));
}


@override
int get hashCode => Object.hash(runtimeType,editCount,onExit);

@override
String toString() {
  return 'AppBarEditState(editCount: $editCount, onExit: $onExit)';
}


}

/// @nodoc
abstract mixin class $AppBarEditStateCopyWith<$Res>  {
  factory $AppBarEditStateCopyWith(AppBarEditState value, $Res Function(AppBarEditState) _then) = _$AppBarEditStateCopyWithImpl;
@useResult
$Res call({
 int editCount,  Function() onExit
});




}
/// @nodoc
class _$AppBarEditStateCopyWithImpl<$Res>
    implements $AppBarEditStateCopyWith<$Res> {
  _$AppBarEditStateCopyWithImpl(this._self, this._then);

  final AppBarEditState _self;
  final $Res Function(AppBarEditState) _then;

/// Create a copy of AppBarEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? editCount = null,Object? onExit = null,}) {
  return _then(_self.copyWith(
editCount: null == editCount ? _self.editCount : editCount // ignore: cast_nullable_to_non_nullable
as int,onExit: null == onExit ? _self.onExit : onExit // ignore: cast_nullable_to_non_nullable
as  Function(),
  ));
}

}


/// Adds pattern-matching-related methods to [AppBarEditState].
extension AppBarEditStatePatterns on AppBarEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppBarEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppBarEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppBarEditState value)  $default,){
final _that = this;
switch (_that) {
case _AppBarEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppBarEditState value)?  $default,){
final _that = this;
switch (_that) {
case _AppBarEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int editCount,   Function() onExit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBarEditState() when $default != null:
return $default(_that.editCount,_that.onExit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int editCount,   Function() onExit)  $default,) {final _that = this;
switch (_that) {
case _AppBarEditState():
return $default(_that.editCount,_that.onExit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int editCount,   Function() onExit)?  $default,) {final _that = this;
switch (_that) {
case _AppBarEditState() when $default != null:
return $default(_that.editCount,_that.onExit);case _:
  return null;

}
}

}

/// @nodoc


class _AppBarEditState implements AppBarEditState {
  const _AppBarEditState({this.editCount = 0, required this.onExit});
  

@override@JsonKey() final  int editCount;
@override final   Function() onExit;

/// Create a copy of AppBarEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBarEditStateCopyWith<_AppBarEditState> get copyWith => __$AppBarEditStateCopyWithImpl<_AppBarEditState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBarEditState&&(identical(other.editCount, editCount) || other.editCount == editCount)&&(identical(other.onExit, onExit) || other.onExit == onExit));
}


@override
int get hashCode => Object.hash(runtimeType,editCount,onExit);

@override
String toString() {
  return 'AppBarEditState(editCount: $editCount, onExit: $onExit)';
}


}

/// @nodoc
abstract mixin class _$AppBarEditStateCopyWith<$Res> implements $AppBarEditStateCopyWith<$Res> {
  factory _$AppBarEditStateCopyWith(_AppBarEditState value, $Res Function(_AppBarEditState) _then) = __$AppBarEditStateCopyWithImpl;
@override @useResult
$Res call({
 int editCount,  Function() onExit
});




}
/// @nodoc
class __$AppBarEditStateCopyWithImpl<$Res>
    implements _$AppBarEditStateCopyWith<$Res> {
  __$AppBarEditStateCopyWithImpl(this._self, this._then);

  final _AppBarEditState _self;
  final $Res Function(_AppBarEditState) _then;

/// Create a copy of AppBarEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? editCount = null,Object? onExit = null,}) {
  return _then(_AppBarEditState(
editCount: null == editCount ? _self.editCount : editCount // ignore: cast_nullable_to_non_nullable
as int,onExit: null == onExit ? _self.onExit : onExit // ignore: cast_nullable_to_non_nullable
as  Function(),
  ));
}


}

/// @nodoc
mixin _$NetworkDetectionState {

 bool get isLoading; IpInfo? get ipInfo;
/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkDetectionStateCopyWith<NetworkDetectionState> get copyWith => _$NetworkDetectionStateCopyWithImpl<NetworkDetectionState>(this as NetworkDetectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkDetectionState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.ipInfo, ipInfo) || other.ipInfo == ipInfo));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,ipInfo);

@override
String toString() {
  return 'NetworkDetectionState(isLoading: $isLoading, ipInfo: $ipInfo)';
}


}

/// @nodoc
abstract mixin class $NetworkDetectionStateCopyWith<$Res>  {
  factory $NetworkDetectionStateCopyWith(NetworkDetectionState value, $Res Function(NetworkDetectionState) _then) = _$NetworkDetectionStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, IpInfo? ipInfo
});


$IpInfoCopyWith<$Res>? get ipInfo;

}
/// @nodoc
class _$NetworkDetectionStateCopyWithImpl<$Res>
    implements $NetworkDetectionStateCopyWith<$Res> {
  _$NetworkDetectionStateCopyWithImpl(this._self, this._then);

  final NetworkDetectionState _self;
  final $Res Function(NetworkDetectionState) _then;

/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? ipInfo = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,ipInfo: freezed == ipInfo ? _self.ipInfo : ipInfo // ignore: cast_nullable_to_non_nullable
as IpInfo?,
  ));
}
/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IpInfoCopyWith<$Res>? get ipInfo {
    if (_self.ipInfo == null) {
    return null;
  }

  return $IpInfoCopyWith<$Res>(_self.ipInfo!, (value) {
    return _then(_self.copyWith(ipInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [NetworkDetectionState].
extension NetworkDetectionStatePatterns on NetworkDetectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkDetectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkDetectionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkDetectionState value)  $default,){
final _that = this;
switch (_that) {
case _NetworkDetectionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkDetectionState value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkDetectionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  IpInfo? ipInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkDetectionState() when $default != null:
return $default(_that.isLoading,_that.ipInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  IpInfo? ipInfo)  $default,) {final _that = this;
switch (_that) {
case _NetworkDetectionState():
return $default(_that.isLoading,_that.ipInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  IpInfo? ipInfo)?  $default,) {final _that = this;
switch (_that) {
case _NetworkDetectionState() when $default != null:
return $default(_that.isLoading,_that.ipInfo);case _:
  return null;

}
}

}

/// @nodoc


class _NetworkDetectionState implements NetworkDetectionState {
  const _NetworkDetectionState({required this.isLoading, required this.ipInfo});
  

@override final  bool isLoading;
@override final  IpInfo? ipInfo;

/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkDetectionStateCopyWith<_NetworkDetectionState> get copyWith => __$NetworkDetectionStateCopyWithImpl<_NetworkDetectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkDetectionState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.ipInfo, ipInfo) || other.ipInfo == ipInfo));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,ipInfo);

@override
String toString() {
  return 'NetworkDetectionState(isLoading: $isLoading, ipInfo: $ipInfo)';
}


}

/// @nodoc
abstract mixin class _$NetworkDetectionStateCopyWith<$Res> implements $NetworkDetectionStateCopyWith<$Res> {
  factory _$NetworkDetectionStateCopyWith(_NetworkDetectionState value, $Res Function(_NetworkDetectionState) _then) = __$NetworkDetectionStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, IpInfo? ipInfo
});


@override $IpInfoCopyWith<$Res>? get ipInfo;

}
/// @nodoc
class __$NetworkDetectionStateCopyWithImpl<$Res>
    implements _$NetworkDetectionStateCopyWith<$Res> {
  __$NetworkDetectionStateCopyWithImpl(this._self, this._then);

  final _NetworkDetectionState _self;
  final $Res Function(_NetworkDetectionState) _then;

/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? ipInfo = freezed,}) {
  return _then(_NetworkDetectionState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,ipInfo: freezed == ipInfo ? _self.ipInfo : ipInfo // ignore: cast_nullable_to_non_nullable
as IpInfo?,
  ));
}

/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IpInfoCopyWith<$Res>? get ipInfo {
    if (_self.ipInfo == null) {
    return null;
  }

  return $IpInfoCopyWith<$Res>(_self.ipInfo!, (value) {
    return _then(_self.copyWith(ipInfo: value));
  });
}
}

/// @nodoc
mixin _$TrayState {

 Mode get mode; int get port; bool get autoLaunch; bool get systemProxy; bool get tunEnable; bool get isStart; String? get locale; Brightness? get brightness; List<Group> get groups; Map<String, String> get selectedMap; bool get showTrayTitle;
/// Create a copy of TrayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrayStateCopyWith<TrayState> get copyWith => _$TrayStateCopyWithImpl<TrayState>(this as TrayState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrayState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.port, port) || other.port == port)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.tunEnable, tunEnable) || other.tunEnable == tunEnable)&&(identical(other.isStart, isStart) || other.isStart == isStart)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.brightness, brightness) || other.brightness == brightness)&&const DeepCollectionEquality().equals(other.groups, groups)&&const DeepCollectionEquality().equals(other.selectedMap, selectedMap)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}


@override
int get hashCode => Object.hash(runtimeType,mode,port,autoLaunch,systemProxy,tunEnable,isStart,locale,brightness,const DeepCollectionEquality().hash(groups),const DeepCollectionEquality().hash(selectedMap),showTrayTitle);

@override
String toString() {
  return 'TrayState(mode: $mode, port: $port, autoLaunch: $autoLaunch, systemProxy: $systemProxy, tunEnable: $tunEnable, isStart: $isStart, locale: $locale, brightness: $brightness, groups: $groups, selectedMap: $selectedMap, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class $TrayStateCopyWith<$Res>  {
  factory $TrayStateCopyWith(TrayState value, $Res Function(TrayState) _then) = _$TrayStateCopyWithImpl;
@useResult
$Res call({
 Mode mode, int port, bool autoLaunch, bool systemProxy, bool tunEnable, bool isStart, String? locale, Brightness? brightness, List<Group> groups, Map<String, String> selectedMap, bool showTrayTitle
});




}
/// @nodoc
class _$TrayStateCopyWithImpl<$Res>
    implements $TrayStateCopyWith<$Res> {
  _$TrayStateCopyWithImpl(this._self, this._then);

  final TrayState _self;
  final $Res Function(TrayState) _then;

/// Create a copy of TrayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? port = null,Object? autoLaunch = null,Object? systemProxy = null,Object? tunEnable = null,Object? isStart = null,Object? locale = freezed,Object? brightness = freezed,Object? groups = null,Object? selectedMap = null,Object? showTrayTitle = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,tunEnable: null == tunEnable ? _self.tunEnable : tunEnable // ignore: cast_nullable_to_non_nullable
as bool,isStart: null == isStart ? _self.isStart : isStart // ignore: cast_nullable_to_non_nullable
as bool,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,brightness: freezed == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as Brightness?,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrayState].
extension TrayStatePatterns on TrayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrayState value)  $default,){
final _that = this;
switch (_that) {
case _TrayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrayState value)?  $default,){
final _that = this;
switch (_that) {
case _TrayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Mode mode,  int port,  bool autoLaunch,  bool systemProxy,  bool tunEnable,  bool isStart,  String? locale,  Brightness? brightness,  List<Group> groups,  Map<String, String> selectedMap,  bool showTrayTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrayState() when $default != null:
return $default(_that.mode,_that.port,_that.autoLaunch,_that.systemProxy,_that.tunEnable,_that.isStart,_that.locale,_that.brightness,_that.groups,_that.selectedMap,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Mode mode,  int port,  bool autoLaunch,  bool systemProxy,  bool tunEnable,  bool isStart,  String? locale,  Brightness? brightness,  List<Group> groups,  Map<String, String> selectedMap,  bool showTrayTitle)  $default,) {final _that = this;
switch (_that) {
case _TrayState():
return $default(_that.mode,_that.port,_that.autoLaunch,_that.systemProxy,_that.tunEnable,_that.isStart,_that.locale,_that.brightness,_that.groups,_that.selectedMap,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Mode mode,  int port,  bool autoLaunch,  bool systemProxy,  bool tunEnable,  bool isStart,  String? locale,  Brightness? brightness,  List<Group> groups,  Map<String, String> selectedMap,  bool showTrayTitle)?  $default,) {final _that = this;
switch (_that) {
case _TrayState() when $default != null:
return $default(_that.mode,_that.port,_that.autoLaunch,_that.systemProxy,_that.tunEnable,_that.isStart,_that.locale,_that.brightness,_that.groups,_that.selectedMap,_that.showTrayTitle);case _:
  return null;

}
}

}

/// @nodoc


class _TrayState implements TrayState {
  const _TrayState({required this.mode, required this.port, required this.autoLaunch, required this.systemProxy, required this.tunEnable, required this.isStart, required this.locale, required this.brightness, required final  List<Group> groups, required final  Map<String, String> selectedMap, required this.showTrayTitle}): _groups = groups,_selectedMap = selectedMap;
  

@override final  Mode mode;
@override final  int port;
@override final  bool autoLaunch;
@override final  bool systemProxy;
@override final  bool tunEnable;
@override final  bool isStart;
@override final  String? locale;
@override final  Brightness? brightness;
 final  List<Group> _groups;
@override List<Group> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

 final  Map<String, String> _selectedMap;
@override Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

@override final  bool showTrayTitle;

/// Create a copy of TrayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrayStateCopyWith<_TrayState> get copyWith => __$TrayStateCopyWithImpl<_TrayState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrayState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.port, port) || other.port == port)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.tunEnable, tunEnable) || other.tunEnable == tunEnable)&&(identical(other.isStart, isStart) || other.isStart == isStart)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.brightness, brightness) || other.brightness == brightness)&&const DeepCollectionEquality().equals(other._groups, _groups)&&const DeepCollectionEquality().equals(other._selectedMap, _selectedMap)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}


@override
int get hashCode => Object.hash(runtimeType,mode,port,autoLaunch,systemProxy,tunEnable,isStart,locale,brightness,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_selectedMap),showTrayTitle);

@override
String toString() {
  return 'TrayState(mode: $mode, port: $port, autoLaunch: $autoLaunch, systemProxy: $systemProxy, tunEnable: $tunEnable, isStart: $isStart, locale: $locale, brightness: $brightness, groups: $groups, selectedMap: $selectedMap, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class _$TrayStateCopyWith<$Res> implements $TrayStateCopyWith<$Res> {
  factory _$TrayStateCopyWith(_TrayState value, $Res Function(_TrayState) _then) = __$TrayStateCopyWithImpl;
@override @useResult
$Res call({
 Mode mode, int port, bool autoLaunch, bool systemProxy, bool tunEnable, bool isStart, String? locale, Brightness? brightness, List<Group> groups, Map<String, String> selectedMap, bool showTrayTitle
});




}
/// @nodoc
class __$TrayStateCopyWithImpl<$Res>
    implements _$TrayStateCopyWith<$Res> {
  __$TrayStateCopyWithImpl(this._self, this._then);

  final _TrayState _self;
  final $Res Function(_TrayState) _then;

/// Create a copy of TrayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? port = null,Object? autoLaunch = null,Object? systemProxy = null,Object? tunEnable = null,Object? isStart = null,Object? locale = freezed,Object? brightness = freezed,Object? groups = null,Object? selectedMap = null,Object? showTrayTitle = null,}) {
  return _then(_TrayState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,tunEnable: null == tunEnable ? _self.tunEnable : tunEnable // ignore: cast_nullable_to_non_nullable
as bool,isStart: null == isStart ? _self.isStart : isStart // ignore: cast_nullable_to_non_nullable
as bool,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,brightness: freezed == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as Brightness?,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$TrayTitleState {

 Traffic get traffic; bool get showTrayTitle;
/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrayTitleStateCopyWith<TrayTitleState> get copyWith => _$TrayTitleStateCopyWithImpl<TrayTitleState>(this as TrayTitleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrayTitleState&&(identical(other.traffic, traffic) || other.traffic == traffic)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}


@override
int get hashCode => Object.hash(runtimeType,traffic,showTrayTitle);

@override
String toString() {
  return 'TrayTitleState(traffic: $traffic, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class $TrayTitleStateCopyWith<$Res>  {
  factory $TrayTitleStateCopyWith(TrayTitleState value, $Res Function(TrayTitleState) _then) = _$TrayTitleStateCopyWithImpl;
@useResult
$Res call({
 Traffic traffic, bool showTrayTitle
});


$TrafficCopyWith<$Res> get traffic;

}
/// @nodoc
class _$TrayTitleStateCopyWithImpl<$Res>
    implements $TrayTitleStateCopyWith<$Res> {
  _$TrayTitleStateCopyWithImpl(this._self, this._then);

  final TrayTitleState _self;
  final $Res Function(TrayTitleState) _then;

/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? traffic = null,Object? showTrayTitle = null,}) {
  return _then(_self.copyWith(
traffic: null == traffic ? _self.traffic : traffic // ignore: cast_nullable_to_non_nullable
as Traffic,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrafficCopyWith<$Res> get traffic {
  
  return $TrafficCopyWith<$Res>(_self.traffic, (value) {
    return _then(_self.copyWith(traffic: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrayTitleState].
extension TrayTitleStatePatterns on TrayTitleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrayTitleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrayTitleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrayTitleState value)  $default,){
final _that = this;
switch (_that) {
case _TrayTitleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrayTitleState value)?  $default,){
final _that = this;
switch (_that) {
case _TrayTitleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Traffic traffic,  bool showTrayTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrayTitleState() when $default != null:
return $default(_that.traffic,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Traffic traffic,  bool showTrayTitle)  $default,) {final _that = this;
switch (_that) {
case _TrayTitleState():
return $default(_that.traffic,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Traffic traffic,  bool showTrayTitle)?  $default,) {final _that = this;
switch (_that) {
case _TrayTitleState() when $default != null:
return $default(_that.traffic,_that.showTrayTitle);case _:
  return null;

}
}

}

/// @nodoc


class _TrayTitleState implements TrayTitleState {
  const _TrayTitleState({required this.traffic, required this.showTrayTitle});
  

@override final  Traffic traffic;
@override final  bool showTrayTitle;

/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrayTitleStateCopyWith<_TrayTitleState> get copyWith => __$TrayTitleStateCopyWithImpl<_TrayTitleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrayTitleState&&(identical(other.traffic, traffic) || other.traffic == traffic)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}


@override
int get hashCode => Object.hash(runtimeType,traffic,showTrayTitle);

@override
String toString() {
  return 'TrayTitleState(traffic: $traffic, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class _$TrayTitleStateCopyWith<$Res> implements $TrayTitleStateCopyWith<$Res> {
  factory _$TrayTitleStateCopyWith(_TrayTitleState value, $Res Function(_TrayTitleState) _then) = __$TrayTitleStateCopyWithImpl;
@override @useResult
$Res call({
 Traffic traffic, bool showTrayTitle
});


@override $TrafficCopyWith<$Res> get traffic;

}
/// @nodoc
class __$TrayTitleStateCopyWithImpl<$Res>
    implements _$TrayTitleStateCopyWith<$Res> {
  __$TrayTitleStateCopyWithImpl(this._self, this._then);

  final _TrayTitleState _self;
  final $Res Function(_TrayTitleState) _then;

/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? traffic = null,Object? showTrayTitle = null,}) {
  return _then(_TrayTitleState(
traffic: null == traffic ? _self.traffic : traffic // ignore: cast_nullable_to_non_nullable
as Traffic,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrafficCopyWith<$Res> get traffic {
  
  return $TrafficCopyWith<$Res>(_self.traffic, (value) {
    return _then(_self.copyWith(traffic: value));
  });
}
}

/// @nodoc
mixin _$GroupsState {

 List<Group> get value;
/// Create a copy of GroupsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupsStateCopyWith<GroupsState> get copyWith => _$GroupsStateCopyWithImpl<GroupsState>(this as GroupsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupsState&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'GroupsState(value: $value)';
}


}

/// @nodoc
abstract mixin class $GroupsStateCopyWith<$Res>  {
  factory $GroupsStateCopyWith(GroupsState value, $Res Function(GroupsState) _then) = _$GroupsStateCopyWithImpl;
@useResult
$Res call({
 List<Group> value
});




}
/// @nodoc
class _$GroupsStateCopyWithImpl<$Res>
    implements $GroupsStateCopyWith<$Res> {
  _$GroupsStateCopyWithImpl(this._self, this._then);

  final GroupsState _self;
  final $Res Function(GroupsState) _then;

/// Create a copy of GroupsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as List<Group>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupsState].
extension GroupsStatePatterns on GroupsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupsState value)  $default,){
final _that = this;
switch (_that) {
case _GroupsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupsState value)?  $default,){
final _that = this;
switch (_that) {
case _GroupsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Group> value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupsState() when $default != null:
return $default(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Group> value)  $default,) {final _that = this;
switch (_that) {
case _GroupsState():
return $default(_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Group> value)?  $default,) {final _that = this;
switch (_that) {
case _GroupsState() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _GroupsState implements GroupsState {
  const _GroupsState({required final  List<Group> value}): _value = value;
  

 final  List<Group> _value;
@override List<Group> get value {
  if (_value is EqualUnmodifiableListView) return _value;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_value);
}


/// Create a copy of GroupsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupsStateCopyWith<_GroupsState> get copyWith => __$GroupsStateCopyWithImpl<_GroupsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupsState&&const DeepCollectionEquality().equals(other._value, _value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_value));

@override
String toString() {
  return 'GroupsState(value: $value)';
}


}

/// @nodoc
abstract mixin class _$GroupsStateCopyWith<$Res> implements $GroupsStateCopyWith<$Res> {
  factory _$GroupsStateCopyWith(_GroupsState value, $Res Function(_GroupsState) _then) = __$GroupsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Group> value
});




}
/// @nodoc
class __$GroupsStateCopyWithImpl<$Res>
    implements _$GroupsStateCopyWith<$Res> {
  __$GroupsStateCopyWithImpl(this._self, this._then);

  final _GroupsState _self;
  final $Res Function(_GroupsState) _then;

/// Create a copy of GroupsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_GroupsState(
value: null == value ? _self._value : value // ignore: cast_nullable_to_non_nullable
as List<Group>,
  ));
}


}

/// @nodoc
mixin _$ProxyState {

 bool get isStart; bool get systemProxy; List<String> get bassDomain; int get port;
/// Create a copy of ProxyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyStateCopyWith<ProxyState> get copyWith => _$ProxyStateCopyWithImpl<ProxyState>(this as ProxyState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyState&&(identical(other.isStart, isStart) || other.isStart == isStart)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bassDomain, bassDomain)&&(identical(other.port, port) || other.port == port));
}


@override
int get hashCode => Object.hash(runtimeType,isStart,systemProxy,const DeepCollectionEquality().hash(bassDomain),port);

@override
String toString() {
  return 'ProxyState(isStart: $isStart, systemProxy: $systemProxy, bassDomain: $bassDomain, port: $port)';
}


}

/// @nodoc
abstract mixin class $ProxyStateCopyWith<$Res>  {
  factory $ProxyStateCopyWith(ProxyState value, $Res Function(ProxyState) _then) = _$ProxyStateCopyWithImpl;
@useResult
$Res call({
 bool isStart, bool systemProxy, List<String> bassDomain, int port
});




}
/// @nodoc
class _$ProxyStateCopyWithImpl<$Res>
    implements $ProxyStateCopyWith<$Res> {
  _$ProxyStateCopyWithImpl(this._self, this._then);

  final ProxyState _self;
  final $Res Function(ProxyState) _then;

/// Create a copy of ProxyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isStart = null,Object? systemProxy = null,Object? bassDomain = null,Object? port = null,}) {
  return _then(_self.copyWith(
isStart: null == isStart ? _self.isStart : isStart // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bassDomain: null == bassDomain ? _self.bassDomain : bassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxyState].
extension ProxyStatePatterns on ProxyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxyState value)  $default,){
final _that = this;
switch (_that) {
case _ProxyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxyState value)?  $default,){
final _that = this;
switch (_that) {
case _ProxyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isStart,  bool systemProxy,  List<String> bassDomain,  int port)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyState() when $default != null:
return $default(_that.isStart,_that.systemProxy,_that.bassDomain,_that.port);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isStart,  bool systemProxy,  List<String> bassDomain,  int port)  $default,) {final _that = this;
switch (_that) {
case _ProxyState():
return $default(_that.isStart,_that.systemProxy,_that.bassDomain,_that.port);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isStart,  bool systemProxy,  List<String> bassDomain,  int port)?  $default,) {final _that = this;
switch (_that) {
case _ProxyState() when $default != null:
return $default(_that.isStart,_that.systemProxy,_that.bassDomain,_that.port);case _:
  return null;

}
}

}

/// @nodoc


class _ProxyState implements ProxyState {
  const _ProxyState({required this.isStart, required this.systemProxy, required final  List<String> bassDomain, required this.port}): _bassDomain = bassDomain;
  

@override final  bool isStart;
@override final  bool systemProxy;
 final  List<String> _bassDomain;
@override List<String> get bassDomain {
  if (_bassDomain is EqualUnmodifiableListView) return _bassDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bassDomain);
}

@override final  int port;

/// Create a copy of ProxyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyStateCopyWith<_ProxyState> get copyWith => __$ProxyStateCopyWithImpl<_ProxyState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyState&&(identical(other.isStart, isStart) || other.isStart == isStart)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other._bassDomain, _bassDomain)&&(identical(other.port, port) || other.port == port));
}


@override
int get hashCode => Object.hash(runtimeType,isStart,systemProxy,const DeepCollectionEquality().hash(_bassDomain),port);

@override
String toString() {
  return 'ProxyState(isStart: $isStart, systemProxy: $systemProxy, bassDomain: $bassDomain, port: $port)';
}


}

/// @nodoc
abstract mixin class _$ProxyStateCopyWith<$Res> implements $ProxyStateCopyWith<$Res> {
  factory _$ProxyStateCopyWith(_ProxyState value, $Res Function(_ProxyState) _then) = __$ProxyStateCopyWithImpl;
@override @useResult
$Res call({
 bool isStart, bool systemProxy, List<String> bassDomain, int port
});




}
/// @nodoc
class __$ProxyStateCopyWithImpl<$Res>
    implements _$ProxyStateCopyWith<$Res> {
  __$ProxyStateCopyWithImpl(this._self, this._then);

  final _ProxyState _self;
  final $Res Function(_ProxyState) _then;

/// Create a copy of ProxyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isStart = null,Object? systemProxy = null,Object? bassDomain = null,Object? port = null,}) {
  return _then(_ProxyState(
isStart: null == isStart ? _self.isStart : isStart // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bassDomain: null == bassDomain ? _self._bassDomain : bassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SelectedProxyState {

 String get proxyName; bool get group; String? get testUrl;
/// Create a copy of SelectedProxyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectedProxyStateCopyWith<SelectedProxyState> get copyWith => _$SelectedProxyStateCopyWithImpl<SelectedProxyState>(this as SelectedProxyState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectedProxyState&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName)&&(identical(other.group, group) || other.group == group)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl));
}


@override
int get hashCode => Object.hash(runtimeType,proxyName,group,testUrl);

@override
String toString() {
  return 'SelectedProxyState(proxyName: $proxyName, group: $group, testUrl: $testUrl)';
}


}

/// @nodoc
abstract mixin class $SelectedProxyStateCopyWith<$Res>  {
  factory $SelectedProxyStateCopyWith(SelectedProxyState value, $Res Function(SelectedProxyState) _then) = _$SelectedProxyStateCopyWithImpl;
@useResult
$Res call({
 String proxyName, bool group, String? testUrl
});




}
/// @nodoc
class _$SelectedProxyStateCopyWithImpl<$Res>
    implements $SelectedProxyStateCopyWith<$Res> {
  _$SelectedProxyStateCopyWithImpl(this._self, this._then);

  final SelectedProxyState _self;
  final $Res Function(SelectedProxyState) _then;

/// Create a copy of SelectedProxyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxyName = null,Object? group = null,Object? testUrl = freezed,}) {
  return _then(_self.copyWith(
proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as bool,testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectedProxyState].
extension SelectedProxyStatePatterns on SelectedProxyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectedProxyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectedProxyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectedProxyState value)  $default,){
final _that = this;
switch (_that) {
case _SelectedProxyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectedProxyState value)?  $default,){
final _that = this;
switch (_that) {
case _SelectedProxyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String proxyName,  bool group,  String? testUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectedProxyState() when $default != null:
return $default(_that.proxyName,_that.group,_that.testUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String proxyName,  bool group,  String? testUrl)  $default,) {final _that = this;
switch (_that) {
case _SelectedProxyState():
return $default(_that.proxyName,_that.group,_that.testUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String proxyName,  bool group,  String? testUrl)?  $default,) {final _that = this;
switch (_that) {
case _SelectedProxyState() when $default != null:
return $default(_that.proxyName,_that.group,_that.testUrl);case _:
  return null;

}
}

}

/// @nodoc


class _SelectedProxyState implements SelectedProxyState {
  const _SelectedProxyState({required this.proxyName, this.group = false, this.testUrl});
  

@override final  String proxyName;
@override@JsonKey() final  bool group;
@override final  String? testUrl;

/// Create a copy of SelectedProxyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectedProxyStateCopyWith<_SelectedProxyState> get copyWith => __$SelectedProxyStateCopyWithImpl<_SelectedProxyState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectedProxyState&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName)&&(identical(other.group, group) || other.group == group)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl));
}


@override
int get hashCode => Object.hash(runtimeType,proxyName,group,testUrl);

@override
String toString() {
  return 'SelectedProxyState(proxyName: $proxyName, group: $group, testUrl: $testUrl)';
}


}

/// @nodoc
abstract mixin class _$SelectedProxyStateCopyWith<$Res> implements $SelectedProxyStateCopyWith<$Res> {
  factory _$SelectedProxyStateCopyWith(_SelectedProxyState value, $Res Function(_SelectedProxyState) _then) = __$SelectedProxyStateCopyWithImpl;
@override @useResult
$Res call({
 String proxyName, bool group, String? testUrl
});




}
/// @nodoc
class __$SelectedProxyStateCopyWithImpl<$Res>
    implements _$SelectedProxyStateCopyWith<$Res> {
  __$SelectedProxyStateCopyWithImpl(this._self, this._then);

  final _SelectedProxyState _self;
  final $Res Function(_SelectedProxyState) _then;

/// Create a copy of SelectedProxyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxyName = null,Object? group = null,Object? testUrl = freezed,}) {
  return _then(_SelectedProxyState(
proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as bool,testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$VpnState {

 TunStack get stack; VpnProps get vpnProps;
/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnStateCopyWith<VpnState> get copyWith => _$VpnStateCopyWithImpl<VpnState>(this as VpnState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnState&&(identical(other.stack, stack) || other.stack == stack)&&(identical(other.vpnProps, vpnProps) || other.vpnProps == vpnProps));
}


@override
int get hashCode => Object.hash(runtimeType,stack,vpnProps);

@override
String toString() {
  return 'VpnState(stack: $stack, vpnProps: $vpnProps)';
}


}

/// @nodoc
abstract mixin class $VpnStateCopyWith<$Res>  {
  factory $VpnStateCopyWith(VpnState value, $Res Function(VpnState) _then) = _$VpnStateCopyWithImpl;
@useResult
$Res call({
 TunStack stack, VpnProps vpnProps
});


$VpnPropsCopyWith<$Res> get vpnProps;

}
/// @nodoc
class _$VpnStateCopyWithImpl<$Res>
    implements $VpnStateCopyWith<$Res> {
  _$VpnStateCopyWithImpl(this._self, this._then);

  final VpnState _self;
  final $Res Function(VpnState) _then;

/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stack = null,Object? vpnProps = null,}) {
  return _then(_self.copyWith(
stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,
  ));
}
/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}
}


/// Adds pattern-matching-related methods to [VpnState].
extension VpnStatePatterns on VpnState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VpnState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VpnState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VpnState value)  $default,){
final _that = this;
switch (_that) {
case _VpnState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VpnState value)?  $default,){
final _that = this;
switch (_that) {
case _VpnState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TunStack stack,  VpnProps vpnProps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnState() when $default != null:
return $default(_that.stack,_that.vpnProps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TunStack stack,  VpnProps vpnProps)  $default,) {final _that = this;
switch (_that) {
case _VpnState():
return $default(_that.stack,_that.vpnProps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TunStack stack,  VpnProps vpnProps)?  $default,) {final _that = this;
switch (_that) {
case _VpnState() when $default != null:
return $default(_that.stack,_that.vpnProps);case _:
  return null;

}
}

}

/// @nodoc


class _VpnState implements VpnState {
  const _VpnState({required this.stack, required this.vpnProps});
  

@override final  TunStack stack;
@override final  VpnProps vpnProps;

/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VpnStateCopyWith<_VpnState> get copyWith => __$VpnStateCopyWithImpl<_VpnState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnState&&(identical(other.stack, stack) || other.stack == stack)&&(identical(other.vpnProps, vpnProps) || other.vpnProps == vpnProps));
}


@override
int get hashCode => Object.hash(runtimeType,stack,vpnProps);

@override
String toString() {
  return 'VpnState(stack: $stack, vpnProps: $vpnProps)';
}


}

/// @nodoc
abstract mixin class _$VpnStateCopyWith<$Res> implements $VpnStateCopyWith<$Res> {
  factory _$VpnStateCopyWith(_VpnState value, $Res Function(_VpnState) _then) = __$VpnStateCopyWithImpl;
@override @useResult
$Res call({
 TunStack stack, VpnProps vpnProps
});


@override $VpnPropsCopyWith<$Res> get vpnProps;

}
/// @nodoc
class __$VpnStateCopyWithImpl<$Res>
    implements _$VpnStateCopyWith<$Res> {
  __$VpnStateCopyWithImpl(this._self, this._then);

  final _VpnState _self;
  final $Res Function(_VpnState) _then;

/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stack = null,Object? vpnProps = null,}) {
  return _then(_VpnState(
stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,
  ));
}

/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}
}


/// @nodoc
mixin _$SharedState {

 SetupParams? get setupParams; VpnOptions? get vpnOptions; String get stopTip; String get startTip; String get currentProfileName; String get stopText; bool get onlyStatisticsProxy;
/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedStateCopyWith<SharedState> get copyWith => _$SharedStateCopyWithImpl<SharedState>(this as SharedState, _$identity);

  /// Serializes this SharedState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedState&&(identical(other.setupParams, setupParams) || other.setupParams == setupParams)&&(identical(other.vpnOptions, vpnOptions) || other.vpnOptions == vpnOptions)&&(identical(other.stopTip, stopTip) || other.stopTip == stopTip)&&(identical(other.startTip, startTip) || other.startTip == startTip)&&(identical(other.currentProfileName, currentProfileName) || other.currentProfileName == currentProfileName)&&(identical(other.stopText, stopText) || other.stopText == stopText)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,setupParams,vpnOptions,stopTip,startTip,currentProfileName,stopText,onlyStatisticsProxy);

@override
String toString() {
  return 'SharedState(setupParams: $setupParams, vpnOptions: $vpnOptions, stopTip: $stopTip, startTip: $startTip, currentProfileName: $currentProfileName, stopText: $stopText, onlyStatisticsProxy: $onlyStatisticsProxy)';
}


}

/// @nodoc
abstract mixin class $SharedStateCopyWith<$Res>  {
  factory $SharedStateCopyWith(SharedState value, $Res Function(SharedState) _then) = _$SharedStateCopyWithImpl;
@useResult
$Res call({
 SetupParams? setupParams, VpnOptions? vpnOptions, String stopTip, String startTip, String currentProfileName, String stopText, bool onlyStatisticsProxy
});


$SetupParamsCopyWith<$Res>? get setupParams;$VpnOptionsCopyWith<$Res>? get vpnOptions;

}
/// @nodoc
class _$SharedStateCopyWithImpl<$Res>
    implements $SharedStateCopyWith<$Res> {
  _$SharedStateCopyWithImpl(this._self, this._then);

  final SharedState _self;
  final $Res Function(SharedState) _then;

/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? setupParams = freezed,Object? vpnOptions = freezed,Object? stopTip = null,Object? startTip = null,Object? currentProfileName = null,Object? stopText = null,Object? onlyStatisticsProxy = null,}) {
  return _then(_self.copyWith(
setupParams: freezed == setupParams ? _self.setupParams : setupParams // ignore: cast_nullable_to_non_nullable
as SetupParams?,vpnOptions: freezed == vpnOptions ? _self.vpnOptions : vpnOptions // ignore: cast_nullable_to_non_nullable
as VpnOptions?,stopTip: null == stopTip ? _self.stopTip : stopTip // ignore: cast_nullable_to_non_nullable
as String,startTip: null == startTip ? _self.startTip : startTip // ignore: cast_nullable_to_non_nullable
as String,currentProfileName: null == currentProfileName ? _self.currentProfileName : currentProfileName // ignore: cast_nullable_to_non_nullable
as String,stopText: null == stopText ? _self.stopText : stopText // ignore: cast_nullable_to_non_nullable
as String,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SetupParamsCopyWith<$Res>? get setupParams {
    if (_self.setupParams == null) {
    return null;
  }

  return $SetupParamsCopyWith<$Res>(_self.setupParams!, (value) {
    return _then(_self.copyWith(setupParams: value));
  });
}/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnOptionsCopyWith<$Res>? get vpnOptions {
    if (_self.vpnOptions == null) {
    return null;
  }

  return $VpnOptionsCopyWith<$Res>(_self.vpnOptions!, (value) {
    return _then(_self.copyWith(vpnOptions: value));
  });
}
}


/// Adds pattern-matching-related methods to [SharedState].
extension SharedStatePatterns on SharedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedState value)  $default,){
final _that = this;
switch (_that) {
case _SharedState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedState value)?  $default,){
final _that = this;
switch (_that) {
case _SharedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SetupParams? setupParams,  VpnOptions? vpnOptions,  String stopTip,  String startTip,  String currentProfileName,  String stopText,  bool onlyStatisticsProxy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedState() when $default != null:
return $default(_that.setupParams,_that.vpnOptions,_that.stopTip,_that.startTip,_that.currentProfileName,_that.stopText,_that.onlyStatisticsProxy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SetupParams? setupParams,  VpnOptions? vpnOptions,  String stopTip,  String startTip,  String currentProfileName,  String stopText,  bool onlyStatisticsProxy)  $default,) {final _that = this;
switch (_that) {
case _SharedState():
return $default(_that.setupParams,_that.vpnOptions,_that.stopTip,_that.startTip,_that.currentProfileName,_that.stopText,_that.onlyStatisticsProxy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SetupParams? setupParams,  VpnOptions? vpnOptions,  String stopTip,  String startTip,  String currentProfileName,  String stopText,  bool onlyStatisticsProxy)?  $default,) {final _that = this;
switch (_that) {
case _SharedState() when $default != null:
return $default(_that.setupParams,_that.vpnOptions,_that.stopTip,_that.startTip,_that.currentProfileName,_that.stopText,_that.onlyStatisticsProxy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SharedState implements SharedState {
  const _SharedState({this.setupParams, this.vpnOptions, required this.stopTip, required this.startTip, required this.currentProfileName, required this.stopText, required this.onlyStatisticsProxy});
  factory _SharedState.fromJson(Map<String, dynamic> json) => _$SharedStateFromJson(json);

@override final  SetupParams? setupParams;
@override final  VpnOptions? vpnOptions;
@override final  String stopTip;
@override final  String startTip;
@override final  String currentProfileName;
@override final  String stopText;
@override final  bool onlyStatisticsProxy;

/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedStateCopyWith<_SharedState> get copyWith => __$SharedStateCopyWithImpl<_SharedState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SharedStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedState&&(identical(other.setupParams, setupParams) || other.setupParams == setupParams)&&(identical(other.vpnOptions, vpnOptions) || other.vpnOptions == vpnOptions)&&(identical(other.stopTip, stopTip) || other.stopTip == stopTip)&&(identical(other.startTip, startTip) || other.startTip == startTip)&&(identical(other.currentProfileName, currentProfileName) || other.currentProfileName == currentProfileName)&&(identical(other.stopText, stopText) || other.stopText == stopText)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,setupParams,vpnOptions,stopTip,startTip,currentProfileName,stopText,onlyStatisticsProxy);

@override
String toString() {
  return 'SharedState(setupParams: $setupParams, vpnOptions: $vpnOptions, stopTip: $stopTip, startTip: $startTip, currentProfileName: $currentProfileName, stopText: $stopText, onlyStatisticsProxy: $onlyStatisticsProxy)';
}


}

/// @nodoc
abstract mixin class _$SharedStateCopyWith<$Res> implements $SharedStateCopyWith<$Res> {
  factory _$SharedStateCopyWith(_SharedState value, $Res Function(_SharedState) _then) = __$SharedStateCopyWithImpl;
@override @useResult
$Res call({
 SetupParams? setupParams, VpnOptions? vpnOptions, String stopTip, String startTip, String currentProfileName, String stopText, bool onlyStatisticsProxy
});


@override $SetupParamsCopyWith<$Res>? get setupParams;@override $VpnOptionsCopyWith<$Res>? get vpnOptions;

}
/// @nodoc
class __$SharedStateCopyWithImpl<$Res>
    implements _$SharedStateCopyWith<$Res> {
  __$SharedStateCopyWithImpl(this._self, this._then);

  final _SharedState _self;
  final $Res Function(_SharedState) _then;

/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? setupParams = freezed,Object? vpnOptions = freezed,Object? stopTip = null,Object? startTip = null,Object? currentProfileName = null,Object? stopText = null,Object? onlyStatisticsProxy = null,}) {
  return _then(_SharedState(
setupParams: freezed == setupParams ? _self.setupParams : setupParams // ignore: cast_nullable_to_non_nullable
as SetupParams?,vpnOptions: freezed == vpnOptions ? _self.vpnOptions : vpnOptions // ignore: cast_nullable_to_non_nullable
as VpnOptions?,stopTip: null == stopTip ? _self.stopTip : stopTip // ignore: cast_nullable_to_non_nullable
as String,startTip: null == startTip ? _self.startTip : startTip // ignore: cast_nullable_to_non_nullable
as String,currentProfileName: null == currentProfileName ? _self.currentProfileName : currentProfileName // ignore: cast_nullable_to_non_nullable
as String,stopText: null == stopText ? _self.stopText : stopText // ignore: cast_nullable_to_non_nullable
as String,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SetupParamsCopyWith<$Res>? get setupParams {
    if (_self.setupParams == null) {
    return null;
  }

  return $SetupParamsCopyWith<$Res>(_self.setupParams!, (value) {
    return _then(_self.copyWith(setupParams: value));
  });
}/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnOptionsCopyWith<$Res>? get vpnOptions {
    if (_self.vpnOptions == null) {
    return null;
  }

  return $VpnOptionsCopyWith<$Res>(_self.vpnOptions!, (value) {
    return _then(_self.copyWith(vpnOptions: value));
  });
}
}

/// @nodoc
mixin _$MigrationData {

 Map<String, Object?>? get configMap; List<Rule> get rules; List<Script> get scripts; List<Profile> get profiles; List<ProfileRuleLink> get links;
/// Create a copy of MigrationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MigrationDataCopyWith<MigrationData> get copyWith => _$MigrationDataCopyWithImpl<MigrationData>(this as MigrationData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationData&&const DeepCollectionEquality().equals(other.configMap, configMap)&&const DeepCollectionEquality().equals(other.rules, rules)&&const DeepCollectionEquality().equals(other.scripts, scripts)&&const DeepCollectionEquality().equals(other.profiles, profiles)&&const DeepCollectionEquality().equals(other.links, links));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(configMap),const DeepCollectionEquality().hash(rules),const DeepCollectionEquality().hash(scripts),const DeepCollectionEquality().hash(profiles),const DeepCollectionEquality().hash(links));

@override
String toString() {
  return 'MigrationData(configMap: $configMap, rules: $rules, scripts: $scripts, profiles: $profiles, links: $links)';
}


}

/// @nodoc
abstract mixin class $MigrationDataCopyWith<$Res>  {
  factory $MigrationDataCopyWith(MigrationData value, $Res Function(MigrationData) _then) = _$MigrationDataCopyWithImpl;
@useResult
$Res call({
 Map<String, Object?>? configMap, List<Rule> rules, List<Script> scripts, List<Profile> profiles, List<ProfileRuleLink> links
});




}
/// @nodoc
class _$MigrationDataCopyWithImpl<$Res>
    implements $MigrationDataCopyWith<$Res> {
  _$MigrationDataCopyWithImpl(this._self, this._then);

  final MigrationData _self;
  final $Res Function(MigrationData) _then;

/// Create a copy of MigrationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? configMap = freezed,Object? rules = null,Object? scripts = null,Object? profiles = null,Object? links = null,}) {
  return _then(_self.copyWith(
configMap: freezed == configMap ? _self.configMap : configMap // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,scripts: null == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<Script>,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<ProfileRuleLink>,
  ));
}

}


/// Adds pattern-matching-related methods to [MigrationData].
extension MigrationDataPatterns on MigrationData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MigrationData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MigrationData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MigrationData value)  $default,){
final _that = this;
switch (_that) {
case _MigrationData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MigrationData value)?  $default,){
final _that = this;
switch (_that) {
case _MigrationData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, Object?>? configMap,  List<Rule> rules,  List<Script> scripts,  List<Profile> profiles,  List<ProfileRuleLink> links)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MigrationData() when $default != null:
return $default(_that.configMap,_that.rules,_that.scripts,_that.profiles,_that.links);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, Object?>? configMap,  List<Rule> rules,  List<Script> scripts,  List<Profile> profiles,  List<ProfileRuleLink> links)  $default,) {final _that = this;
switch (_that) {
case _MigrationData():
return $default(_that.configMap,_that.rules,_that.scripts,_that.profiles,_that.links);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, Object?>? configMap,  List<Rule> rules,  List<Script> scripts,  List<Profile> profiles,  List<ProfileRuleLink> links)?  $default,) {final _that = this;
switch (_that) {
case _MigrationData() when $default != null:
return $default(_that.configMap,_that.rules,_that.scripts,_that.profiles,_that.links);case _:
  return null;

}
}

}

/// @nodoc


class _MigrationData implements MigrationData {
  const _MigrationData({final  Map<String, Object?>? configMap, final  List<Rule> rules = const [], final  List<Script> scripts = const [], final  List<Profile> profiles = const [], final  List<ProfileRuleLink> links = const []}): _configMap = configMap,_rules = rules,_scripts = scripts,_profiles = profiles,_links = links;
  

 final  Map<String, Object?>? _configMap;
@override Map<String, Object?>? get configMap {
  final value = _configMap;
  if (value == null) return null;
  if (_configMap is EqualUnmodifiableMapView) return _configMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<Rule> _rules;
@override@JsonKey() List<Rule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

 final  List<Script> _scripts;
@override@JsonKey() List<Script> get scripts {
  if (_scripts is EqualUnmodifiableListView) return _scripts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scripts);
}

 final  List<Profile> _profiles;
@override@JsonKey() List<Profile> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}

 final  List<ProfileRuleLink> _links;
@override@JsonKey() List<ProfileRuleLink> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}


/// Create a copy of MigrationData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MigrationDataCopyWith<_MigrationData> get copyWith => __$MigrationDataCopyWithImpl<_MigrationData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrationData&&const DeepCollectionEquality().equals(other._configMap, _configMap)&&const DeepCollectionEquality().equals(other._rules, _rules)&&const DeepCollectionEquality().equals(other._scripts, _scripts)&&const DeepCollectionEquality().equals(other._profiles, _profiles)&&const DeepCollectionEquality().equals(other._links, _links));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_configMap),const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_scripts),const DeepCollectionEquality().hash(_profiles),const DeepCollectionEquality().hash(_links));

@override
String toString() {
  return 'MigrationData(configMap: $configMap, rules: $rules, scripts: $scripts, profiles: $profiles, links: $links)';
}


}

/// @nodoc
abstract mixin class _$MigrationDataCopyWith<$Res> implements $MigrationDataCopyWith<$Res> {
  factory _$MigrationDataCopyWith(_MigrationData value, $Res Function(_MigrationData) _then) = __$MigrationDataCopyWithImpl;
@override @useResult
$Res call({
 Map<String, Object?>? configMap, List<Rule> rules, List<Script> scripts, List<Profile> profiles, List<ProfileRuleLink> links
});




}
/// @nodoc
class __$MigrationDataCopyWithImpl<$Res>
    implements _$MigrationDataCopyWith<$Res> {
  __$MigrationDataCopyWithImpl(this._self, this._then);

  final _MigrationData _self;
  final $Res Function(_MigrationData) _then;

/// Create a copy of MigrationData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? configMap = freezed,Object? rules = null,Object? scripts = null,Object? profiles = null,Object? links = null,}) {
  return _then(_MigrationData(
configMap: freezed == configMap ? _self._configMap : configMap // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,scripts: null == scripts ? _self._scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<Script>,profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<ProfileRuleLink>,
  ));
}


}

/// @nodoc
mixin _$SetupState {

 int? get profileId; int? get profileLastUpdateDate; OverwriteType get overwriteType; List<Rule> get addedRules; Script? get script; bool get overrideDns; Dns get dns;
/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetupStateCopyWith<SetupState> get copyWith => _$SetupStateCopyWithImpl<SetupState>(this as SetupState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupState&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileLastUpdateDate, profileLastUpdateDate) || other.profileLastUpdateDate == profileLastUpdateDate)&&(identical(other.overwriteType, overwriteType) || other.overwriteType == overwriteType)&&const DeepCollectionEquality().equals(other.addedRules, addedRules)&&(identical(other.script, script) || other.script == script)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.dns, dns) || other.dns == dns));
}


@override
int get hashCode => Object.hash(runtimeType,profileId,profileLastUpdateDate,overwriteType,const DeepCollectionEquality().hash(addedRules),script,overrideDns,dns);

@override
String toString() {
  return 'SetupState(profileId: $profileId, profileLastUpdateDate: $profileLastUpdateDate, overwriteType: $overwriteType, addedRules: $addedRules, script: $script, overrideDns: $overrideDns, dns: $dns)';
}


}

/// @nodoc
abstract mixin class $SetupStateCopyWith<$Res>  {
  factory $SetupStateCopyWith(SetupState value, $Res Function(SetupState) _then) = _$SetupStateCopyWithImpl;
@useResult
$Res call({
 int? profileId, int? profileLastUpdateDate, OverwriteType overwriteType, List<Rule> addedRules, Script? script, bool overrideDns, Dns dns
});


$ScriptCopyWith<$Res>? get script;$DnsCopyWith<$Res> get dns;

}
/// @nodoc
class _$SetupStateCopyWithImpl<$Res>
    implements $SetupStateCopyWith<$Res> {
  _$SetupStateCopyWithImpl(this._self, this._then);

  final SetupState _self;
  final $Res Function(SetupState) _then;

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = freezed,Object? profileLastUpdateDate = freezed,Object? overwriteType = null,Object? addedRules = null,Object? script = freezed,Object? overrideDns = null,Object? dns = null,}) {
  return _then(_self.copyWith(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,profileLastUpdateDate: freezed == profileLastUpdateDate ? _self.profileLastUpdateDate : profileLastUpdateDate // ignore: cast_nullable_to_non_nullable
as int?,overwriteType: null == overwriteType ? _self.overwriteType : overwriteType // ignore: cast_nullable_to_non_nullable
as OverwriteType,addedRules: null == addedRules ? _self.addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,script: freezed == script ? _self.script : script // ignore: cast_nullable_to_non_nullable
as Script?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,
  ));
}
/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptCopyWith<$Res>? get script {
    if (_self.script == null) {
    return null;
  }

  return $ScriptCopyWith<$Res>(_self.script!, (value) {
    return _then(_self.copyWith(script: value));
  });
}/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}
}


/// Adds pattern-matching-related methods to [SetupState].
extension SetupStatePatterns on SetupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetupState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetupState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetupState value)  $default,){
final _that = this;
switch (_that) {
case _SetupState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetupState value)?  $default,){
final _that = this;
switch (_that) {
case _SetupState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? profileId,  int? profileLastUpdateDate,  OverwriteType overwriteType,  List<Rule> addedRules,  Script? script,  bool overrideDns,  Dns dns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupState() when $default != null:
return $default(_that.profileId,_that.profileLastUpdateDate,_that.overwriteType,_that.addedRules,_that.script,_that.overrideDns,_that.dns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? profileId,  int? profileLastUpdateDate,  OverwriteType overwriteType,  List<Rule> addedRules,  Script? script,  bool overrideDns,  Dns dns)  $default,) {final _that = this;
switch (_that) {
case _SetupState():
return $default(_that.profileId,_that.profileLastUpdateDate,_that.overwriteType,_that.addedRules,_that.script,_that.overrideDns,_that.dns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? profileId,  int? profileLastUpdateDate,  OverwriteType overwriteType,  List<Rule> addedRules,  Script? script,  bool overrideDns,  Dns dns)?  $default,) {final _that = this;
switch (_that) {
case _SetupState() when $default != null:
return $default(_that.profileId,_that.profileLastUpdateDate,_that.overwriteType,_that.addedRules,_that.script,_that.overrideDns,_that.dns);case _:
  return null;

}
}

}

/// @nodoc


class _SetupState implements SetupState {
  const _SetupState({required this.profileId, required this.profileLastUpdateDate, required this.overwriteType, required final  List<Rule> addedRules, required this.script, required this.overrideDns, required this.dns}): _addedRules = addedRules;
  

@override final  int? profileId;
@override final  int? profileLastUpdateDate;
@override final  OverwriteType overwriteType;
 final  List<Rule> _addedRules;
@override List<Rule> get addedRules {
  if (_addedRules is EqualUnmodifiableListView) return _addedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addedRules);
}

@override final  Script? script;
@override final  bool overrideDns;
@override final  Dns dns;

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupStateCopyWith<_SetupState> get copyWith => __$SetupStateCopyWithImpl<_SetupState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupState&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileLastUpdateDate, profileLastUpdateDate) || other.profileLastUpdateDate == profileLastUpdateDate)&&(identical(other.overwriteType, overwriteType) || other.overwriteType == overwriteType)&&const DeepCollectionEquality().equals(other._addedRules, _addedRules)&&(identical(other.script, script) || other.script == script)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.dns, dns) || other.dns == dns));
}


@override
int get hashCode => Object.hash(runtimeType,profileId,profileLastUpdateDate,overwriteType,const DeepCollectionEquality().hash(_addedRules),script,overrideDns,dns);

@override
String toString() {
  return 'SetupState(profileId: $profileId, profileLastUpdateDate: $profileLastUpdateDate, overwriteType: $overwriteType, addedRules: $addedRules, script: $script, overrideDns: $overrideDns, dns: $dns)';
}


}

/// @nodoc
abstract mixin class _$SetupStateCopyWith<$Res> implements $SetupStateCopyWith<$Res> {
  factory _$SetupStateCopyWith(_SetupState value, $Res Function(_SetupState) _then) = __$SetupStateCopyWithImpl;
@override @useResult
$Res call({
 int? profileId, int? profileLastUpdateDate, OverwriteType overwriteType, List<Rule> addedRules, Script? script, bool overrideDns, Dns dns
});


@override $ScriptCopyWith<$Res>? get script;@override $DnsCopyWith<$Res> get dns;

}
/// @nodoc
class __$SetupStateCopyWithImpl<$Res>
    implements _$SetupStateCopyWith<$Res> {
  __$SetupStateCopyWithImpl(this._self, this._then);

  final _SetupState _self;
  final $Res Function(_SetupState) _then;

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = freezed,Object? profileLastUpdateDate = freezed,Object? overwriteType = null,Object? addedRules = null,Object? script = freezed,Object? overrideDns = null,Object? dns = null,}) {
  return _then(_SetupState(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,profileLastUpdateDate: freezed == profileLastUpdateDate ? _self.profileLastUpdateDate : profileLastUpdateDate // ignore: cast_nullable_to_non_nullable
as int?,overwriteType: null == overwriteType ? _self.overwriteType : overwriteType // ignore: cast_nullable_to_non_nullable
as OverwriteType,addedRules: null == addedRules ? _self._addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,script: freezed == script ? _self.script : script // ignore: cast_nullable_to_non_nullable
as Script?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,
  ));
}

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptCopyWith<$Res>? get script {
    if (_self.script == null) {
    return null;
  }

  return $ScriptCopyWith<$Res>(_self.script!, (value) {
    return _then(_self.copyWith(script: value));
  });
}/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}
}

// dart format on
