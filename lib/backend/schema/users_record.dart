import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "fcmToken" field.
  String? _fcmToken;
  String get fcmToken => _fcmToken ?? '';
  bool hasFcmToken() => _fcmToken != null;

  // "fcmTokenUpdatedAt" field.
  DateTime? _fcmTokenUpdatedAt;
  DateTime? get fcmTokenUpdatedAt => _fcmTokenUpdatedAt;
  bool hasFcmTokenUpdatedAt() => _fcmTokenUpdatedAt != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  void _initializeFields() {
    _fcmToken = snapshotData['fcmToken'] as String?;
    _fcmTokenUpdatedAt = snapshotData['fcmTokenUpdatedAt'] as DateTime?;
    _uid = snapshotData['uid'] as String?;
    _userId = snapshotData['user_id'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? fcmToken,
  DateTime? fcmTokenUpdatedAt,
  String? uid,
  String? userId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'fcmToken': fcmToken,
      'fcmTokenUpdatedAt': fcmTokenUpdatedAt,
      'uid': uid,
      'user_id': userId,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.fcmToken == e2?.fcmToken &&
        e1?.fcmTokenUpdatedAt == e2?.fcmTokenUpdatedAt &&
        e1?.uid == e2?.uid &&
        e1?.userId == e2?.userId;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality()
      .hash([e?.fcmToken, e?.fcmTokenUpdatedAt, e?.uid, e?.userId]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
