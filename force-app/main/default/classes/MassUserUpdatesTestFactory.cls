/**
* @Author    : VW
* @Purpose   : Test Factory Class for MassUserUpdates. Used for setting up the data for testing.
*/
@isTest(SeeAllData=True)
public class MassUserUpdatesTestFactory {
    
    public static List<Profile> profilesList;
    public static String TEST_USER_FIRSTNAME        = 'Test_FN';
    public static String TEST_USER_LASTNAME         = 'Test_LN';
    public static String TEST_USER_EMAIL            = 'testuser@email.com';
    public static String TEST_USER_USERNAME         = 'testuser@un.com';
    public static String TEST_USER_EMAILENCODINGKEY = 'UTF-8';
    public static String TEST_USER_LANGLOCALEKEY    = 'en_US';
    public static String TEST_USER_LOCALESIDKEY     = 'en_US';
    public static String TEST_USER_TIMEZONESIDKEY   = 'America/Los_Angeles'; 
    // controller
    public MassUserUpdatesTestFactory () {
        profilesList = [SELECT id, Name FROM Profile LIMIT 2];    
    }    
    // retruns a list of users
    public static List<User> getUsersList(Integer count, Boolean isActive){
        List<User> usersList = new List<User>();
        User tempUser;
        String profileId ;
        
        if(profilesList != null && profilesList.get(0) != null)
            profileId = profilesList.get(0).id;
        else            
            profileId = UserInfo.getProfileId();        
            
        for(Integer i = 0; i < count; i++){
            tempUser = createTestUser(TEST_USER_FIRSTNAME +'_' +i , TEST_USER_LASTNAME +'_' +i , TEST_USER_EMAIL+i, TEST_USER_USERNAME+i, profileId, isActive, i);
            usersList.add(tempUser);
        }           
        insert usersList;
        return usersList;
    }
    
    // Creates a Test User with a given Profile
    private static User createTestUser(String firstName,String lastName,String email,String userName,String profileId, Boolean isActive, Integer index) {
        return new User(
                        FirstName = firstName,
                        LastName = lastName,
                        Email = email,
                        Username = userName,
                        ProfileId = profileId,  
                        isActive =  isActive,
                        Alias = lastName.substring(0,5) + index ,
                        CommunityNickname = lastName.substring(0,5) + index,
                        TimeZoneSidKey = TEST_USER_TIMEZONESIDKEY,
                        LocaleSidKey = TEST_USER_LOCALESIDKEY,
                        EmailEncodingKey = TEST_USER_EMAILENCODINGKEY,
                        LanguageLocaleKey = TEST_USER_LANGLOCALEKEY
                    );
    }   
}