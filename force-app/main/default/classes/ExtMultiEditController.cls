//saved previous version as extMultiEditController.txt


public with sharing class ExtMultiEditController {
     
    public List<Account> accountList {get; set;}
    public Account account { get; set;}
    private ID accountId {get; set;}
    public String mydata {get; set;}
    public String myrecordid {get; set;}
    public String accountJson { get; set; }
    public String allAccountJson { get; set; }  
    public String[] myDataString { get; set; }
    public Integer start1 { get; set; }
    public Integer pageSize { get; set; }

        public ExtMultiEditController() {              
            //  getting start and limit from post
                        
                  if (ApexPages.currentPage().getParameters().get('record') != null) {
                        mydata = ApexPages.currentPage().getParameters().get('record'); 
                        string[] splitted = myrecordid.split(',');
                         System.debug('____IN_______UPDATE_______ACCOUNT' + splitted[0]);        
                //      Account account = getAccount(splitted[0]);
                      account.name = mydata;    
                      update account;                        
                    }
                    else {
                        start1 = 0;
                        pageSize = 2;
                     }            
                    myDataString = new String[]{};
                    fetchaccountList();             
                   makeJson1(); 
             //       makeMyDataString();  
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
                    jsonRecordsString += '"ischecked":' + '"0"';   
                    jsonRecordsString += '},';
              } 
     //       string jsonString = '[' + jsonRecordsString + ']';
            string jsonString = '{"total":"'+accountList.size()+'", "results":[' + jsonRecordsString + ']}';          
            jsonString = jsonString.replaceAll(',]',']');  
            this.accountJson = jsonString;
            System.debug('____account_______JSON_______:' + jsonString );               
        }
        
        public void makeJsonForPage() {        
                string jsonRecordsString = '';
                Integer i = 1;
                Integer j = 0;
                Account[] opps = new Account[]{};                    
                    for ( Account act : accountList ) {
                                if (j >= start1) {
                                        if (i <= pageSize) {
                            jsonRecordsString += '{';  
                            jsonRecordsString += '"id":' + '"'+act.id+'",';  
                            jsonRecordsString += '"name":' + '"'+act.name+'",'; 
                            jsonRecordsString += '"ischecked":' + '"0"';   
                            jsonRecordsString += '},';
                            i++;    
                            }                                
                      }
                      opps.add(act);
                      j++; 
                    }  
             //       string jsonString = '[' + jsonRecordsString + ']';
                    string jsonString = '{"total":"'+opps.size()+'", "results":[' + jsonRecordsString + ']}';          
                    jsonString = jsonString.replaceAll(',]',']');  
                    this.accountJson = jsonString;
                    System.debug('____account_______JSON_______:' + jsonString );               
        }
        
        
         public void makeMyDataString() { 
          //  String[] myDataString1 = new String[]{};
            string jsonRecordsString = '';
            Integer i = 0;       
                for ( Account act : accountList ) {
                    string recordsString = '';
                        recordsString += '[';  
                        recordsString += '"'+act.id+'",';  
                        recordsString += '"'+act.name+'",'; 
                        recordsString += '"0"';   
                        recordsString += ']';                                                           
                    myDataString.add(recordsString);
                    System.debug('____account_______JSON_______:' + myDataString[i]);               
                    i++;
                  } 
            }
            
       public void makeJsonForAllAccounts() { 
          //  String[] myDataString1 = new String[]{};
            Integer i = 0;       
                for ( Account act : accountList ) {
                    string recordsString = '';
                        recordsString += '[';  
                        recordsString += '"'+act.id+'",';  
                        recordsString += '"'+act.name+'",'; 
                        recordsString += ']';                                                           
                    myDataString.add(recordsString);
                    System.debug('____account_______JSON_______:' + myDataString[i]);               
                    i++;
                  } 
            }      
            
        
       public PageReference updateAccount() {
          mydata = ApexPages.currentPage().getParameters().get('record');  
        //  System.debug('____IN_______UPDATE_______ACCOUNT' +mydata);
          
         System.debug('____IN_______UPDATE_______ACCOUNT' +myrecordid);          
          string[] splitted = myrecordid.split(',');
         System.debug('____IN_______UPDATE_______ACCOUNT' + splitted[0]);
        
              Account account = getAccount(splitted[0]);
              account.name = splitted[1];    
              update account;
              
           return null;           
        }
        
       public PageReference updateAccountNew() {
              mydata = ApexPages.currentPage().getParameters().get('record');  
            //  System.debug('____IN_______UPDATE_______ACCOUNT' +mydata);
          
             System.debug('____IN_______UPDATE_______ACCOUNT' +myrecordid);          
             string[] splitted = mydata.split(':');
             
             System.debug('____IN_______UPDATE_______ACCOUNT' + splitted[1]);
        
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
                
}