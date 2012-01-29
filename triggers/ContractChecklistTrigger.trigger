trigger ContractChecklistTrigger on Contract_Checklist__c (after update, before insert, before update, after insert) {
  ContractChecklistClass objChecklist = new ContractChecklistClass();
  
  //Static Boolean informaticaTriggered = false;
  
  if (trigger.isAfter && trigger.isUpdate) {
  	
    List<Contract_Checklist__c> statusChanged = new List<Contract_Checklist__c>();
    
    for (Contract_Checklist__c checklist : trigger.new) {
      if(checklist.Status__c != trigger.oldMap.get(checklist.Id).Status__c){
        system.debug('SIZE =>' + trigger.new.size());
        system.debug('Status => ' + checklist.Status__c + '|| Old Status => ' + trigger.oldMap.get(checklist.Id).Status__c);
        system.debug('Did my status change?' + checklist.Status__c);
        statusChanged.add(checklist); 
      }
    }
    objChecklist.statusChanged(statusChanged); 
  }
  
  if (trigger.isBefore && trigger.isUpdate) {
  	objChecklist.ContractReturnedToMMDate(trigger.new);
  	objChecklist.ContractReturnedToLoadingTeam(trigger.new);
  	objChecklist.ContractLoadingComplete(trigger.new);
  	objChecklist.ContractRejectedReturnedToLoading(trigger.new);
  	objChecklist.ContractRejected(trigger.new);
  	objChecklist.DocusignMailRecievedDate(trigger.new);
  	objChecklist.DateIdRequested(trigger.new);
  }
  
  if(trigger.isInsert && trigger.isBefore) {
  	objChecklist.AssignValuesBeforeInsert(trigger.new);
  }
  
  if (trigger.isInsert && trigger.isAfter) {
  	objChecklist.statusChanged(trigger.new);
  }
  
  if (trigger.isInsert) {
  	//this will trigger the job to report back to PSG setting the Contract_Checklist ID on the PSG record.
    ContractChecklistClass.RunInformatica();
  }
}