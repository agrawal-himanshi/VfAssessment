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
    },
    // helper method to create folders
    createFolders : function(component,event){
        var fileName = component.get('v.newFolderName');
        var currentFolder=component.get('v.path')[component.get('v.path').length-1].value;
        if(currentFolder=='root'){
            currentFolder='';
        }
        var filePath=currentFolder+'/'+fileName;
        var action = component.get('c.createFolderInDropBox');
        action.setParams({
            'filePath': filePath,
            'current' :currentFolder
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var filesAndFolders = response.getReturnValue();
                component.set("v.folderAndFile", filesAndFolders);
                component.set('v.newFolderName','');

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

    },
    //helper method to upload file to dropbox
    uploadFileToDropbox: function(component, file,helper,fileName) {
        var currentFolder = component.get('v.path')[component.get('v.path').length-1].value;
        console.log(currentFolder);
        if(currentFolder=='root'){
            currentFolder='';
        }
        var filePath = currentFolder + '/' + fileName;
        console.log(filePath);
        var reader = new FileReader();
        reader.onload = $A.getCallback(function() {
            var fileContents = reader.result;
            var base64Mark = 'base64,'; // binary-to-text encoding
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            console.log(fileContents);
            var action = component.get("c.uploadFile");
            action.setParams({
                'filePath': filePath,
                'current' :currentFolder,
                'fileContents': fileContents
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    
                    var filesAndFolders = response.getReturnValue();
                    component.set("v.folderAndFile", filesAndFolders);
                    component.set('v.fileName','');
                    component.set('v.fileContent',null);
                    
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
        });
        reader.readAsDataURL(file);
    },
    //helper method to get the path for breadcrum
     getPath :function(component,event){
        var path = component.get("v.path");
        var folderPath = event.getSource().get("v.name");
        var index = path.findIndex(item => item.value === folderPath);
        if (index === -1 || index === path.length - 1) {
            return;
        }
        path = path.slice(0, index + 1);
        component.set("v.path", path);
        var action = component.get("c.getFileAndFolders");
        action.setParams({
            'currentFolder': folderPath,
            'accessToken': '',
            'isNew' : false  
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var filesAndFolders = response.getReturnValue();
                component.set("v.folderAndFile", filesAndFolders);
                var path = component.get('v.path');
                path.push({label: folderName, value: currentFolder});
                component.set("v.path", path);
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
    },
    //helper method to open current folder
    openCurrentFolder : function(component, event){
        var currentFolder = event.currentTarget.dataset.path;
        var folderName = event.currentTarget.title;
        console.log(currentFolder);
        var action = component.get("c.getFileAndFolders");
        action.setParams({
            'accessToken': '',
            'currentFolder': currentFolder,
            'isNew' : false
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var filesAndFolders = response.getReturnValue();
                component.set("v.folderAndFile", filesAndFolders);
                var path = component.get('v.path');
                path.push({label: folderName, value: currentFolder});
                component.set("v.path", path);
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
    },
    //helper method to preview file in dropbox
    perviewFileInDropBox : function(component,event){
        var directory = event.target.parentElement.parentElement;
        console.log(directory);
        var filePath = directory.getAttribute('data-path');
        var action = component.get('c.getPreview');
        action.setParams({
            'filePath': filePath
        });
        console.log(filePath);
        console.log("9999");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var url = response.getReturnValue();
                window.open(url, '_blank');
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
    },
    //helper method to download file from dropbox
    download : function(component,event){
        var directry = event.target.parentElement.parentElement.parentElement;
        console.log(directry);
        var filePath = directry.getAttribute('data-id');
        console.log(filePath);
        var action = component.get('c.fileDownload');
        console.log(filePath);
        action.setParams({
            filePath: filePath
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === 'SUCCESS') {
                var fileContent = response.getReturnValue();
                console.log(fileContent);
                const link = document.createElement('a');
                link.href = fileContent;
                link.target = '_self';
                link.click();
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
    },
    //helper method to delete files and folders
    delete : function(component,event){
        var directory = event.target.parentElement.parentElement.parentElement;
        var filePath = directory.getAttribute('data-path');
        var currentFolder=component.get('v.path')[component.get('v.path').length-1].value;
        var action = component.get('c.deleteFileOrFolder');
        action.setParams({
            'filePath': filePath,
            'current' :currentFolder
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var filesAndFolders = response.getReturnValue();
                component.set("v.folderAndFile", filesAndFolders);

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
})