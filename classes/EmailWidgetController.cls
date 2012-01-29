public with sharing class EmailWidgetController {

    private Id caseId;

    public EmailWidgetWrapper myEmailWidget{get; set;}

	public void setCaseId(Id caseId){
		if(myEmailWidget == null) {
			this.caseId = caseId;
	        myEmailWidget = new EmailWidgetWrapper(null, caseId, null, null);
		}
	}
	
	public Id getCaseId() {
		return caseId;
	}

	public void setDefaultFolder(String folder){
		if(myEmailWidget.folder == '') {
			myEmailWidget.folder = folder;
			myEmailWidget.updateTemplates();
		}
	}
	
	public String getDefaultFolder() {
		return myEmailWidget.folder;
	}
}