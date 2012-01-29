public with sharing class CaseTeamClass {

	public static Case_Team__c FindByEmail(String email) {
		// dynamically build query
		List<SoqlBuilder.Condition> conditions = new List<SoqlBuilder.Condition>();
		conditions.add(new SoqlBuilder.Condition('Email_Service_Address__c', String.escapeSingleQuotes(email)));

		String objectName = Case_Team__c.sObjectType.getDescribe().getName();
		List<SObject> listObjects = SoqlBuilder.ExecuteSelectQuery(objectName, conditions);
		
		if(listObjects.isEmpty() == false) {
			return (Case_Team__c)listObjects.get(0);
		}
		
		return null;
	}
}