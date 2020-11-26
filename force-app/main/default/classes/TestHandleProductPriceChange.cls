@isTest
private class TestHandleProductPriceChange {

    static testMethod void testPriceChange() {
    
    //create an invoice stmnt and insert it into the db
    Invoice_Statement__c invoice = new Invoice_Statement__c(Status__C = 'Negotiating');
    insert invoice;
    //create new merchandise records
    Merchandise__c[] products = new Merchandise__c[]{
    new Merchandise__c(Name = 'item 1', Description__c = 'test product 1', Price__c = 10, Stock_Price__c = 9,
    Total_Inventory__c = 10),
    new Merchandise__c(Name = 'item 2', Description__c = 'test product 2', Price__c = 11, Stock_Price__c = 10,
    Total_Inventory__c = 10)
    };
    insert products;
    //adding line items
    Line_Item__c[] lineItems = new Line_Item__c[] {
    new Line_Item__c(Invoice_Statement__c = invoice.id, Merchandise__c = products[0].id,
    Unit_Price__c = 10, Units_Sold__c = 3),
    new Line_Item__c(Invoice_Statement__c = invoice.id, Merchandise__c = products[1].id,
    Unit_Price__c = 11, Units_Sold__c = 6)
    };
    insert lineItems;
    //updating the price of the merchandise record to execute the trigger
    products[0].price__c = 20; // raise price
    products[1].price__c = 5; // lower price
    Test.startTest();
    update products;
    Test.stopTest();
    lineItems =
    [SELECT id, unit_price__c FROM Line_Item__c WHERE id IN :lineItems];
    System.assert(lineItems[0].unit_price__c == 10); // unchanged
    System.assert(lineItems[1].unit_price__c == 5); // changed!!
    }
    
    
}