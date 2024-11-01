({
	//helper method to authorize user
    authUser : function(component,event) {
        var url = window.location.href;
        function getParameterByName(name, url) {
            if (!url) url = window.location.href;
            name = name.replace(/[\[\]]/g, '\\$&');
            var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
            results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, ' '));
        }
        var code = getParameterByName('code');
        if(code === undefined || code==='' || code===null) {
            console.log("----1----");
            var action  = component.get("c.createAuthURL");
            console.log("----2----");
            action.setCallback(this, function(response){
                console.log("----3----");
                var status = response.getState();
                console.log(status);
                if(status === "SUCCESS"){
                    var folder = response.getReturnValue();
                    console.log(folder);
                    component.set('v.folderAndFile',folder);
                    component.set('v.recordsPresent',true);
                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error("Error message: " +  errors[0].message);
                        }
                    } 
                    else {
                        console.error("Unknown Error");
                    }
                } 
            });
            $A.enqueueAction(action);
        }
        else{
            console.log("8989");
            var actions = component.get('c.getAccessToken');
            console.log("889");
            actions.setParams({
                'code' : code,
                'currentFolder' : component.get('v.path')[component.get('v.path').length-1].value
            });
            console.log("89");
            actions.setCallback(this, function(response){
                var status = response.getState();
                console.log(status);
                if(status === "SUCCESS"){
                    var folder = response.getReturnValue();
                    console.log(folder);
                    
                    component.set('v.folderAndFile',folder);
                    component.set('v.recordsPresent',true);

                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error("Error message: " +  errors[0].message);
                        }
                    } 
                    else {
                        console.error("Unknown Error");
                    }
                } 
            });
            
            $A.enqueueAction(actions);
        }
    }  
})