public with sharing class BillBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public List<Id> receivesBillByEmail = new List<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return  Database.getQueryLocator([SELECT Id, Bill_By_Email__c FROM Account 
        WHERE Bill_By_Email__c != null AND Active__c = 'Yes']);
        
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        //this is a method that will process the queried for records by preparing
        //This method will also call our BillAPI.getBills() method.
        for(Account billAccount : scope){
            if(billAccount.Bill_By_Email__c == TRUE){
                receivesBillByEmail.add(billAccount.Id);



            }
        }

        BillAPI.getBills();


    }

    public void finish(Database.BatchableContext bc) {
        //this is the final method of the class, that will be called after all processing in the
        //start and execute methods is complete. We will use this method to send an email to each
        //customer in the receivesBillByEmail list. First, we must query for the recently created bills for
        //each account with the following nested query:
        //[SELECT Id, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC) FROM Account WHERE Id IN :this.receivesBillByEmail]
        List<Account> accountToRecieveEmail = [SELECT Id,Email__c, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC) FROM Account WHERE Id IN :this.receivesBillByEmail];

        
        //We will then iterate over the results of this query and associate the Id of the most recent bill (value) with the
        //corresponding Id of the account Id (key) in a Map<Id, Id> that we will call billMap, using the .put(Id, Id)
        //method of the Map class:
        Map<Id,Id> billMap = new Map<Id,Id>();
        Map<Id,String> emailMap = new Map<Id,String>();

        for (Account acc : accountToRecieveEmail) {
            // Check if there are related bills
            if (!acc.Bills__r.isEmpty()) {
                // Get the most recent bill (first one in the ordered list)
                Id mostRecentBillId = acc.Bills__r[0].Id;
                // Put the account Id and the most recent bill Id into the map
                billMap.put(acc.Id, mostRecentBillId);
                emailMap.put(acc.Id,acc.Email__c);
            }
        }
        

        Map<String, Blob> sendMap = new Map<String, Blob>();

    // Iterate over the entries in the billMap
        for (Id accountId : billMap.keySet()) {
    
    // Get the associated account's email
    // Assuming Account has a custom field Email__c
    String email = emailMap.get(accountId);
    Id billId = billMap.get(accountId);
    
    if( email != null && billId != null){
    PageReference pageRef = new PageReference('/apex/BillVFP?id=' + billId);
    Blob pdfBlob = pageRef.getContentAsPDF();
        
        // Add the email and the PDF to the sendMap
        sendMap.put(email, pdfBlob);
        //finally, we will call our BillEmailer.sendEmails(sendMap) method. Remember, this method is VOID,
        //so there will be no return value;

        BillEmailer.sendEmails(sendMap);
        
            }
    }
        }
}