trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after update, after delete, after undelete) {
    

    TriggerParameter tp = new TriggerParameter();
    tp.isExecuting=true;
    tp.objectName='opportunityLineItem';

    tp.operationTime=TriggerParameter.OperationTime.IS_AFTER;
    tp.newList=trigger.new;
    tp.newMap=trigger.newMap;
    tp.oldList=trigger.old;
    tp.oldMap=trigger.oldMap;
    
    if (trigger.isInsert){
        tp.operationType=TriggerParameter.OperationType.IS_INSERT;
    }else if (trigger.isUpdate){
        tp.operationType=TriggerParameter.OperationType.IS_UPDATE;
    }else if (trigger.isDelete){
        tp.operationType=TriggerParameter.OperationType.IS_DELETE;
    }else if (trigger.isUndelete){
        tp.operationType=TriggerParameter.OperationType.IS_UNDELETE;
    }
    TriggerEventRouter.route(tp);

    /* naive implementation
    Set<Id> affectedopportunities= new Set<Id>();

    if (trigger.isDelete){
        calculateRollup(trigger.old, new List<OpportunityLineItem>());

    }else if(trigger.isUndelete){
        calculateRollup(new List<OpportunityLineItem>(), trigger.new);

    }else if(trigger.isInsert) {
        calculateRollup(new List<OpportunityLineItem>(), trigger.new);
    }else if(trigger.isUpdate){
        calculateRollup(trigger.old, trigger.new);
    }

    public void calculateRollup(List<OpportunityLineItem> oldList,List<OpportunityLineItem> newList ){
        //calculating the opportunities affected
        for (OpportunityLineItem oli: oldList){
            affectedopportunities.add(oli.opportunityId);
        }
        for (OpportunityLineItem oli: newList){
            affectedopportunities.add(oli.opportunityId);
        }

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
    */
}