import 'package:printfast_rebuild/domain/entities/copyshop_entity.dart';

abstract class CopyshopServices {
  Future<CopyShopEntity> getCopyShopInfo(String adminLocationByEmail);
}