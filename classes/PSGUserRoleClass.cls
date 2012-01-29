public with sharing class PSGUserRoleClass {
	
	public static List<PSG_User_Role__c> findByAccount(Id accountId) {
		return [SELECT Id
                  ,Name
                  ,Role__c
                  ,Account__c
                  ,Account__r.Name
                  ,PSG_User__c
                  ,PSG_User__r.Name
                  ,PSG_User__r.Phone__c
                  ,PSG_User__r.Email__c
              FROM PSG_User_Role__c
             WHERE Account__c = :accountId
             ORDER BY Role__c ASC];
	}
	
	public static PSG_User_Role__c findByName(String psgUserRoleName) {
	  return [SELECT Id
                  ,Name
                  ,Role__c
                  ,Account__c
                  ,Account__r.Name
                  ,PSG_User__c
                  ,PSG_User__r.Name
                  ,PSG_User__r.Phone__c
                  ,PSG_User__r.Email__c
              FROM PSG_User_Role__c
             WHERE Name = :psgUserRoleName
             LIMIT 1];	
	}
	
	public static Boolean isMarketManager(PSG_User__c psgUser) {
		
		return PSGUserRoleClass.hasRole(psgUser, '%Market%');
	}

	public static Boolean isApprover(PSG_User__c psgUser) {
		
		return PSGUserRoleClass.hasRole(psgUser, 'Recontracting Approver');
	}
	
	//// Private Methods
	private static Boolean hasRole(PSG_User__c psgUser, String role) {
		
		List<PSG_User_Role__c> roles = [Select Id From PSG_User_Role__c Where PSG_User__c = : psgUser.Id And Role__c like : role];

		return (roles.isEmpty() == false);
	}
}