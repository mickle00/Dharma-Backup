public class EIDRequestExtension {

        private final String CASE_SOBJECT_TYPE = 'Case';
        private final String CASE_RECORD_TYPE = 'Id_Request';
        private final String CASE_SUBJECT = 'Expedia Id Request';

        public Contract_Checklist__c ContractChecklist {get; set;}
        public String UserComments{get;set;}
        public String AccountName {get;set;}
        public String Phone {get;set;}
        public String Chain {get;set;}
        public String Fax {get;set;}
        public String Brand {get;set;}
        public String StructureType {get;set;}
        public String PriceLevel {get;set;}
        public String SuperRegion {get;set;}
        public String Region {get;set;}
        public String Market {get;set;}
        public String Submarket {get;set;}
        public String ClosestAirport {get;set;}
        public String BillingStreet {get;set;}
        public String BillingCity {get;set;}
        public String BillingState {get;set;}
        public String BillingPostalCode {get;set;}
        public String BillingCountry {get;set;}
        public Boolean InvalidInput {get;set;}
        public String IdsRequested {get;set;}
        
    public EIDRequestExtension() {
    	try {
	    	Id contractChecklistId = Apexpages.currentPage().getParameters().get('Id');
	        Contract_Checklist__c objChecklist = ContractChecklistClass.findById(contractChecklistId);
        										 
	    	this.ContractChecklist = objChecklist;
	        this.UserComments = this.PrePopulateComments();
	        this.InitializeFields();
		}catch(Exception ex) {
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'No contract checklist found. Please contact support at <a href="mailto:gsosfsup@expedia.com">gsosfsup@expedia.com.</a>'));
		}
    }
    
    public PageReference Save() {
        try {
            // create a case
            if(!ValidInput()){
                InvalidInput = true;
            }else {
                    Case objCase = this.CreateCase();
                    
                    // redirect to case
                    return new ApexPages.StandardController(objCase).view();
            }
        }catch(Exception ex) {
            system.debug(ex.getMessage());
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, ex.getMessage()));
        }
        
        return Apexpages.currentPage();
    }
    
    public PageReference Cancel() {
        //update contract checklist
        this.ContractChecklist.Status__c = 'Expedia Hotel ID request cancelled';
        update this.ContractChecklist;
        
        // redirect to contract checklist
        return new ApexPages.StandardController(this.ContractChecklist).view();
        
    }
    
    public List<SelectOption> getStructureTypes() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(Structure_Type__c structType : [Select Id, Name From Structure_Type__c order by Name]) {
            options.add(new SelectOption(structType.Name, structType.Name));
        }
        
        return options;
    }
    
    /////////// Private Methods

    private Case CreateCase() {
        Case objCase = new Case(); 
        objCase.RecordTypeId = this.GetCaseRecordType().Id; 
        objCase.AccountId = this.ContractChecklist.Account__c; 
        objCase.Subject = CASE_SUBJECT; 
        objCase.SuppliedPhone = this.Phone;
        objCase.Description = this.UserComments; 
        objCase.Additional_Information__c = this.GetRequest();
        objCase.Type = 'Account Management';
        objCase.Origin = 'MM';
        objCase.Ids_Requested__c = this.IdsRequested;
        
		database.DMLOptions dmo = new database.DMLOptions();
        
		AssignmentRule[] ar = [SELECT Id 
                               FROM AssignmentRule 
                              WHERE Active = True];
                               
		if(ar.size() != 0) {
			dmo.AssignmentRuleHeader.assignmentRuleId = ar[0].Id;
		}
      
		dmo.AssignmentRuleHeader.useDefaultRule = false;
		objCase.setOptions(dmo);

        insert objCase;
        
        return objCase;
    }
        
    private RecordType GetCaseRecordType() {
        return [Select Id From RecordType Where SObjectType = : CASE_SOBJECT_TYPE and DeveloperName = : CASE_RECORD_TYPE limit 1];
    }
        
    private String PrePopulateComments() {
        // Added to prepopulate comments with a note to setup Expedia Pay 
        // and/or EVC to pass on to case. Used this method instead of creating 
        // new fields on case object. 
        String comments;
        
        if ((this.ContractChecklist.Set_up_Expedia_Pay__c == true) || (this.ContractChecklist.Set_up_EVC__c == true)) { 
            comments = 'NOTE:';
            
            if (this.ContractChecklist.Set_up_Expedia_Pay__c == true) { 
                comments += ' Need to set up Expedia Pay.'; 
            } 
            
            if (this.ContractChecklist.Set_up_EVC__c == true) { 
                comments += ' Need to set up EVC.'; 
            } 
        }// END
        
        return comments; 
    }
        
    private String GetRequest() {
        String strRequest;
        
        strRequest = 'Account Name: ' + this.AccountName + '\n';
        strRequest += 'Phone: ' + this.Phone + '\n';
        strRequest += 'Fax: ' + this.Fax + '\n';
        strRequest += 'Billing Street: ' + this.BillingStreet + '\n';
        strRequest += 'Billing City: ' + this.BillingCity + '\n';
        strRequest += 'Billing State/Province: ' + this.BillingState + '\n';
        strRequest += 'Billing Zip/Postal Code: ' + this.BillingPostalCode + '\n';
        strRequest += 'Billing Country: ' + this.BillingCountry + '\n';
        strRequest += 'Chain: ' + this.Chain + '\n';
        strRequest += 'Brand: ' + this.Brand + '\n';
        strRequest += 'Structure Type: ' + this.StructureType + '\n';
        strRequest += 'Price Level: ' + this.PriceLevel + '\n';
        strRequest += 'Super Region: ' + this.SuperRegion + '\n';
        strRequest += 'Region: ' + this.Region + '\n';
        strRequest += 'Market: ' + this.Market + '\n';
        strRequest += 'Submarket: ' + this.Submarket + '\n';
        strRequest += 'Closest Airport: ' + this.ClosestAirport + '\n';
        strRequest += 'Ids Requested: ' + this.IdsRequested + '\n';
        
        return strRequest;
    }       
        
    private void InitializeFields() {
        InvalidInput = false;
        
        if(this.ContractChecklist.Account__c != NULL) {
                /*String fields = 'Name,Phone,Fax,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Chain__r.Name,Brand__r.Name,ESR_Structure_Type__r.Name,Structure_Type__c,Price_Level__c,Super_Region__r.Name,Region__r.Name,Market__r.Name,Submarket__r.Name,Closest_Airport__c,Expedia_Hotel_Id__c,Vendor_Id__c';
                List<SoqlBuilder.Condition> conditions = new List<SoqlBuilder.Condition>{new SoqlBuilder.Condition('Id', this.objContractChecklist.Account__c)};
                List<Account> accounts = (List<Account>)SoqlBuilder.ExecuteSelectQuery(fields,'Account',conditions, null, null);
                */
                
                List<Account> accounts = [Select Name,
                								 Phone,
                								 Fax,
                								 BillingStreet,
                								 BillingCity,
                								 BillingState,
                								 BillingPostalCode,
                								 BillingCountry,
                								 Chain__r.Name,
                								 Brand__r.Name,
                								 ESR_Structure_Type__r.Name,
                								 Price_Level__c,
                								 Super_Region__r.Name,
                								 Region__r.Name,
                								 Market__r.Name,
                								 Submarket__r.Name,
                								 Closest_Airport__c,
                								 Expedia_Hotel_Id__c,
                								 Vendor_Id__c
                								 From Account
                								 Where Id = : this.ContractChecklist.Account__c]; 
                
                for(Account acct : accounts) {
                this.AccountName = acct.Name;
                this.Phone = acct.Phone;
                this.Fax = acct.Fax;
                this.BillingStreet = acct.BillingStreet;
                this.BillingCity = acct.BillingCity;
                this.BillingState = acct.BillingState;
                this.BillingPostalCode = acct.BillingPostalCode;
                this.BillingCountry = acct.BillingCountry;
                this.Chain = acct.Chain__r.Name;
                this.Brand = acct.Brand__r.Name;
                this.StructureType = acct.ESR_Structure_Type__r.Name;
                this.PriceLevel = acct.Price_Level__c;
                this.SuperRegion = acct.Super_Region__r.Name;
                this.Region = acct.Region__r.Name;
                this.Market = acct.Market__r.Name;
                this.Submarket = acct.Submarket__r.Name;
                this.ClosestAirport = acct.Closest_Airport__c;
                this.IdsRequested = getRequestType(acct.Expedia_Hotel_Id__c , acct.Vendor_Id__c);
                }
        }else {
            this.IdsRequested = getRequestType(null, null);
        }
    }
    
    private Boolean ValidInput() {
        if(this.AccountName == '' || this.BillingCity == '' || this.BillingStreet == '' || this.BillingCountry == '' ||
                this.Chain == '' || this.Brand == '' || this.StructureType == '' || this.SuperRegion == '' || this.Submarket == '' ||
                this.Phone == '' || this.Fax == '' || this.ClosestAirport == ''){
                return false;
        }
        return true;
    }

    private String getRequestType(String eId, String vId) {
        String returnTypes = '';
        if (eId == null || eId == '') returnTypes += 'Expedia Hotel ID;'; 
        if (vId == null || vId == '') returnTypes += 'Expedia Vendor ID;'; 
        
        return returnTypes;
    }
}