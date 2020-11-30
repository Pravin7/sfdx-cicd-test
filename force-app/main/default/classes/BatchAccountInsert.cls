public with sharing class BatchAccountInsert implements Database.Batchable<sObject> {

   public final String Query;
   public final String Entity;
   public final String Field;
   public final String Value;

   public BatchAccountInsert(String q){
      Query=q;
   }

   public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }
   
   public void execute(Database.BatchableContext BC, List<Account> act){
   List <Account> lstAccount = new list<Account>();  
     for(Account a : act){
        // s.put(Field,Value);
			if(a.name == 'The Brick Hut') {
				Account actNew = new Account(name='Pravin');
				lstAccount.add(actNew);
			}
     }
	     try {
	     insert lstAccount;
	     } catch (DMLexception e) {
	     	System.debug('____DMLEXCEPTION___'+e.getMessage());
	     }
     }

   public void finish(Database.BatchableContext BC){
        system.debug('_______________finsih________');          
   }
}