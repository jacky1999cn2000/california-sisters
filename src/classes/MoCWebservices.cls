global class MoCWebservices {

  webservice static void updatePacketStatus(Id packetId, String status){
    Packet__c packet = [SELECT Id, Status__c FROM Packet__c WHERE Id =: packetId];
    packet.Status__c = status;

    List<OrderLineItem__c> orderLineItemList = [SELECT Id, Status__c FROM OrderLineItem__c WHERE Packet__c =: packetId];
    for (OrderLineItem__c orderLineItem : orderLineItemList) {
      orderLineItem.Status__c = status;
    }

    update packet;
    update orderLineItemList;
  }

}