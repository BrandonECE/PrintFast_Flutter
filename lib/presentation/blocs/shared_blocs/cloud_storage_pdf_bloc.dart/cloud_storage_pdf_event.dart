part of 'cloud_storage_pdf_bloc.dart';

sealed class CloudStoragePdfEvent extends Equatable {
  const CloudStoragePdfEvent();

  @override
  List<Object?> get props => [];
}

final class ChangePdfFileFromCloudStorageEvent extends CloudStoragePdfEvent {
  const ChangePdfFileFromCloudStorageEvent({
    required this.fileFromCloudStorage,
  });
  final Uint8List? fileFromCloudStorage;
  @override
  List<Object?> get props => [fileFromCloudStorage];
}

final class ChangeStatusPdfFileFromCloudStorageEvent
    extends CloudStoragePdfEvent {
  const ChangeStatusPdfFileFromCloudStorageEvent({
    required this.cloudStoragePdfViewStatus,
  });
  final CloudStoragePdfViewStatus cloudStoragePdfViewStatus;
  @override
  List<Object?> get props => [cloudStoragePdfViewStatus];
}


final class ChangeStatusPdfFileFromCloudStorageToPrintEvent extends CloudStoragePdfEvent {
  const ChangeStatusPdfFileFromCloudStorageToPrintEvent({
    required this.cloudStoragePrintPdfStatus,
  });
  final CloudStoragePrintPdfStatus cloudStoragePrintPdfStatus;
  @override
  List<Object?> get props => [cloudStoragePrintPdfStatus];
}
