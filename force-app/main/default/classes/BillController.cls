public with sharing class BillController {
    @AuraEnabled(cacheable=true scope='global')
    public static Bill__c[] getBills() {
        return [
            SELECT
                Id,
                Invoice_Number__c,
                Balance__c,
                Account__r.Name
            FROM Bill__c
            ORDER BY Name
            
        ];
    }

    @AuraEnabled(cacheable=true scope='global')
    public static Bill__c[] searchBill(String searchTerm) {
        // Return all bears when no search term
        searchTerm = searchTerm.trim();
        if (searchTerm == '') {
            return getBills();
        }
        // Prepare query paramters
        searchTerm = '%' + searchTerm + '%';
        // Execute search query
        return [
            SELECT
                 Id,
                Invoice_Number__c,
                Balance__c,
                Account__r.Id,
                Account__r.Name
            FROM Bill__c
            WHERE Account__r.Name LIKE :searchTerm
        ];
    }
}

 