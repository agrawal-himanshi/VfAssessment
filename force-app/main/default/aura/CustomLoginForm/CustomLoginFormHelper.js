({
    loginHelper : function(component, event, helper, usrName, pwd) {
        var action = component.get("c.login");
        console.log("---1---");
        action.setParams({ userName : usrName,
                          password : pwd,
                          url : component.get("v.startUrl") 
                         });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS" || state === "DRAFT") {
                if(response.getReturnValue() != 'success'){
                    alert(response.getReturnValue());
                }  
            } else if (state === "INCOMPLETE") {
                console.log("No response from server or client is offline.");
            } else if (state === "ERROR") {
                console.log("Error message: " + response.getReturnValue());
                alert("Please entre a valid username and password");

                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        })
        $A.enqueueAction(action);
    }
})