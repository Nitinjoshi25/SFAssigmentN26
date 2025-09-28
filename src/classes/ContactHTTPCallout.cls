@RestResource(UrlMapping='/ContactInformation/*')
global with sharing class ContactHTTPCallout {

    @HttpGet
    global static List<Contact> getContactInformation(){
        RestRequest req = RestContext.request;
        String contactExternalId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        List<Contact> contacts = [SELECT Id, Product__c, Home_Location__c, (SELECT Id, Plan_Type__c, Price__c FROM Contact_Products__r)
            FROM Contact WHERE ExternalID__c =: contactExternalId];
        return contacts;
    }
}