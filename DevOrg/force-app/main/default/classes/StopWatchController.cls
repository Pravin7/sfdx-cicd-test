public class StopWatchController{
    
    Public Sobject obj {get; set;}
    Public String sobjName {get; set;}
    Public Integer totalTime {get; set;}  
    Public String timeBundle {get; set;} 
    Public Integer secTime {get; set;}  
    Public Integer minTime {get; set;}  
    Public Integer hourTime {get; set;} 
    Public Boolean stopTimer {get; set;}
    Public Id recId {get; set;}
    Public StopWatchController ctl;
    
        
    public StopWatchController(ApexPages.StandardController stdController) {
        try {
            this.recId = ApexPages.currentPage().getParameters().get('id');
            if (recId != null) {            // id validations need to be checked
                this.sobjName = recId.getSObjectType().getDescribe().getName();
            }
            String objQuery = '[SELECT id, caseHours__c, caseMinutes__c, caseSeconds__c, Stop_Timer__c FROM '+ sobjName +' WHERE id = : recId.id LIMIT 1]';
            sObject objTemp = Database.query(objQuery);
            
            if (objTemp != null) {
                this.obj = objTemp;
                
                stopTimer = Boolean.valueOf( obj.get('Stop_Timer__c') );
                if (Integer.valueOf( obj.get('caseHours__c') ) == null) {
                    hourTime = 0;
                } else {
                    hourTime =  Integer.valueOf( obj.get('caseHours__c') );
                }                 
                if (Integer.valueOf( obj.get('caseMinutes__c') ) == null) {
                    minTime = 0;
                } else {
                    minTime = Integer.valueOf( obj.get('caseMinutes__c') );
                } 
                
                if (Integer.valueOf( obj.get('caseSeconds__c') ) == null) {
                    secTime = 0;
                } else {
                    secTime = Integer.valueOf( obj.get('caseSeconds__c') );
                }
                System.debug('##START_TIME_' + secTime + '_' + minTime + '_' + hourTime + '_' + stopTimer );
            }
        } catch(Exception e) {
            System.debug('#EXCEPTION :' + e.getMessage()); 
        }     
    }
 
    
    public PageReference startClock() { 
		return null; 
    }
    
    public PageReference stopClock() {
		return saveTime();
    }
    
    public PageReference saveTime() {
        //get bundle
        //save time in custom time field
        //on each page refresh get time from controller custom field sec, min , hr
        Integer tempTime;
        System.debug('#TOTAL TIME _' + timeBundle);
        if (timeBundle == NULL || String.isBlank(timeBundle)) { 
            System.debug('#NULL_TIME_BUNDLE' + timeBundle);
            return null;
        } 
        String[] splitTimeBundle = timeBundle.split('#');
        Integer BundleSize = splitTimeBundle.size();                  
        for(Integer i=0; i<BundleSize; i++) {
            if (i == 0) {
                if (splitTimeBundle[i] != NULL) {                            //seconds
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
                }
            } else if (i == 1) {                                             //minutes
                if (splitTimeBundle[i] != NULL) {
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
                }
            } else if (i == 2) {                                             //hours
                if (splitTimeBundle[i] != NULL) {
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
                }
            } else if (i == 3) {
                if (splitTimeBundle[i] != NULL) {
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
        }        
        System.debug('##FINAL_TIME_' + secTime + '_' + minTime + '_' + hourTime + '_' + stopTimer );       
        
        setCaseTimeAndSave();
        return null;   
   }  
    
    public Boolean setCaseTimeAndSave() {        
        obj.put('caseHours__c', hourTime);
        obj.put('caseMinutes__c', minTime);
        obj.put('caseSeconds__c', secTime);
        try {
            update(obj);
            System.debug('#UPDATED RECORD:' + obj.id);
        }
        catch (Exception e) {
            System.debug('#EXCEPTION :' + e.getMessage());
        }
        return true;
    }   
    
    public StopWatchController getCtl() {
        //ctl.sobjName
        //ctl.totalTime 
       // ctl.timeBundle 
        //ctl.secTime 
        //ctl.minTime 
        //ctl.totalTime 
        ctl = this;
        return ctl;
    }
}