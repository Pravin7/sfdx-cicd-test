({

    init: function(cmp, event, helper) {
        var child = cmp.get("v.child");
        if(child){
            console.log(child.Account); 
            console.log(child.Account.Id); 
            console.log(child["Account"]["Name"]);
            let fieldVsData = new Map();
            /*
            //for (let row of data) {
                fieldVsData.set('Account', child.Account);
            	fieldVsData.set('Account.Id', child.Account.Id);
            	fieldVsData.set('Account.Name', child.Account.Name);
            //}
            for(var key of fieldVsData){
                fieldValues.push({value:fieldVsData[key], key:key});
                console.log(key);
            }
                        cmp.set("v.parentFieldValues", fieldVsData);
            */
                        var fieldValues = [];

                fieldValues.push({value:child["AccountId"], key:"AccountId"});
                fieldValues.push({value:child["Account"]["Id"], key:"Account.Id"});
				fieldValues.push({value:child["Account"]["Name"], key:"Account.Name"});

            cmp.set("v.parentFieldValuesList", fieldValues);
            console.log(cmp.get("v.parentFieldValuesList"));
			console.log(cmp.get("v.parentFieldValues"));
           /*
            if (state === "SUCCESS") {                
                var custs = [];
                var conts = response.getReturnValue();
                for(var key in conts){
                    custs.push({value:conts[key], key:key});
                }
                component.set("v.customers", custs);
                component.set("v.showBool", true);
            } 
            */
        }
         
        cmp.set("v.accountFields", cmp.get("v.fieldNames").split(","));
        //var fieldList = cmp.get("v.fieldNames").split(","));
        cmp.set("v.dataLoaded", "done");
        console.log(cmp.get("v.accountFields"));
    },
    
    handleLoad: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
    },

    handleSubmit: function(cmp, event, helper) {
        cmp.set('v.disabled', true);
        cmp.set('v.showSpinner', true);
    },

    handleError: function(cmp, event, helper) {
        // errors are handled by lightning:inputField and lightning:nessages
        // so this just hides the spinnet
        cmp.set('v.showSpinner', false);
    },
    
    valueChanged: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
        console.log(event.getSource().get('v.fieldName'));
        let fieldName = event.getSource().get('v.fieldName');
        console.log(event.getParam("value"));
		cmp.set('v.dynamicValue', event.getParam("value"));
        
		//If using lightning:input, assign the field name as 'name' to the input component.
		//console.log(event.getSource().get('v.name'));
    },

    handleSuccess: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
        cmp.set('v.saved', true);
    }
});