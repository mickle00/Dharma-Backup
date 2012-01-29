@isTest
private class PSGUserClass_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        PSG_User__c psgUser = new PSG_User__c();
        
        psgUser.Email__c = 'test@test.com';
        psgUser.Name = 'Joe User';
        
        insert psgUser;
        
        test.startTest();
        // find by id
        PSG_User__c foundPSGUser = PSGUserClass.findById(psgUser.Id);
        system.assertEquals(psgUser.Id,foundPSGUser.Id);
        
        // find by email
        foundPSGUser = PSGUserClass.findByEmail(psgUser.Email__c);
        system.assertEquals(psgUser.Email__c,foundPSGUser.Email__c);

        // find by name
        foundPSGUser = PSGUserClass.findByName(psgUser.Name);
        system.assertEquals(psgUser.Name,foundPSGUser.Name);
        test.stopTest();
    }

    static testMethod void myUnitTest2() {
        PSG_User__c psgUser = new PSG_User__c();
        
        psgUser.Email__c = 'test@test.com';
        psgUser.Name = 'Joe User';
        
        insert psgUser;
        
        test.startTest();
        // generate re-contracting token
    	PSGUserClass.generateToken(psgUser);
        system.assertNotEquals(psgUser.ReContracting_Token__c, null);

        // verify re-contracting token
    	PSGUserClass.verifyToken(psgUser, psgUser.ReContracting_Token__c);
        system.assertEquals(psgUser.Token_Verified__c, true);

        system.assertEquals(PSGUserClass.isAuthenticatedUser(psgUser), true);
    	
        test.stopTest();
    }
}