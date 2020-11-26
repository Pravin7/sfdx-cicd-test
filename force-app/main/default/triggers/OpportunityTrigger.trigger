trigger OpportunityTrigger on Opportunity (after update) {


    TriggerParameter tp = new TriggerParameter();
    tp.isExecuting=true;
    tp.objectName='opportunity';
    tp.operationType=TriggerParameter.OperationType.IS_UPDATE;
    tp.operationTime=TriggerParameter.OperationTime.IS_AFTER;
    tp.newList=trigger.new;
    tp.newMap=trigger.newMap;
    tp.oldList=trigger.old;
    tp.oldMap=trigger.oldMap;
    TriggerEventRouter.route(tp);

    /* naive implementation
    //determine the opps where either discount % has changed or total discount has changed
    Set<Id> percentChanged= new Set<Id>();
    Set<Id> totalChanged= new Set<Id>();
    for (Id opportunityId : trigger.newMap.keySet()){
        Opportunity newOp= trigger.newMap.get(opportunityId);
        Opportunity oldOp= trigger.oldMap.get(opportunityId);
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
            double changeFactor= trigger.newMap.get(op.Id).percentDiscount__c/trigger.oldMap.get(op.Id).percentDiscount__c;
            changeOpportunityLineItems(op.OpportunityLineItems,changeFactor);       
        }
    }
    //do processing for total change
    system.debug(LoggingLevel.INFO, 'totalChangedSize-'+totalChanged.size());

    if(totalChanged.size()>0){
        for( Opportunity op:fetchOpportunityWithLineItems(totalChanged)){
            system.debug(LoggingLevel.INFO, 'opp-'+trigger.newMap.get(op.Id));
            double changeFactor= trigger.newMap.get(op.Id).totalDiscount__c/trigger.oldMap.get(op.Id).totalDiscount__c;
            changeOpportunityLineItems(op.OpportunityLineItems,changeFactor);
        }
    }
    //update the opportunity line items
    update opportnityLineForUpdate;

    public void changeOpportunityLineItems(List<opportunitylineItem> ols, double changeFactor){
        //same factor is to be applied individually to each lineitem
        for (OpportunityLineItem ol:ols){
            ol.discount= changeFactor*ol.discount;
            opportnityLineForUpdate.add(ol);
        }
    }

    public List<Opportunity> fetchOpportunityWithLineItems(Set<Id> opportunityIds){
        return [select Id, Amount, totalDiscount__c,percentDiscount__c,(select Id, quantity, unitPrice,discount,subTotal,totalPrice from OpportunityLineItems) from opportunity where Id in:opportunityIds];
    }
    */

}