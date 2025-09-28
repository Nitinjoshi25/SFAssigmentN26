public with sharing class DAL_ProductPlan {

    public static List<Product_Plan__c> getProductPlanByProductAndCountry(Id productId, Id countryId){
        return [SELECT Id, Plan_Types__c, Standard_Price__c FROM Product_Plan__c WHERE Product__c =: productId
            AND Country__c =: countryId AND Plan_Available__c = TRUE];
    }
}