public class sitesVFReContracting {
    private static final Integer PAGE_SIZE = 25;
    private static final String GSO_TOKEN = 'GSO_TOKEN';
    private static final String APPROVER_ALIAS = 'gsotestap@expedia.com'; //etpdmms@expedia.com

    // Wrapper class for account contacts
    public class AccountWrapper {
        private List<Account_Contact__c> availableContacts {get; set;} // contacts associated with the account
        public Account Acct {get; set;}
        public Id SelectedContactId {get; set;} // contact selected
        
        public AccountWrapper(Account acct, Id selectedContactId) {
            this.Acct = acct;
            this.availableContacts = acct.Account_Contacts__r;
            this.SelectedContactId = selectedContactId;
        }
        
        // Returns a list of contacts associated with the account
        public List<SelectOption> Contacts {
            get{
                if(Contacts == null) {
                    Contacts = new List<SelectOption>();
                    
                    Contacts.add(new SelectOption('', 'Select a contact'));
                    for(Account_Contact__c myContact : availableContacts) {
                        String label = myContact.Contact__r.Name;
                        // include title if one exists
                        if(myContact.Contact__r.Title != null) {
                             label += ' (' + myContact.Contact__r.Title + ')';
                        }
                        Contacts.add(new SelectOption(myContact.Contact__c, label));
                    }
                }
                return Contacts;
            }
            set;
        }

        // Returns the selected contact object
        public Contact SelectedContact{
            get{
                if(this.SelectedContactId != NULL){
                    SelectedContact = ContactClass.findById(this.SelectedContactId);
                }
                
                return SelectedContact;
            }
            set;
        }
    } //// End AccountWrapper class
    
    // Wrapper class for Commercial Terms
    public class TermWrapper {
        public Term__c Term {get; set;}
        public String SelectedValue {get; set;}
        public Boolean ValidInput {get; set;}
        // indicates if the term is rendered as a select list or textbox
        public Boolean RenderSelectList { get { return this.Term.Term_Values__r.size() > 1; } } 
        public Boolean Required { get { return this.Term.Required__c; } } // indicates if the term is required
        public Boolean DisplayChild { get { return DisplayChildTerm(); } }
        public List<TermWrapper> childTerms {get; set;}
        public String DefaultValue {get; set;}
        
        public TermWrapper(Term__c term) {
            this.Term = term;
            this.ValidInput = true;
            this.SelectedValue = DefaultValue = getDefaultValue();
            this.childTerms = new List<TermWrapper>();
        }

        public List<SelectOption> TermValues{
            get {
                if(TermValues == null) {
                    TermValues = new List<SelectOption>();
                    // get list of term values
                    TermValues.add(new SelectOption('', 'Select One'));
                    
                    for(Term_Value__c termValue : this.Term.Term_Values__r) {
                        TermValues.add(new SelectOption(termValue.Name, termValue.Name));
                        if(termValue.Default_Value__c == true) SelectedValue = termValue.Name;
                    }
                }
                return TermValues;
            }
            private set;
        }
        
        public PageReference onChangeofTerms() {
            // set child values
            for(TermWrapper childTerm : childTerms) {
                childTerm.SelectedValue = (this.displayChild == false ? null : childTerm.DefaultValue);
            }
            
            return null;
        }
        
        public Boolean IsValid() {
            return RequiredValueSet() && IsNumeric();
        }
        
        public List<GSOContract_Term__c> CreateContractTerms(GSOContract__c myContract) {
            List<GSOContract_Term__c> contractTerms = new List<GSOContract_Term__c>();
    
            // create parent terms
            if(this.SelectedValue != null && this.SelectedValue != '') {
                GSOContract_Term__c myContractTerm = new GSOContract_Term__c();
                myContractTerm.GSOContract__c = myContract.Id;
                myContractTerm.Term__c = this.Term.Id;
                myContractTerm.Value__c = this.SelectedValue;
                
                contractTerms.add(myContractTerm);
                
                // if the selected value is outside of the validation range an approval is required
                if((this.Term.Min_Value__c  != null && Decimal.valueOf(myContractTerm.Value__c) < this.Term.Min_Value__c) ||
                    (this.Term.Max_Value__c  != null && Decimal.valueOf(myContractTerm.Value__c) > this.Term.Max_Value__c)){
                    myContract.Approval_Required__c = true;
                    myContract.Approval_Status__c = 'Pending Approval';
                }
            }
            // set the contract terms
            if(this.Term.Description__c == 'Length of contract (months)') {
                myContract.Contract_Term_months__c = Integer.valueOf(this.SelectedValue);
            }
            
            // create child terms
            for(TermWrapper childTerm : childTerms) {
                if(this.DisplayChildTerm() == true) {
                    contractTerms.addAll(childTerm.CreateContractTerms(myContract));
                }
            }
            
            return contractTerms;
        }

        ////// Private Methods
        
        private Boolean DisplayChildTerm() {
            // determine if the child term is displayed. if the selected value of the parent term equals the 'When to Display'
            // value of the child term the child term is displayed.
            return (this.Term.When_To_Display__c == this.SelectedValue);
        }
        
        private Boolean RequiredValueSet() {
            Boolean valueSet = this.ValidInput = true;
            
            // if the term is required validate that the value is not null
            if(this.Required && (this.SelectedValue == '' || this.SelectedValue == null)) {
                valueSet = this.ValidInput = false;
            }
            
            // validate child terms
            if(this.DisplayChildTerm() == true) {
                for(TermWrapper childTerm : childTerms) {
                    if(childTerm.RequiredValueSet() == false) {
                        valueSet = false;
                    }
                }
            }
            
            return valueSet;
        }

        private Boolean IsNumeric() {
            Boolean isNumeric = this.ValidInput = true;
            
            // for text values attempt to convert to a decimal
            if(this.RenderSelectList == false && (this.SelectedValue != '' && this.SelectedValue != null)){
                try{
                    Decimal myDecimal = Decimal.valueOf(this.SelectedValue);
                }catch (Exception ex){
                     isNumeric = this.ValidInput = false;
                }
            }
            
            // validate child terms
            if(this.DisplayChildTerm() == true) {
                for(TermWrapper childTerm : childTerms) {
                    if(childTerm.IsNumeric() == false) {
                        isNumeric = false;
                    }
                }
            }
            
            return isNumeric;
        }

        private String getDefaultValue() {
            for(Term_Value__c termValue : this.Term.Term_Values__r) {
                if(termValue.Default_Value__c == true) {
                    return termValue.Name;
                }
            }
            return null;
        }
        
    } //// End TermWrapper class

    // used to search for a single account
    public String ExpediaHotelId {get; set;}
    public Boolean SupplierTrainingByMM {get; set;}
    public Boolean ApprovalRequired {get; set;}
    
    public PSG_User__c PSGUser {
        get {
            if(PSGUser == null) {
                String marketManager = Apexpages.currentPage().getParameters().get('MM');
                PSGUser = PSGUserClass.findByEmail(marketManager);
            }
            return PSGUser;
        }
        set; 
    }

    // list of all accounts associated to the market manager
    public List<AccountWrapper> AvailableAccounts {
        get{
            if(AvailableAccounts == null) {
                AvailableAccounts = getAvailableAccounts();
            }
            return AvailableAccounts;
        }
        set;
    }
    
    // list of all accounts that have been selected
    public Map<Id, AccountWrapper> SelectedAccounts {
        get {
            if(SelectedAccounts == null) {
                SelectedAccounts = new Map<Id, AccountWrapper>();
            }
            return SelectedAccounts;
        }
        private set;
    }
    
    // list of all available terms
    public List<TermWrapper> AvailableTerms { 
        get {
            if(AvailableTerms == null) {
                AvailableTerms = getListofTerms();
            }
            return AvailableTerms;
        }
        set;
    }
    
    // add or remove accounts to the selected list
    public void setSelectedAccounts(){
        for(AccountWrapper availAcct : AvailableAccounts) {
            if(availAcct.SelectedContactId != null) {
                // add account to the list
                SelectedAccounts.put(availAcct.Acct.Id, availAcct);
            }else {
                // remove account from the list
                SelectedAccounts.remove(availAcct.Acct.Id);
            }
        }
    }
    
    ////// Paging Properties and Methods
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return ListController.getHasNext();
        }
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return ListController.getHasPrevious();
        }
    }
 
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return ListController.getPageNumber();
        }
    }
 
    public Integer numberOfPages {
        get {
            numberOfPages = ListController.getResultSize()/PAGE_SIZE;
            if(math.mod(ListController.getResultSize(),PAGE_SIZE) > 0) {
                numberOfPages = numberOfPages + 1;
            }
            return numberOfPages;
        }
        private set;
    }

    // navigates to step 1 of the wizard
    public PageReference goToStep1() {
        return Page.ReContractingStep1;
    }

    // navigates to step 2 of the wizard
    public PageReference goToStep2() {
        if(SelectedAccounts.isEmpty() == true) {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'You must select at least one account.'));
            return null;
        }
        return Page.ReContractingStep2;
    }
    
    // navigates to step 3 of the wizard
    public PageReference goToStep3() {
        // validate the input
        if(ValidateInput() == true) {
            // redirect to next step in the wizard
            return Page.ReContractingStep3;
        }
        return null;
    }

    // navigates to step 3 of the wizard
    public PageReference Submit() {
        // create contracts for each selected account
        if(SubmitHelper() == true) {
            return Page.ReContractingConfirmation;
        }
        
        return null;    
    }

    // returns the first page of records
    public void first() {
        ListController.first();
        AvailableAccounts = getAvailableAccounts();
    }
 
    // returns the last page of records
    public void last() {
        ListController.last();
        AvailableAccounts = getAvailableAccounts();
    }

    // returns the previous page of records
    public void previous() {
        ListController.previous();
        AvailableAccounts = getAvailableAccounts();
    }
 
    // returns the next page of records
    public void next() {
        ListController.next();
        AvailableAccounts = getAvailableAccounts();
    }
    ////// End Paging Properties and Methods
        
    public PageReference VerifyAuthentication() {
        // User has not been authenticated redirect to the authentication page
        if(PSGUserClass.isAuthenticatedUser(PSGUser) == false) { 
            return Page.ReContractingAuthentication;
        }

        // User has been authenticated
        return null;
    }
    
    public PageReference Search() {
        // clear the current list
        ListController = null;
        // query for accounts
        AvailableAccounts = getAvailableAccounts();
        
        return Apexpages.currentPage();
    }
    
    //// Private Methods
    private ApexPages.StandardSetController ListController {
        get {
            // used to get paged results
            if(ListController == null && PSGUser != null) {
                // build query
                String query = BuildQuery();
                
                ListController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
                ListController.setPageSize(PAGE_SIZE);
            }
            
            // if the list controller is still null 
            if(ListController == null) ListController = new ApexPages.StandardSetController(new List<Account>());
            return ListController;
        }
        private set;
    }
    
    private String BuildQuery() {
        // exclude accounts with contracts
        String accountIds;
        for(Account myAccount : [Select Id From Account Where Id In (Select Account__c From GSOContract__c Where (Approval_Required__c = false) OR (Approval_Required__c = true AND Approval_Status__c != 'Rejected'))]) {
            if(accountIds == NULL) {
                accountIds = '\'' + myAccount.Id + '\'';
            }else {
                accountIds += ',\'' + myAccount.Id + '\'';
            }
        }

        // build query string
        String query = 'Select Name, Id, Expedia_Hotel_Id__c, Region__r.Name,' +
                        ' (Select Contact__r.Id, Contact__r.Name, Contact__r.Title From Account_Contacts__r order by Contact__r.Name) ' +
                        ' From Account Where Market_Manager_Name__c = \'' + String.escapeSingleQuotes(PSGUser.Name) + '\'';
                        
        if(accountIds != null) query += ' And Id Not In (' + accountIds + ')';
                        
        if(ExpediaHotelId != '' && ExpediaHotelId != null) {
            query += ' And Expedia_Hotel_Id__c = \'' + String.escapeSingleQuotes(ExpediaHotelId) + '\'';
        }
                        
        return query;
    }
    // get list of available accounts
    private List<AccountWrapper> getAvailableAccounts() {
        List<AccountWrapper> accounts = new List<AccountWrapper>();
        
        // call ListController to get paged results
        for(Account myAccount : (List<Account>) ListController.getRecords()) {
            // check to see if the account is already included in the selected accounts.
            // if it's already been selected set the selected contact id
            AccountWrapper selAcct = SelectedAccounts.get(myAccount.Id);
            Id selectedContact = (selAcct == null ? null : selAcct.SelectedContactId);
            
            accounts.add(new AccountWrapper(myAccount, selectedContact));
        }

        return accounts;
    }
    
    private List<TermWrapper> getListofTerms() {
        // used to map the parent term wrapper to the child term
        Map<Id, TermWrapper> tempTerms = new Map<Id, TermWrapper>();
        // since we can't sort the values in a map we need to use a list.
        List<TermWrapper> terms = new List<TermWrapper>();
        
        // get date range for current year. ex.: 1/1/2011 - 12/31/2011
        Date beginDate = Date.newInstance(1, 1, system.today().year());
        Date endDate = Date.newInstance(12, 31, system.today().year());
        
        // get terms for the current year
        for(Term__c term : TermClass.findByDate(beginDate, endDate)) {
            
            if(term.Parent_Term__c == null) {
                // create parent term
                TermWrapper myTerm = new TermWrapper(term);
                tempTerms.put(term.Id, myTerm);
                terms.add(myTerm);
            }else {
                // get parent term
                TermWrapper parentTerm;
                parentTerm = tempTerms.get(term.Parent_Term__c);

                // create child term
                TermWrapper childTerm = new TermWrapper(term);
                // add child term to the parent term
                parentTerm.childTerms.add(childTerm);
            }
       }
        
        return terms;
    }
    
    private Boolean ValidateInput() {
        Boolean validInput = true;
        
        for(TermWrapper myTerm : AvailableTerms) {
            // if the term is required, validate that the value is not null
            if(myTerm.IsValid() == false) {
                validInput = false;
            }
        }
        return validInput;
    }
    
    private Boolean SubmitHelper() {
        Boolean success = true;
        
        try {
            // create a contract submission record
            GSO_Contract_Submission__c submission = CreateSubmission();
            
            // create contracts for each selected account
            List<GSOContract__c> contracts = CreateContracts(submission);
            
            // create contract terms
            List<GSOContract_Term__c> contractTerms = CreateContractTerms(contracts);
            
            // set the list controller to null so that the available accounts list is refreshed if the user starts the wizard
            // again
            ListController = null;
        }catch(Exception ex) {
            Apexpages.addMessages(ex);
            success = false;
        }
        
        return success;
    }
    
    private List<GSOContract__c> CreateContracts(GSO_Contract_Submission__c submission) {
        List<GSOContract__c> contracts = new List<GSOContract__c>();
        
        // create contracts for each selected account
        for(AccountWrapper myAccount : SelectedAccounts.values()) {
            GSOContract__c myContract = new GSOContract__c();
            myContract.Account__c = myAccount.Acct.Id;
            myContract.Contact__c = myAccount.SelectedContactId;
            myContract.Date_Contract_Started__c = Date.Today();
            myContract.GSO_Contract_Submission__c = submission.Id;
            myContract.Batch_Size__c = SelectedAccounts.size();
            myContract.Supplier_Training_by_Market_Manager__c = false;//this.SupplierTrainingByMM;
            
            contracts.add(myContract);
        }
        
        // insert contracts
        insert contracts;

        return contracts;
    }
    
    private List<GSOContract_Term__c> CreateContractTerms(List<GSOContract__c> contracts) {
        List<GSOContract_Term__c> contractTerms = new List<GSOContract_Term__c>();

        // link contracts to terms
        for(GSOContract__c myContract : contracts) {
            for(TermWrapper myTerm : AvailableTerms) {
                contractTerms.addAll(myTerm.CreateContractTerms(myContract));
            }
        }
        
        // insert contract terms
        insert contractTerms;

        // update the contract terms
        update contracts;
        
        ApprovalRequired = contracts.get(0).Approval_Required__c;

        return contractTerms;
    }
    
    private GSO_Contract_Submission__c CreateSubmission() {
        GSO_Contract_Submission__c submission = new GSO_Contract_Submission__c();
        submission.PSG_User__c = PSGUser.Id;
        submission.Market_Manager_Email__c = PSGUser.Email__c;
        
        // set the email alias for the workflow rule to allow an email notification to all approvers
        submission.Approver_Email__c = getApproverEmail(); //APPROVER_ALIAS;
        
        insert submission;
        
        return submission;
    }
    
    private String getApproverEmail(){
        String approverEmail;
         
        AccountWrapper myAccountWrapper = SelectedAccounts.values().get(0);
        String region = myAccountWrapper.Acct.Region__r.Name;
        
        if(region.contains('Italy')) {
            approverEmail = 'lvaleri@expedia.com.staging';
        }else if(region.contains('Spain')) {
            approverEmail = 'cdavids@expedia.com.staging';
        }else if(region.contains('Germany')) {
            approverEmail = 'aerichson@expedia.com.staging';
        }else {
            approverEmail = APPROVER_ALIAS;
        }
        
        return approverEmail;
    }
}