public with sharing class OrderItemTriggerHandler {
    public static void updateOrderTotals(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return;
        }

        // Map to hold Order updates
        Map<Id, Order__c> ordersToUpdate = new Map<Id, Order__c>();

        // Query OrderItem__c and aggregate total quantity & total price
        List<AggregateResult> aggregatedResults = [
            SELECT OrderId__c orderId, 
                   SUM(Quantity__c) totalQuantity, 
                   SUM(Price__c) totalPrice
            FROM OrderItem_c__c
            WHERE OrderId__c IN :orderIds
            GROUP BY OrderId__c
        ];

        for (AggregateResult result : aggregatedResults) {
            Id orderId = (Id) result.get('orderId');
            Decimal totalQuantity = (Decimal) result.get('totalQuantity');
            Decimal totalPrice = (Decimal) result.get('totalPrice');

            // Create an Order update record
            Order__c orderToUpdate = new Order__c(
                Id = orderId,
                TotalProductCount__c = totalQuantity,
                TotalPrice__c = totalPrice
            );
            ordersToUpdate.put(orderId, orderToUpdate);
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate.values();
        }
    }
}
