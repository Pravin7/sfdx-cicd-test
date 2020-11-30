public class AdvantageHoursUsageExtn {
    public Map<String, List<Decimal>> ExpectedVsActualUsageMap {get; set;}
    public Map<String, List<Decimal>> clientVsOtherClientsUsageMap {get; set;}
    public Map<String, Decimal> monthVsActualUsageMap {get; set;}
    // following fields can be accessed from client object
    public String clientName {get; set;}
    public String startingMonth {get; set;}
    public String startingYear {get; set;}    
    public Integer numberOfMonths {get; set;}
    
    public AdvantageHoursUsageExtn() {
        // get the client
        ExpectedVsActualUsageMap = new Map<String, List<Decimal>>(); 
        clientVsOtherClientsUsageMap  = new Map<String, List<Decimal>>();
        monthVsActualUsageMap = new Map<String, Decimal>();                 
        getClient();
        populateMaps();        
    }
    
    private void getClient() {
        clientName = 'PIP';
        startingMonth = 'June';
 		startingYear = '2014';
        Date startDate = Date.newInstance(2014, 06, 01);
        numberOfMonths = 12;      
    }
    
    private void populateMaps() {
        
    }

}