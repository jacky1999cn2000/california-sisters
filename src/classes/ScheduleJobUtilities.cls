public class ScheduleJobUtilities {

  /*
     update customer monthly spending and total spending
   */
  public static void updateCustomerInfo(){
    // retrieve all customers
    List<Customer__c> customerList = [SELECT Id, Total_Spending_RMB__c, Monthly_Spending_RMB__c FROM Customer__c];

    // retrieve this month's all orders
    List<Order__c> orderList = [SELECT Customer__c,Total_Price_RMB__c FROM Order__c WHERE CreatedDate = THIS_MONTH];

    // create a spending map - key as customerId, value as this monthly total spending
    Map<Id, Decimal> spendingMap = new Map<Id, Decimal>();
    for(Order__c order : orderList) {
      if(spendingMap.get(order.Customer__c) == null) {
        spendingMap.put(order.Customer__c, order.Total_Price_RMB__c);
      }else{
        spendingMap.put(order.Customer__c, spendingMap.get(order.Customer__c) + order.Total_Price_RMB__c);
      }
    }

    // update customer info
    for(Customer__c customer : customerList) {
      customer.Monthly_Spending_RMB__c = spendingMap.keySet().contains(customer.Id) ? spendingMap.get(customer.Id) : 0;
      customer.Total_Spending_RMB__c = spendingMap.keySet().contains(customer.Id) ? customer.Total_Spending_RMB__c + spendingMap.get(customer.Id) : customer.Total_Spending_RMB__c + 0;
    }

    update customerList;
  }

  /*
     update FI STATS
   */
  public static void updateFISTATS(){
    // retrieve this month's total revenue and total cost
    AggregateResult[] arList = [SELECT SUM(Total_Cost_RMB__c) totalCost,SUM(Total_Price_RMB__c) totalRevenue FROM Order__c WHERE CreatedDate = THIS_MONTH];
    Decimal totalRevenue = Decimal.valueOf(String.valueOf(arList[0].get('totalRevenue')));
    Decimal totalCost = Decimal.valueOf(String.valueOf(arList[0].get('totalCost')));

    // retrieve this month's packet fees
    AggregateResult[] arList2 = [SELECT SUM(Cost_RMB__c) packetFeeTotal FROM Packet__c WHERE CREATEDDATE = THIS_MONTH];
    Decimal packetFeeTotal = Decimal.valueOf(String.valueOf(arList2[0].get('packetFeeTotal')));

    // insert a fiStats record
    FI_STATS__c fiStats = new FI_STATS__c();
    fiStats.Revenue_RMB__c = totalRevenue;
    fiStats.Profit_RMB__c = totalRevenue - totalCost - packetFeeTotal;
    insert fiStats;
  }

  /*
     update product info
   */
  public static void updateProductInfo(){
    // retrieve all products
    List<Product__c> productList = [SELECT Id, Current_Profit_RMB__c, Current_Revenue_RMB__c, Current_Quantity__c, Total_Profit_RMB__c, Total_Revenue_RMB__c, Total_Quantity__c FROM Product__c];

    // retrieve this month's sold products' total revenue and cost
    AggregateResult[] arList = [SELECT Product__c, SUM(Cost_RMB__c) totalCost, SUM(Price_RMB__c) totalRevenue, COUNT(Id) soldQuantities FROM OrderLineItem__c WHERE CREATEDDATE = THIS_MONTH GROUP BY Product__c];

    // create a productInfo map - key as productId, value as another map (key as 'totalCost', 'totalRevenue', 'soldQuantities', value as corresponding value)
    Map<Id, Map<String, String>> productInfoMap = new Map<Id, Map<String, String>>();
    for(AggregateResult ar : arList) {
      Map<String, String> productInfo = new Map<String, String>();
      productInfo.put('totalCost', String.valueOf(ar.get('totalCost')));
      productInfo.put('totalRevenue', String.valueOf(ar.get('totalRevenue')));
      productInfo.put('soldQuantities', String.valueOf(ar.get('soldQuantities')));
      productInfoMap.put(Id.valueOf(String.valueOf(ar.get('Product__c'))), productInfo);
    }

    // update product info
    for(Product__c product : productList) {
      product.Current_Quantity__c = productInfoMap.keySet().contains(product.Id) ? Integer.valueOf(productInfoMap.get(product.Id).get('soldQuantities')) : 0;
      product.Current_Revenue_RMB__c = productInfoMap.keySet().contains(product.Id) ? Decimal.valueOf(productInfoMap.get(product.Id).get('totalRevenue')) : 0;
      product.Current_Profit_RMB__c = productInfoMap.keySet().contains(product.Id) ? Decimal.valueOf(productInfoMap.get(product.Id).get('totalRevenue')) - Decimal.valueOf(productInfoMap.get(product.Id).get('totalCost')) : 0;

      product.Total_Quantity__c = productInfoMap.keySet().contains(product.Id) ? product.Total_Quantity__c + Integer.valueOf(productInfoMap.get(product.Id).get('soldQuantities')) : product.Total_Quantity__c + 0;
      product.Total_Revenue_RMB__c = productInfoMap.keySet().contains(product.Id) ? product.Total_Revenue_RMB__c + Decimal.valueOf(productInfoMap.get(product.Id).get('totalRevenue')) : product.Total_Revenue_RMB__c + 0;
      product.Total_Profit_RMB__c = productInfoMap.keySet().contains(product.Id) ? product.Total_Profit_RMB__c + Decimal.valueOf(productInfoMap.get(product.Id).get('totalRevenue')) - Decimal.valueOf(productInfoMap.get(product.Id).get('totalCost')) : product.Total_Profit_RMB__c + 0;
    }

    update productList;
  }

}
