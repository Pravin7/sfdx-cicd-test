global with sharing class SmartFilterExampleController extends SmartFilter.PageControllerBase {
     public List<Account> accountList {get;set;}
     public List<Contact> contactList {get;set;}    
     public List<Opportunity> opportunityList {get;set;}    
     public List<String> testString {get; set;}

    
     public SmartFilterExampleController(){
   		 accountList = new List<Account>();
         contactList = new List<Contact>();
         opportunityList = new List<Opportunity>();
         testString = new List<String>();
         testString.add('AccountNumber');
         
     }

	 public SmartFilter.SmartFiltersComponentController myComponentController1 {set; 
            get{ //System.debug('Calling SmartFiltersComponentController..... ');
                    //get the map, then the component controller using the	appropriate key
                if(getComponentControllerMap()!=null){
                    SmartFilter.SmartFiltersComponentController mcc;
                    mcc = (SmartFilter.SmartFiltersComponentController)getComponentControllerMap().get('Account');
                    if(mcc!= null)
                    return mcc;
                }
                return new SmartFilter.SmartFiltersComponentController();
             }
    }

	 public SmartFilter.SmartFiltersComponentController myComponentController2 {set; 
            get{ //System.debug('Calling SmartFiltersComponentController..... ');
                    //get the map, then the component controller using the	appropriate key
                if(getComponentControllerMap()!=null){
                    SmartFilter.SmartFiltersComponentController mcc;
                    mcc = (SmartFilter.SmartFiltersComponentController)getComponentControllerMap().get('Contact');
                    if(mcc!= null)
                    return mcc;
                }
                return new SmartFilter.SmartFiltersComponentController();
             }
    } 
    
	 public SmartFilter.SmartFiltersComponentController myComponentController3 {set; 
            get { 
                if(getComponentControllerMap()!=null){
                    SmartFilter.SmartFiltersComponentController mcc;
                    mcc = (SmartFilter.SmartFiltersComponentController)getComponentControllerMap().get('Opportunity');
                    if(mcc!= null)
                    return mcc;
                }
                return new SmartFilter.SmartFiltersComponentController();
             }
    }    
 	public void fetchAccounts() {
 		String predicates = myComponentController1.fetchQuery();
		System.debug('Fetch Test Query Result.............'+predicates);
		if(predicates!=null && predicates!= ''){
 			system.debug('inside if condition...........');
 			accountList = Database.query('select Id, name from account where '+predicates);
 		} else {
 			system.debug('inside else condition...........'); 
            accountList = [select Id,name from account limit 100];
 		}
 	}
    
 	public void fetchContacts() {
 		String predicates = myComponentController2.fetchQuery();
		System.debug('Fetch Test Query Result.............'+predicates);
		if(predicates!=null && predicates!= ''){
 			system.debug('inside if condition...........');
 			contactList = Database.query('select Id, name from Contact where '+predicates);
 		} else {
 			system.debug('inside else condition...........'); 
            contactList = [select Id,name from Contact limit 100];
 		}
 	}

 	public void fetchOpportunities() {
 		String predicates = myComponentController1.fetchQuery();
		System.debug('Fetch Test Query Result.............'+predicates);
		if(predicates!=null && predicates!= ''){
 			system.debug('inside if condition...........');
 			opportunityList = Database.query('select Id, name from Opportunity where '+predicates);
 		} else {
 			system.debug('inside else condition...........'); 
            opportunityList = [select Id,name from Opportunity limit 100];
 		}
 	}    
}