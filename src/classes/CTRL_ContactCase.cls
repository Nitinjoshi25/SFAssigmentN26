public with sharing class CTRL_ContactCase {

    @AuraEnabled(Cacheable = true)
    public static List<Contact_Product__c> getContactProductByContactId(Id contactId){
        return DAL_ContactProduct.getContactProductByContactId(contactId);
    }

    @AuraEnabled
    public static void upsertContactProducts(List<Contact_Product__c> contactProducts){
        if(!contactProducts.isEmpty()){
            try{
                upsert contactProducts;
            }catch(Exception e){
                System.debug('Line number: ' + e.getLineNumber() +  ' - Cause: ' + e.getCause() + ' - Message: ' + e.getMessage());
                throw e;
            }
        }
    }

    @AuraEnabled
    public static void deleteContactProducts(List<Contact_Product__c> contactProducts){
        if(!contactProducts.isEmpty()){
            try{
                delete contactProducts;
            }catch(Exception e){
                System.debug('Line number: ' + e.getLineNumber() +  ' - Cause: ' + e.getCause() + ' - Message: ' + e.getMessage());
                throw e;
            }
        }
    }
}