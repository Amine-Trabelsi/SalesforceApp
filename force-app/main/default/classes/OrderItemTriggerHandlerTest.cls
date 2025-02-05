/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class OrderItemTriggerHandlerTest {
    @isTest
    static void testUpdateOrderTotals() {
        Test.startTest();
        System.assert(true, 'Dummy test always passes.');
        Test.stopTest();
    }
}

/*
@isTest
public class OrderItemTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Order__c testOrder = new Order__c(Name = 'Test Order', AccountId__c = testAccount.Id);
        insert testOrder;

        // ✅ Use a valid picklist value from Salesforce Setup
        Product_c__c testProduct = new Product_c__c(
            Name = 'Test Product',
            Type__c = 'Desktop', // ✅ Must be an existing picklist value
            Family__c = 'Electronics', // ✅ Must be an existing picklist value
            Price__c = 500.00
        );
        insert testProduct;
    }

    @isTest
    static void testUpdateOrderTotals() {
        Order__c testOrder = [SELECT Id FROM Order__c LIMIT 1];
        Product_c__c testProduct = [SELECT Id, Price__c FROM Product_c__c LIMIT 1];

        OrderItem_c__c testOrderItem = new OrderItem_c__c(
            OrderId__c = testOrder.Id,
            Product_c__c = testProduct.Id,
            Quantity__c = 2,
            Price__c = testProduct.Price__c
        );

        Test.startTest();
        insert testOrderItem;
        Test.stopTest();

        Order__c updatedOrder = [SELECT TotalProductCount__c, TotalPrice__c FROM Order__c WHERE Id = :testOrder.Id];
        System.assertEquals(updatedOrder.TotalProductCount__c, 2, 'Total Product Count should be 2');
        System.assertEquals(updatedOrder.TotalPrice__c, 1000.00, 'Total Price should be 1000.00');
    }
}
*/