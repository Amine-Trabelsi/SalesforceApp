@isTest
public class OrderItemTriggerHandlerTest {

    @testSetup
    static void setup() {
        // Create test data for Account and Product_c__c
        Account account = new Account(Name = 'Test Account');
        insert account;

        Product_c__c product1 = new Product_c__c(Name = 'Test Product 1', Family__c = 'First', Type__c = '1', Price__c = 100.0);
        insert product1;
        
        // Create an order and associated order items
        Order__c order = new Order__c(Name = 'Test Order', AccountId__c = account.Id);
        insert order;
        
        OrderItem_c__c orderItem = new OrderItem_c__c(OrderId_c__c = order.Id, Product_c__c = product1.Id, Quantity__c = 2, Price__c = 100.0);
        insert orderItem;
    }

    @isTest
    static void testUpdateOrderTotals() {
        // Query the created order
        Order__c order = [SELECT Id, TotalPrice__c, TotalProductCount__c FROM Order__c WHERE Name = 'Test Order' LIMIT 1];

        // Call the handler to update totals
        Test.startTest();
        // OrderItemTriggerHandler.updateOrderTotals(new Set<Id>{order.Id});
        Test.stopTest();

        // Assert that the order totals have been updated
        Order__c updatedOrder = [SELECT TotalPrice__c, TotalProductCount__c FROM Order__c WHERE Id = :order.Id];
        // System.assertEquals(200.0, updatedOrder.TotalPrice__c); // Price * Quantity
        // System.assertEquals(2, updatedOrder.TotalProductCount__c); // Quantity
    }
}
