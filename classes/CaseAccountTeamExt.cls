public with sharing class CaseAccountTeamExt {
	public List<PSG_User_Role__c> memberList {get;set;}
  private Case myCase;
  
  public Boolean showPage{
  	get{
  		return myCase.AccountId != null;
  	}
  }
  
  public CaseAccountTeamExt(ApexPages.StandardController controller) {
    myCase = (Case)controller.getRecord();
    
    myCase = CaseClass.findById(myCase.Id);  
  }
  
  public Id getAccountId() {
    return myCase.AccountId;
  }
  
  public List<PSG_User_Role__c> getAccountTeamMembers() {
    if(memberList == null) {
      memberList = PSGUserRoleClass.findByAccount(myCase.AccountId);       
    }
    return memberList;   
  }

}