global with sharing class UserInquiryEmailHander implements Messaging.InboundEmailHandler {
    
    String[] Bucket;
    Map<String,String> fieldMap = new Map<String,String>();
    String theBody;  
  
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
 
    String firstName = '';
    String LastName = '';
    UserInquiry__c userInquiry = new UserInquiry__c();
    List<String> fieldList = new List<String>();    
    String value;
    
    try{                       
         if (email.plainTextBody != null){
            theBody = email.plainTextBody;                
         } else {
            theBody = 'NO_DATA';
         }
    }
    catch(Exception e) {
            System.debug('====> inquiry failed________'+e.getMessage());
    }
 
    System.debug('====> Created inquiry________'+userInquiry.Id);
    System.debug('====> inquiry body________ '+theBody);
    theBody = theBody.substring(theBody.indexOf('[START]')+7,theBody.indexOf('[END]'));
  //  fieldList = theBody.split('(?<![^\\\\]\\\\):');
    fieldMap.put('firstname','');
    fieldMap.put('lastname','');
    fieldMap.put('phone','');
    
    populateFieldMap();
    
    for(String field : fieldList){
        if (field.split('=',0).size() == 2){
             fieldMap.put(field.split('=',0)[0],field.split('=',0)[1]);             
           }
    }       
    
    userInquiry.First_Name__c = removeSeprator(fieldMap.get('firstname'));
    userInquiry.Last_Name__c =  removeSeprator(fieldMap.get('lastname'));
//   userInquiry.email__c = envelope.fromAddress;
    userInquiry.phone__c = removeSeprator(fieldMap.get('phone'));
    insert userInquiry;
    
    if (email.textAttachments != null && email.textAttachments.size() > 0) {
      for (integer i = 0 ; i < email.textAttachments.size() ; i++) {
        Attachment attachment = new Attachment();
        // attach to the newly created contact record
        attachment.ParentId = userInquiry.Id;
        attachment.Name = email.textAttachments[i].filename;
        attachment.Body =  blob.valueOf(email.textAttachments[i].body);
        insert attachment;
      }
    }
    
    if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
      for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
        Attachment attachment = new Attachment();
        // attach to the newly created contact record
        attachment.ParentId = userInquiry.Id;
        attachment.Name = email.binaryAttachments[i].filename;
        attachment.Body =  email.binaryAttachments[i].body;
        insert attachment;
      }
    }
    
        System.debug('====> Done inserted attachment ======>'+userInquiry.Id);
    
    return result;
 
  }
  
  void populateFieldMap() {  	
      Set<String> keys = fieldMap.keySet();
      Integer j = 0;
      Integer counter = 0;
      for(String firstKey : keys) {
      		counter++;
      		System.debug('OUTERiteration_____'+counter+'___firstKey__'+firstKey);
	      	if (theBody.containsIgnoreCase(firstKey)) {
			String[] restString = theBody.split(firstKey);
			String value = '';			
			if(restString.size()==2){				
				j = 1;
			}
			else {
				j = 0;
			}
			System.debug('restString before for loop___'+restString[j]);
				for(String secondKey : keys) {
			        System.debug('Inneriteration_____+1');
			        if(secondKey.equals(firstKey)){continue;}					
					if(restString[j].containsIgnoreCase(secondKey)) {
						restString[j] = restString[j].substringBefore(secondKey);						
					    System.debug('restString in for loop___'+value);
					}
					value = restString[j];
				}
	         fieldMap.put(firstKey,value);
	      }
      }   
      
     System.debug('firstname___'+fieldMap.get('firstname'));
     System.debug('lastname___'+fieldMap.get('lastname'));
     System.debug('phone___'+fieldMap.get('phone'));     
  }
  
  String removeSeprator(String myfield) {
  	String temp;
  	if(myfield.contains('=')) {
  		myfield = myfield.split('=')[1];
  	}
  	return myfield;
  }
}