@IsTest
private class Test_TH_Contact {

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
                ExternalID__c = '12345678',
                Allow_Multiple_Product_With_Same_Plan__c = true
            ),
            new Contact(
                LastName = 'Test 2',
                Product__c = products[1].Id,
                Home_Location__c =  countries[1].Id,
                ExternalID__c = '98765432',
                Discount_Applied__c = 5,
                Allow_Multiple_Product_With_Same_Plan__c = false
            )
        };
        insert contacts;

        List<Contact_Product__c> contactProducts = new List<Contact_Product__c>{
            new Contact_Product__c(
                Contact__c = contacts[0].Id,
                Product__c = products[0].Id,
                Plan_Type__c = 'Black',
                Price__c = 10
            ),
            new Contact_Product__c(
                Contact__c = contacts[0].Id,
                Product__c = products[0].Id,
                Plan_Type__c = 'Black',
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
    static void testCheckIfTheContactHasMoreThanOneOfTheSamePlans(){
        Contact contact = [SELECT Id FROM Contact WHERE Allow_Multiple_Product_With_Same_Plan__c = TRUE LIMIT 1];
        contact.Allow_Multiple_Product_With_Same_Plan__c = false;
        try{
            update contact;
        }catch(Exception e){
            System.assert(e.getMessage().contains(Label.Contact_w_1_Product));
        }
    }

    @IsTest
    static void testSetIfDiscountAppliedChange(){
        Contact contact = [SELECT Id FROM Contact WHERE Discount_Applied__c = NULL LIMIT 1];
        Contact_Product__c contactProduct = [SELECT Id, Price__c, Discount__c FROM Contact_Product__c WHERE Contact__c =: contact.Id LIMIT 1];
        contact.Discount_Applied__c = 10;
        update contact;
        System.assertNotEquals(contactProduct.Discount__c, [SELECT Id, Discount__c FROM Contact_Product__c WHERE Id =: contactProduct.Id][0].Discount__c);
    }
}