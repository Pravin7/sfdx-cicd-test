@isTest
public class CaseSWatchExtensionTestClass{    
	static testmethod void testStartClock() {
        PageReference stopWatchPage = Page.StopWatchForCase;
        Test.setCurrentPage(stopWatchPage);        
        Case a = new Case(Total_Time_In_Seconds__c = 0); 
        insert a;
        ApexPages.StandardController sc = new ApexPages.standardController(a);
        CaseSWatchExtension caseExtension = new CaseSWatchExtension(sc); 
		System.debug('__'+caseExtension.totalTimeInSeconds+'__'+a.Total_Time_In_Seconds__c);                
        System.assertEquals(caseExtension.totalTimeInSeconds, a.Total_Time_In_Seconds__c);
        
       /*
		time bundle format used here is,
		for string '54#0#0#true' sec, min, hour, and stopTimer value 
	   */
        caseExtension.timeBundle = '54#0#0#true';
        caseExtension.startClock();
		System.debug('__'+caseExtension.totalTimeInSeconds+'__'+a.Total_Time_In_Seconds__c);        
        caseExtension.stopClock();
        
        caseExtension.timeBundle = '54#1#1#false';
        caseExtension.startClock();
		System.debug('__'+caseExtension.totalTimeInSeconds+'__'+a.Total_Time_In_Seconds__c);        
        caseExtension.stopClock();
    }
}