public class AccountTeamWrapper {
	public Boolean checked{ get; set; }    
  public PSG_User_Role__c userRole { get; set;}
    
  public AccountTeamWrapper(PSG_User_Role__c thisUserRole) {
    userRole = thisUserRole;        
    checked = false; 
  }
}