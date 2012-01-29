public with sharing class ReContractingAuthentication {
	public PSG_User__c PSGUser {get; set;}
    public String PSGUserEmail {get; set;}
    public String Confirmation {get; set;}

    public PageReference RequestAuthentication() {
        if(this.PSGUserEmail == '') {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, 'Please enter an email address'));
                return null;
        }
        
        // authenticate the user and display confirmation
        if(AuthenticateUser() == true) {
                this.Confirmation = 'Email has been successfully authenticated. You should receive an email with a link to the Re-Contracting site.';
        }else {
                this.Confirmation = 'Unable to authenticate the email address. Please contact GSO Support at gsosfdc@expedia.com.';
        }
        
        return Apexpages.currentPage();
    }

    public PageReference VerifyAuthentication() {
    	PSGUser = getPSGUser();
    	
    	if(PSGUser != null) {
	    	// check for token in the querystring. if one exists verify that it matches the token on the psg user and set the verified flag
	    	String token = setToken();
	        
	        // User has been authenticated need to redirect to the appropriate page.
			// MM will be redirected to the intake form        
	        // Approvers will be redirected to the approval page
	        if(PSGUserClass.isAuthenticatedUser(PSGUser) == true) { 
	        	try{
		        	PageReference p = getPageReference();
	        		p.getParameters().put('MM', PSGUser.Email__c);
	        		return p;
	        	}catch(Exception ex){
	        		Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, 'An error ocurred. Please contact GSO Support at <a href="mailto:gsosfsup@expedia.com">gsosfsup@expedia.com</a>'));
	        	}
	        }
    	}

        // User has not been authenticated remain on page
        return null;
    }

    //// Private Methods

    private Boolean AuthenticateUser() {
        Boolean authenticated = false;
        
        // verify a PSG User record exists
        PSGUser = PSGUserClass.findByEmail(this.PSGUserEmail);
        
        if(PSGUser != NULL) {
	        // generate a token
	        PSGUserClass.generateToken(PSGUser);
	        authenticated = true;
        }
        
        return authenticated;
    }
    
    private String setToken() {
    	String token;
    	
		// check the querystring for a token
    	if(PSGUser != null && Apexpages.currentPage().getParameters().containsKey('token') == true){
	        token = Apexpages.currentPage().getParameters().get('token');
	        // if a valid token is found in the querystring store the token in a cookie and verify the token
	        if(token == PSGUser.ReContracting_Token__c) {
		        // set the verified flag
		        PSGUserClass.verifyToken(PSGUser, token);
	        }
    	}
    	
    	return token;
    }
    
    private PSG_User__c getPSGUser() {
    	PSG_User__c objPSGUser;
    	
    	// check the querystring for the market manager/approver name
    	if(Apexpages.currentPage().getParameters().containsKey('MM')){
	        String myPSGUser = EncodingUtil.UrlDecode(Apexpages.currentPage().getParameters().get('MM'), 'UTF-8');
	        // verify that there is a PSGUser record
	        objPSGUser = PSGUserClass.findByEmail(myPSGUser);
    	}
    	
		return objPSGUser;
    }
    
    private PageReference getPageReference() {
    	PageReference myPageReference;
    	
    	if(PSGUserRoleClass.isApprover(PSGUser)) {
	    	// the user is an approver redirect to the approval page
    		myPageReference = Page.ReContractingApprovalStep1;
    	}else if(PSGUserRoleClass.isMarketManager(PSGUser)) {
			// the user is a market manager redirect to MM Intake Form
    		myPageReference = Page.ReContractingStep1;
    	}
    	
    	return myPageReference;
    }
}