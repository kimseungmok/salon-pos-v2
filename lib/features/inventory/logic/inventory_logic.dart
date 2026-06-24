import '../../../db/app_database.dart';

/// design/spec/v3/inventory/data_spec.md statusOf() 그대로. F-INV-01.
enum InventoryStatus { normal, low, outOfStock }

const Map<InventoryStatus, String> kInventoryStatusLabel = {
  InventoryStatus.normal: '正常',
  InventoryStatus.low: '不足',
  InventoryStatus.outOfStock: '品切れ',
};

InventoryStatus statusOf(InventoryItemRow item) {
  if (item.quantity == 0) return InventoryStatus.outOfStock;
  if (item.quantity < item.threshold) return InventoryStatus.low;
  return InventoryStatus.normal;
}
