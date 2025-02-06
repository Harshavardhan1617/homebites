import 'package:pocketbase/pocketbase.dart';

class ReceivedResponseModel {
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final Map<String, dynamic> expand;
  final String id;
  final String note;
  final String price;
  final String status;
  final String responseBy;
  final String responseTo;
  final DateTime updated;
  final String voiceNote;

  ReceivedResponseModel({
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.expand,
    required this.id,
    required this.note,
    required this.price,
    required this.status,
    required this.responseBy,
    required this.responseTo,
    required this.updated,
    required this.voiceNote,
  });

  factory ReceivedResponseModel.fromRecord(RecordModel record) {
    return ReceivedResponseModel(
      collectionId: record.get('collectionId'),
      collectionName: record.get('collectionName'),
      created: DateTime.parse(record.get('created')),
      expand: record.get('expand') as Map<String, dynamic>,
      id: record.id,
      note: record.get('note'),
      price: record.get('price'),
      status: record.get('status'),
      responseBy: record.get('response_by'),
      responseTo: record.get('response_to'),
      updated: DateTime.parse(record.get('updated')),
      voiceNote: record.get('voice_note'),
    );
  }
}

class ResponseBy {
  final String avatar;
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final String email;
  final bool emailVisibility;
  final String id;
  final bool isVegetarian;
  final String? location;
  final String mobileNumber;
  final String name;
  final DateTime updated;
  final bool verified;

  ResponseBy({
    required this.avatar,
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.email,
    required this.emailVisibility,
    required this.id,
    required this.isVegetarian,
    this.location,
    required this.mobileNumber,
    required this.name,
    required this.updated,
    required this.verified,
  });

  factory ResponseBy.fromMap(Map<String, dynamic> map) {
    return ResponseBy(
      avatar: map['avatar'],
      collectionId: map['collectionId'],
      collectionName: map['collectionName'],
      created: DateTime.parse(map['created']),
      email: map['email'],
      emailVisibility: map['emailVisibility'],
      id: map['id'],
      isVegetarian: map['is_vegetarian'],
      location: map['location'],
      mobileNumber: map['mobile_number'],
      name: map['name'],
      updated: DateTime.parse(map['updated']),
      verified: map['verified'],
    );
  }
}
