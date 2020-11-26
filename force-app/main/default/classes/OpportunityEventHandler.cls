public class OpportunityEventHandler {
          public OpportunityEventHandler() {

         }
         public void enter(TriggerParameter tp){
                 if (tp.operationType != TriggerParameter.OperationType.IS_UPDATE) return;
                 //determine the opps where either discount % has changed or total discount has changed
                 Set<Id> percentChanged= new Set<Id>();
                 Set<Id> totalChanged= new Set<Id>();
                 for (Id opportunityId : tp.newMap.keySet()){
                         Opportunity newOp= (Opportunity)tp.newMap.get(opportunityId);
                         Opportunity oldOp= (Opportunity)tp.oldMap.get(opportunityId);
                         //if no change return
                         if (newOp.totalDiscount__c==oldOp.totalDiscount__c && newOp.percentDiscount__c==oldOp.percentDiscount__c){
                                 continue;
                         }else if(newOp.totalDiscount__c!=oldOp.totalDiscount__c && newOp.percentDiscount__c!=oldOp.percentDiscount__c){
                                 //both has changed percentage wins
                                 percentChanged.add(opportunityId);
                                 continue;
                         }else if(newOp.totalDiscount__c!=oldOp.totalDiscount__c){
                                 //total changed
                                 totalChanged.add(opportunityId);
                                 continue;
                         }else if(newOp.percentDiscount__c!=oldOp.percentDiscount__c){
                                 //percent changed
                                 percentChanged.add(opportunityId);
                                 continue;
                         }
                 }
                 List<OpportunityLineItem> opportnityLineForUpdate= new List<OpportunityLineItem> ();
                 //do processing for % change
                 system.debug(LoggingLevel.INFO, 'percentChangedSize-'+percentChanged.size());

                 if (percentChanged.size()>0){
                         for( Opportunity op:fetchOpportunityWithLineItems(percentChanged)){
                                 decimal newDiscount=((opportunity)tp.newMap.get(op.Id)).percentDiscount__c;
                                 decimal oldDiscount=((opportunity)tp.oldMap.get(op.Id)).percentDiscount__c;
                                 if ( oldDiscount!=0){
                                         double changeFactor= Double.valueOf(newDiscount)/Double.valueOf(oldDiscount);
                                         changeOpportunityLineItems(op.OpportunityLineItems,changeFactor,opportnityLineForUpdate);
                                 }else {
                                         double changePercentage= Double.valueOf(newDiscount);
                                         changeOpportunityLineItemsFromZero(op.OpportunityLineItems,changePercentage,opportnityLineForUpdate);

                                 }
                         }
                 }
                 //do processing for total change
                 system.debug(LoggingLevel.INFO, 'totalChangedSize-'+totalChanged.size());

                 if(totalChanged.size()>0){
                         for( Opportunity op:fetchOpportunityWithLineItems(totalChanged)){
                                 system.debug(LoggingLevel.INFO, 'opp-'+tp.newMap.get(op.Id));
                                 decimal newTotalDiscount=((opportunity)tp.newMap.get(op.Id)).totalDiscount__c;
                                 decimal oldTotalDiscount=((opportunity)tp.oldMap.get(op.Id)).totalDiscount__c;
                                 if ( oldTotalDiscount!=0){
                                         double changeFactor= newTotalDiscount/oldTotalDiscount;
                                         changeOpportunityLineItems(op.OpportunityLineItems,changeFactor,opportnityLineForUpdate);
                                 }else{
                                         double changePercentage= Double.valueOf(newTotalDiscount);
                                         changeOpportunityLineItemsFromZero(op.OpportunityLineItems,changePercentage,opportnityLineForUpdate);
                                 }
                         }
                 }
                 //update the opportunity line items
                 update opportnityLineForUpdate;


         }

         public boolean permit(TriggerParameter tp){
                 boolean permitted= false;
                 //if its for OpportunitylineItem then allow because I know I have made updates to it
                 if (('opportunityLineItem').equalsIgnoreCase(tp.objectName) && tp.operationType==TriggerParameter.OperationType.IS_UPDATE) {
                         permitted=true;
                 }
                 return permitted;
         }

         //utility methods
         public void changeOpportunityLineItems(List<opportunitylineItem> ols, double changeFactor,List<OpportunityLineItem> opportnityLineForUpdate){
                 //same factor is to be applied individually to each lineitem
             for (OpportunityLineItem ol:ols){
                 ol.discount= changeFactor*ol.discount;
                 opportnityLineForUpdate.add(ol);
             }
         }
         public void changeOpportunityLineItemsFromZero(List<opportunitylineItem> ols, double changePercentage,List<OpportunityLineItem> opportnityLineForUpdate){
                 //same factor is to be applied individually to each lineitem
             for (OpportunityLineItem ol:ols){
                 ol.discount= changePercentage;
                 opportnityLineForUpdate.add(ol);
             }
         }

         public List<Opportunity> fetchOpportunityWithLineItems(Set<Id> opportunityIds){
                 return [select Id, Amount, totalDiscount__c,percentDiscount__c,(select Id, quantity, unitPrice,discount,subTotal,totalPrice from OpportunityLineItems) from opportunity where Id in:opportunityIds];
         }

}