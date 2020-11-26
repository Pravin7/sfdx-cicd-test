global class TotalContacts{

  WebService static Integer findContactTotal(Id accId) {
    Integer dummy = 3;
    account acc = [select id,name from account where Id =:accId];  
    return dummy;
  }

}