/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EmailUtilities_Test {

    static testMethod void myUnitTest() {
      
  	  Case testCase = new Case(subject='Test Case',suppliedName='Joe Blow',suppliedEmail='joe@jote.com');
  	  insert testCase;
  	
  	  Contact myContact = new Contact(email='test@test.com',lastname='test',firstname='this');
  	  insert myContact;
  	 
  	  EmailMessage objEmail = new EmailMessage();
  	  
  	  Messaging.Inboundemail email = new Messaging.Inboundemail();
  	  email.subject = 'This is a test! [ref:Whoa:ref]';
  	  email.fromAddress = 'yuk@yuky.com';
  	  email.plainTextBody = 'I just want to test this class';
  	  
  	  Messaging.InboundEmail.Binaryattachment emailAttachment = new Messaging.InboundEmail.Binaryattachment();
      emailAttachment.Body = Blob.valueOf('Some Text');
      emailAttachment.mimeTypeSubType = 'application/pdf';
      emailAttachment.fileName = 'Test File.pdf';
        
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { emailAttachment };
        
      Messaging.InboundEmail.Textattachment emailTextAttachment = new Messaging.InboundEmail.Textattachment();
      emailTextAttachment.Body = 'Some Text';
      emailTextAttachment.mimeTypeSubType = 'text/plain';
      emailTextAttachment.fileName = 'Test File.txt';
        
      email.Textattachments = new Messaging.inboundEmail.Textattachment[] { emailTextAttachment };
      
      EmailUtilities objEmailUtil = new EmailUtilities();
  	  objEmailUtil.saveAttachmentsToParentFromInboundEmail(email,testCase.id,true);
  	
  	  String subject = 'Email: changing    [ ref:00DM8nm4.500MVJfX:ref ]';
  	  
  	  Task myTask = new Task(whatId = testCase.id
  	                        ,whoId = myContact.id
  	                        ,subject = subject
  	                        ,status = 'Completed'
  	                        ,priority='Completed');
  	  
  	  insert myTask;
  	  
  	  List<Case> cases = new List<Case>();
  	  Case myCase = new Case(suppliedName='Joe Blow',suppliedEmail='joe@blow.com',subject='Test Case');
  	  cases.add(myCase);
  	  myCase.subject = subject;
  	  cases.add(myCase);
  	  myCase.subject = 'Email: changing    [ ref:00';
  	  cases.add(myCase);
  	  
  	  Set<String> emailContactKeys = EmailUtilities.getEmailContactKeys(cases);
  	  system.assertEquals(emailContactKeys.size(), 1);
  	    	  
  	  myCase.SuppliedName = 'Joe';
  	  emailContactKeys = EmailUtilities.getEmailContactKeys(cases);
  	  system.assertEquals(emailContactKeys.size(), 1);
  	  
  	  // MPS DISABLED 8/3/11 BECAUSE OVER EMAIL LIMIT CAUSING TEST TO FAIL & COULDNT BLACKLIST ADDRESSES
  	  // Test sending an email
      //EmailUtilities.sendSingleEmailMessage(new String[]{'test@test.com'}, new String[]{'me@me.com'}, 'me@me.com', 
      //  'senderDisplayName', 'plainTextBody', 'subject', null);
        
      // Test suppressEmailAutoResponse
      Boolean result;
      // false
      result = EmailUtilities.suppressEmailAutoResponse('test@test.com');
      system.assertEquals(result, false);
      //true
      result = EmailUtilities.suppressEmailAutoResponse('noreply@test.com');
      system.assertEquals(result, true);
      
      // Test getting correct email alias and name
      String emailAlias;
      String emailAliasName;
      
      emailAlias = EmailUtilities.getExpediaReplyToAlias('Geography');
      emailAliasName = EmailUtilities.getExpediaReplyToAliasName('Geography');
      system.assertEquals(emailAlias, 'geosup@expedia.com');
      system.assertEquals(emailAliasName, 'Geography Change Requests');
      
      emailAlias = EmailUtilities.getExpediaReplyToAlias('Destination_Services');
      emailAliasName = EmailUtilities.getExpediaReplyToAliasName('Destination_Services');
      system.assertEquals(emailAlias, 'dsmaint@expedia.com');
      system.assertEquals(emailAliasName, 'Destination Services Content Maintenance');
      
      emailAlias = EmailUtilities.getExpediaReplyToAlias('Test');
      emailAliasName = EmailUtilities.getExpediaReplyToAliasName('Test');
      system.assertEquals(emailAlias, 'donotreply.gso@expedia.com');
      system.assertEquals(emailAliasName, 'Expedia GSO');
      
      // Test get orgwide email address
      Map<String,Id> orgWideEmails = EmailUtilities.getOrgWideEmailAddressToId();
      
      // Test buildEmailRecipientsText
      EmailUtilities.buildEmailRecipientsText(new String[] {'test@test.com','rest@rest.com'}
                                             ,new String[] {'cc@test.com','carbon@test.com'}
                                             ,'\n');
    }
}