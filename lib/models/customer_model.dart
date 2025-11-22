import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String custID;
  final String name;
  final String address;
  final String phoneNo;
  final String branchCode;
  final String status;
  final List<TTHDocument> tthDocuments;

  Customer({
    required this.custID,
    required this.name,
    required this.address,
    required this.phoneNo,
    required this.branchCode,
    required this.status,
    required this.tthDocuments,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Handle TTHDocuments conversion
    List<TTHDocument> tthDocuments = [];

    if (json['TTHDocuments'] is List) {
      tthDocuments = (json['TTHDocuments'] as List)
          .map((docJson) => TTHDocument.fromJson(docJson))
          .toList();
    }

    return Customer(
      custID: json['CustID'] ?? '',
      name: json['Name'] ?? '',
      address: json['Address'] ?? '',
      phoneNo: json['PhoneNo'] ?? '',
      branchCode: json['BranchCode'] ?? '',
      status: json['Status'] ?? 'Belum Diberikan',
      tthDocuments: tthDocuments,
    );
  }

  @override
  List<Object?> get props => [custID, name, address, phoneNo, branchCode, status, tthDocuments];
}

class TTHDocument extends Equatable {
  final String tthNo;
  final String ttottPNo;
  final String docDate;
  final int received;
  final String? receivedDate;
  final String? failedReason;
  final String status;

  TTHDocument({
    required this.tthNo,
    required this.ttottPNo,
    required this.docDate,
    required this.received,
    this.receivedDate,
    this.failedReason,
    required this.status,
  });

  factory TTHDocument.fromJson(Map<String, dynamic> json) {
    return TTHDocument(
      tthNo: json['TTHNo'] ?? '',
      ttottPNo: json['TTOTTPNo'] ?? '',
      docDate: json['DocDate'] ?? '',
      received: json['Received'] ?? 0,
      receivedDate: json['ReceivedDate'],
      failedReason: json['FailedReason'],
      status: json['Status'] ?? 'Belum Diberikan',
    );
  }

  @override
  List<Object?> get props => [tthNo, ttottPNo, docDate, received, receivedDate, failedReason, status];
}