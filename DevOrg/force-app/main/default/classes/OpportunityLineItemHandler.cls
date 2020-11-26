public with sharing class OpportunityLineItemHandler implements TriggerHandlerInterface{
         public OpportunityLineItemHandler() {

         }
         public void enter(TriggerParameter tp){
                 if (tp.operationTime == TriggerParameter.OperationTime.IS_BEFORE) return;//processing all after
                 Set<Id> affectedopportunities= new Set<Id>();

                 if (tp.operationType == TriggerParameter.OperationType.IS_DELETE){
                         calculateRollup(tp.oldList, new List<OpportunityLineItem>(),affectedopportunities);

                 }else if(tp.operationType == TriggerParameter.OperationType.IS_UNDELETE){
                         calculateRollup(new List<OpportunityLineItem>(), tp.newList,affectedopportunities);

                 }else if(tp.operationType == TriggerParameter.OperationType.IS_INSERT) {
                         calculateRollup(new List<OpportunityLineItem>(), tp.newList,affectedopportunities);
                 }else if(tp.operationType == TriggerParameter.OperationType.IS_UPDATE){
                         calculateRollup(tp.oldList, tp.newList,affectedopportunities);
                 }


                 Map<Id,opportunity> opportunities=new Map<Id,opportunity>([select Id , percentDiscount__c, totalDiscount__c from Opportunity where Id in:affectedopportunities]);
                 AggregateResult[] discountSummary= [select SUM(subtotal) unDiscounted, SUM(totalprice) afterDiscount , opportunityId from OpportunitylineItem where opportunityId in :affectedopportunities group by opportunityId];
                 system.debug(Logginglevel.INFO, 'affected Opportunities'+affectedopportunities);

                 system.debug(Logginglevel.INFO, 'opportunity summary -'+discountSummary);
                 system.debug(Logginglevel.INFO, 'opportunity map size-'+opportunities.size());

                 for (AggregateResult ar : discountSummary){
                         system.debug(Logginglevel.INFO, 'percent Discount -'+((double)ar.get('unDiscounted')-(double)ar.get('afterDiscount'))*100/(double)ar.get('unDiscounted'));
                         system.debug(Logginglevel.INFO, 'total Discount -'+((double)ar.get('unDiscounted')-(double)ar.get('afterDiscount')));

                         opportunities.get((Id)ar.get('opportunityId')).percentDiscount__c=((double)ar.get('unDiscounted')-(double)ar.get('afterDiscount'))*100/(double)ar.get('unDiscounted');
                         opportunities.get((Id)ar.get('opportunityId')).totalDiscount__c=(double)ar.get('unDiscounted')-(double)ar.get('afterDiscount');
                 }
                 system.debug(Logginglevel.INFO, 'Opportunities'+opportunities.values());

                 update opportunities.values();
         }
         public boolean permit(TriggerParameter tp){
                 /*boolean permitted= false;
                 //if its for Opportunity then allow because I know I have made changesto it opportunity
                 if (('opportunity').equalsIgnoreCase(tp.objectName)  && tp.operationType==TriggerParameter.OperationType.IS_UPDATE) {
                         permitted=true;
                 }
                 return permitted;
                 */
                 return false;
         }
         public void calculateRollup(List<OpportunityLineItem> oldList,List<OpportunityLineItem> newList,Set<Id> affectedopportunities ){
                         //calculating the opportunities affected
                         for (OpportunityLineItem oli: oldList){
                                 affectedopportunities.add(oli.opportunityId);
                         }
                         for (OpportunityLineItem oli: newList){
                                 affectedopportunities.add(oli.opportunityId);
                         }

                 }
 }