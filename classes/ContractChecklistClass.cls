public with sharing class ContractChecklistClass {
	
	Private Map<String,RecordType> recordTypesMap = Utilities.getRecordTypesMap('Contract_Checklist__c', true);
	
	public static Boolean informaticaRunning = false;
	
	public static Contract_Checklist__c findById(Id contractChecklistId) {
		
		return [SELECT Id
                  ,Account__c
                  ,Status__c
                  ,PSG_Checklist_Created_By__c
				  ,Account__r.Name
				  ,Set_up_EVC__c
				  ,Set_up_Expedia_Pay__c 
              FROM Contract_Checklist__c
             WHERE Id = :contractChecklistId
             LIMIT 1];
	}
	
	public static List<Contract_Checklist__c> findByIds(Set<Id> checklistIds) {
	  return [SELECT Id
	                ,Account__c
                  ,Status__c
              FROM Contract_Checklist__c
             WHERE Id IN :checklistIds];	
	}
	
	public static void RunInformatica() {
		if (ContractChecklistClass.informaticaRunning == false) {
			ContractChecklistClass.informaticaRunning = true;
		  External_Logins__c login = External_Logins__c.getInstance('informatica_cloud');
  
      if(login != null) {
        //system.debug('INFORMATICA TRIGGERED=' + informaticaTriggered);
        InformaticaCloud.runJob(login.UserName__c,login.Password__c,'CL-Contract-ID-Update-GSO-PSG','DSS');  
        //informaticaTriggered = true;
      }	
		}
	} 
    
  public void statusChanged(List<Contract_Checklist__c> changedStatuses){
    ContractLoadingStepClass objStep = new ContractLoadingStepClass();
    objStep.newContractLoadingSteps(changedStatuses);
   
  }
  
  public void ContractReturnedToMMDate(List<Contract_Checklist__c> checklists) {
  	
  	for (Contract_Checklist__c checklist : checklists) {
  		if (checklist.Date_Returned_to_MM_MC__c == null && 
  		    ContractReturnedToMM(checklist.Status__c) == true &&
  		    checklist.RecordTypeId == recordTypesMap.get('Hotel').Id ) {
  		  checklist.Date_Returned_to_MM_MC__c = datetime.now();
  		}
  	}
  }
  
  public void ContractReturnedToLoadingTeam(List<Contract_Checklist__c> checklists) {
  	 
    for (Contract_Checklist__c checklist : checklists) {
      if (checklist.Date_Returned_to_Loading_Team_From_MM_MC__c == null && 
           ContractReturnedToLoadingTeam(checklist.Status__c) == true &&
           checklist.RecordTypeId == recordTypesMap.get('Hotel').Id ) {
         checklist.Date_Returned_to_Loading_Team_From_MM_MC__c = datetime.now();
       }	
    }
  }
  
  public void ContractRejectedReturnedToLoading(List<Contract_Checklist__c> checklists) {
     
    for (Contract_Checklist__c checklist : checklists) {
      if (checklist.Rejected_Return_to_Loading_Date__c == null && 
           ContractRejectedReturnedToLoading(checklist.Status__c) == true &&
           checklist.RecordTypeId == recordTypesMap.get('Hotel').Id ) {
         checklist.Rejected_Return_to_Loading_Date__c = datetime.now();
       }  
    }
  }
  
  public void ContractRejected(List<Contract_Checklist__c> checklists) {
     
    for (Contract_Checklist__c checklist : checklists) {
      if (checklist.Rejected_Date__c == null && 
           ContractRejected(checklist.Status__c) == true &&
           checklist.RecordTypeId == recordTypesMap.get('Hotel').Id ) {
         checklist.Rejected_Date__c = datetime.now();
       }  
    }
  }
  
  public void ContractLoadingComplete(List<Contract_Checklist__c> checklists) {
     
    for (Contract_Checklist__c checklist : checklists) {
      if (ContractLoadingComplete(checklist.Status__c) == true) {
      	if (checklist.Contract_Complete_Date__c == null) {
      	  checklist.Contract_Complete_Date__c = datetime.now();	
      	}
      	if (checklist.RecordTypeId == recordTypesMap.get('Hotel').Id &&
      	    checklist.Date_MM_Notified__c == null) {
      	  checklist.Date_MM_Notified__c = datetime.now();
      	}
      }     
    }  
  } 
  
  public void DocusignMailRecievedDate(List<Contract_Checklist__c> checklists) {
  	for (Contract_Checklist__c checklist : checklists) {
  		if (checklist.Docusign_Mail_Received_Date__c != null &&
  		    checklist.Contract_Start_Loading_Date__c == null &&
  		    checklist.RecordTypeId == recordTypesMap.get('Hotel').Id) {
  		  checklist.Contract_Start_Loading_Date__c = datetime.now();
  		}
  	} 
  }
  public void DateIdRequested(List<Contract_Checklist__c> checklists) {
    for (Contract_Checklist__c checklist : checklists) {
      if (RequestedIDs(checklist.Status__c) == true &&
          checklist.Date_ID_Requested__c == null) {
        checklist.Date_ID_Requested__c = datetime.now();
      }
    } 	
  	
  }
  public void updateContractChecklistStatus(Set<Id> checklistIds,String status) {
        
    List<Contract_Checklist__c> checklists = ContractChecklistClass.findByIds(checklistIds);
                                                  
    for(Contract_Checklist__c checklist : checklists) {
      checklist.Status__c = status;
    }
        
    update checklists;
  }
  
  public void AssignValuesBeforeInsert(List<Contract_Checklist__c> checklists) {
    for(Contract_Checklist__c checklist : checklists) {
    	if (DestinationServicesChecklist(checklist.PSG_RecordType__c)) {
    		checklist.RecordTypeId = recordTypesMap.get('Destination_Services').Id;
    		checklist.Contract_Start_Loading_Date__c = datetime.now();
    	}
    	
    	if (HotelChecklist(checklist.PSG_RecordType__c)) {
    		checklist.RecordTypeId = recordTypesMap.get('Hotel').Id;
    	}
    }	
  }
  
  private Boolean DestinationServicesChecklist(String psgRecordType) {
    return psgRecordType == 'Destination_Services_Checklist';	
  }
  
  private Boolean HotelChecklist(String psgRecordType) {
  	return psgRecordType == 'New2007ContractRecordType';
  }
  
  private Boolean ContractReturnedToMM(String status) {
    return status == 'Contract Returned to MM/MC-See Comments';
  }
  
  private Boolean ContractReturnedToLoadingTeam(String Status) {
  	return status == 'Contract Returned to Loading Team';
  }
  
  private Boolean ContractLoadingComplete(String status) {
    return status == 'Contract Loading Complete';
  }
  
  private Boolean ContractRejectedReturnedToLoading(String status) {
  	return status == 'Rejected - Returned to Loading';
  }
  
  private Boolean ContractRejected(String status) {
  	return status == 'Rejected';
  }
  
  private Boolean RequestedIDs(String status) {
  	return status == 'Requested ID\'s(Vendor or Expedia ID)';
  }
  
  private Boolean LoadingContract(String status) {
  	return status == 'Loading Contract';
  }
}