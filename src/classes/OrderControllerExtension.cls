public class OrderControllerExtension {

  private final sObject order;

  /* properties used for pagination */
  public Integer noOfRecords { get; set; }
  public Integer size { get; set; }

  public OrderControllerExtension(ApexPages.StandardController stdController) {
    this.order = (Order__c)stdController.getRecord();
  }

  /* StandardSetController for pagination */
  public ApexPages.StandardSetController setCon {
    get {
      if(setCon == null) {
        size = 5;
        String queryString = 'SELECT Name, Major_Category__c, Minor_Category__c, Brand__c, Total_Quantity__c FROM Product__c ORDER BY Total_Quantity__c DESC';
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
      }

      return setCon;
    }
    set;
  }

  /*
     get function for products
   */
  public List<Product__c> getProducts(){
    List<Product__c> producntsList = new List<Product__c>();
    if(setCon != null) {
      for(Product__c product : (List<Product__c>)setCon.getRecords())
        producntsList.add(product);
    }

    return producntsList;
  }

  /*
     get picklist values for majorCategory selector
   */
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

  /*
     get picklist values for minorCategory selector
   */
  @RemoteAction
  public static Map<String, String> getMinorCategories(String majorCategory) {
    //***result {Apparel={内衣=NeiYi, 鞋=Xie}, Edible={保健品=BaoJianPin, 零食=LingShi}, Makeup={彩妆=CaiZhuang, 护肤=HuFu}}
    Map<String, Map<String,String>> result = HL_FieldDescribeUtil.getDependentOptionsImpl(Product__c.Minor_Category__c, Product__c.Major_Category__c);
    return result.get(majorCategory);
  }

  /*
     get picklist values for brand selector
   */
  @RemoteAction
  public static Map<String, String> getBrands(String minorCategory) {
    //***result {BaoJianPin={保健品品牌一=BaoJianPinPinPai1, 保健品品牌二=BaoJianPinPinPai2}, CaiZhuang={彩妆品牌一=CaiZhuangPinPai1, 彩妆品牌二=CaiZhuangPinPai2}, HuFu={护肤品牌一=HuFuPinPai1, 护肤品牌二=HuFuPinPai2}, LingShi={零食品牌一=LingShiPinPai1, 零食品牌二=LingShiPinPai2}, NeiYi={内衣品牌一=NeiYiPinPai1, 内衣品牌二=NeiYiPinPai2}, Xie={鞋品牌一=XiePinPai1, 鞋品牌二=XiePinPai2}}
    Map<String, Map<String,String>> result = HL_FieldDescribeUtil.getDependentOptionsImpl(Product__c.Brand__c, Product__c.Minor_Category__c);
    return result.get(minorCategory);
  }

}
