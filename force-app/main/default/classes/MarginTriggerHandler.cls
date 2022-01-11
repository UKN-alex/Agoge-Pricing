public with sharing class MarginTriggerHandler {

    // Defino minhas propriedades/variáveis

    List<Margin__c> oldRecords {get; set;} //Trigger old
    List<Margin__c> newRecords {get; set;} // Trigger new
    Map<Id, Margin__c> oldMap {get; set;} // Trigger oldMap
    Map<Id, Margin__c> newMap {get; set;} // Trigger newMap

    public MarginTriggerHandler(List<Margin__c> oldRecords, List<Margin__c> newRecords, Map<Id, Margin__c> oldMap, Map<Id, Margin__c> newMap) {

        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    // Método BEFORE_INSERT
    public void beforeInsert(){
        MarginHelper.validateMarginCetegory(this.newRecords);
        MarginHelper.calcScore(this.newRecords);
    }
}
