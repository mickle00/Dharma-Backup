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
private class GSOContractTermClass_Test {

    static testMethod void myUnitTest() {
    	// create submission
    	GSO_Contract_Submission__c mySubmission = new GSO_Contract_Submission__c();
    	insert mySubmission;
    	
        // create contract
        GSOContract__c myContract = new GSOContract__c(GSO_Contract_Submission__c = mySubmission.Id);
        insert myContract;
        
        // create terms
	    Term__c[] terms = new Term__c[] {
	      new Term__c(Description__c = 'Term 1'),
		    new Term__c(Description__c = 'Term 2'),
		    new Term__c(Description__c = 'Term 3')
		  };
        insert terms;
        
        // create contract terms
        GSOContract_Term__c[] contractTerms = new GSOContract_Term__c[] {
        	new GSOContract_Term__c(Value__c= '1', Term__c = terms.get(0).Id, GSOContract__c = myContract.Id),
        	new GSOContract_Term__c(Value__c= '2', Term__c = terms.get(1).Id, GSOContract__c = myContract.Id),
        	new GSOContract_Term__c(Value__c= '3', Term__c = terms.get(2).Id, GSOContract__c = myContract.Id)
        };
        insert contractTerms;
        
        test.startTest();
        
        List<GSOContract_Term__c> results = GSOContractTermClass.findByContractId(myContract.Id);
        system.assertEquals(results.size(), contractTerms.size());
        
        test.stopTest();
    }
}