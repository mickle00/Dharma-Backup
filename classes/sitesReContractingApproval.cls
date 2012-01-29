public class sitesReContractingApproval {
	public List<GSOContract_Term__c > Terms {get; set;}
	public List<ContractWrapper> Contracts {get; set;}
	public List<GSO_Contract_Submission__c> Submissions {get; set;}
	public GSO_Contract_Submission__c Submission {get; set;}
	public Boolean SelectAllCheckboxes {get; set;}
	public String ApprovalComment {get; set;}
	public String ApprovalStatus {get; set;}
	public Boolean Completed {get; set;}
	public Id SubmissionId {get; set;}

    public PSG_User__c PSGUser {
    	get {
    		if(PSGUser == null) {
		        String approver = Apexpages.currentPage().getParameters().get('MM');
		        PSGUser = PSGUserClass.findByEmail(approver);
    		}
    		return PSGUser;
    	}
    	set;
	}
	
	///// Wrapper class for GSO Contracts
	public class ContractWrapper {
		public GSOContract__c objGSOContract {get; set;}
		public Boolean Selected {get; set;}
		
		public ContractWrapper(GSOContract__c myContract) {
			objGSOContract = myContract;
			Selected = true;
		}
	}// End of ContractWrapper class
	
	public sitesReContractingApproval() {
		if(PSGUser != null) {
			Submissions = getSubmissions();
		} 
		
		// get submission
		Submission = getSubmission();
		
		if(Submission != null) {
			// get contracts
			Contracts = getContracts();

			// get terms			
			if(Contracts.isEmpty() == false) {
				Terms = getTerms(Contracts.get(0).objGSOContract.Id);
			}
		}
		
		SelectAllCheckboxes = true;
		Completed = false;
	}
	
	public PageReference Submit() {
		
		if(ApprovalStatus == null) {
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, 'Please select an approval status.'));
		}else {
			ApproveReject();
		}
		return Apexpages.currentPage();
	}
	
	public PageReference Step1() {
    	PageReference p = Page.ReContractingApprovalStep1;
    	p.setRedirect(true);
		p.getParameters().put('MM', PSGUser.Email__c);
		return p;
	}

    public PageReference VerifyAuthentication() {
        // User has not been authenticated redirect to the authentication page
        if(PSGUserClass.isAuthenticatedUser(PSGUser) == false) { 
            return Page.ReContractingAuthentication;
        }

        // User has been authenticated
        return null;
    }
    
    ///// Private Methods
    private List<GSO_Contract_Submission__c> getSubmissions() {
    	return GSOContractSubmissionClass.getPendingApprovals(this.PSGUser.Email__c);
    }
    
	private GSO_Contract_Submission__c getSubmission() {
		GSO_Contract_Submission__c mySubmission;
		
		try{
			Id sId = (SubmissionId != null ? SubmissionId : Apexpages.currentPage().getParameters().get('Id'));
			// get submission
			system.debug('>>>>>> sitesReContractingApproval getSubmission sid: ' + sId);
			mySubmission = GSOContractSubmissionClass.findById(sId);
		}catch(Exception ex)
		{
			system.debug('>>>>>> sitesReContractingApproval getSubmission exception: ' + ex);
		}
		
		return mySubmission;
	}
	
	private List<ContractWrapper> getContracts() {
		List<ContractWrapper> gsoContracts = new List<ContractWrapper>();
		
		// get list of contracts
		for(GSOContract__c myContract : GSOContractClass.findBySubmissionId(Submission.Id)) {
			gsoContracts.add(new ContractWrapper(myContract));				
		}
		
		return gsoContracts;
	}
	
	private List<GSOContract_Term__c > getTerms(Id contractId) {
		// get list of terms
		return GSOContractTermClass.findByContractId(contractId);
	}
	
	private void ApproveReject() {
		List<GSOContract__c> gsoContracts = new List<GSOContract__c>();
		
		// set approval status and comments for each selected hotel
		for(ContractWrapper myContract : Contracts) {
			if(myContract.Selected == true) {
				myContract.objGSOContract.Approved_By__c = psgUser.Id;
				myContract.objGSOContract.Approval_Status__c = ApprovalStatus;
				myContract.objGSOContract.Approval_Comment__c = ApprovalComment;
				
				gsoContracts.add(myContract.objGSOContract);
			}
		}
		
		try{
			update gsoContracts;
			Completed = true;
		}catch(Exception ex) {
			Apexpages.addMessages(ex);
		}
	}
	
}