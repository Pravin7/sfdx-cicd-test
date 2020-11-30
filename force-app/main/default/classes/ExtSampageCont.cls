public with sharing class ExtSampageCont {    
     public Merchandise__c item { get; set;} 
     public Id merchId { get; set;}
        public ExtSampageCont() {
            merchId = 'a009000000BfgUX';
            getitem();              
        }

        public void getitem() {
                try {
                       item = [SELECT id,name from Merchandise__c WHERE
                                        id = :merchId ];
                       System.debug('__________Merch :'+ item.name ); 
                }
                catch(DMLException e) {
                        System.debug('____error account:'  );                       
                }
        }
          
}