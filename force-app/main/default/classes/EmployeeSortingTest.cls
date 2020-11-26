@isTest
private class EmployeeSortingTest {
    static testmethod void test1() {        
        List<Employee> empList = new List<Employee>();
        empList.add(new Employee(101,'Joe Smith', '4155551212'));
        empList.add(new Employee(101,'J. Smith', '4155551212'));
        empList.add(new Employee(25,'Caragh Smith', '4155551000'));
        empList.add(new Employee(105,'Mario Ruiz', '4155551099'));
        
        // Sort using the custom compareTo() method
        empList.sort();
        
        // Write list contents to the debug log
        System.debug(empList);
        
        // Verify list sort order.
        System.assertEquals('Caragh Smith', empList[0].Name);
        System.assertEquals('Joe Smith', empList[1].Name); 
        System.assertEquals('J. Smith', empList[2].Name);
        System.assertEquals('Mario Ruiz', empList[3].Name);
    }
}