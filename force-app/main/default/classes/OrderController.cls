public with sharing class OrderController {
    @AuraEnabled
    public static String createOrder(List<OrderItemWrapper> cartItems, Id accountId) {
        if (cartItems == null || cartItems.isEmpty()) {
            throw new AuraHandledException('Cart is empty. Cannot create an order.');
        }
        
        if (accountId == null) {
            throw new AuraHandledException('Account ID is required to create an order.');
        }

        // Calculate total price and total product count
        Decimal totalPrice = 0;
        Integer totalProductCount = 0;

        for (OrderItemWrapper item : cartItems) {
            totalPrice += item.price * item.quantity;
            totalProductCount += item.quantity;
        }

        try {
            // Create Order record
            Order__c newOrder = new Order__c(
                Name = 'Order - ' + DateTime.now().format(),
                AccountId__c = accountId,  // FIX: Ensure it's 'AccountId' (not 'AccountId__c')
                TotalProductCount__c = totalProductCount,
                TotalPrice__c = totalPrice
            );
            insert newOrder;

            // Create Order Items
            List<OrderItem_c__c> orderItems = new List<OrderItem_c__c>();
            for (OrderItemWrapper item : cartItems) {
                OrderItem_c__c orderItem = new OrderItem_c__c(
                    OrderId__c = newOrder.Id,
                    Product_c__c = item.productId,  // FIX: Ensure this matches Product__c API name
                    Quantity__c = item.quantity,
                    Price__c = item.price
                );
                orderItems.add(orderItem);
            }

            insert orderItems;

            return newOrder.Id; // Return created Order ID

        } catch (Exception e) {
            throw new AuraHandledException('Failed to create order: ' + e.getMessage());
        }
    }

    // Wrapper class for cart items
    public class OrderItemWrapper {
        @AuraEnabled public String productId;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Integer quantity;
    }
}
