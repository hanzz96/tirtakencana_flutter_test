import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/customer_model.dart';
import '../../services/api_service.dart';
import '../../utils/logger.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final ApiService apiService;

  CustomerBloc({required this.apiService}) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<FilterCustomersByShop>(_onFilterCustomersByShop);
    on<RefreshCustomers>(_onRefreshCustomers);
    on<ConfirmGiftAccept>(_onConfirmGiftAccept);
    on<ConfirmGiftReject>(_onConfirmGiftReject);
  }

  void _onLoadCustomers(LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());

    try {
      final customers = await apiService.getCustomers();

      emit(CustomerLoaded(
        customers: customers,
        filteredCustomers: customers,
        selectedShop: 'Semua Toko',
      ));
    } catch (e) {
      emit(CustomerError(message: 'Failed to load customers: $e'));
    }
  }

  void _onFilterCustomersByShop(FilterCustomersByShop event, Emitter<CustomerState> emit) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      List<Customer> filteredCustomers;

      if (event.shopName == 'Semua Toko') {
        filteredCustomers = currentState.customers;
      } else {
        filteredCustomers = currentState.customers
            .where((customer) => customer.name == event.shopName)
            .toList();
      }

      emit(currentState.copyWith(
        filteredCustomers: filteredCustomers,
        selectedShop: event.shopName,
      ));
    }
  }

  void _onRefreshCustomers(RefreshCustomers event, Emitter<CustomerState> emit) async {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      try {
        final customers = await apiService.getCustomers();
        emit(CustomerLoaded(
          customers: customers,
          filteredCustomers: customers,
          selectedShop: currentState.selectedShop,
        ));
      } catch (e) {
        emit(currentState.copyWith(isRefreshing: false));
        // Optionally show error message
      }
    }
  }
  void _onConfirmGiftAccept(ConfirmGiftAccept event, Emitter<CustomerState> emit) async {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      emit(currentState.copyWith(isUpdating: true));

      try {
        // HIT API gift-confirmation
        await apiService.confirmGift(
          custId: event.custId,
          action: 'terima',
          ttOtpNumbers: event.tthNumbers,
        );

        AppLogger.info('✅ Gift acceptance confirmed via API');

        // Reload data setelah update berhasil
        final customers = await apiService.getCustomers();
        emit(CustomerLoaded(
          customers: customers,
          filteredCustomers: customers,
          selectedShop: currentState.selectedShop,
          isUpdating: false, // Set kembali ke false
        ));
      } catch (e) {
        emit(CustomerError(message: 'Gagal menerima hadiah: $e'));
      }
    }
  }

  void _onConfirmGiftReject(ConfirmGiftReject event, Emitter<CustomerState> emit) async {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      emit(currentState.copyWith(isUpdating: true));

      try {
        // HIT API gift-confirmation dengan alasan
        await apiService.confirmGift(
          custId: event.custId,
          action: 'tolak',
          ttOtpNumbers: event.tthNumbers,
          failedReason: event.failedReason,
        );

        AppLogger.info('✅ Gift rejection confirmed via API');

        // Reload data setelah update berhasil
        final customers = await apiService.getCustomers();
        emit(CustomerLoaded(
          customers: customers,
          filteredCustomers: customers,
          selectedShop: currentState.selectedShop,
          isUpdating: false, // Set kembali ke false
        ));
      } catch (e) {
        AppLogger.error('❌ Failed to confirm gift rejection', e);
        emit(CustomerError(message: 'Gagal menolak hadiah: $e'));
      }
    }
  }
}