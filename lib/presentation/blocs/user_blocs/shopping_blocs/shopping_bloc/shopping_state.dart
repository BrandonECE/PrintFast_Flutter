part of 'shopping_bloc.dart';

enum ShoppingStatus { idle, loading, inProgress, itHasBeenCancelled, failure, failureByNoReception }

final class ShoppingState extends Equatable {
  const ShoppingState({
    required this.hasFile,
    required this.fileName,
    required this.bytes,
    required this.pages,
    required this.isColor,
    required this.isFormatCarta,
    required this.totalPrice,
    required this.isLoading,
    required this.shoppingStatus,
    required this.messageError
  });

  final bool isLoading;
  final bool hasFile;
  final Uint8List? bytes;
  final String fileName;
  final int pages;
  final bool isColor;
  final bool isFormatCarta;
  final double totalPrice;
  final ShoppingStatus shoppingStatus;
  final String? messageError;

  ShoppingState copyWith({
    bool? isLoading,
    bool? hasFile,
    Uint8List? bytes,
    String? fileName,
    int? pages,
    bool? isColor,
    bool? isFormatCarta,
    double? totalPrice,
    ShoppingStatus? shoppingStatus,
    String? messageError
  }) {
    return ShoppingState(
      isLoading: isLoading ?? this.isLoading,
      hasFile: hasFile ?? this.hasFile,
      bytes: bytes ?? this.bytes,
      fileName: fileName ?? this.fileName,
      pages: pages ?? this.pages,
      isColor: isColor ?? this.isColor,
      isFormatCarta: isFormatCarta ?? this.isFormatCarta,
      totalPrice: totalPrice ?? this.totalPrice,
      shoppingStatus: shoppingStatus ?? this.shoppingStatus,
      messageError: messageError ?? this.messageError
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    hasFile,
    bytes,
    fileName,
    pages,
    isColor,
    isFormatCarta,
    totalPrice,
    shoppingStatus,
    messageError
  ];
}

final class ShoppingInitial extends ShoppingState {
  const ShoppingInitial()
    : super(
        isLoading: false,
        hasFile: false,
        bytes: null,
        fileName: "exampe.pdf",
        isColor: false,
        isFormatCarta: false,
        pages: 4,
        totalPrice: 0,
        shoppingStatus: ShoppingStatus.idle,
        messageError: null
      );
}
