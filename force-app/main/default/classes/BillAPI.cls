public with sharing class BillAPI {
    public static void getBills() {
        /* 
        Start by creating an HttpRequest object and set the endpoint and method.
        Endpoint: https://my-json-server.typicode.com/grizzleevelyn/231017_dev_clicked/db
        Method: GET
        */

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://my-json-server.typicode.com/grizzleevelyn/231017_dev_clicked/db');
        request.setMethod('GET');


        // Set up an Http object and an HTTPResponse object, then use the .getBody() method to get the response body.
        Http http = new Http();
        HttpResponse response = http.send(request);

      //  System.debug('response body--'+ response.getBody());

        // Deserialize the JSON response into a list of BillWrapper objects.
     
           ResponseWrapper responseWrapper = (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
           List<BillWrapper> bwList = responseWrapper.bills;

        // Create a list to hold the bills we will insert into Salesforce.
        List<Bill__c> insertBill = new List<Bill__c>();

        // Query for active accounts (Active__c = 'Yes').
        // Learn more about SOQL: https://trailhead.salesforce.com/en/content/learn/modules/apex_database/apex_database_soql
        List<Account> activeAccount =[SELECT Name,Id FROM Account WHERE Active__c = 'Yes'];

      //  System.debug('AccountActive ' + activeAccount);

        // Create a map to hold active account names and their IDs.
        // Learn more about Maps: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_map.htm
        Map<String,Id> accountMap = new Map<String,Id>();

        // Iterate over the list of active accounts and add their name and ID to the map.
        for(Account acc : activeAccount){
            accountMap.put(acc.Name,acc.Id);
        }

       // System.debug('account map ' + accountMap);


        /*
        Iterate over the list of BillWrapper objects and create a new Bill__c record for each.
        Match the new bill fields with the properties of the BillWrapper class.
        For example, for Bill__c.Balance__c, use Decimal.valueOf(bw.balance.replace('$', '')) to convert the balance to a decimal.
        Remember, DML (Data Manipulation Language) operations should not be inside loops. Learn more about DML: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_section.htm
        */

         //Todo I need to get list of bill in the system
    //compare it with the new ones before insertion.
    //I think i will use map to retrieve and check the account name related to the bill
    // and yank it off the list
    List<Bill__c> checkBill = [SELECT invoice_Number__c FROM Bill__c];
    Map<String,Bill__c> verifyBill = new Map<String,Bill__c>(checkBill);
    List<Bill__c> dupliBil = new List<Bill__c>();
    
        try{
        for(BillWrapper bw : bwList){
            if(accountMap.containsKey(bw.accountName)){
            Bill__c newBill = new Bill__c();

            newBill.Balance__c = Decimal.valueOf(bw.balance.replace('$', ''));
            newBill.invoice_Number__c= bw.billId;
            newBill.Account__c = accountMap.get(bw.accountName);

            if(verifyBill.containsKey(newBill.invoice_Number__c)){
                System.debug('Hey this bill already exist I cannot add it');
                dupliBil.add(newBill);
            }


            insertBill.add(newBill);

            }

        }

        } catch(Exception msg){
            
        }


        //finally, insert the new bills list
        if(!insertBill.isEmpty()){
            //insert insertBill;
            Database.upsert(insertBill, false);
            System.debug('Bills inserted');

        } else {

            System.debug('Nothing to insert');
        System.debug('we have ' + dupliBil.size() + ' duplicates');
        //System.debug(dupliBil);
        }
        
    }

    /*  
    This is a wrapper class. A wrapper class allows us to create an instance of a class with the properties we specify.
    In this case, we are creating a class that will hold the properties for BillId, AccountName, and Balance.
    These properties will be populated from the JSON structure stored in our external data source.
    Once we get the body of our HTTP callout, we will use the following line of code to transform the response body into a list of instances of our wrapper class, BillWrapper:
    List<BillWrapper> bwList = (List<BillWrapper>)JSON.deserialize(responseBody, List<BillWrapper>.class);
    Once we have a list of BillWrapper objects (bwList), we will iterate over the bwList, create a new Bill__c record, and assign the values of the BillWrapper properties to the fields on the Bill__c record.
    */
    public class BillWrapper {
        public String billId;
        public String accountName;
        public String balance;
    }

    public class ResponseWrapper {
        public List<BillWrapper> bills;
    }

}



