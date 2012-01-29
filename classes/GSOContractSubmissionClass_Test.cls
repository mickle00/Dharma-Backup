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
private class GSOContractSubmissionClass_Test {

    static testMethod void myUnitTest() {
    	String approverEmail = 'gsotestap@expedia.com';
    	
    	// create psg user
    	PSG_User__c myPSGUser = new PSG_User__c(Name= 'test user', Email__c= 'gsotest@expedia.com', Active__c= true );
    	insert myPSGUser;
    	
    	// create submission
		GSO_Contract_Submission__c submission = new GSO_Contract_Submission__c(PSG_User__c= myPSGUser.Id, Approver_Email__c= approverEmail);
		insert submission;
		
		// create contract
		GSOContract__c myContract = new GSOContract__c(GSO_Contract_Submission__c= submission.Id, Approval_Status__c= 'Pending Approval', Approval_Required__c= true);
		insert myContract;
		
		submission = [Select Id, PSG_User__c, Approver_Email__c, Contracts_Pending_Approval__c From GSO_Contract_Submission__c Where Id = : submission.Id];
		system.assertEquals(submission.Contracts_Pending_Approval__c, 1);
		
		test.startTest();
		
		GSO_Contract_Submission__c result = GSOContractSubmissionClass.findById(submission.Id);
		system.assertEquals(result.Id, submission.Id);
		
		List<GSO_Contract_Submission__c> results = GSOContractSubmissionClass.getPendingApprovals(approverEmail);
		system.assertEquals(results.size(), submission.Contracts_Pending_Approval__c);
		
		test.stopTest();
    }
}