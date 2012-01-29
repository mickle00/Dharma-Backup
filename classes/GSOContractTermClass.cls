public with sharing class GSOContractTermClass {
	
	public static List<GSOContract_Term__c> findByContractId(Id contractId) {
		// build where clause
    	List<SoqlBuilder.Condition> conditions = new List<SoqlBuilder.Condition>();
    	conditions.add(new SoqlBuilder.Condition('GSOContract__c', contractId));
    	
		return findBy('*, Term__r.Description__c', conditions, null, null);
	}

	//// Private methdos
	
    private static List<GSOContract_Term__c> findBy(String myFields, List<SoqlBuilder.Condition> conditions, String conditionLogic, String orderBy) {
		return SoqlBuilder.ExecuteSelectQuery(myFields, 'GSOContract_Term__c', conditions, conditionLogic, orderBy);
    }

}