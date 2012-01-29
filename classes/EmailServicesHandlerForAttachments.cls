/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class EmailServicesHandlerForAttachments implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        try {
        	EmailUtilities objEmail = new EmailUtilities();
        	objEmail.SaveAttachmentFromEmail(email);
        	/*
          String attachmentId = email.subject.substring(email.subject.indexOf('ParentId=>'));
           
          parentId = parentId.replace('ParentId=>', '');
          System.debug('Before Attachment:  attachmentId=' + attachmentId);
          
          objEmail.saveAttachmentsToParentFromInboundEmail(email, attachmentId, true);
          */
          
          
        }
        catch (Exception ex) {
        	
        }
        return result;
    }
}