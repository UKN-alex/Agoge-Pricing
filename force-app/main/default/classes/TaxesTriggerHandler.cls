public with sharing class TaxesTriggerHandler {

    List<Taxes__c> oldRecords {get; set;}
    List<Taxes__c> newRecords {get; set;}
    Map<Id,Taxes__c> oldMap {get; set;}
    Map<Id, Taxes__c> newMap {get; set;}
    


    public TaxesTriggerHandler(List<Taxes__c> oldRecords, List<Taxes__c> newRecords, Map<Id, Taxes__c> oldMap, Map<Id, Taxes__c> newMap) {

        this.oldRecords = oldRecords;
        this.newRecords = newRecords; 
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        TaxesHelper.validateTaxesCategory(this.newRecords);
    }
}
