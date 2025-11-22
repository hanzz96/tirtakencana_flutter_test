part of 'gift_bloc.dart';

abstract class GiftState extends Equatable {
  const GiftState();

  @override
  List<Object> get props => [];
}

class GiftInitial extends GiftState {}

class GiftLoading extends GiftState {}

class GiftLoaded extends GiftState {
  final List<GiftSummary> gifts;

  const GiftLoaded({required this.gifts});

  @override
  List<Object> get props => [gifts];
}

class GiftError extends GiftState {
  final String message;

  const GiftError({required this.message});

  @override
  List<Object> get props => [message];
}