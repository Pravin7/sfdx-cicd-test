public class TriggerEventRouter {
    
         private TriggerEventRouter() {}
         public static TriggerHandlerInterface runningHandler=null;//if its populated when a bunch of events are router then this has caused it
         public static EventStack eventStack= new EventStack();
         public  class EventStack{
                 List<String> eventSignatures= new List<String>();
                 Map<String,TriggerParameter > tpMap = new Map<String, TriggerParameter >();
                 public boolean checkRentry(TriggerParameter tp){
                         //create a signature for the current event type , temporal, object, and type
                         //search for it within the existing stack and return response appropriately
                         
                         String sign = tp.objectName + '#'+ tp.operationType + '#' +tp.OperationTime;
                         if (tpMap.containsKey(sign)) {
                             return true;
                         } else {
                             tpMap.put(sign, tp);
                             Set<TriggerHandlerInterface> handlersSet = getHandlers(tp.objectName);
                             if (null != handlersSet && !handlersSet.isEmpty()) {
                                 for (TriggerHandlerInterface handler : handlersSet) {
                                     runningHandler = handler;
                                 }
                             }
                             return false;
                         }                         
                         
                 }
         }
         //main method called by each trigger
         public static void route(TriggerParameter tp){
                 if (!eventStack.checkRentry(tp)){//if its not exact same trigger i.e eventType, object and time
                         //check if this invocation was caused by some handler already executing then we ask for his permit
                         if (null!=runningHandler){
                             runningHandler.permit(tp);
                         }else{//if its fresh entry simple execute all handlers
                            runningHandler.enter(tp);
                         }

                 }//if its exactly same we do nothing

         }



         //Gets the handlers from custom settings Named TriggerEventHandler__c with fields: Name - Name of handler , handles__c - 'objectName__c' it handles
         public static set<TriggerHandlerInterface> getHandlers(String objectName){
                 system.debug('getHandlers(objectName='+ objectName+')');
                 system.debug('Registered handlers-'+ TriggerEventHandler__c.getAll().values());

                 set<TriggerHandlerInterface> handlers= new set<TriggerHandlerInterface>();
                 try
                 {
                         for (TriggerEventHandler__c aHandler : TriggerEventHandler__c.getAll().values()){
                                 if (aHandler.handles__c==objectName){
                                         Type handlerType= Type.forName( aHandler.Name);
                                         if (handlerType!=null)
                                                 handlers.add((TriggerHandlerInterface)handlerType.newInstance());
                                 }
                         }
                 }catch(Exception e){
                         system.debug('Could not find a handler handlers.size-'+ handlers.size());
                 }
                 return handlers;
         }
}