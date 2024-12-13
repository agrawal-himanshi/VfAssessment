@RestResource(urlMapping='/Contact/*')
global class SalesforceAccessForIntegration {
 	 /* 
    Name: getContacts,
    Param:null
    Return Type:List<ContentDocumentLink>
    description:Get the files form org.
    */   
    @HttpGet
	global static List<ContentDocumentLink> getContacts() {
		String userName = RestContext.request.params.get('UserName');
        String userId1 = RestContext.request.params.get('UserId');
        String fName = RestContext.request.params.get('FName');
        String lName = RestContext.request.params.get('LName');
	        
        List<Contact> existingContact = [SELECT Id FROM Contact WHERE FirstName = :fName AND LastName = :lName LIMIT 1];
		List<ContentDocumentLink> contacts = new List<ContentDocumentLink>();
        if (!existingContact.isEmpty()) {
         	contacts = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType, ContentDocument.Title, ContentDocument.CreatedDate, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId = :existingContact[0].Id];
    	}else {
            	Contact newContact = new Contact(
                	FirstName = fName,
                	LastName = lName
            	);
           		insert newContact;
        }
        return contacts;
	}

    /* 
    Name: CreateContact,
    Param:fileName,content,userId,FName,LName
    Return Type:List<ContentDocumentLink>
    description:upload file to Org.
    */ 
    @HttpPost
    global static List<ContentDocumentLink> CreateContact(String fileName , String content , Id userId ,String FName, String LName){
        List<Contact> existingContact = [SELECT Id FROM Contact WHERE FirstName = :FName AND LastName = :LName LIMIT 1];
	    ContentVersion cv = new ContentVersion();
    	cv.Title = fileName;
    	cv.VersionData = EncodingUtil.base64Decode(content);
    	cv.PathOnClient = fileName;
    	insert cv;
	
        Id con = [select contentDocumentId from contentVersion where Id = :cv.Id].contentDocumentId;
	    ContentDocumentLink cdl = new ContentDocumentLink();
    	cdl.LinkedEntityId = existingContact[0].Id;
    	cdl.ContentDocumentId = con;
    	cdl.ShareType = 'I';
    	insert cdl;

        List<ContentDocumentLink> files = [SELECT Id, ContentDocument.Title, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId = :existingContact[0].Id];
        return files;
    }
    

}