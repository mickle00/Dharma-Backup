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
private class CaseAccountTeamExt_Test {

    static testMethod void myUnitTest() {
      PageReference pageRef = Page.CaseAccountTeam;
      Test.setCurrentPageReference(pageRef);
      
      Account newAccount = new Account (name='XYZ Organization');
      insert newAccount;
      
      PSG_User__c psgUser = new PSG_User__c(Name = 'Test User'
                                        ,Email__c = 'test@email.com'
                                        ,Active__c = true);
                                        
      insert psgUser;
      
      PSG_User__c psgUserCreator = new PSG_User__c(Name = 'Test User'
                                        ,Email__c = 'test@email.com'
                                        ,Active__c = true
                                        ,Title__c = 'Market Manager');
                                        
      insert psgUserCreator;
      
      PSG_User_Role__c userRole = new PSG_User_Role__c(Account__c = newAccount.Id
                                                      ,PSG_User__c = psgUser.Id
                                                      ,Role__c = 'Market Manger');
      insert userRole;

      Case myCase = new Case(Status = 'New'
                            ,AccountId = newAccount.id
                            ,Description = 'New'
                            ,Subject = 'Testing blows');
                                                                   
                  

      insert myCase;
      
      ApexPages.StandardController controller = new ApexPages.standardController(myCase);
      
      // create an instance of the controller
      CaseAccountTeamExt extension = new CaseAccountTeamExt(controller);
      //System.currentPageReference().getParameters().put('psgUser',psgUser.Id);

      Id accountId = extension.getAccountId();
      List<PSG_User_Role__c> accountTeamMembers = extension.getAccountTeamMembers();  
  }
}