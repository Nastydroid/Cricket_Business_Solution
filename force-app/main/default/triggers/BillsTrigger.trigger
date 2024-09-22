/**
 * @description       : 
 * @author            : mac_Spectre
 * @group             : 
 * @last modified on  : 08-22-2024
 * @last modified by  : mac_Spectre
**/
trigger BillsTrigger on Bill__c (before insert,after insert) {
    if(Trigger.isBefore){
        BillTriggerHandler.validateAccountField(Trigger.new);
        BillTriggerHandler.invoiceNumber(Trigger.new);
    }

    else if(Trigger.isAfter){
        BillTriggerHandler.OpportunityCreation(Trigger.new);
    }



}