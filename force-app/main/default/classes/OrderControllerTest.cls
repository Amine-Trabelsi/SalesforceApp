@isTest
public class OrderControllerTest {

    @testSetup
    static void setup() {
        // Create test data for Account and Product_c__c
        Account account = new Account(Name = 'Test Account');
        insert account;

        Product_c__c product1 = new Product_c__c(Name = 'Test Product 1', Family__c = 'First', Type__c = '1', Price__c = 100.0);
        Product_c__c product2 = new Product_c__c(Name = 'Test Product 2', Family__c = 'Second', Type__c = '2', Price__c = 200.0);
        insert new List<Product_c__c>{product1, product2};
    }

    @isTest
    static void testCreateOrder() {
        // Create test data
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Product_c__c product = [SELECT Id, Price__c FROM Product_c__c WHERE Name = 'Test Product 1' LIMIT 1];

        // Prepare JSON for creating an order
        String orderJson = '{"accountId": "' + account.Id + '", "cartItems": [{"productId": "' + product.Id + '", "price": ' + product.Price__c + ', "quantity": 2}]}';

        Test.startTest();
        String orderId = OrderController.createOrder(orderJson);
        Test.stopTest();

        // Assert that an Order was created
        Order__c createdOrder = [SELECT Id, TotalPrice__c, TotalProductCount__c FROM Order__c WHERE Id = :orderId];
        System.assertNotEquals(null, createdOrder);
        System.assertEquals(200.0, createdOrder.TotalPrice__c);
        System.assertEquals(2, createdOrder.TotalProductCount__c);
    }

    @isTest
    static void testCreateOrderEmptyCart() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        // Prepare JSON for creating an order with an empty cart
        String orderJson = '{"accountId": "' + account.Id + '", "cartItems": []}';

        try {
            Test.startTest();
            OrderController.createOrder(orderJson);
            Test.stopTest();
            System.assert(false, 'Exception not thrown');
        } catch (AuraHandledException e) {
            //System.assertEquals('Cart is empty. Cannot create an order.', e.getMessage());
        }
    }

    @isTest
    static void testCreateOrderNoAccountId() {
        // Prepare JSON for creating an order with no account ID
        String orderJson = '{"cartItems": [{"productId": "12345", "price": 100, "quantity": 2}]}';

        try {
            Test.startTest();
            OrderController.createOrder(orderJson);
            Test.stopTest();
            System.assert(false, 'Exception not thrown');
        } catch (AuraHandledException e) {
            //System.assertEquals('Account ID is required to create an order.', e.getMessage());
        }
    }
}
