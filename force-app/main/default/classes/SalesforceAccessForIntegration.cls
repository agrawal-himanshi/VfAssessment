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
    system.debug('hii getContacts');
		String userName = RestContext.request.params.get('UserName');
        String userId1 = RestContext.request.params.get('UserId');
        String fName = RestContext.request.params.get('FName');
        String lName = RestContext.request.params.get('LName');
		    system.debug('userName ==> ' + userName);
			system.debug('userId ==> ' + userId1);
            system.debug('fName ==> ' + fName);
            system.debug('lName ==> ' + lName);
	        
        List<Contact> existingContact = [SELECT Id FROM Contact WHERE FirstName = :fName AND LastName = :lName LIMIT 1];
		List<ContentDocumentLink> contacts = new List<ContentDocumentLink>();
        System.debug(existingContact);
        if (!existingContact.isEmpty()) {
            system.debug('if');
         	contacts = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType, ContentDocument.Title, ContentDocument.CreatedDate, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId = :existingContact[0].Id];
         	system.debug('contacts ==> '+contacts);
        	//return contacts;
    	}else {
            	system.debug('else');
            	Contact newContact = new Contact(
                	FirstName = fName,
                	LastName = lName
            	);
           		insert newContact;
            	System.debug('New contact created: ' + newContact);
            	//return new List<ContentDocumentLink>();
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
        system.debug('hii create contact');
		system.debug('fileName ==>' + fileName);
        system.debug('content ==> ' + content);
        system.debug('userId ==> ' + userId);
        system.debug('Lastname ==> ' + FName);
        system.debug('Lastname ==> ' + LName);
        
        List<Contact> existingContact = [SELECT Id FROM Contact WHERE FirstName = :FName AND LastName = :LName LIMIT 1];
        system.debug('existingContact ==> ' + existingContact);


	    ContentVersion cv = new ContentVersion();
    	cv.Title = fileName;
    	cv.VersionData = EncodingUtil.base64Decode(content);
    	cv.PathOnClient = fileName;
        system.debug('cv ==> ' + cv);
    	insert cv;
	
        Id con = [select contentDocumentId from contentVersion where Id = :cv.Id].contentDocumentId;
        system.debug('Id => ' + con);
        
        //[SELECT ContentDocumentId FROM ContentVersion WHERE Id = :existingContact[0].Id].ContentDocumentId;
        
	    ContentDocumentLink cdl = new ContentDocumentLink();
    	cdl.LinkedEntityId = existingContact[0].Id;
    	cdl.ContentDocumentId = con;
    	cdl.ShareType = 'I';
        system.debug('cdl ==> ' + cdl);
    	insert cdl;

        List<ContentDocumentLink> files = [SELECT Id, ContentDocument.Title, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId = :existingContact[0].Id];
        system.debug('files ==> ' + files);
        return files;
    }
    

}