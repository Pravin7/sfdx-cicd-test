/**
* @author    : VW
* @Purpose   : This class is a pagination controller for navigation on VF page  -updated **.
*/

global with sharing class CustomIterable implements Iterator<List<Wrapper>>{ 
	// properties
	List<User> usersList {get; set;} 
	List<Wrapper> userWrappersList {get; set;} 
	global List<Wrapper> userWrappersListRequested {get; set;} 
	Wrapper userWrapperObj;
	Integer i {get; set;} 

	// Properties for page and record #
	public Integer fetchedRecordCount {get;set;}
	public Integer currentPageNumber {get;set;}
	public Integer totalPages {get;set;}
	public Integer recordsFrom {get;set;}
	public Integer recordsTo {get;set;}
    
    // Constructor. Requires Selected users' list and page size
    public CustomIterable(List<User> usersListFromCon, Integer pageSize){
    	usersList = usersListFromCon;
        userWrappersList = new List<Wrapper>(); 
		userWrappersListRequested = new List<Wrapper>();
		
		for(User tempUser : usersList) {
			userWrapperObj = new Wrapper(tempUser, false);
			userWrappersList.add(userWrapperObj);
		} 
		fetchedRecordCount = usersList.size();
        // calculate the total pase required depending on # of records and page size
		if(Math.mod(usersList.size(),pageSize) == 0)
			totalPages = usersList.size()/pageSize;
		else
			totalPages = Integer.valueOf(usersList.size()/pageSize) + 1;
		// this index is used to determine how many and which records to be shown on the page
		i = 0; 
    }
	// checks if there are any records in the iterable obj after the records shown on the current page
	global Boolean hasNext(){ 
		if(i >= userWrappersList.size()) {
			return false; 
		} else {
			return true; 
		}
	} 
	// checks if there are any records in the iterable obj before the records shown on the current page
	global Boolean hasPrevious(){ 
		if(i <= Integer.valueOf(MassUserUpdatesPageController.pageSize)) {
			return false; 
		} else {
			return true; 
		}
	}   
    // Return a list of user wrapper to be shown when clicked on next
	global List<Wrapper> next(){       
		Integer currentPageSize = Integer.valueOf(MassUserUpdatesPageController.pageSize);
		userWrappersListRequested = new List<Wrapper>(); 
		integer startNumber;
		integer size = userWrappersList.size();
        
		if(hasNext()){  
		
			if(size <= (i + currentPageSize)){
				startNumber = i;
				i = size;
			}
			else{
				i = (i + currentPageSize);
				startNumber = (i - currentPageSize);
			}           
			// form a list of records to be shown on the current page
			for(integer start = startNumber; start < i; start++) {
				userWrappersListRequested.add(userWrappersList[start]);
			}
			// calculate current page # and to/from values
			currentPageNumber = Integer.valueOf(startNumber / currentPageSize) + 1;            
			calculateFromToValues();
		} 
		return userWrappersListRequested;
	} 
	// Return a list of user wrapper to be shown when clicked on previous
	global List<Wrapper> previous(){      
		Integer currentPageSize = Integer.valueOf(MassUserUpdatesPageController.pageSize);
		userWrappersListRequested = new List<Wrapper>(); 

		integer size = userWrappersList.size(); 
		if(i == size){
			if(math.mod(size, currentPageSize) > 0){    
				i = size - math.mod(size, currentPageSize);
			}
			else {
				i = (size - currentPageSize);
			} 

		} else{	   
			i = (i - currentPageSize);
		}
		// form a list of records to be shown on the current page
		for(integer start = (i - currentPageSize); start < i; ++start) {
			userWrappersListRequested.add(userWrappersList[start]);
		}       
        // calculate current page # and to/from values
		currentPageNumber = Integer.valueOf((i - currentPageSize)/ currentPageSize) + 1;
		calculateFromToValues();
		return userWrappersListRequested;
	}  
	// This method calls To and From values for the records to be shown on the page
	public void calculateFromToValues(){
		Integer currentPageSize = Integer.valueOf(MassUserUpdatesPageController.pageSize);
		recordsFrom = currentPageSize *( currentPageNumber - 1) + 1;

		if((recordsFrom + currentPageSize) < fetchedRecordCount)
			recordsTo = currentPageSize * currentPageNumber;
		else
			recordsTo = fetchedRecordCount;
	}
}