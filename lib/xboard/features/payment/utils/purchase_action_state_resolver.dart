class PurchaseActionStateResolver {
  static bool shouldShowProcessing({required bool isSubmittingPurchase}) {
    return isSubmittingPurchase;
  }
}
