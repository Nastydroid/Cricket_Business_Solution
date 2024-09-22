public  class BillTriggerHandler {

    public static void validateAccountField(List<Bill__c> bill){
        for(Bill__c bills : bill){
            if(String.isBlank(bills.Account__c)){
                
                bills.Account__c.addError('Account is missing,Look for it');
                
            }
        }
    
    }  


    public static void invoiceNumber(List<Bill__c> bill){
        for(Bill__c bills : bill){
            //Integer i = 000000;
            if(String.isBlank(bills.invoice_Number__c)){
        
                bills.invoice_Number__c = invoiceNumberGenerator();

                
            }
        }

    }

    public static void OpportunityCreation(List<Bill__c> oldBill){
        List<Opportunity> createOpp = new List<Opportunity>();

        for(Bill__c bill : oldBill){
            //query the account to get account related to the bill object
            Account relatedAccount =[SELECT Id,Name FROM Account WHERE Id = :bill.Account__c LIMIT 1];
            //Query the opportunity to see opportunity associated with the account Id on Bill object
            List<Opportunity> opportunityWithAccout = [SELECT Id FROM Opportunity WHERE AccountId = :bill.Account__c AND StageName !='Closed Won' AND StageName != 'Closed Lost'];
            if(opportunityWithAccout.isEmpty()){
                Opportunity newOpp = new Opportunity(
                    AccountId=bill.Account__c,
                    Name = relatedAccount.Name +'-Opportunity'+  bill.invoice_Number__c,
                    Amount =bill.Balance__c,
                    StageName='Prospecting',
                    CloseDate = System.today().addMonths(8)
                );

                createOpp.add(newOpp);
            }
            
        }
        if(!createOpp.isEmpty()){
            insert createOpp;
        }
    }
    
    
    public static String invoiceNumberGenerator(){

        String invoice = 'INV-'+ UUID.randomUUID().toString().substring(0,9);
        return invoice;

        /*String invoice;
         Integer i = 0000000;
        while(i == 0000000){

            i++;

            invoice = 'INV-' + i.toString(); 
        
            
        }
        

        return invoice;*/
        
       

    }
}