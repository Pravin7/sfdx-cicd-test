public class templateExample{

    String name;
    Boolean showGreeting = false;
    
    public PageReference save() {
        showGreeting = true;
        return null;
    }
    
    public void setNameField(String nameField) {
        name = nameField;
    }
    
    public String getNameField() {
        return name;
    }
    
    public Boolean getShowGreeting() {
        return showGreeting;
    }
}