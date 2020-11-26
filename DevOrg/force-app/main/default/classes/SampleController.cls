public with sharing class SampleController {
        DateTime t1;
    transient DateTime t2;
    public List<Position__c> posList {get; set;}
    public Position__c pos { get; set;}
    private ID posId {get; set;} 

    public String getT1() {
        if (t1 == null) t1 = System.now();
        return '' + t1;
    }

    public String getT2() {
        if (t2 == null) t2 = System.now();
        return '' + t2;
        }
        
        public SampleController() {
                posId = ApexPages.currentPage().getParameters().get('id');
                if (posId != null)
                        fetchPos();
                        
        }
        
        public void fetchPosList() {
                try {
                        posList = [SELECT id,name,Skills_Required__c,Max_Pay__c,Min_Pay__c,Job_Description__c from Position__c];
                }
                catch(DMLException e) {
                        System.debug('____error poslist:'  );
                }
        }
        
        public void fetchPos() {
                try {
                        pos = [SELECT id,name,Skills_Required__c,Max_Pay__c,Min_Pay__c,Job_Description__c from Position__c WHERE
                                        id = : posId];
                }
                catch(DMLException e) {
                        System.debug('____error pos:'  );                       
                }
        }
        
        public PageReference mysave() {
        update pos;
        PageReference secondPage = Page.dynamic;
        secondPage.setRedirect(true);
        secondPage.getParameters().put('id',posId);
        return secondPage; 
    }
                
}