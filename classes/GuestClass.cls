public class GuestClass {
	
	public Id CaseId {get; set;}
	
	public List<Guest__c> getGuestList() {
		List<Guest__c> guests = [SELECT Name, 
									Id, 
									Arrival_Date__c, 
									Number_of_Nights__c, 
									New_Expedia_Booking_ID__c, 
									Relocation_Cost__c, 
									Difference_absorbed_by__c, 
									New_Vendor__r.Id, 
									New_Vendor__r.Name 
									FROM Guest__c g, g.New_Vendor__r, g.Case__r 
									WHERE Case__r.Id = : CaseId];
									
		return guests;
	}
}