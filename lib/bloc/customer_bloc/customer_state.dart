part of 'customer_bloc.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final String selectedShop;
  final bool isRefreshing;
  final bool isUpdating;

  const CustomerLoaded({
    required this.customers,
    required this.filteredCustomers,
    required this.selectedShop,
    this.isRefreshing = false,
    this.isUpdating = false,
  });

  CustomerLoaded copyWith({
    List<Customer>? customers,
    List<Customer>? filteredCustomers,
    String? selectedShop,
    bool? isRefreshing,
    bool? isUpdating,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      selectedShop: selectedShop ?? this.selectedShop,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object> get props => [customers, filteredCustomers, selectedShop, isRefreshing, isUpdating];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError({required this.message});

  @override
  List<Object> get props => [message];
}