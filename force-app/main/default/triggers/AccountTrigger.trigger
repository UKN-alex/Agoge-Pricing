trigger AccountTrigger on Account (before insert, before update) {

    //Instanciando minha handler
    AccountTriggerHandler handler = new AccountTriggerHandler(
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
    );
    // // BEFORE INSERT

    //     if(Trigger.isInsert && Trigger.isBefore){
    //         // Antes da inserção (Before insert)
    //         // Validação que permite apenas a inserção  de CNPJs com 14 caracteres. 04/12/22
    //         for (Account account : Trigger.new){
    //          if (account.CNPJ__c.length() < 14) {
    //         System.debug('Entrou no BEFORE_INSERT');
 //             account.CNPJ__c.addError('Por favor verificar se o campo está com o preenchimento correto!');
 //         }
 //     }
 //         if (account.CNPJ__c.length() < 14){
 //         System.debug('CNPJ' + account.CNPJ__c);
 //     }
 
 
 //     // BEFORE UPDATE
 //     else if (Trigger.isUpdate && Trigger.isBefore){
 //         // Antes da alteração (Before UPDATE)
 //         // Validação que permite apenas a atualização de CNPJs com 14 caracteres. 04/12/22
 //         for (Account account : Trigger.new){
 //         System.debug('Entrou no BEFOR_UPDATE');
 //         if (account.CNPJ__c.length() < 14){
 //             account.CNPJ__c.addError('Por favor verificar se o campo está com o preenchimento correto!');
 //         }
 //     }
 //         System.debug('CNPJ' + account.CNPJ__c);
 //     }
 
 
         
     
     
 // Esturatura com Switch-Case
 // Relativo ao seguinte IF
 
 // Estrutura com IF 
 //  if (Trigger.operationType == System.TriggerOperation.BEFORE_INSERT {
 //         //Code
 //     }
 
   switch on Trigger.operationType {
       //Entrada condicional

       //Para o BEFORE_INSERT - (Antes da entrada do meu registro no Banco de Dados)
        when BEFORE_INSERT {
            System.debug('Entrou no BEFORE_INSERT');
            handler.beforeInsert();
        }
        // Para o BEFORE_UPDATE - (Antes da atualização do meu registro no Banco de Dados)
        when BEFORE_UPDATE {
           System.debug('Entrou no BEFORE_UPDATE');
           handler.beforeUpdate();
        }

        // Para Inserção de registro no Banco de Dados
        // When AFTER_INSERT {
            
        // }
    } 

 }



