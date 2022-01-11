public with sharing class AccountHelper {
    public AccountHelper() {

    }

    public static void checkAccountCNPJ(List<Account> accountList){
        for (Account account : accountList) {
                if (account.CNPJ__c.length() < 14){
                    account.CNPJ__c.addError('Por favor verificar se o campo está com o preenchimento correto!');
                }
        }
    }
}
