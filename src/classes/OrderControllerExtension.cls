public class OrderControllerExtension {

  private final sObject order;

  /* properties used for pagination */
  public Integer noOfRecords { get; set; }
  public Integer size { get; set; }

  /* parameters used for searching products (passed in by javascript function) */
  public String productName { get; set; }
  public String majorCategory { get; set; }
  public String minorCategory { get; set; }
  public String brand { get; set; }

  /* comma delimited product ids for selected products (passed in by javascript function) */
  public String productIds { get; set; }

  public OrderControllerExtension(ApexPages.StandardController stdController) {
    this.order = (Order__c)stdController.getRecord();
  }

  /* StandardSetController for pagination */
  public ApexPages.StandardSetController setCon {
    get {
      if(setCon == null) {
        size = 5;
        String queryString = this.constructQuery(productName,majorCategory,minorCategory,brand);
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
      }

      return setCon;
    }
    set;
  }

  /*
     get SOQL query
   */
  private String constructQuery(String productName, String majorCategory, String minorCategory, String brand){
    System.debug('***constructQuery');
    System.debug('***name '+productName);
    System.debug('***major '+majorCategory);
    System.debug('***minor '+minorCategory);
    System.debug('***brand '+brand);

    String query = 'SELECT Name, Major_Category__c, Minor_Category__c, Brand__c, Total_Quantity__c FROM Product__c';

    if(productName != null && productName.trim() != '') {
      query += ' WHERE Name LIKE \'%' + productName + '%\'';
    }

    if(majorCategory != null && majorCategory != 'novalue') {
      if(query.contains('WHERE')) {
        query += ' AND Major_Category__c = \'' + majorCategory + '\'';
      }else{
        query += ' WHERE Major_Category__c = \'' + majorCategory + '\'';
      }
    }

    if(minorCategory != null && minorCategory != 'novalue') {
      if(query.contains('WHERE')) {
        query += ' AND Minor_Category__c = \'' + minorCategory + '\'';
      }else{
        query += ' WHERE Minor_Category__c = \'' + minorCategory + '\'';
      }
    }

    if(brand != null && brand != 'novalue') {
      if(query.contains('WHERE')) {
        query += ' AND Brand__c = \'' + brand + '\'';
      }else{
        query += ' WHERE Brand__c = \'' + brand + '\'';
      }
    }

    query += ' ORDER BY Total_Quantity__c DESC';

    System.debug('***query '+query);
    return query;
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
     search for products
   */
  public PageReference searchProducts(){
    setCon = null;
    getProducts();
    setCon.setPageNumber(1);
    return null;
  }

  /*
     select products
   */
  public PageReference selectProducts(){
    return null;
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
