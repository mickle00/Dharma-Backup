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
private class GSOContractClass_Test {
	  
	  static testMethod void runTests() {
	  	
	  	Set<Id> gsoContractIds = new Set<Id>();
	  	Map<Id,GSOContract__c> gsoContractIdToContractMap = new Map<Id,GSOContract__c>();
      GSOContractClass objContract = new GSOContractClass();
      GSO_Contract_Submission__c submission = new GSO_Contract_Submission__c();
      insert submission;
	    
	    List<GSOContract__c> newContracts = new List<GSOContract__c>();
	   
	    for (Integer i = 0; i < 200; i++) {
	      GSOContract__c newContract = new GSOContract__c(GSO_Contract_Submission__c = submission.Id);
	      newContracts.add(newContract);		  	
	    }
	    
	    insert newContracts;
	    
	    for (GSOContract__c thisContract : newContracts) {
	    	gsoContractIds.add(thisContract.Id);
	    	gsoContractIdToContractMap.put(thisContract.Id,thisContract);
	    }
    	
    	test.startTest();
    	List<GSOContract__c> contracts = objContract.FindAllById(gsoContractIds);
    	
    	system.assertEquals(contracts.size(), 200);
    	

    }
    
    static testMethod void testUpdatePhaseAndORTEVCCases(){
    	Account testAccount = new Account();
    	
    	testAccount.ARI_Enabled__c = true;
    	testAccount.Expedia_Hotel_Id__c = 'TESTING';
    	testAccount.Name = 'SALESFORCE TEST DATA IS STUPID';
    	insert testAccount;
    	
    	Set<Id> gsoContractIds = new Set<Id>();
      Map<Id,GSOContract__c> gsoContractIdToContractMap = new Map<Id,GSOContract__c>();
      GSOContractClass objContract = new GSOContractClass();
      GSO_Contract_Submission__c submission = new GSO_Contract_Submission__c();
      insert submission;
      
      List<GSOContract__c> newContracts = new List<GSOContract__c>();
     
      for (Integer i = 0; i < 4; i++) {
        GSOContract__c newContract = new GSOContract__c(GSO_Contract_Submission__c = submission.Id,Account__c = testAccount.Id,Setup_on_EVC__c = true);
        newContracts.add(newContract);        
      }
      
      insert newContracts;
      
      for (GSOContract__c thisContract : newContracts) {
        gsoContractIds.add(thisContract.Id);
        gsoContractIdToContractMap.put(thisContract.Id,thisContract);
      }
      
      List<GSOContract__c> contracts = objContract.FindAllById(gsoContractIds);
    	
      GSOContract__c commercialContract = contracts[0];
      GSOContract__c paymentContract = contracts[1];
      GSOContract__c legalContract = contracts[2];
      
      
      
      EPC_Activity__c commercialActivity = new EPC_Activity__c(Action__c = 'Viewed'
                                                              ,Date_of_Activity__c = Date.today()
                                                              ,EPC_Section__c = 'Commercial Terms'
                                                              ,GSO_Contract__c = commercialContract.Id);
                                                              
      EPC_Activity__c paymentActivity = new EPC_Activity__c(Action__c = 'Viewed'
                                                           ,Date_of_Activity__c = Date.today()
                                                           ,EPC_Section__c = 'Payment Information'
                                                           ,GSO_Contract__c = paymentContract.Id);
                                                           
      EPC_Activity__c legalActivity = new EPC_Activity__c(Action__c = 'Viewed'
                                                         ,Date_of_Activity__c = Date.today()
                                                         ,EPC_Section__c = 'Legal Terms'
                                                         ,GSO_Contract__c = legalContract.Id);
      
      
      
      //Commercial Contract
      insert commercialActivity;
      insert paymentActivity;
      insert legalActivity;  
      
      legalContract = [SELECT Id,Date_EPC_Completed__c FROM GSOContract__c WHERE Id = :legalContract.Id];
      legalContract.Date_EPC_Completed__c = Date.today();
      update legalContract;
    	
    }
    
    static testMethod void myUnitTest() {
    	// create submission
    	GSO_Contract_Submission__c submission = new GSO_Contract_Submission__c();
    	insert submission;
    	
    	// create contract
    	GSOContract__c[] contracts = new GSOContract__c[] {
    		new GSOContract__c(GSO_Contract_Submission__c= submission.Id),
    		new GSOContract__c(GSO_Contract_Submission__c= submission.Id),
    		new GSOContract__c(GSO_Contract_Submission__c= submission.Id)
    	};
    	insert contracts;
    	
    	test.startTest();
    	
    	List<GSOContract__c> results = GSOContractClass.findBySubmissionId(submission.Id);
    	system.assertEquals(results.size(), contracts.size());
    	
    	test.stopTest();
    }
}