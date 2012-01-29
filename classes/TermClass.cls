public with sharing class TermClass {
	
	public static List<Term__c> findByDate(Date beginDate, Date endDate) {
		// fields to retrieve
		String myFields = '*, (Select Name, Default_Value__c From Term_Values__r order by Sort_Order__c)';
		
		// build where clause
    	List<SoqlBuilder.Condition> conditions = new List<SoqlBuilder.Condition>();
    	conditions.add(new SoqlBuilder.Condition('End_Date__c', null));
    	conditions.add(new SoqlBuilder.Condition('End_Date__c', string.valueOf(beginDate), '>='));
    	conditions.add(new SoqlBuilder.Condition('End_Date__c', string.valueOf(endDate), '<='));
    	
		List<Term__c> terms = findBy(myFields, conditions, '{0} OR ({1} AND {2})', 'Sort_Order__c');

		return terms;
	}
	

	//// Private methdos
	
    private static List<Term__c> findBy(String myFields, List<SoqlBuilder.Condition> conditions, String conditionLogic, String orderBy) {
		return SoqlBuilder.ExecuteSelectQuery(myFields, 'Term__c', conditions, conditionLogic, orderBy);
    }
}