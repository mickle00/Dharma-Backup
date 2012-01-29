trigger GSOContract_Trigger on GSOContract__c (before update) {
	
	List<GSOContract__c> ortCompletedContracts = new List<GSOContract__c>();
	List<GSOContract__c> updatedContracts = new List<GSOContract__c>();
  GSOContractClass objContract = new GSOContractClass();
    
  if (trigger.isUpdate && trigger.isBefore) {
  	objContract.ORTPostProcessing(trigger.new,trigger.oldMap);
  	objContract.UpdatePhase(trigger.new, trigger.oldMap);
  	objContract.CompleteContract(trigger.new);
  }
}