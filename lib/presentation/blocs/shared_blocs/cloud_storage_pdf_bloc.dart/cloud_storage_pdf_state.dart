part of 'cloud_storage_pdf_bloc.dart';

enum CloudStoragePdfViewStatus { loading, success, failure }

enum CloudStoragePrintPdfStatus { initial, loading, failure }

final class CloudStoragePdfState extends Equatable {
  const CloudStoragePdfState({
    required this.fileFromCloudStorage,
    required this.cloudStoragePdfViewStatus,
    required this.cloudStoragePrintPdfStatus,
  });
  final Uint8List? fileFromCloudStorage;
  final CloudStoragePdfViewStatus cloudStoragePdfViewStatus;
  final CloudStoragePrintPdfStatus cloudStoragePrintPdfStatus;

  CloudStoragePdfState copyWith({
    Uint8List? fileFromCloudStorage,
    CloudStoragePdfViewStatus? cloudStoragePdfViewStatus,
    CloudStoragePrintPdfStatus? cloudStoragePrintPdfStatus,
  }) {
    return CloudStoragePdfState(
      fileFromCloudStorage: fileFromCloudStorage ?? this.fileFromCloudStorage,
      cloudStoragePdfViewStatus:
          cloudStoragePdfViewStatus ?? this.cloudStoragePdfViewStatus,
      cloudStoragePrintPdfStatus:
          cloudStoragePrintPdfStatus ?? this.cloudStoragePrintPdfStatus,
    );
  }

  @override
  List<Object?> get props => [
    fileFromCloudStorage,
    cloudStoragePdfViewStatus,
    cloudStoragePrintPdfStatus,
  ];
}

final class CloudStoragePdfViewInitial extends CloudStoragePdfState {
  const CloudStoragePdfViewInitial()
    : super(
        fileFromCloudStorage: null,
        cloudStoragePdfViewStatus: CloudStoragePdfViewStatus.loading,
        cloudStoragePrintPdfStatus: CloudStoragePrintPdfStatus.initial,
      );
}
