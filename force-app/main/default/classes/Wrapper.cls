/**
* @author    : VW
* @Purpose   : A wrapper class for User Object. 
*              This is used for implementing selection of multiple user records and performing operations on them. 
*/
global with sharing class Wrapper {
    // flag to hold whether or not record is selected    
    public Boolean selected { get; set; }   
    // user object record
    public User userObj {get; set;}
    
    public Wrapper (User userObj) {       
        this.selected = false;        
        this.userObj = userObj;        
    }   
    
    public Wrapper (User userObj, Boolean selected) {        
        this.selected = selected;        
        this.userObj = userObj;        
    }    
}