public with sharing class AttachmentClass {
	
	public void createAttachment(Id parentId, String fileName, Blob fileBody, String description) {
		System.debug('ATTACHMENT ParentId=' + parentId);
	  Attachment newAttachment = new Attachment(ParentId = parentId,
                                              Name = fileName, 
                                              Body = fileBody,
                                              Description = description);
    insert newAttachment;
	}
}