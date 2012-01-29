/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EmailWidgetController_Test {

    static testMethod void myUnitTest() {
    	// create account
    	Account myAccount = new Account(Name = '999TestAcct0');
    	insert myAccount;
    	
    	// create contact
    	Contact myContact = new Contact (LastName = '999Test1', Email = '999test@test.com', Case_Priority__c = '2', AccountId= myAccount.Id);
    	insert myContact;
    	
        // create case
        Case myCase = new Case(Subject = 'Test Case1', SuppliedName='Bob Smith', SuppliedEmail= '999test@test.com', ContactId= myContact.Id);
        insert myCase;
        
        system.assertNotEquals(myCase.Id, null);
        
		test.startTest();

		EmailWidgetController myEmailWidgetController = new EmailWidgetController();
		myEmailWidgetController.setCaseId(myCase.Id);
		System.assertEquals(myEmailWidgetController.getCaseId(), myCase.Id);

		myEmailWidgetController.setDefaultFolder('ADM');
		System.assertEquals(myEmailWidgetController.getDefaultFolder(), 'ADM');
		
		test.stopTest();

    }
}