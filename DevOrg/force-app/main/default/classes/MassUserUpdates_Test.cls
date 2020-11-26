/**
* @Author    : VW
* @Purpose   : Test Class for MassUserUpdatesPageController
*/
@isTest(SeeAllData=True)
public class MassUserUpdates_Test {   
        
    public static testmethod void massUserUpdatesPageControllerTest(){          
        
        List<User> tempUsersList = MassUserUpdatesTestFactory.getUsersList(5,true);
        User tempUser;
        Wrapper wrapper;
        //Instantiate and construct the controller class.   
        MassUserUpdatesPageController controller = new MassUserUpdatesPageController();  
        
        if(tempUsersList != null){           
            tempUser = tempUsersList[0];           
            wrapper = new Wrapper(tempUser,true);           
            controller.selectedUserIdVsWrappersMap = new Map<Id,Wrapper>{ tempUser.id => wrapper };
        }
        
        // Start the actual tests
        Test.startTest();
        
        //Instantiate a page
        PageReference pageRef = Page.MassUserUpdatesPage;
        Test.setCurrentPage(pageRef);  
        
        CustomIterable tempICustIterable = controller.obj;
        
        System.assertNotEquals(tempICustIterable, null);
        // Asset the results 
        System.assertEquals(tempICustIterable.recordsFrom,1);
        System.assertEquals(tempICustIterable.recordsTo,10);
        System.assertEquals(tempICustIterable.currentPageNumber,1);
        System.assertEquals(tempICustIterable.totalPages,6);   
        
        Integer activeUserCount = 0;
        Integer deactiveUserCount = 0;
        List<Wrapper> userWrappersList = new List<Wrapper>();
        
        List<String> updatedUsersIds = new List<String>();
        for(User tempUser1 : tempUsersList){
            updatedUsersIds.add(tempUser1.id);
            userWrappersList.add(new Wrapper (tempUser1, true));
        }
        controller.userWrappersList = userWrappersList;
        
        List<User> updatedUsers = [SELECT Id, Name, IsActive FROM User WHERE Id IN : updatedUsersIds];
                
        for(User tempUser2 : updatedUsers){
            if( tempUser2.isActive == true)
                activeUserCount++;
        }                
        System.assertEquals(activeUserCount,5); 
        
        controller.deactivateUsers();
        
        updatedUsers = [SELECT Id, Name, IsActive FROM User WHERE Id IN : updatedUsersIds];        
        System.assertNotEquals(updatedUsers,null);
        System.assert(updatedUsers.size()==5); 
        
        for(User tempUser3 : updatedUsers){
            if( tempUser3.isActive == false)
                deactiveUserCount++;
        }                
        System.assertEquals(deactiveUserCount,5);
        
        controller.last();
        controller.previous();
        controller.next();
        controller.first();
        // to ensure that filtered queries are covered
        controller.userView = 'All Active Users';
        controller.processPageSizeChange(); 
        controller.userRole = '';
        controller.processPageSizeChange(); 
        controller.userRole = 'All';
        controller.userProfile = '';
        controller.processPageSizeChange(); 
        controller.userRole = '';
        controller.userProfile = '';
        controller.processPageSizeChange(); 
        
        controller.userProfile = 'All';
        controller.userView = 'All Inactive Users';
        controller.processPageSizeChange(); 
        controller.userRole = '';
        controller.processPageSizeChange();  
        controller.userRole = 'All';
        controller.userProfile = '';
        controller.processPageSizeChange();  
        controller.userRole = '';
        controller.userProfile = '';
        controller.processPageSizeChange(); 
        
        controller.activateUsers();                
        controller.processPageChange();
        controller.processPageSizeChange();  
        // Stop tests
        Test.stopTest();
    }
    
    public static testmethod void staticDataTest(){
        
        PageReference pageRef = Page.MassUserUpdatesPage;
        Test.setCurrentPage(pageRef);
        MassUserUpdatesPageController controller = new MassUserUpdatesPageController();   
        
        controller.getUsers();
        controller.getUsersProfile();
        controller.getUsersRole();
        controller.getPageSizeOptions();      
        
        System.assertNotEquals(controller, null);        
    }
    // Test method to test wrapper constructor
    public static testmethod void wrapperConstructorTest(){
        User tempUser = [SELECT id FROM User LIMIT 1];
        Wrapper wrapper = new Wrapper(tempUser);
        // assert the constructor result
        System.assertNotEquals(wrapper, null);
    }
    // Test method to test controller helper
    public static testmethod void controllerHelperTest(){
        List<User> tempUsersList = MassUserUpdatesTestFactory.getUsersList(5,true);
        MassUserUpdatesPageController controller = new MassUserUpdatesPageController();  
        
        Map<String, Integer> licenseNameVsCountMap = MassUserUpdatesControllerHelper.getRequiredLicensesInfo(tempUsersList, controller.profileIdVsLicIdMap, controller.licIdVsLicNameMap);       
        MassUserUpdatesControllerHelper.handleLicensesException(licenseNameVsCountMap);
        // asset the results 
        System.assertNotEquals(licenseNameVsCountMap, null);
        
    }    
    
}