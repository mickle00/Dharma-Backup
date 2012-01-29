public with sharing class EmailWidgetWrapper {
	
	public EmailWidgetWrapper (Connection__c myConnection, id myCaseId, Set<String> templateFolders, string fromAddress){
		this.templateFolders = templateFolders;
		this.myConnection = myConnection;
		this.folders = findTemplateFolders();
		this.templates = findTemplates();		
		this.myCaseId = myCaseId;
		this.fromAddress = fromAddress;
		this.myCase = (myCaseId != null ? CaseClass.findById(myCaseId) : null);
		this.hotelContacts = findHotelContacts();
		this.vendorContacts = findVendorContacts();
		this.systemContacts = findSystemContacts();
		this.marketManagers = findMarketManagers();
		this.accountTeamMembers = findAccountTeamMembers();
		
	}
	
	public List<SelectOption> folders {get; set;}
	public List<SelectOption> templates {get; set;}
	public List<SelectOption> hotelContacts {get; set;}
	public List<SelectOption> vendorContacts {get; set;}
	public List<SelectOption> systemContacts {get; set;}
	public List<SelectOption> marketManagers {get; set;}
	public List<SelectOption> accountTeamMembers {get; set;}
	public Connection__c myConnection {get; set;}
	public string hotelContact{get; set;}
	public id myCaseId{get; set;}
	public String fromAddress{get;set;}
	
    public List<String> selectedHotelContacts{
		get{
			if (selectedHotelContacts == null) selectedHotelContacts = new List<String>();
			return selectedHotelContacts;
		} set;
	}
    public List<String> selectedVendorContacts{
		get{
			if (selectedVendorContacts == null) selectedVendorContacts = new List<String>();
			return selectedVendorContacts;
		} set;
	}
    public List<String> selectedSystemContacts{
		get{
			if (selectedSystemContacts == null) selectedSystemContacts = new List<String>();
			return selectedSystemContacts;
		} set;
	}
    public List<String> selectedMarketManagers{
		get{
			if (selectedMarketManagers == null) selectedMarketManagers = new List<String>();
			return selectedMarketManagers;
		} set;
	}
    public List<String> selectedAccountTeamMembers{
		get{
			if (selectedAccountTeamMembers == null) selectedAccountTeamMembers = new List<String>();
			return selectedAccountTeamMembers;
		} set;
	}
	
	public string template {
		get{
			
			if (template == null) return '';
			return template;							
		}set;
	}
		
	public string folder {
		get{
			if (folder == null) return '';
			return folder;							
		}set;
	}
    public PageReference sendConnectivityEmail(){
    	String myPageReference = '/email/author/emailauthor.jsp?';
		myPageReference += 'retURL=' + getReturnUrl(); // RETURN URL 
		myPageReference += '&p2_lkid=' + (this.selectedHotelContacts.isEmpty() ? this.hotelContact : this.selectedHotelContacts.remove(0));//this.hotelContact; // ContactID
		myPageReference += '&p3_lkid=' + (myConnection != null ? myConnection.Id : myCaseId); // RELATED TO WHATID
		//myPageReference += '&p2=' + '' ;// TO: (CONTACT NAME)									
		//myPageReference += '&p24=' + ccAddresses() ;// ADDITIONAL TO
		myPageReference += '&p4=' + ccAddresses(); // CC ADDRESS
		myPageReference += '&template_id=' + this.template;
		myPageReference += '&new_template=1';
		if(this.fromAddress != null && this.fromAddress != '') {
			myPageReference += '&p26=' + this.fromAddress; // FROM ADDRESS
		}
    	
    	PageReference emailURL = new PageReference (myPageReference); 
    	emailURL.setRedirect(true);
    	return emailURL;   	
	}
	
	public PageReference updateTemplates() {
		system.debug('>>>>>>>>>>> folder ' + folder);
		this.templateFolders = new Set<String>{folder};
		this.templates = findTemplates();		
		
		return null;//Apexpages.currentPage();
	}
	
	// PRIVATE METHODS		
	
	private Set<String> templateFolders;
	private Case myCase;
	private Map<Id, String> hotelContactEmails = new Map<Id, String>();
	
	private string ccAddresses(){
		string ccAddresses = '';		
		ccAddresses += flattenStringList(buildHotelContactsEmail());
		ccAddresses += flattenStringList(this.selectedVendorContacts);		
		ccAddresses += flattenStringList(this.selectedSystemContacts);
		ccAddresses += flattenStringList(this.selectedAccountTeamMembers);
		ccAddresses += this.connectivityAccountManager(); //Added by Steve 10/6
		
		return ccAddresses;
	}
	
	
	// Turn a list into a semicolon separated string
    private string flattenStringList(List<String> myList){
    	String myStrings = '';
    	if (myList != null){
			for (String myString : myList){
				myStrings = myStrings + myString + '; ';
			}
		}
    	return myStrings;
	}
	
	private List<String> buildHotelContactsEmail() {
		List<String> emails = new List<String>();
		
		for(String hotelContactId : this.selectedHotelContacts) {
			emails.add(hotelContactEmails.get(hotelContactId));
		}
		
		return emails;
	}
	
    private List<SelectOption> findTemplateFolders() {
        List<SelectOption> options = new List<SelectOption>();      

		for(Folder myFolder : [Select Type, Name, AccessType From Folder Where Type = 'Email']) {
			options.add(new SelectOption(myFolder.Name, myFolder.Name));
		}

        options.add(new SelectOption('','-- None -- '));
        return options;
    } 

	private List<SelectOption> findTemplates() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','-- None -- '));		
		
    	List<EmailTemplate> emailTemplates = [SELECT Id 
    										   		,Name
    										   		,Folder.Name
    									   		FROM EmailTemplate 
    									  	   WHERE FolderId IN (SELECT Id 
    									  			    			FROM Folder 
    									  					  	   WHERE Name IN :templateFolders)
					  				   		order by Folder.Name, Name asc];

        
        for (EmailTemplate myTemplate : emailTemplates){
        	String templateName = (folder == '' ? myTemplate.Folder.Name + ': ' : '') + myTemplate.Name;
        	options.add(new SelectOption(myTemplate.Id, templateName));
        }           
        
        return options;
	}

    private List<SelectOption> findHotelContacts() {
        List<SelectOption> options = new List<SelectOption>();    

        for (Account_Contact__c hotelContact : AccountContactClass.findByAccountId(getAccountId())){
        	// used to get the email for cc address field
        	hotelContactEmails.put(hotelContact.Contact__c, hotelContact.Contact__r.Email);
        	options.add(new SelectOption(hotelContact.Contact__c, getContactName(hotelContact)));
        }
        options.add(new SelectOption('','-- None -- '));
        return options;
    } 

    private List<SelectOption> findVendorContacts() {
        List<SelectOption> options = new List<SelectOption>();        
		
		if(myConnection != null) {
	        for (Account_Contact__c vendorContact : AccountContactClass.findByAccountId(myConnection.Connectivity_System__r.Connectivity_Vendor__c)){
	        	options.add(new SelectOption(vendorContact.Contact__r.Email,vendorContact.Contact__r.FirstName + ' ' + vendorContact.Contact__r.LastName));
	        }
		}
        return options;
    } 
 
    private List<SelectOption> findSystemContacts() {
        List<SelectOption> options = new List<SelectOption>();

		if(myConnection != null) {
	        for (Connectivity_System_Contact__c systemContact : ConnectivitySystemContactClass.findByConnectivitySystemId(myConnection.Connectivity_System__c)){
	        	options.add(new SelectOption(systemContact.Contact__r.Email,systemContact.Contact__r.FirstName + ' ' + systemContact.Contact__r.LastName));
	        }
		}
        return options;
    }

    private List<SelectOption> findMarketManagers() {
        List<SelectOption> options = new List<SelectOption>(); 

		if(myConnection != null) {
	        if (myConnection.Account__r.Market_Manager_Email__c != null && myConnection.Account__r.Market_Manager_Name__c != null){       
	        	options.add(new SelectOption(myConnection.Account__r.Market_Manager_Email__c, myConnection.Account__r.Market_Manager_Name__c));
	        }
		}
        return options;
    }
    private List<SelectOption> findAccountTeamMembers() {
        List<SelectOption> options = new List<SelectOption>(); 	        
        List<PSG_User_Role__c> accountTeamMembers = PSGUserRoleClass.findByAccount(getAccountId());
        										   
        for (PSG_User_Role__c accountTeamMember : accountTeamMembers){
        	options.add(new SelectOption(accountTeamMember.PSG_User__r.Email__c,accountTeamMember.PSG_User__r.Name + ' (' + accountTeamMember.Role__c + ')'));
        }   
        return options;
    }     	
    
    //Added by Steve 10/6
    private String connectivityAccountManager() {
      if (myConnection != null && myConnection.Connectivity_System__r.Connectivity_Vendor__r.Market_Manager_Email__c != null){
        return myConnection.Connectivity_System__r.Connectivity_Vendor__r.Market_Manager_Email__c;
      } 
      return '';  
    }
    
    private String getReturnUrl() {
    	String retURL;
    	
    	if(this.myConnection != null) {
    		retURL = EncodingUtil.urlEncode('/apex/ManageConnection?Id=' + this.myConnection.Id + '&' + ConnectionController.getCaseQueryString(this.myCaseId), 'UTF-8');
    	}else if(this.myCase != null){
    		Pagereference myPage = new Apexpages.StandardController(this.myCase).view();
    		retURL = myPage.getUrl();
    	}
    	
    	return retURL;
    }
    
    private Id getAccountId() {
    	return (this.myConnection != null ? this.myConnection.Account__c : this.myCase.AccountId);
    }
	
	private String getContactName(Account_Contact__c hotelContact){
		String contactName = '';
		if(hotelContact.Contact__r.FirstName != null) {
			contactName = hotelContact.Contact__r.FirstName;
		}
		if(hotelContact.Contact__r.LastName != null) {
			contactName += ' ' + hotelContact.Contact__r.LastName;
		}
		if(hotelContact.Contact__r.Title != null) {
			contactName	+= ' (' + hotelContact.Contact__r.Title + ')';
		}
		
		return contactName;
	}
	
}