public with sharing class OrderHelper {
    public OrderHelper() {

    }

    public static List<OrderItem> checkRecalcItens(Map<Id, Order> oldMap, Map<Id, Order> newMap){
        Set<Id> orderIds = new Set<Id>();

        for(Order newOrder : newMap.values()) {
            Order oldOrder = oldMap.get(newOrder.Id);

            if(newOrder.DistribuitionCenter__c != oldOrder.DistribuitionCenter__c){
                orderIds.add(newOrder.id);
            }
        }

        List<OrderItem> orderItemList = [
            SELECT Id, ListPrice, Product2Id, OrderId
            FROM OrderItem
            WHERE OrderId IN : orderIds
        ];

        List<OrderItem> updatedOrderItemList = OrderItemHelper.calcPrice(orderItemList);

        return updatedOrderItemList;
    }
    
}
