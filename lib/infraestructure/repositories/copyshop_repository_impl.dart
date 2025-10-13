import 'package:printfast_rebuild/domain/entities/all_entities/copyshop_entity.dart';
import 'package:printfast_rebuild/domain/repositories/copyshop_repository.dart';
import 'package:printfast_rebuild/domain/services/copyshop_service.dart';

class CopyshopRepositoryImpl extends CopyshopRepository {
  final CopyshopService copyshopServices;
  CopyshopRepositoryImpl({required this.copyshopServices});

  @override
  Future<CopyShopEntity> getCopyShopInfo(String adminLocationByEmail) {
    try {
      return copyshopServices.getCopyShopInfo(adminLocationByEmail);
    } catch (e) {
      return Future.error(e);
    }
  }
}
