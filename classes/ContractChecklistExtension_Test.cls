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
private class ContractChecklistExtension_Test {

    static testMethod void myUnitTest() {
    	
    	// create account
    	Account objAccount = (Account)SmartFactory.createSObject('Account');
    	insert objAccount;
    	
    	// create contract checklist
    	Contract_Checklist__c objContractChecklist = (Contract_Checklist__c)SmartFactory.createSObject('Contract_Checklist__c');
    	objContractChecklist.Status__c = 'Requested ID\'s(Vendor or Expedia ID)';
    	objContractChecklist.Account__c = objAccount.Id;
    	insert objContractChecklist;

    	test.startTest();
    	
	    ApexPages.StandardController stdCon = new ApexPages.StandardController(objContractChecklist);
        ContractChecklistExtension extContractChecklist = new ContractChecklistExtension(stdCon);
		
		// get redirect url
		extContractChecklist.EIDRequestRedirect();
		System.assertNotEquals(extContractChecklist.RedirectUrl, '');
		
		test.stopTest();
		
    }
}