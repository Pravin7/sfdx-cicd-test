trigger DistributionTrigger on Distribution__c (after insert, after update, after delete) {
	
	    if(trigger.isInsert || trigger.isUpdate){
	        try{             
	       		DistributionHelper.insertInvestmentDistribution(trigger.new);
	        }
	        catch(Exception e){
				System.debug('*********Error************'+e);
	        }      
		}
		
		if(trigger.isDelete){
	        try{             
	       // 	DistributionHelper.handleDistributionDelete(trigger.old);
	        }
	        catch(Exception e){
				System.debug('*********Error************'+e);
	        }
		}		
}