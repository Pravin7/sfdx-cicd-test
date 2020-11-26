public with sharing class SampleJsonController {

    public String treeJson { get; set; }
    
    public SampleJsonController() {
        treeJson = '['+
           +'{'+
            '"text": "To Do",';
       treeJson += '"cls": "folder",'+
            +'"expanded": true,'+
            +'"children": ['+
                +'{'+
                    '"text": "Go jogging",'+
                    '"leaf": true'+
                '},'+
                '{'+
                    '"text": "Take a nap",'+
                    '"leaf": true'+
                '},'+
                '{'+
                    '"text": "Climb Everest",'+
                    '"leaf": true'+
                '}'+
            ']'+
        '}'+
        ']';
    }
    
}