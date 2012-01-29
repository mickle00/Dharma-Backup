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
private class ReContractingAuthentication_Test {

    static testMethod void myUnitTest() {
        PSG_User__c psgUser = new PSG_User__c();
        
        psgUser.Email__c = 'test@test.com';
        psgUser.Name = 'Joe User';
        
        insert psgUser;
        
        test.startTest();
        
        // test if PSGUserEmail is blank or null
        ReContractingAuthentication controller = new ReContractingAuthentication();
        controller.PSGUserEmail = '';
        controller.RequestAuthentication();
        System.assertEquals(Apexpages.hasMessages(), true);

        controller.PSGUserEmail = psgUser.Email__c;
        controller.RequestAuthentication();

        System.assertEquals(controller.Confirmation, 'Email has been successfully authenticated. You should receive an email with a link to the Re-Contracting site.');

        test.stopTest();
    }
}