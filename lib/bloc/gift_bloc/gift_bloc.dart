import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/gift_summary_model.dart';
import '../../services/api_service.dart';

part 'gift_event.dart';
part 'gift_state.dart';

class GiftBloc extends Bloc<GiftEvent, GiftState> {
  final ApiService apiService;

  GiftBloc({required this.apiService}) : super(GiftInitial()) {
    on<LoadGiftSummary>(_onLoadGiftSummary);
  }

  void _onLoadGiftSummary(LoadGiftSummary event, Emitter<GiftState> emit) async {
    emit(GiftLoading());

    try {
      final gifts = await apiService.getGiftSummary();
      emit(GiftLoaded(gifts: gifts));
    } catch (e) {
      emit(GiftError(message: 'Failed to load gift summary: $e'));
    }
  }
}