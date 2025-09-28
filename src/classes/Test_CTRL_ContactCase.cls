@IsTest
private class Test_CTRL_ContactCase {

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
    static void testGetContactProductByContactId(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        System.assertEquals(2, CTRL_ContactCase.getContactProductByContactId(contact.Id).size());
    }

    @IsTest
    static void testUpsertContactProduct(){
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        List<Contact_Product__c> contactProducts = [SELECT Id, Contact__c, Product__c FROM Contact_Product__c WHERE Contact__c =: contact.Id];
        for(Contact_Product__c contactProduct: contactProducts){
            contactProduct.Plan_Type__c = 'Metal';
        }
        contactProducts.add(new Contact_Product__c(
            Contact__c = contactProducts[0].Contact__c,
            Product__c = contactProducts[0].Product__c,
            Plan_Type__c = 'Metal',
            Price__c = 25)
        );
        CTRL_ContactCase.upsertContactProducts(contactProducts);
        System.assertEquals(contactProducts.size(), CTRL_ContactCase.getContactProductByContactId(contact.Id).size());
    }

    @IsTest
    static void testDeleteContactProduct(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        List<Contact_Product__c> contactProducts = [SELECT Id FROM Contact_Product__c WHERE Id =: contact.Id LIMIT 1];
        CTRL_ContactCase.deleteContactProducts(contactProducts);
        System.assertNotEquals(contactProducts.size(), CTRL_ContactCase.getContactProductByContactId(contact.Id).size());
    }
}