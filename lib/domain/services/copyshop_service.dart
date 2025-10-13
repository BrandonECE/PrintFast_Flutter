
import 'package:printfast_rebuild/domain/entities/all_entities/copyshop_entity.dart';

abstract class CopyshopService {
  Future<CopyShopEntity> getCopyShopInfo(String adminLocationByEmail);
    /// Sube bytes del PDF y devuelve la ruta relativa en el bucket, p.ej. "orders/{registration}/{pdfName}"

}
