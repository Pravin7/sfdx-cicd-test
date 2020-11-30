global class MyJSControllers {
    public String accountName { get; set; }
    public static Account account { get; set; }
    public MyJSControllers() { }
    
    @RemoteAction
    global static Account getAccount(String accountName) {
    account = [select id, name, phone, type, numberofemployees from Account where name = :accountName ];
    return account;
    }
    
}