import 'package:printfast_rebuild/domain/entities/entities.dart';

abstract class CopyshopRepository {
  Future<CopyShopEntity> getCopyShopInfo(String adminLocationByEmail);
}
