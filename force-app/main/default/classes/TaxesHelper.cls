public with sharing class TaxesHelper {
    public TaxesHelper() {

    }

    public static void validateTaxesCategory(List<Taxes__c> taxesList){
        for (Taxes__c taxes : taxesList){

            if (taxes.Imposto__c == null){
                taxes.Imposto__c.addError('Por favor preenchar o campo!');
            }
            else if (taxes.Product__c == null){
                taxes.Product__c.addError('Por favor preencha o campo!');
            }
            else if (taxes.States__c == null){
                taxes.States__c.addError('Por favor preenchar o campo!');
            }
        }
    }


}
