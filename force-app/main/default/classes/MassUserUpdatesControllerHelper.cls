/**
* @author    : VW
* @Purpose   : This class is a helper for  MassUserUpdatesController. Provides methods to send email, handles exceptions.
*/
public class MassUserUpdatesControllerHelper {
    /* 
    * This method form the info. about the licenses and their required quantity    
    * @param 1. list of users to be updated 2. profileIdVsLicIdMap 3. licIdVsLicNameMap
    * @return Map<String, Integer> - License Name against count of them required to perform the selected operation
    */
    public static Map<String, Integer> getRequiredLicensesInfo(List<User> updateUsersList, Map<String, String> profileIdVsLicIdMap, Map<String, String> licIdVsLicNameMap){  
        
        Map<String, Integer> profileIdVsCountMap = new Map<String, Integer>();
        Map<String, Integer> licenseNameVsCountMap = new Map<String, Integer>(); 
        List<String> updateUserIdsList = new List<String>();
        // prepare a list of user Ids
        for(User tempUesr : updateUsersList){
            updateUserIdsList.add(tempUesr.id);
        }
		// get profile and their count
        List<AggregateResult> profileCountList = [SELECT ProfileId, count(Id) noOfUsers FROM User Where Id IN :updateUserIdsList GROUP BY ProfileId]; 

        for(AggregateResult tempResult : profileCountList ){            
            profileIdVsCountMap.put(String.valueOf(tempResult.get('ProfileId')), Integer.valueOf(tempResult.get('noOfUsers')));
        }     
        // prepare licenseNameVsCountMap
        for(String profileId : profileIdVsCountMap.keySet()){    
            if(licenseNameVsCountMap.keySet().contains(licIdVsLicNameMap.get(profileIdVsLicIdMap.get(profileId)))){
                licenseNameVsCountMap.put( licIdVsLicNameMap.get(profileIdVsLicIdMap.get(profileId)) , licenseNameVsCountMap.get(licIdVsLicNameMap.get(profileIdVsLicIdMap.get(profileId))) + profileIdVsCountMap.get(profileId));
            }else
                licenseNameVsCountMap.put( licIdVsLicNameMap.get(profileIdVsLicIdMap.get(profileId)) , profileIdVsCountMap.get(profileId));
        }

        return licenseNameVsCountMap;
    }
    /* 
    * This method form the info. about the licenses and their required quantity    
    * @param 1. licenseNameVsCountMap
    * @return Boolean - if exception occurs while sending an email, return true else false
    */
    public static Boolean handleLicensesException(Map<String, Integer> licenseNameVsCountMap) {
        
        // form a template for the email that gets sent when Licenses error occurs during update operation
        String emailHTMLMessageStr = 
            'Hi ' + UserInfo.getFirstName() + 
            ',<br/><br/>Your Salesforce organization does not have sufficient licenses available to perform the user update action.' +
            ' <br/><br/>Below is the summary of the licenses that were required.' + 
            ' <br/><br/><table border="1"><tr><th>License</th><th>Quantity Required</th></tr>';
        
        for(String tempLicense : licenseNameVsCountMap.keySet()){             
            emailHTMLMessageStr  = emailHTMLMessageStr + '<tr><td>' + tempLicense + '</td><td align="center">' + licenseNameVsCountMap.get(tempLicense) + '</td></tr>';
        }
        
        emailHTMLMessageStr = emailHTMLMessageStr + 
            '</table><br/>Please make sure that you have required licenses or featured licenses.<br/>To see available licenses, Login to Salesforce org and then Navigate to : Setup | Administration Setup | Company Information | User Licenses' +
            '<br/><br/>Contact Salesforce to purchase additional licenses.<br/><br/>Regards';
        
        String currentUserEmail = UserInfo.getUserEmail();     
        String emailMessageSubject = Label.Email_Subject;  
        // call a method to actually send an email
        return sendEmailMessage(new String[]{currentUserEmail}, emailMessageSubject, emailHTMLMessageStr );
    }
    
    /* 
    * This method form the info. about the licenses and their required quantity    
    * @param 1. toAddresses 2. emailMessageSubject 3. emailMessageBody
    * @return Boolean - if exception occurs while sending an email, return true else false
    */    
    public static Boolean sendEmailMessage(String[] toAddresses, String emailMessageSubject, String emailMessageBody){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        
        mail.setToAddresses(toAddresses);    
        // set sender name value in "Email Sender Name" custom label
        mail.setSenderDisplayName(Label.Email_Sender_Name);        
        mail.setSubject(emailMessageSubject);        
        String emailHTMLBody = emailMessageBody;        
        mail.setHtmlBody(emailHTMLBody);
       
        try{ 
            // call messaging API to send an email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception exp){   
            // if exception occurs, return true to handle it
			return true;            
        }
        
        return false; 
    }    

}