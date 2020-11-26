/**
* @author    : VW
* @Purpose   : This is a controller class for MassUserUpdatesPage. Delegates pagination functions to CustomIterable class.
*              Contains logic for filtering out user records as per selection.
*/

public with sharing class MassUserUpdatesPageController {
    // Controller Properties
    public String tocall {get; set;}
    public String userView {get; set;}
    public String userRole {get; set;}
    public String userProfile {get; set;}
    
    public Integer selectedRecordsCount {get; set;}
    public String resultMessage {get; set;}
    public String selectedFilterChar {get; set;}
    public CustomIterable obj {get; set;}
    public List<Wrapper> userWrappersList {get; set;}
    // Static vars
    public static String pageSize {get; set;}
    public static Boolean selectAll {get; set;}
    // List variables to hold profiles and roles 
    public List<Profile> li_Profile;
    public List<UserRole> li_UserRoles; 
    // Map to hold selected user Ids against User Wrapper
    public Map<Id,Wrapper> selectedUserIdVsWrappersMap {get; set;}   
    // Map to hold User License Ids against License name
    public Map<String, String> licIdVsLicNameMap = new Map<String, String>();
    // Map to hold User Profile Ids against License Ids
    public Map<String, String> profileIdVsLicIdMap = new Map<String, String>();

    // At first set page size to 10 
    static{    
        pageSize = '10';
    }
    
    // Constuctor. 
    public MassUserUpdatesPageController () {      
        // invoke initialization method to prepare data required
        init();   
        selectedUserIdVsWrappersMap = new Map<Id,Wrapper> ();
        
        // create a iterable object to perform navigation
        obj = new CustomIterable(getFilteredUsers(), Integer.valueOf(pageSize));        
        next();    
    }
    
    /* 
    * This method queries DB to get User Roles' and Profiles' names. Prepares data structures for various operations    
    * @param
    * @return
    */
    public void init(){
        List<UserLicense> userLicsList;
        userView = userRole = userProfile = Label.All;
        
        li_Profile= [SELECT Id, Name, Description, UserLicenseId, UserType 
                     FROM Profile 
                     WHERE Name != '' Order By Name];  
        
        li_UserRoles = [SELECT Id, Name FROM UserRole WHERE Name != '' Order By Name];        
        userLicsList = [SELECT Id,Name FROM UserLicense WHERE Name != ''];
        
        for(UserLicense tempLic : userLicsList) {
            licIdVsLicNameMap.put(tempLic.id, tempLic.Name);
        }
        
        for(Profile tempProfile : li_Profile) {
            profileIdVsLicIdMap.put(tempProfile.id, tempProfile.UserLicenseId);
        }
    } 
    
    /* 
    * This method acutally updates the selected users   
    * @param flag - to indicate which operation to be performed(Activation/ Deactivation)
    * @return 
    */
    public void updateIsActive(Boolean flag) {
        List<User> updateUsersList = new List<User>();        
        Integer activeSelectedUsers = 0;
        Integer inactiveSelectedUsers = 0;
        // when user does not change page manually, call pagechange to method to ensure that the selected users are processed  
        processPageChange ();
        // handle the flow when user does not select any record for processing
        if(selectedUserIdVsWrappersMap.values().size() <= 0){
            resultMessage = Label.Did_not_select;  
            selectedUserIdVsWrappersMap.clear();
            return;
        }
        // get the count of active and deactive users from the selected users
        for(Wrapper tempWrapper : selectedUserIdVsWrappersMap.values()){
            if(tempWrapper.userObj.isActive == true)
                activeSelectedUsers++;                 
            else
                inactiveSelectedUsers++;
            
            tempWrapper.userobj.isActive = flag;
            // prepare users list for updates
            updateUsersList.add(tempWrapper.userobj);
            tempWrapper.selected = false;
        }
        // form appropriate feedback message for users
        resultMessage = Label.Result_Message + selectedUserIdVsWrappersMap.values().size() +'.' ;        
        
        if( flag == true )        
            resultMessage = resultMessage + Label.Total_Activated + inactiveSelectedUsers +'.' + Label.Note;                 
        else
            resultMessage = resultMessage + Label.Total_Deactivated + activeSelectedUsers +'.' + Label.Note;     
        
        try{    
            //do actual update
            update updateUsersList; 
            
        } catch (Exception exp) {
            // handle if some exception has occurred
            String exceptionMessage = exp.getMessage();
            // in case of activation operation, if required licenses are not available, display appropriate message to user
            if(exceptionMessage.contains(Label.LICENSE_LIMIT_EXCEEDED)){  
                // call helper methods to get the license information required to do the selected operation
                Map<String, Integer> licenseNameVsCountMap = MassUserUpdatesControllerHelper.getRequiredLicensesInfo(updateUsersList, profileIdVsLicIdMap, licIdVsLicNameMap);
                Boolean isException = MassUserUpdatesControllerHelper.handleLicensesException(licenseNameVsCountMap);     
                if(!isException)
                    resultMessage = Label.License_Error  + ' $#$' + Userinfo.getUserEmail() ;       
                else
                    resultMessage = Label.General_Exception;
            }else{
                resultMessage = Label.General_Exception;
            }                            
        }        
        // deselect the select all checkbox
        selectAll = false;
        // refresh the map after each operation
        selectedUserIdVsWrappersMap.clear();
    }
    
   /* 
    * This method resets password for selected users   
    * @return 
    */
    public void resetUserPassword() {
        Boolean flag = true; // to activate users.
        Integer inactiveSelectedUsers = 0;
        List <User> listOfResetPasswordUsers = new list <User>();
        Integer counter = 0;
        User user = New User();
        Integer srCount = 0 ;
        Map<String, String> userNameErrorMsgMap = new Map<String, String>();
        
        processPageChange();
        if(selectedUserIdVsWrappersMap.values().size() <= 0){
            resultMessage = Label.Did_not_select;  
            selectedUserIdVsWrappersMap.clear();
            return;
        }
        // count for selected users       
        for(Wrapper tempWrapper : selectedUserIdVsWrappersMap.values()){
            counter++;
            if(tempWrapper.userObj.isActive == false) {
                inactiveSelectedUsers++;                                    
                // activate user
                tempWrapper.userobj.isActive = flag;                        
                listOfResetPasswordUsers.add(tempWrapper.userobj);
                tempWrapper.selected = false;
            }            
        }
        resultMessage = Label.Result_Message + counter + '.' + Label.Total_Activated + inactiveSelectedUsers +'.' + Label.Reset_Password_Note + Label.Note;
        try {        
        	List<Database.SaveResult> saveResults = Database.update(listOfResetPasswordUsers);
	        for (Database.SaveResult sr : saveResults) {
	             if (sr.isSuccess()) {                
	                System.ResetPasswordResult rpr = System.resetPassword(sr.getId(),true);
	                System.debug('__________Successfully reset password for user: ' + sr.getId() + '__pass:' + rpr.getPassword());
	             }
	             else {
	             	// Need to test exception condition
	            	user = selectedUserIdVsWrappersMap.get(sr.getId()).userobj;
					userNameErrorMsgMap.put(user.name,sr.getErrors()[srCount].getMessage());
					System.debug('__________Exception occured for user: '+ user.name +'____' + userNameErrorMsgMap.get(user.name));
					// create email template and method to send exception                   
					srCount++;	   // to iterate sr array
	             }                   	
        	}
        }
        catch (Exception exp) {
		        System.debug('__________result msg: ' + resultMessage);
	            // handle if some exception has occurred
	            String exceptionMessage = exp.getMessage();
	            // in case of activation operation, if required licenses are not available, display appropriate message to user
	            if(exceptionMessage.contains(Label.LICENSE_LIMIT_EXCEEDED)){  
	                // call helper methods to get the license information required to do the selected operation
	                Map<String, Integer> licenseNameVsCountMap = MassUserUpdatesControllerHelper.getRequiredLicensesInfo(listOfResetPasswordUsers, profileIdVsLicIdMap, licIdVsLicNameMap);
	                Boolean isException = MassUserUpdatesControllerHelper.handleLicensesException(licenseNameVsCountMap);     
	                if(!isException)
	                    resultMessage = Label.License_Error  + ' $#$' + Userinfo.getUserEmail() ;       
	                else
	                    resultMessage = Label.General_Exception;
	            } else {
	                resultMessage = Label.General_Exception;
	            } 	        
	        }
          
        
  /*      Integer ListSize = sr.getErrors().size();
             if (ListSize > 0) {
             	for ( Integer  i = 0; i < ListSize; i++) {
           			sr.getErrors()[i].getStatusCode();
             	}
             } 			*/         
                 
        selectAll = false;
        selectedUserIdVsWrappersMap.clear();            
    }
    
    /* 
    * This method gets called when user clicks in Activate button   
    * @param
    * @return 
    */
    public PageReference activateUsers() {
        updateIsActive(true);        
        return null;
    } 
    /* 
    * This method gets called when user clicks in Deactivate button   
    * @param
    * @return 
    */
    public PageReference deactivateUsers() {
        updateIsActive(false);
        return null;
    }    
    /* 
    * This method ensures that appropriate records are shown when user changes page size or navigates to diff page of the records
    * Releads the iterable object as per the selections of filters
    * @param
    * @return 
    */
    public void processPageSizeChange (){
        // query DB to get the records as per filter selection
        getFilteredUsers ();
        obj = new CustomIterable(getFilteredUsers(), Integer.valueOf(pageSize));         
        selectAll = false;
        userWrappersList = obj.next();
    }    
    /* 
    * This method used for persisting the checkboxes on the selected records across pages
    * form "selectedUserIdVsWrappersMap" which is later used for getting the selected records across pages and do some operations on them
    * @param
    * @return 
    */
    public void processPageChange () { 
        for( Wrapper tempWrapper : userWrappersList ){        
            if(tempWrapper.selected){
                selectedUserIdVsWrappersMap.put(tempWrapper.userobj.id, tempWrapper);
            }else{
                selectedUserIdVsWrappersMap.remove(tempWrapper.userobj.id);
            }
        }
        selectAll = false;         
    }
        
    /* 
    * This method actually fetches the records as per filters' selection
    * @param
    * @return List<User> - as per filters applied
    */
    private List<User> getFilteredUsers () {
        List<User> filteredUsers;      
        Boolean status = true;
        // determine which status has user selected under User Status  filter
        if(userView == Label.All_Active_Users){
            status = true;                 
        } else if(userView == Label.All_Inactive_Users){
            status = false;                
        } else {    
            status = null;  
        }       
        // accordingly apply where conditions in the query
        if(status == null) {
            if(userRole == Label.All && userProfile == Label.All){
                filteredUsers = [SELECT Id, Name, UserRoleId, ProfileId, IsActive, Profile.Name, UserRole.Name, Email, Alias, Username FROM User 
                                 Where Id != :Userinfo.getUserId() 
                                 Order By Name];               
             
            } else if(userProfile == Label.All) { 
                filteredUsers = [SELECT Id, Name, UserRoleId, ProfileId, IsActive, Profile.Name, UserRole.Name, Email, Alias, Username FROM User 
                                 Where Id != :Userinfo.getUserId() and UserRoleId = :userRole
                                 Order By Name];
               
            } else if(userRole == Label.All) {                    
                filteredUsers = [SELECT Id, Name, UserRoleId, ProfileId, IsActive, Profile.Name, UserRole.Name, Email, Alias, Username FROM User 
                                 Where Id != :Userinfo.getUserId() and ProfileId = :userProfile
                                 Order By Name];
                
            } else {     
                filteredUsers = [SELECT Id, Name, UserRoleId, ProfileId, IsActive, Profile.Name, UserRole.Name, Email, Alias, Username FROM User 
                                 Where Id != :Userinfo.getUserId() and ProfileId = :userProfile and UserRoleId = :userRole
                                 Order By Name];
            }   

        } else if(userRole == Label.All && userProfile == Label.All) {
            filteredUsers = [SELECT Id, Name, UserRoleId, ProfileId, IsActive, Profile.Name, UserRole.Name, Email, Alias, Username FROM User 
                             Where Id != :Userinfo.getUserId() and IsActive = :status
                             Order By Name];            

        } else if(userProfile == Label.All) {
            filteredUsers = [SELECT Id, Name, UserRoleId, ProfileId, IsActive, Profile.Name, UserRole.Name, Email, Alias, Username FROM User 
                             Where Id != :Userinfo.getUserId() and UserRoleId = :userRole and IsActive = :status
                             Order By Name];            

        } else if(userRole == Label.All) {
            filteredUsers = [SELECT Id, Name, UserRoleId, ProfileId, IsActive, Profile.Name, UserRole.Name, Email, Alias, Username FROM User 
                             Where Id != :Userinfo.getUserId() and ProfileId = :userProfile and IsActive = :status
                             Order By Name];
        } else {
            filteredUsers = [SELECT Id, Name, UserRoleId, ProfileId, IsActive, Profile.Name, UserRole.Name, Email, Alias, Username FROM User 
                             Where Id != :Userinfo.getUserId() and ProfileId = :userProfile and UserRoleId = :userRole and IsActive = :status
                             Order By Name];            
        }
        
        return filteredUsers;
        
    }
    
    /*
    * Returns the list of user roles
    */
    public List<SelectOption> getUsersRole() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Label.All,Label.Select_User_Role));

        for(UserRole tempUserRole : li_UserRoles) {
            options.add(new SelectOption(tempUserRole.id, tempUserRole.name));
        }
        return options;
    }

    /*
    * Returns the list of page size options
    */
    public List<SelectOption> getPageSizeOptions() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('10','10'));
        options.add(new SelectOption('20','20'));
        options.add(new SelectOption('50','50'));
        options.add(new SelectOption('100','100'));                
        options.add(new SelectOption('200','200'));        

        return options;
    }
    
    /*
    * Returns the list of user profiles 
    */
    public List<SelectOption> getUsersProfile() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Label.All, Label.Select_User_Profile));

        for(Profile tempUserProfile : li_Profile){
            options.add(new SelectOption(tempUserProfile.id, tempUserProfile.name));
        }
        return options;
    }

    /*
    * Returns the list of views
    */
    public List<SelectOption> getUsers() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Label.All,Label.All_Users));
        options.add(new SelectOption(Label.All_Active_Users,Label.All_Active_Users));
        options.add(new SelectOption(Label.All_Inactive_Users,Label.All_Inactive_Users));

        return options;
    }
    
    // All Pagination Related Methods Goes Below        
    public Boolean hasNext {
        get {
            return obj.hasNext();
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            return obj.hasPrevious();
        }
        set;
    }
    // Every method from here calls corresponding iterable method along ensuring page change
    public void next() {
        if(userWrappersList != null)
            processPageChange();
        userWrappersList = obj.next();
    }

    public void previous() {
        if(userWrappersList != null)
            processPageChange();
        userWrappersList = obj.previous();
    }
    // go to first page by invoking previous till iterable has previous records
    public void first() {        
        while(obj.hasPrevious()){
            if(userWrappersList != null)
                processPageChange();
            userWrappersList = obj.previous();
        }        
        selectAll = false;
    }
    // go to last page by invoking next till iterable has next records
    public void last() {        
        while(obj.hasNext()){
            if(userWrappersList != null)
                processPageChange();
            userWrappersList = obj.next();
        }
        selectAll = false;
    }
}