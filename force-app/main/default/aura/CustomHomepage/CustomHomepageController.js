({
    // init method
    doInit: function(component, event, helper) {
        // Get the URL parameters
        var queryParams = new URLSearchParams(window.location.search);
        var source = queryParams.get('source');
        // Check if the source is 'settings'
        if (source === 'settings') {
            console.log("Navigated from Settings component");
            helper.authUser(component,event);
        }
    },
    // to see user details
    viewUser: function(component, event, helper){
        component.set("v.userView", true);
    },
    // selected integration type
    selectResource: function(component, event, helper) {
        const selectedResource = event.currentTarget.dataset.selected;
        component.set("v.selectedResource", selectedResource);
    },
    //select settings or logout
    handleMenuSelect: function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue === "settings") {
            window.location.href = "settings";
        } else if (selectedMenuItemValue === "logout") {
            // Handle logout action
        }
    },
    //sidebar toggle
    toggleSidebar : function(component, event, helper) {
        var isExpanded = component.get("v.isSidebarExpanded");
        component.set("v.isSidebarExpanded", !isExpanded);
    },
    //select create folder or upload file
    handleAddSelect: function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue === "createFolder") {
            component.set("v.createFolderModal", true);
        } 
        else if (selectedMenuItemValue === "uploadFolder") {
            component.set("v.uploadFolderModal", true);
        }
    },
    //hide modal of create folder
    hideCreateFolderModal: function(component, event, helper){
        component.set("v.createFolderModal", false);
    },
    //hide modal of upload folder
    hideUploadFolderModal: function(component, event, helper){
        component.set("v.uploadFolderModal", false);
    },
    //authorization
    doAuth : function(component, event, helper) {
        console.log("-----");
        helper.authUser(component,event);
    },
    //to create folder
    createfolder: function(component, event, helper){
        console.log("-----");
        var folderName=component.get('v.newFolderName');
        console.log(folderName);
        if(folderName){
            helper.createFolders(component,event);
            component.set('v.createFolderModal',false);
        }
    },
    //to get files content like its name, content and type
    //files attribute contains an array or list of file objects
    onUpload :  function(component, event, helper) {
        var filess = event.getSource().get("v.files");
        if (filess && filess.length > 0) {;
            var file = filess[0];
            var fileName = file.name;
            component.set('v.fileContent',file);
            component.set('v.fileName',fileName);
        }
    },
    // to upload files
    uploadFolder: function(component, event, helper) {
        var file = component.get('v.fileContent');
        console.log(file);
        var fileName = component.get('v.fileName');
        console.log(fileName);
        if (file!==null&&file!==undefined) {
            helper.uploadFileToDropbox(component, file,helper,fileName);
            component.set("v.uploadFolderModal", false);
        }        
    },
    //to open the folder
    openFolder : function(component, event, helper){
        helper.openCurrentFolder(component,event);
    },
    //to view file
    perviewFile : function(component, event, helper) {
        helper.perviewFileInDropBox(component,event);
    },
    //to download file
    downloadFile : function(component, event, helper){
        helper.download(component,event);
    },
    //for breadcrum   
    handlePath :function(component, event, helper){
        helper.getPath(component,event);
    },
    //to delete file    
    deleteFile :function(component, event, helper){
        helper.delete(component,event);
    }
})