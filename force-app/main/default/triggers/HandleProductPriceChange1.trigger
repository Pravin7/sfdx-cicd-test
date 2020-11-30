trigger HandleProductPriceChange1 on Merchandise1__c (after update) {

    // update invoice line items associated with open invoices
    List<Line_Item1__c> openLineItems =
    [SELECT j.Unit_Price__c, j.Merchandise1__r.Price__c
    FROM Line_Item1__c j
    WHERE j.Invoice_Statement1__r.Status__c = 'Negotiating'
    AND j.Merchandise1__r.id IN :Trigger.new
    FOR UPDATE];

    for( Line_Item1__c li: openLineItems) {
        if (li.Merchandise1__r.Price__c < li.Unit_Price__c) {
            li.Unit_Price__c = li.Merchandise1__r.Price__c;
        }
    }
    update openLineItems;
}