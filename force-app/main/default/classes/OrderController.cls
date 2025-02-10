public with sharing class OrderController {
    @AuraEnabled
    public static String createOrder(String orderJson) {
        // Deserialize the JSON into a map
        Map<String, Object> orderData = (Map<String, Object>) JSON.deserializeUntyped(orderJson);

        // Extract values safely
        List<Object> cartItemsRaw = (List<Object>) orderData.get('cartItems');
        //List<Map<String, Object>> cartItemsRaw = (List<Map<String, Object>>) orderData.get('cartItems');

        String accountId = (String) orderData.get('accountId');

        if (cartItemsRaw == null || cartItemsRaw.isEmpty()) {
            throw new AuraHandledException('Cart is empty. Cannot create an order.');
        }

        if (accountId == null) {
            throw new AuraHandledException('Account ID is required to create an order.');
        }

        List<OrderItemWrapper> cartItems = new List<OrderItemWrapper>();
        for (Object item : cartItemsRaw) {
            Map<String, Object> itemMap = (Map<String, Object>) item;
            OrderItemWrapper orderItem = new OrderItemWrapper();
            orderItem.productId = (String) itemMap.get('productId');
            orderItem.price = (Decimal) itemMap.get('price');
            orderItem.quantity = ((Decimal) itemMap.get('quantity')).intValue();
            cartItems.add(orderItem);
        }

        
        
        // Calculate total price and total product count
        Decimal totalPrice = 0;
        Integer totalProductCount = 0;

        for (OrderItemWrapper item : cartItems) {
            totalPrice += item.price * item.quantity;
            totalProductCount += item.quantity;
        }
        try {
            //Create Order record
            Order__c newOrder = new Order__c(
                Name = 'Order - ' + DateTime.now().format(),
                AccountId__c = accountId,  // FIX: Ensure it's 'AccountId' (not 'AccountId__c')
                TotalProductCount__c = totalProductCount,
                TotalPrice__c = totalPrice
            );
            Database.SaveResult orderResult = Database.insert(newOrder);

            if (!orderResult.isSuccess()) {
                throw new AuraHandledException('Failed to create Order.');
            }

            // return newOrder.Id;
            // Create Order Items
            List<OrderItem_c__c> orderItems = new List<OrderItem_c__c>();
            for (OrderItemWrapper item : cartItems) {
                OrderItem_c__c orderItem = new OrderItem_c__c(
                    OrderId_c__c = newOrder.Id,
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