public with sharing class CTRL_ProductPlan {

    @AuraEnabled(Cacheable = true)
    public static List<Product_Plan__c> getProductPlans(Id productId, Id countryId){
        return DAL_ProductPlan.getProductPlanByProductAndCountry(productId, countryId);
    }
}