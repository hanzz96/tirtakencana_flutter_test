part of 'customer_bloc.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object> get props => [];
}

class LoadCustomers extends CustomerEvent {}

class RefreshCustomers extends CustomerEvent {}

class FilterCustomersByShop extends CustomerEvent {
  final String shopName;

  const FilterCustomersByShop(this.shopName);

  @override
  List<Object> get props => [shopName];
}


// Events baru untuk konfirmasi hadiah
class ConfirmGiftAccept extends CustomerEvent {
  final String custId;
  final List<String> tthNumbers;

  const ConfirmGiftAccept({required this.custId, required this.tthNumbers});

  @override
  List<Object> get props => [custId, tthNumbers];
}

class ConfirmGiftReject extends CustomerEvent {
  final String custId;
  final List<String> tthNumbers;
  final String failedReason;

  const ConfirmGiftReject({
    required this.custId,
    required this.tthNumbers,
    required this.failedReason,
  });

  @override
  List<Object> get props => [custId, tthNumbers, failedReason];
}

class UpdateGiftStatus extends CustomerEvent {
  final int tthId;
  final String action; // 'terima' untuk ubah dari tolak ke terima

  const UpdateGiftStatus({required this.tthId, required this.action});

  @override
  List<Object> get props => [tthId, action];
}