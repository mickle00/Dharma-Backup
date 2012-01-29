public with sharing class GSOContractSubmissionClass {
	
	public static GSO_Contract_Submission__c findById(Id submissionId) {
		String myFields = '*, PSG_User__r.Name';
		
		// build where clause
    	List<SoqlBuilder.Condition> conditions = new List<SoqlBuilder.Condition>();
    	conditions.add(new SoqlBuilder.Condition('Id', submissionId));
    	
		List<GSO_Contract_Submission__c> submissions = findBy(myFields, conditions, null, null);
		if(submissions.isEmpty() == false) {
			return submissions.get(0);
		}

		return null;
	}

	public static List<GSO_Contract_Submission__c> getPendingApprovals(string approverEmail) {
		String myFields = '*, PSG_User__r.Name, (Select Account__r.Name, Account__r.Expedia_Hotel_Id__c From GSOContracts__r)';
		
		// build where clause
    	List<SoqlBuilder.Condition> conditions = new List<SoqlBuilder.Condition>();
    	conditions.add(new SoqlBuilder.Condition('Contracts_Pending_Approval__c', '0', '>'));
    	conditions.add(new SoqlBuilder.Condition('Approver_Email__c', approverEmail));
    	
		List<GSO_Contract_Submission__c> submissions = findBy(myFields, conditions, null, 'CreatedDate');

		return submissions;
	}
	

	//// Private methdos
	
    private static List<GSO_Contract_Submission__c> findBy(String myFields, List<SoqlBuilder.Condition> conditions, String conditionLogic, String orderBy) {
		return SoqlBuilder.ExecuteSelectQuery(myFields, 'GSO_Contract_Submission__c', conditions, conditionLogic, orderBy);
    }
}