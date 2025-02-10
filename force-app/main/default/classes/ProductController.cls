public with sharing class ProductController {
    @AuraEnabled(cacheable=true)
    public static List<product_c__c> getProducts(String familyFilter, String typeFilter, String searchTerm) {
        // Start with a base query without 'WHERE 1=1'
        String query = 'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c FROM product_c__c';
        
        // Initialize an empty list to store conditions
        List<String> conditions = new List<String>();
        
        // Apply filters dynamically and add conditions to the list
        if (String.isNotBlank(familyFilter)) {
            conditions.add('Family__c = :familyFilter');
        }
        if (String.isNotBlank(typeFilter)) {
            conditions.add('Type__c = :typeFilter');
        }
        if (String.isNotBlank(searchTerm)) {
            String sanitizedSearchTerm = '%' + searchTerm.replaceAll('[^a-zA-Z0-9 ]', '') + '%'; // Remove special chars
            conditions.add('(Name LIKE :sanitizedSearchTerm OR Description__c LIKE :sanitizedSearchTerm)');
        }
        
        // If there are conditions, append them to the query
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        
        // Return results with a LIMIT to prevent too many records
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