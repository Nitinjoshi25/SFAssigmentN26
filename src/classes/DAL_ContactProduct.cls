public with sharing class DAL_ContactProduct {

    public static List<Contact_Product__c> getContactProductByContactId(Id contactId){
        return [SELECT Id, Plan_Type__c, Price__c, Product__c, Discount__c FROM Contact_Product__c
            WHERE Contact__c =: contactId ORDER BY Plan_Type__c ASC];
    }

    public static List<AggregateResult> getContactProductByContactIdGroupByPlanType(Set<Id> contactsId){
        return [SELECT COUNT(Id) Records, Plan_Type__c, Contact__c FROM Contact_Product__c
            WHERE Contact__c =: contactsId GROUP BY Plan_Type__c, Contact__c];
    }

    public static List<Contact_Product__c> getContactProductsByContacts(Set<Id> idContacts){
        return [SELECT Id, Plan_Type__c, Price__c, Product__c, Discount__c, Contact__c FROM Contact_Product__c
            WHERE Contact__c IN: idContacts ORDER BY Plan_Type__c ASC];
    }
}