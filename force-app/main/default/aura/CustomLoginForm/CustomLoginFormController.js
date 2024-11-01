({
	onLogin : function(component, event, helper) {
		var usrName = component.find('username').get('v.value');
        var pwd = component.find('password').get('v.value');
        if(usrName !='' && pwd !=''){
            helper.loginHelper(component, event, helper, usrName, pwd);
        }
        else{
            console.log("empty");
            alert('Please enter a valid username and password'+ usrName,pwd);
        }
	}
})