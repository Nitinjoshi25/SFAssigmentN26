public with sharing class TH_Contact{

    public static void checkIfTheContactHasMoreThanOneOfTheSamePlans(List<Contact> newList, Map<Id, Contact> oldMap){
        Set<Id> idContacts = new Set<Id>();
        for(Contact contact: newList){
            if(contact.Allow_Multiple_Product_With_Same_Plan__c != oldMap.get(contact.Id).Allow_Multiple_Product_With_Same_Plan__c
                    && !contact.Allow_Multiple_Product_With_Same_Plan__c){
                idContacts.add(contact.Id);
            }
        }
        if(!idContacts.isEmpty()){
            List<AggregateResult> contactProducts = DAL_ContactProduct.getContactProductByContactIdGroupByPlanType(idContacts);
            if(!contactProducts.isEmpty()){
                Map<Id, List<String>> mapContactProductTypesPerPerson = new Map<Id, List<String>>();
                for(AggregateResult aggregateResult: contactProducts){
                    if(Integer.valueOf(aggregateResult.get('Records')) > 1){
                        Id contactId = String.valueOf(aggregateResult.get('Contact__c'));
                        String contactProductPlanType = String.valueOf(aggregateResult.get('Plan_Type__c'));
                        if(mapContactProductTypesPerPerson.containsKey(contactId)){
                            mapContactProductTypesPerPerson.get(contactId).add(contactProductPlanType);
                        }else{
                            mapContactProductTypesPerPerson.put(contactId, new List<String>{contactProductPlanType});
                        }
                    }
                }
                if(!mapContactProductTypesPerPerson.isEmpty()){
                    for(Contact contact: newList){
                        if(mapContactProductTypesPerPerson.containsKey(contact.Id)){
                            String contactPlanTypes = String.join(mapContactProductTypesPerPerson.get(contact.Id), ', ');
                            contact.addError(Label.Contact_w_1_Product + ' ' + contactPlanTypes);
                        }
                    }
                }
            }
        }
    }

    public static void setIfDiscountAppliedChange(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        Set<Id> idContacts = new Set<Id>();
        for(Contact contact: newMap.values()){
            if(contact.Discount_Applied__c != oldMap.get(contact.Id).Discount_Applied__c){
                idContacts.add(contact.Id);
            }
        }
        if(!idContacts.isEmpty()){
            List<Contact_Product__c> contactProducts = DAL_ContactProduct.getContactProductsByContacts(idContacts);
            for(Contact_Product__c contactProduct: contactProducts){
                Contact contact = newMap.containsKey(contactProduct.Contact__c)? newMap.get(contactProduct.Contact__c): null;
                contactProduct.Discount__c = contact.Discount_Applied__c;
                contactProduct.Price__c = (contact.Discount_Applied__c != null && contact.Discount_Applied__c != 0)?
                    contactProduct.Price__c - (contactProduct.Price__c * contact.Discount_Applied__c)/ 100: contactProduct.Price__c;
            }
            if(!contactProducts.isEmpty()){
                try{
                    update contactProducts;
                }catch(Exception e){
                    System.debug('Line number: ' + e.getLineNumber() +  ' - Cause: ' + e.getCause() + ' - Message: ' + e.getMessage());
                    throw e;
                }
            }
        }
    }
}