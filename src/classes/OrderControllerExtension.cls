public class OrderControllerExtension {

  private final sObject order;

  public OrderControllerExtension(ApexPages.StandardController stdController) {
    this.order = (Order__c)stdController.getRecord();
  }

  @RemoteAction
  public static Map<String, String> getMajorCategories() {
    Map<String, String> optionsMap = new Map<String, String>();
    List<Schema.PicklistEntry> pleList = Product__c.Major_Category__c.getDescribe().getPicklistValues();

    for (Schema.PicklistEntry ple : pleList) {
      String label = ple.getLabel();
      String value = ple.getValue();
      optionsMap.put(label, value);
    }

    return optionsMap;
  }

  @RemoteAction
  public static Map<String, String> getMinorCategories(String majorCategory) {
    //***result {Apparel={内衣=NeiYi, 鞋=Xie}, Edible={保健品=BaoJianPin, 零食=LingShi}, Makeup={彩妆=CaiZhuang, 护肤=HuFu}}
    Map<String, Map<String,String>> result = HL_FieldDescribeUtil.getDependentOptionsImpl(Product__c.Minor_Category__c, Product__c.Major_Category__c);
    return result.get(majorCategory);
  }

  @RemoteAction
  public static Map<String, String> getBrands(String minorCategory) {
    //***result {BaoJianPin={保健品品牌一=BaoJianPinPinPai1, 保健品品牌二=BaoJianPinPinPai2}, CaiZhuang={彩妆品牌一=CaiZhuangPinPai1, 彩妆品牌二=CaiZhuangPinPai2}, HuFu={护肤品牌一=HuFuPinPai1, 护肤品牌二=HuFuPinPai2}, LingShi={零食品牌一=LingShiPinPai1, 零食品牌二=LingShiPinPai2}, NeiYi={内衣品牌一=NeiYiPinPai1, 内衣品牌二=NeiYiPinPai2}, Xie={鞋品牌一=XiePinPai1, 鞋品牌二=XiePinPai2}}
    Map<String, Map<String,String>> result = HL_FieldDescribeUtil.getDependentOptionsImpl(Product__c.Brand__c, Product__c.Minor_Category__c);
    return result.get(minorCategory);
  }

}
