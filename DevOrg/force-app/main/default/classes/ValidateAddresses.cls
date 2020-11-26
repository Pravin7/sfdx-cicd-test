public class ValidateAddresses {
    public static Boolean AsyncValidationFlag = false;
    
    @Future(callout=true) 
    public static void validateAddressSOAP(Set<ID> ids) {
        try {
            // Build list of addresses to validate
            Map<ID, Candidate__c> mapCands = findCandidates(ids);
            List<ValidateAddressesSOAP.addressSOAP> listAddress = new List<ValidateAddressesSOAP.addressSOAP>();
            for (Candidate__c cand : mapCands.values()) {
                ValidateAddressesSOAP.addressSOAP address = new ValidateAddressesSOAP.addressSOAP();
                address.id = cand.id;
                address.line1 = cand.Street_Address_1__c;
                address.line2 = cand.Street_Address_2__c;
                address.city = cand.city__c;
                address.state = cand.state_Province__c;
                address.country = cand.country__c;
                address.zipCode = cand.zip_postal_code__c;
                listAddress.add(address);
            }
                        
            // Make callout
            // TODO Exercise 10-2:: Construct an instance of the ValidateAddressesSOAP.ValidateAddressesPort class
            //      and assign it to a variable called "soapPort" of type ValidateAddressesSOAP.ValidateAddressesPort.
 			ValidateAddressesSOAP.ValidateAddressesPort soapPort = new ValidateAddressesSOAP.ValidateAddressesPort();
            List<ValidateAddressesSOAP.validationResultSOAP> listResult = soapPort.ValidateAddresses(listAddress);
           // TODO Exercise 10-2: Using the "soapPort" variable, call the ValidateAddresses method, 
            //      passing it the variable "listAddress", and assign the resulting list to a variable called "listResult", 
            //      which should be a list of ValidateAddressesSOAP.validationResultSOAP objects.

            // Verify results
            for (ValidateAddressesSOAP.validationResultSOAP result : listResult) {
                Candidate__c cand = mapCands.get(result.testAddress.id);
                if (result.isValid) {
                    cand.Valid_US_Address__c = true;
                    cand.Address_Error__c = null;
                } else {
                    cand.Valid_US_Address__c = false;
                    cand.Address_Error__c = 'Invalid Address';                 
                }
            }
            
            // Update Candidate
            AsyncValidationFlag = true;
            update mapCands.values();
        } catch (Exception ex) {
            // Handle Exception
            System.debug('ERROR: '+ ex);
         }
    }
    
    private static Map<ID, Candidate__c> findCandidates(Set<ID> ids) {
        Map<ID, Candidate__c> output;
        output = new Map<ID, Candidate__c>([SELECT ID, Street_Address_1__c, Street_Address_2__c, city__c,
                                                state_Province__c, country__c, zip_postal_code__c
                                            FROM candidate__c
                                            WHERE id in :ids]);
        return output;
    }
}