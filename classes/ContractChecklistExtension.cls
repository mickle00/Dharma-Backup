public class ContractChecklistExtension {

	private final Contract_Checklist__c objContractChecklist;
	private final String REQUEST_IDS = 'Requested ID\'s(Vendor or Expedia ID)';
	private final String CASE_SOBJECT_TYPE = 'Case';
	private final String CASE_RECORD_TYPE = 'Id_Request';
	
	public String RedirectUrl { get; set; }
	
    public ContractChecklistExtension(ApexPages.StandardController controller) {
		this.objContractChecklist = (Contract_Checklist__c)controller.getRecord();
    }
	
	public PageReference EIDRequestRedirect() {
		Pagereference objPage = Apexpages.currentPage();
		RedirectUrl = '';
		
		System.debug('>>>>>> ContractChecklistExtension.EIDRequestRedirect Status = ' + this.objContractChecklist.Status__c);
		System.debug('>>>>>> ContractChecklistExtension.EIDRequestRedirect Vendor Id = ' + this.objContractChecklist.Account__r.Vendor_Id__c);
		System.debug('>>>>>> ContractChecklistExtension.EIDRequestRedirect Expedia Hotel Id = ' + this.objContractChecklist.Account__r.Expedia_Hotel_Id__c);
		system.debug('>>>>>>>> ContractChecklistExtension.CaseSubmitted case submitted = ' + this.CaseSubmitted());
		
		if(this.objContractChecklist.Status__c == REQUEST_IDS 
		  && (this.objContractChecklist.Account__r.Vendor_Id__c == NULL 
		  || this.objContractChecklist.Account__r.Expedia_Hotel_Id__c == NULL)
		  && this.CaseSubmitted() == false) {

			// redirect to 
			objPage = Page.EIDRequest; 
			objPage.getParameters().put('Id', this.objContractChecklist.Id);
			RedirectUrl = objPage.getUrl();
		}
		
		return null;
	}
	
	///////// Private Methods
	private Boolean CaseSubmitted() {
		RecordType rtCase = this.GetCaseRecordType();
		system.debug('>>>>>>>> ContractChecklistExtension.CaseSubmitted case record type = ' + rtCase.Id);
		system.debug('>>>>>>>> ContractChecklistExtension.CaseSubmitted case account id = ' + this.objContractChecklist.Account__c);
		
		List<Case> objCase = [Select Id, CaseNumber FROM Case WHERE RecordTypeId = : rtCase.Id AND IsClosed = false AND AccountId = : this.objContractChecklist.Account__c LIMIT 1];
		return (objCase.isEmpty() == false);
	}

	private RecordType GetCaseRecordType() {
		return [Select Id From RecordType Where SObjectType = : CASE_SOBJECT_TYPE and DeveloperName = : CASE_RECORD_TYPE limit 1];
	}
}