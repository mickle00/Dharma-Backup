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
private class sitesReContractingApproval_Test {
	static PSG_User__c psgUser;
	static GSO_Contract_Submission__c submission;
	
    static testMethod void myUnitTest() {
		Initialize();
		
        test.startTest();

        Apexpages.currentPage().getParameters().put('MM', psgUser.Email__c);
        Apexpages.currentPage().getParameters().put('Id', submission.Id);
        sitesReContractingApproval controller = new sitesReContractingApproval();
        
        System.assertNotEquals(controller.psgUser, null);
        //System.assertEquals(controller.VerifyAuthentication(), null);
        
        // set approval status
        controller.ApprovalStatus = 'Rejected';
        controller.ApprovalComment = 'Rejected';
        controller.Submit();

        test.stopTest();
    }
    
    private static void Initialize() {
        // create user
        psgUser = new PSG_User__c();
        psgUser.Email__c = 'test@test.com';
        psgUser.Name = 'Joe User';
        
        insert psgUser;
        
        // create account
        Account myAccount = new Account();
        myAccount.Name = 'Test Account';
        myAccount.Market_Manager_Name__c = psgUser.Name;
        
        insert myAccount;
        
        // create psg user role
        PSG_User_Role__c myPSGUserRole = new PSG_User_Role__c();
        myPSGUserRole.Account__c = myAccount.Id;
        myPSGUserRole.PSG_User__c = psgUser.Id;
        myPSGUserRole.Role__c = 'Regional Director';
        
        insert myPSGUserRole;
        
        // create contact
        Contact myContact = new Contact();
        myContact.FirstName = 'Jill';
        myContact.LastName = 'User';
        myContact.AccountId = myAccount.Id;
        
        insert myContact; 
        
        // create terms
        Term__c myTerm = new Term__c();
        myTerm.Description__c = 'Contract Length (months)';
        myTerm.Start_Date__c = System.today();
        
        insert myTerm;

        // create submission
    	submission = new GSO_Contract_Submission__c();
    	submission.PSG_User__c = PSGUser.Id;
    	submission.Market_Manager_Email__c = PSGUser.Email__c;
    	submission.Approver_Email__c = myPSGUserRole.PSG_User__r.Email__c;
    	
    	insert submission;

		// create contract
		GSOContract__c myContract = new GSOContract__c();
		myContract.Account__c = myAccount.Id;
		myContract.Contact__c = myContact.Id;
		myContract.Date_Contract_Started__c = Date.Today();
		myContract.GSO_Contract_Submission__c = submission.Id;
		myContract.Batch_Size__c = 1;
		
		insert myContract;
		
		// create contract terms
		GSOContract_Term__c myContractTerm = new GSOContract_Term__c();
		myContractTerm.GSOContract__c = myContract.Id;
		myContractTerm.Term__c = myTerm.Id;
		myContractTerm.Value__c = '11';
		
		insert myContractTerm;
    }
}