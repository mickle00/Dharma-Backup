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
private class sitesVFReContracting_Test {

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
        
        // authenticate the user
        ReContractingAuthentication authentication = new ReContractingAuthentication();
        authentication.PSGUserEmail = psgUser.Email__c;
        authentication.RequestAuthentication();
        
        // get recontracting token
        psgUser = PSGUserClass.findByEmail(psgUser.Email__c);
        System.assertNotEquals(psgUser.ReContracting_Token__c, null);
        Apexpages.currentPage().getParameters().put('mm', psgUser.Email__c);
        Apexpages.currentPage().getParameters().put('token', psgUser.ReContracting_Token__c);
        authentication.VerifyAuthentication();

        test.startTest();
        
        sitesVFReContracting controller = new sitesVFReContracting();
        system.assertEquals(controller.PSGUser.ReContracting_Token__c, psgUser.ReContracting_Token__c);
        
        // verify that the user has been authenticated
        PageReference pRef = controller.VerifyAuthentication();
        system.assertEquals(pRef, null);
        
        // get available accounts
        List<sitesVFReContracting.AccountWrapper> accounts = controller.AvailableAccounts;
        system.assertNotEquals(accounts.isEmpty(), true);
        
        // set the selected accounts
        for(sitesVFReContracting.AccountWrapper myAccountWrapper : accounts) {
        	myAccountWrapper.SelectedContactId = myContact.Id;
        }
        controller.setSelectedAccounts();
        
        // verify that accounts have been selected
        System.assertNotEquals(controller.SelectedAccounts.isEmpty(), true);
        
        // verify that terms exist
        System.assertNotEquals(controller.AvailableTerms.isEmpty(), true);
        for(sitesVFReContracting.TermWrapper term : controller.AvailableTerms) {
        	term.SelectedValue = '5';
        }
        
        controller.Submit();
        // verify that a contract was created
        List<GSOContract__c> contracts = [Select Id From GSOContract__c Where Account__c = : myAccount.Id];
        System.assertNotEquals(contracts.isEmpty(), true);
        
        // verify navigation
        controller.first();
        controller.next();
        controller.previous();
        controller.last();
        controller.goToStep1();
        controller.goToStep2();
        controller.goToStep3();
        System.assertEquals(controller.hasNext, false);
       	System.assertEquals( controller.hasPrevious, false);
        
        test.stopTest();
    }
}