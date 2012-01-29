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
private class ContractChecklistTrigger_Test {

    static testMethod void myUnitTest() {
      
      Account testAccount = new Account(Name = 'Test Account 1');
      
      insert testAccount;
      Contract_Checklist__c checklist = new Contract_Checklist__c(Account__c = testAccount.Id
                                                                 ,Checklist_Type__c = 'Test'
                                                                 ,Status__c = 'New');
      
      insert checklist;
      
      checklist.Status__c = 'Closed';
      test.startTest();
      update checklist;
      
    }
}