global class EmailServicesHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
       
    system.debug('*** EmailServicesHandler => envelope.toAddress = ' + envelope.toAddress + ' ***');      
    CaseClass objCase = new CaseClass();
    
    try{
	    // Lookup the record type and team based on the envelope.toAddress
	    Case_Team__c caseTeam = CaseTeamClass.FindByEmail(envelope.toAddress);
	    
	    if(caseTeam != null) {
			// only generate a case for active case teams
			if(caseTeam.Active__c == True) {
		      // Look at To envelope.toAddress and call appropriate case, passing correct record type
		      objCase.processEmail(email, caseTeam.Record_Type_Developer_Name__c, caseTeam.Team__c, caseTeam.Language__c);
			}        
	    }else {
	      // email not handled so create a
	      //Support Request
	      objCase.processEmail(email, 'Support_Request', null, null);
	    }
    }catch(Exception ex) {
    	Id exId = ExceptionClass.InsertException(ex);
    	EmailUtilities.saveAttachmentsToException(email, exId);
    }

    system.debug('***EmailServicesHandler => Before Return***');    
    return result;  
  }

}