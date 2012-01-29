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
private class EIDRequestExtension_Test {

    static testMethod void myUnitTest() {
        
        Super_Region__c objSuperRegion = [Select Id From Super_Region__c where Name = 'LATAM'];
    	// create account
    	Account objAccount = (Account)SmartFactory.createSObject('Account');
    	objAccount.Super_Region__c = objSuperRegion.Id;
    	insert objAccount;
    	
    	// create contract checklist
    	Contract_Checklist__c objContractChecklist = (Contract_Checklist__c)SmartFactory.createSObject('Contract_Checklist__c');
    	objContractChecklist.Status__c = 'Requested ID\'s(Vendor or Expedia ID)';
    	objContractChecklist.Set_up_Expedia_Pay__c = true;
    	objContractChecklist.Set_up_EVC__c = true;
    	objContractChecklist.Account__r = objAccount;
    	insert objContractChecklist;

		test.startTest();
		
		Apexpages.currentPage().getParameters().put('Id', objContractChecklist.Id);
        EIDRequestExtension extEIDRequest = new EIDRequestExtension();
		
		extEIDRequest.Save();
		extEIDRequest.Cancel();
		
		test.stopTest();
    }
}