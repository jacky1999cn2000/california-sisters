public with sharing class PacketControllerExtension {

  private final sObject packet;

  /* properties used for pagination */
  public Integer noOfRecords { get; set; }
  public Integer size { get; set; }

  /* parameters used for searching order line items (passed in by javascript function) */
  public String customerId { get; set; }
  public String productId { get; set; }

  /* comma delimited order line item ids for selected order line items (passed in by javascript function) */
  public String orderLineItemIds { get; set; }

  /* comma delimited order line item ids for order line items that need to be removed from current packet (passed in by javascript function) */
  public String removeOrderLineItemIds { get; set; }

  public PacketControllerExtension(ApexPages.StandardController stdController) {
    this.packet = (Packet__c)stdController.getRecord();
  }

  /* StandardSetController for pagination */
  public ApexPages.StandardSetController setCon {
    get {
      if(setCon == null) {
        size = 10;
        String queryString = this.constructQuery(productId,customerId);
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
  private String constructQuery(String productId, String customerId){

    String query = 'SELECT Id, Name, Order__r.Customer__r.Name, Product__r.Name, Price_RMB__c, Cost_RMB__c FROM OrderLineItem__c WHERE Status__c = \'Undelivered\' AND Packet__c = NULL';

    if(customerId != null && customerId != 'novalue') {
      query += ' AND Order__r.Customer__c = \'' + customerId + '\'';
    }

    if(productId != null && productId != 'novalue') {
      query += ' AND Product__c = \'' + productId + '\'';
    }

    System.debug('***query '+query);
    return query;
  }

  /*
     get function for order line items
   */
  public List<OrderLineItem__c> getOrderLineItems(){
    List<OrderLineItem__c> orderLineItemList = new List<OrderLineItem__c>();
    if(setCon != null) {
      for(OrderLineItem__c orderLineItem : (List<OrderLineItem__c>)setCon.getRecords())
        orderLineItemList.add(orderLineItem);
    }

    return orderLineItemList;
  }

  /*
     get function for selected order line items
   */
  public List<OrderLineItem__c> getSelectedOrderLineItems(){
    List<OrderLineItem__c> orderLineItemList = [SELECT Id, Name, Order__r.Customer__r.Name, Product__r.Name, Price_RMB__c, Cost_RMB__c FROM OrderLineItem__c WHERE Packet__c = : this.packet.Id];
    return orderLineItemList;
  }

  /*
     search for order line items
   */
  public PageReference searchOrderLineItems(){
    setCon = null;
    getOrderLineItems();
    setCon.setPageNumber(1);
    return null;
  }

  /*
     select order line items
   */
  public PageReference selectOrderLineItems(){
    if(orderLineItemIds != null && orderLineItemIds.trim() != '') {
      List<String> orderLineItemIdList = orderLineItemIds.split(',');
      List<OrderLineItem__c> orderLineItemList = [SELECT Id, Packet__c FROM OrderLineItem__c WHERE Id IN : orderLineItemIdList];
      for (OrderLineItem__c orderLineItem : orderLineItemList) {
        orderLineItem.Packet__c = this.packet.Id;
      }
      update orderLineItemList;
    }

    PageReference pr = new PageReference('/'+this.packet.Id);
    pr.setRedirect(true);
    return pr;
  }

  /*
     remove order line items
   */
  public PageReference removeOrderLineItems(){
    if(removeOrderLineItemIds != null && removeOrderLineItemIds.trim() != '') {
      List<String> orderLineItemIdList = removeOrderLineItemIds.split(',');
      List<OrderLineItem__c> orderLineItemList = [SELECT Id, Packet__c FROM OrderLineItem__c WHERE Id IN : orderLineItemIdList];
      for (OrderLineItem__c orderLineItem : orderLineItemList) {
        orderLineItem.Packet__c = null;
      }
      update orderLineItemList;
    }

    PageReference pr = new PageReference('/'+this.packet.Id);
    pr.setRedirect(true);
    return pr;
  }

  /*
     get picklist values for customerName selector
   */
  @RemoteAction
  public static Map<String, String> getCustomerNames() {
    Map<String, String> optionsMap = new Map<String, String>();
    List<OrderLineItem__c> orderLineItemList = [SELECT Order__r.Customer__c, Order__r.Customer__r.Name FROM OrderLineItem__c WHERE Status__c = 'Undelivered' AND Packet__c = NULL];

    for (OrderLineItem__c orderLineItem : orderLineItemList) {
      optionsMap.put(orderLineItem.Order__r.Customer__r.Name, String.valueOf(orderLineItem.Order__r.Customer__c));
    }

    return optionsMap;
  }

  /*
     get picklist values for productName selector
   */
  @RemoteAction
  public static Map<String, String> getProductNames() {
    Map<String, String> optionsMap = new Map<String, String>();
    List<OrderLineItem__c> orderLineItemList = [SELECT Product__c, Product__r.Name FROM OrderLineItem__c WHERE Status__c = 'Undelivered' AND Packet__c = NULL];

    for (OrderLineItem__c orderLineItem : orderLineItemList) {
      optionsMap.put(orderLineItem.Product__r.Name, String.valueOf(orderLineItem.Product__c));
    }

    return optionsMap;
  }

}
