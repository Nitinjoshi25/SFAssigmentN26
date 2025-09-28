@IsTest
private class Test_CTRL_ProductPlan {

    @TestSetup
    static void setup(){
        List<Product2> products = new List<Product2>{
            new Product2(
                Name = 'Product Test 1',
                ProductCode = 'Pro-Test 1',
                IsActive = true
            ),
            new Product2(
                Name = 'Product Test 2',
                ProductCode = 'Pro-Test 2',
                IsActive = true
            )
        };
        insert products;

        List<Country__c> countries = new List<Country__c>{
            new Country__c(Name = 'Germany'),
            new Country__c(Name = 'Spain')
        };
        insert countries;

        List<Contact> contacts = new List<Contact>{
            new Contact(
                LastName = 'Test 1',
                Product__c = products[0].Id,
                Home_Location__c =  countries[0].Id,
                ExternalID__c = '12345678'
            ),
            new Contact(
                LastName = 'Test 2',
                Product__c = products[1].Id,
                Home_Location__c =  countries[1].Id,
                ExternalID__c = '98765432',
                Discount_Applied__c = 5
            )
        };
        insert contacts;

        List<Product_Plan__c> productPlans = new List<Product_Plan__c>{
            new Product_Plan__c(
                Country__c = countries[0].Id,
                Product__c = products[0].Id,
                Standard_Price__c = 5,
                Plan_Types__c = 'Standard'
            ),
            new Product_Plan__c(
                Country__c = countries[0].Id,
                Product__c = products[0].Id,
                Standard_Price__c = 15,
                Plan_Types__c = 'Metal'
            ),
            new Product_Plan__c(
                Country__c = countries[1].Id,
                Product__c = products[1].Id,
                Standard_Price__c = 5,
                Plan_Types__c = 'Standard'
            ),
            new Product_Plan__c(
                Country__c = countries[1].Id,
                Product__c = products[1].Id,
                Standard_Price__c = 15,
                Plan_Types__c = 'Metal'
            )
        };
        insert productPlans;

        List<Contact_Product__c> contactProducts = new List<Contact_Product__c>{
            new Contact_Product__c(
                Contact__c = contacts[0].Id,
                Product__c = products[0].Id,
                Plan_Type__c = 'Standard',
                Price__c = 10
            ),
            new Contact_Product__c(
                Contact__c = contacts[0].Id,
                Product__c = products[0].Id,
                Plan_Type__c = 'Metal',
                Price__c = 15
            ),
            new Contact_Product__c(
                Contact__c = contacts[1].Id,
                Product__c = products[1].Id,
                Plan_Type__c = 'Standard',
                Price__c = 20
            ),
            new Contact_Product__c(
                Contact__c = contacts[1].Id,
                Product__c = products[1].Id,
                Plan_Type__c = 'Metal',
                Price__c = 25
            )
        };
        insert contactProducts;
    }

    @IsTest
    static void testGetProductPlans(){
        Contact contact = [SELECT Id, Product__c, Home_Location__c FROM Contact LIMIT 1];
        System.assertNotEquals(0, CTRL_ProductPlan.getProductPlans(contact.Product__c, contact.Home_Location__c).size());
    }
}