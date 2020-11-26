public with sharing class TriggerParameter {
    public TriggerParameter(){}
    public String objectName{get;set;}

    public Enum OperationType {IS_INSERT,IS_UPDATE,IS_DELETE,IS_UNDELETE}
    public Enum OperationTime {IS_BEFORE,IS_AFTER}
    public boolean isExecuting{get;set;}

    public OperationType operationType{get;set;}
    public OperationTime operationTime{get;set;}
    
    public List<sObject> newList {get;set;}
    public Map<Id,sObject> newMap {get;set;}

    public List<sObject> oldList {get;set;}
    public Map<Id,sObject> oldMap {get;set;}
    public Integer size{get;set;}
}