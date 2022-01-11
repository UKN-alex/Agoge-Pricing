public with sharing class AccountTriggerHandler {

    List <Account> oldRecords  {get; set;} // Variável relativa Trigger.old
    List <Account> newRecords {get; set;} // Variável relativa Trigger.new
    Map <Id, Account> oldMap {get; set;} // Variável relativa   
    Map <Id, Account> newMap {get; set;} // Variável relativa  

    // Construtor
    public AccountTriggerHandler(List <Account> oldRecords, List <Account> newRecords,Map <Id, Account> oldMap,Map <Id, Account> newMap) {
        // Sempre que for referenciar utilizar o This.nomeParametro do construtor
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    // Meus métodos
    // Relativo ao BEFORE_INSERT reponsável por todo o fluxo de rotinas do BEFORE_INSERT da Trigger
    public void beforeInsert() {
        AccountHelper.checkAccountCNPJ(this.newRecords);       
    }

    // Relativo ao BEFORE_UPDATE reponsável por todo o fluxo de rotinas do BEFORE_UPDATE da Trigger
    public void beforeUpdate(){
        AccountHelper.checkAccountCNPJ(this.newRecords);
    }

    // Relativo ao AFTER_INSERT reponsável por todo o fluxo de rotinas do AFTER_INSERT da Trigger
    public void AFTER_INSERT(){

    }
}
