public with sharing class ExtcrudController1 {
     
    public List<Account> accountList {get; set;}
    public Account account { get; set;}
    private ID accountId {get; set;}
    public String mydata {get; set;}
    public String myrecordid {get; set;}
    public String accountJson { get; set; } 

        public ExtcrudController1() {
               
                    fetchaccountList(); 
                    makeJson1();   
        }
        
        public void fetchaccountList() {
                try {
                        accountList = [SELECT id,name from Account];
                }
                catch(DMLException e) {
                        System.debug('____error accountlist:'  );
                }
        }
        
        public void fetchAccount() {
                try {
                        account = [SELECT id,name from Account WHERE
                                        id = : accountId];
                }
                catch(DMLException e) {
                        System.debug('____error account:'  );                       
                }
        }
        
        public PageReference mysave() {
        update account;
        PageReference secondPage = Page.dynamic;
        secondPage.setRedirect(true);
        secondPage.getParameters().put('id',accountId);
        return secondPage; 
    }
    
        public void makeJson1() {        
        string jsonRecordsString = '';       
            for ( Account act : accountList ) {
                    jsonRecordsString += '{';  
                    jsonRecordsString += '"id":' + '"'+act.id+'",';  
                    jsonRecordsString += '"name":' + '"'+act.name+'",';  
                    jsonRecordsString += '},';
              } 
            string jsonString = '[' + jsonRecordsString + ']';
            jsonString = jsonString.replaceAll(',]',']');  
            this.accountJson = jsonString;
            System.debug('____account_______JSON_______:' + jsonString );               
        }
        
       public PageReference updateAccount() {
         // mydata = ApexPages.currentPage().getParameters().get('record');  
         //  System.debug('____IN_______UPDATE_______ACCOUNT' +mydata);
            
         System.debug('____IN_______UPDATE_______ACCOUNT' +myrecordid);          
         string[] splitted = myrecordid.split(',');
         System.debug('____IN_______UPDATE_______ACCOUNT' + splitted[0]);
        
              Account account = getAccount(splitted[0]);
              account.name = splitted[1];    
              update account;
 
           return null;           
        }
        
        public void parse() {
            Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(mydata);
            List<Object> items = (List<Object>)root.get('items');
            for (Object item : items) {
                Map<String, Object> i = (Map<String, Object>)item;
                System.debug(i.get('id'));
            }
        }
        
        public Account getAccount(String id) {
            for( Account acc : accountList) {
                if(id.equals((String)acc.id)){
                    System.debug('____account found______________' +acc.name);
                    return acc;
                 } 
            }
               System.debug('____no account found______________' +mydata);
               return null;
        } 
        
        @RemoteAction
        public static Account remoteUpdateAccount(String bundle) {
              if (bundle == null) return null;                       
              string[] splitted = bundle.split(',');
              System.debug('____IN_______UPDATE_______ACCOUNT' + splitted[0]);
              
              List<Account> accountList = [SELECT id,name from Account];  
              Account account = new Account();
              for( Account acc : accountList) {
                if(splitted[0].equals((String)acc.id)){
                    System.debug('____account found______________' +acc.name);
                    account = acc;
                 } 
              }
              account.name = splitted[1];    
              update account;
              return account;
        }

}