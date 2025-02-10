@isTest
public class ProductControllerTest {

    @testSetup
    static void setup() {
        // Create test data for Product_c__c
        Product_c__c product1 = new Product_c__c(Name = 'Test Product 1', Family__c = 'First', Type__c = '1', Price__c = 100.0);
        Product_c__c product2 = new Product_c__c(Name = 'Test Product 2', Family__c = 'Second', Type__c = '2', Price__c = 200.0);
        insert new List<Product_c__c>{product1, product2};
    }

    @isTest
    static void testGetProducts() {
        // Test the getProducts method
        Test.startTest();
        List<Product_c__c> products = ProductController.getProducts('First', '1', 'Test');
        Test.stopTest();

        // Assert that we get the expected results
        System.assertEquals(1, products.size());
        System.assertEquals('Test Product 1', products[0].Name);
    }

    // @isTest
    // static void testCreateProduct() {
    //     // Create a new Product
    //     Product_c__c newProduct = new Product_c__c(Name = 'New Product', Family__c = 'Third', Type__c = '3', Price__c = 150.0);

    //     // Test the createProduct method
    //     Test.startTest();
    //     Product_c__c createdProduct = ProductController.createProduct(newProduct);
    //     Test.stopTest();

    //     // Assert that the product was created
    //     System.assertNotEquals(null, createdProduct.Id);
    //     System.assertEquals('New Product', createdProduct.Name);
    // }

    @isTest
    static void testCreateProductNoPermission() {
        // Create a new Product
        Product_c__c newProduct = new Product_c__c(Name = 'Unauthorized Product', Family__c = 'Fourth', Type__c = '4', Price__c = 250.0);

        // Simulate a non-manager user
        User testUser = [SELECT Id FROM User WHERE Profile.Name != 'Manager' LIMIT 1];
        System.runAs(testUser) {
            try {
                Test.startTest();
                ProductController.createProduct(newProduct);
                Test.stopTest();
                System.assert(false, 'Exception not thrown');
            } catch (AuraHandledException e) {
                //System.assertEquals('You do not have permission to create products.', e.getMessage());
            }
        }
    }
}
