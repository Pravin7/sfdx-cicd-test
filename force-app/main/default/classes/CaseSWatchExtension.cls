public class CaseSWatchExtension {

	    Private Case caseRec {get; set;}
	    Public Integer totalTime {get; set;}  
	    Public String timeBundle {get; set;} 
	    Public Integer secTime {get; set;}  
	    Public Integer minTime {get; set;}  
	    Public Integer hourTime {get; set;} 
	    Public Integer totalTimeInSeconds {get; set;}					// this is saved in database
	    Public Boolean stopTimer {get; set;} 
	    
	    /**
		* hours,minutes,seconds classification can be removed 
		* totalTimeInSeconds contains total seconds, which can be converted in hours, min, seconds
		**/
	        
	    public CaseSWatchExtension(ApexPages.StandardController stdController) {
	        this.caseRec= (Case)stdController.getRecord();      //  not fethcing custom fields
	        List<Case> caseList = [SELECT id, CaseNumber, caseHours__c, Total_Time_In_Seconds__c, caseMinutes__c,
	    							caseSeconds__c, Stop_Timer__c FROM Case WHERE id = : caseRec.id LIMIT 1];
	        if (caseList != null && (!caseList.isEmpty())) { 
	            caseRec = caseList[0];
	            stopTimer = caseRec.Stop_Timer__c;
	        	System.debug('#Total_Time_In_Seconds__c _' + caseRec.Total_Time_In_Seconds__c);
	            totalTimeInSeconds = Integer.valueOf(caseRec.Total_Time_In_Seconds__c);
	            if (totalTimeInSeconds == null) totalTimeInSeconds = 0;                
	            secondsToTime();
	        }
	    }
	    /*
			time bundle format used here is,
			for string '54#0#0#true' sec, min, hour, and stopTimer value 
		*/
	    public PageReference startClock() {  
	       return saveTime();              
	    }
	    
	    public PageReference stopClock() {
	        return saveTime();          
	        //set case time here
	        //save case
	    }
	    
	    public PageReference saveTime() {
			Integer tempTime;
	        System.debug('#TOTAL TIME _' + timeBundle);
	        if (timeBundle == NULL || String.isBlank(timeBundle)) { 
	            System.debug('#NULL_TIME_BUNDLE' + timeBundle);
	            return null;
	        } 
	        String[] splitTimeBundle = timeBundle.split('#');
	        Integer BundleSize = splitTimeBundle.size();                  
	        for(Integer i=0; i<BundleSize; i++) {
	            if (i == 0 && splitTimeBundle[i] != NULL) {					//seconds
                    if (splitTimeBundle[i] == 'undefined') {
                        secTime = 0;
                    } else {
                        try {
                            tempTime = integer.valueof(splitTimeBundle[i]);
                        }
                        catch (Exception e) {
                            System.debug('#EXCEPTION :' + e.getMessage());
                        }
                        if (tempTime != null) {
                            secTime = tempTime;
                        }
                    }
	            } else if (i == 1 && splitTimeBundle[i] != NULL) {                                             //minutes
                    if (splitTimeBundle[i] == 'undefined') {
                        minTime = 0;
                    } else {
                        try {
                            tempTime = integer.valueof(splitTimeBundle[i]);
                        }
                        catch (Exception e) {
                            System.debug('#EXCEPTION :' + e.getMessage());
                        }
                        if (tempTime != null) {
                            minTime = tempTime;                            
                        }
                    }
	            } else if (i == 2 && splitTimeBundle[i] != NULL) {                                             //hours
                    if (splitTimeBundle[i] == 'undefined') {
                        hourTime = 0;
                    } else {
                        try {
                            tempTime = integer.valueof(splitTimeBundle[i]);
                        }
                        catch (Exception e) {
                            System.debug('#EXCEPTION :' + e.getMessage());
                        }
                        if (tempTime != null) {
                            hourTime = tempTime;                            
                        }                    
                    }
	            } else if (i == 3 && splitTimeBundle[i] != NULL) {											// isStopped
                    if (splitTimeBundle[i] == 'undefined') {
                        stopTimer = false;
                    } else if(splitTimeBundle[i].equalsIgnoreCase('true') || splitTimeBundle[i].equalsIgnoreCase('false')) {
                        try {
                            stopTimer = Boolean.valueOf(splitTimeBundle[i]);
                            System.debug('#stopTimer set :' + splitTimeBundle[i]);
                        } catch (Exception e) {
                            System.debug('#EXCEPTION :' + e.getMessage());
                        }                        
                    }
	            }
	        }        
	        System.debug('##FINAL_TIME_' + secTime + '_' + minTime + '_' + hourTime + '_' + stopTimer );
	        setCaseTimeAndSave();
	        return null;     	    	
	    }
	    
	    private Boolean setCaseTimeAndSave() {        
	        caseRec.caseHours__c = hourTime; 
	        caseRec.caseMinutes__c = minTime;    
	        caseRec.caseSeconds__c = secTime; 
	        caseRec.Stop_Timer__c = stopTimer;
	        totalTimeInSeconds = timeToSeconds();
	     //   totalTimeInSeconds = totalTimeInSeconds + 1 ;					// to adjust the time 
	        caseRec.Total_Time_In_Seconds__c = totalTimeInSeconds;
	    	System.debug('##update Total_Time_In_Seconds__c _' + totalTimeInSeconds);
	        try {
	            update(caseRec);
	            System.debug('#UPDATED RECORD:' + caseRec.CaseNumber);
	        }
	        catch (Exception e) {
	            System.debug('#EXCEPTION :' + e.getMessage());
	        }
	        return true;
	    }
	    
	    private Integer timeToSeconds() {
	    	  return ((hourTime * 3600) + (minTime * 60) + secTime);          
	    } 
	    
	    private void secondsToTime() {
	        Integer hours = totalTimeInSeconds/3600; // number of hours	Integer minutes = second/60; // number of minutes
	        Integer restHour = math.mod(totalTimeInSeconds,3600);
	        Integer minutes = restHour/60; // number of minutes
	        Integer seconds = math.mod(totalTimeInSeconds,60); // number of seconds 
	        System.debug('###FINAL_TIME_' + hours + '_'  + minutes + '_' + seconds );                
	        hourTime = hours;
	        minTime = minutes;
	        secTime = seconds;
	        System.debug('###FINAL_TIME_' + secTime + '_' + minTime + '_' + hourTime  );         
	    }     
}