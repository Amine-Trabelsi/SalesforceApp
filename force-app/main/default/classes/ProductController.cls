public with sharing class ProductController {
    @AuraEnabled(cacheable=true)
    public static List<product_c__c> getProducts(String familyFilter, String typeFilter, String searchTerm) {
        String query = 'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c FROM product_c__c WHERE 1=1';
        
        // Apply filters dynamically
        if (String.isNotBlank(familyFilter)) {
            query += ' AND Family__c = :familyFilter';
        }
        if (String.isNotBlank(typeFilter)) {
            query += ' AND Type__c = :typeFilter';
        }
        if (String.isNotBlank(searchTerm)) {
            query += ' AND (Name LIKE \'%' + searchTerm + '%\' OR Description__c LIKE \'%' + searchTerm + '%\')';
        }
        
        return Database.query(query + ' LIMIT 10');
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isCurrentUserManager() {
        User currentUser = [SELECT IsManager__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return currentUser.IsManager__c;
    }

    @AuraEnabled(cacheable=true)
    public static Product_c__c createProduct(Product_c__c newProduct) {
        if (!isCurrentUserManager()) {
            throw new AuraHandledException('You do not have permission to create products.');
        }

        insert newProduct;
        return newProduct;
    }
}
