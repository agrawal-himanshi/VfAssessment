({
    //method to navigate to homepage
    navigateToHomePage : function(component, event, helper) {
        // Navigate to the home page URL
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 'https://briskmindssoftwaresoluti-6b-dev-ed.develop.my.site.com/dropboxCommunity/s/'
        });
        urlEvent.fire();
    },
    // handle the selection of settings and logout
    handleMenuSelect: function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue === "settings") {
            var url = "https://briskmindssoftwaresoluti-6b-dev-ed.develop.my.site.com/dropboxCommunity/s/settings";
            window.open(url, '_blank');
        } 
        else if (selectedMenuItemValue === "logout") {
            // Handle logout action
        }
    },
    //method to authorize the user
    doAuth : function(component, event, helper) {
        component.set("v.isConnected", true);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 'https://briskmindssoftwaresoluti-6b-dev-ed.develop.my.site.com/dropboxCommunity/s?source=settings'
        });
        urlEvent.fire();
        console.log("-----");
        helper.authUser(component,event);
    },
    //method to revoke the access token
    doRevoke : function(component, event, helper) {
        component.set("v.isConnected", false);
        console.log("Attempting to revoke access token...");
        var action  = component.get("c.doRevokeAccessToken"); 
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                console.log("Access token successfully revoked.");
                var authUrl = response.getReturnValue();
                // Redirect the user
                window.location.href = authUrl;
            } else if (status === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("Error revoking access token: " + errors[0].message);
                } 
                else {
                    console.log("Unknown error occurred while revoking the access token.");
                }
            }
        });
        $A.enqueueAction(action);
    }
})