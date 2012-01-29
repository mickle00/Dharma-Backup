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
private class PSGUserRoleClass_Test {

    static testMethod void myUnitTest() {
        // create user
        PSG_User__c psgUser = new PSG_User__c();
        
        psgUser.Email__c = 'test@test.com';
        psgUser.Name = 'Joe User';
        
        insert psgUser;
        
        // create account
        Account myAccount = new Account();
        myAccount.Name = 'Test Account';
        myAccount.Market_Manager_Name__c = psgUser.Name;
        
        insert myAccount;
        
        // create psg user role
        PSG_User_Role__c role = new PSG_User_Role__c();
        role.Account__c = myAccount.Id;
        role.PSG_User__c = psgUser.Id;
        role.Role__c = 'Market Coordinator';
        
        insert role;
        
        test.startTest();
        
        List<PSG_User_Role__c> roles = PSGUserRoleClass.findByAccount(myAccount.Id);
        for(PSG_User_Role__c myRole : roles) {
	        PSG_User_Role__c myPSGUserRole = PSGUserRoleClass.findByName(myRole.Name);
        }
        
        system.assertEquals(PSGUserRoleClass.isMarketManager(psgUser), true);
        system.assertEquals(PSGUserRoleClass.isApprover(psgUser), false);
        
        test.stopTest();
    }
}