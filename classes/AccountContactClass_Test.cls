@isTest
private class AccountContactClass_Test {

    static testMethod void myUnitTest() {
    	Account testAccount = new Account(Name = 'TestAccount');
    	insert testAccount;
    	
    	Contact testContact = new Contact(FirstName = 'MyMethod', LastName = 'Tester', Email = 'methodtest@fakeemailaddress.bad');
    	insert testContact;
    	
        Test.startTest();
        Account_Contact__c myAccountContact = new Account_Contact__c(Account__c = testAccount.Id, Contact__c = testContact.Id);
        
        List<Account_Contact__c> allAccountContacts = new List<Account_Contact__c>();
        allAccountContacts.add(myAccountContact);        
        AccountContactClass.buildUniqueKeys(allAccountContacts);
        
        system.assertEquals(myAccountContact.Unique_Key__c, myAccountContact.Account__c + ':' + myAccountContact.Contact__c);
        insert myAccountContact;
        
        allAccountContacts = AccountContactClass.findByAccountId(testAccount.Id);
        
        Set<String> testEmails = new Set<String>{testContact.email};
        
        AccountContactClass acObj = new AccountContactClass();        
        acObj.getEmailToListOfAccountContacts(allAccountContacts);
        acObj.getAllByContactEmail(testEmails);
        acObj.getEmailCountsForEmails(testEmails);        
        Test.stopTest();
    }
}