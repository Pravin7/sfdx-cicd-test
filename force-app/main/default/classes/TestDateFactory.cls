@isTest
public class TestDateFactory{
    
    public static Invoice_Statement1__c createOneInvoiceStatement(
                                                 Boolean withLineItem) { 
        // Create one invoice statement
        Invoice_Statement1__c testInvoice = createInvoiceStatement();        
        if (withLineItem == true) {
            // Create a merchandise item
            Merchandise1__c m = createMerchandiseItem('Orange juice');
            // Create one line item and associate it with the invoice statement.        
            AddLineItem(testInvoice, m);
        }                   
        
        return testInvoice;
    }            
    
    // Helper methods
    //
    private static Merchandise1__c createMerchandiseItem(String merchName) {
        Merchandise1__c m = new Merchandise1__c(
            Name=merchName,
            Description__c='Fresh juice',
            Price__c=2,
            Total_Inventory__c=1000);
        insert m;
        return m;
    }
    
    private static Invoice_Statement1__c createInvoiceStatement() {        
        Invoice_Statement1__c inv = new Invoice_Statement1__c(                
            Description__c='Test Invoice');      
        insert inv;
        
        return inv;
    } 
    
    private static Line_Item1__c AddLineItem(Invoice_Statement1__c inv, 
                                            Merchandise1__c m) {
        Line_Item1__c lineItem = new Line_Item1__c(
                                    Invoice_Statement1__c = inv.Id, 
                                    Merchandise1__c = m.Id, 
                                    Unit_Price__c = m.Price__c, 
                                    Units_Sold__c = (Double)(10*Math.random()+1));
        insert lineItem;
        
        return lineItem;
    }       
}