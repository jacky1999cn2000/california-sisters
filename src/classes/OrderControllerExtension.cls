public class OrderControllerExtension {

  private final sObject order;

  public OrderControllerExtension(ApexPages.StandardController stdController) {
    this.order = (Order__c)stdController.getRecord();
  }

  @RemoteAction
  public static String getMajorCategories() {
    Map<String, List<String>> result = HL_FieldDescribeUtil.getDependentOptionsImpl(Product__c.Minor_Category__c, Product__c.Major_Category__c);
    System.debug('***result '+result);
    return 'test';
  }

}
