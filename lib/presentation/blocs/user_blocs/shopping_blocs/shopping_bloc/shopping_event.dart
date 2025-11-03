part of 'shopping_bloc.dart';

sealed class ShoppingEvent extends Equatable {
  const ShoppingEvent();

  @override
  List<Object?> get props => [];
}

final class ShoppingChangeHasFileEvent extends ShoppingEvent {
  const ShoppingChangeHasFileEvent({required this.hasFile});
  final bool hasFile;
  @override
  List<Object> get props => [hasFile];
}

final class ShoppingChangeTotalPriceEvent extends ShoppingEvent {
  const ShoppingChangeTotalPriceEvent({required this.totalPrice});
  final double totalPrice;
  @override
  List<Object> get props => [totalPrice];
}

final class ShoppingChangeFileNameEvent extends ShoppingEvent {
  const ShoppingChangeFileNameEvent({required this.fileName});
  final String fileName;
   @override
  List<Object> get props => [fileName]; 
}

final class ShoppingChangeNumPagesEvent extends ShoppingEvent {
  const ShoppingChangeNumPagesEvent({required this.pages});
  final int pages;
  @override
  List<Object> get props => [pages];
}

final class ShoppingChangeIsColorEvent extends ShoppingEvent {
  const ShoppingChangeIsColorEvent({required this.isColor});
  final bool isColor;
  @override
  List<Object> get props => [isColor];
}

final class ShoppingChangeIsFormatCartaEvent extends ShoppingEvent {
  const ShoppingChangeIsFormatCartaEvent({required this.isFormatCarta});
  final bool isFormatCarta;

  @override
  List<Object> get props => [isFormatCarta];
}

final class ShoppingChangeIsLoadingEvent extends ShoppingEvent {
  const ShoppingChangeIsLoadingEvent({required this.isLoading});
  final bool isLoading;
  @override
  List<Object> get props => [isLoading];
}

final class ShoppingChangeUint8ListBytesEvent extends ShoppingEvent {
  const ShoppingChangeUint8ListBytesEvent({required this.bytes});
  final Uint8List? bytes;
  @override
  List<Object?> get props => [bytes];
}

final class ShoppingChangeStatusEvent extends ShoppingEvent {
  const ShoppingChangeStatusEvent({required this.shoppingStatus, this.messageError});
  final ShoppingStatus shoppingStatus;
  final String? messageError;
  @override
  List<Object?> get props => [shoppingStatus, messageError];
}

final class ShoppingResetEvent extends ShoppingEvent {
  const ShoppingResetEvent({required this.shoppingStatus});
  final ShoppingStatus shoppingStatus;
  @override
  List<Object> get props => [shoppingStatus];
}