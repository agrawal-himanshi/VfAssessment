import { LightningElement, track } from 'lwc';
import boxIconResource from '@salesforce/resourceUrl/boxIconResource';
import createAuthURL from '@salesforce/apex/boxController.createAuthURL';
import getAccessToken from '@salesforce/apex/BoxController.getAccessToken';
import getFilesANdFolders from '@salesforce/apex/boxController.getFilesANdFolders';
import userDetails from '@salesforce/apex/boxController.userDetails';
import createFolderInBox from '@salesforce/apex/boxController.createFolderInBox';
import uploadFileBox from '@salesforce/apex/boxController.uploadFileBox';
import deleteFileOrFolder from '@salesforce/apex/BoxController.deleteFileOrFolder';
import previewFile from '@salesforce/apex/BoxController.previewFile';
import downloadFile from '@salesforce/apex/BoxController.downloadFile';
import accessTokenWithRefreshToken from '@salesforce/apex/boxController.accessTokenWithRefreshToken';
import createAuthURLForOtherAcc from '@salesforce/apex/boxController.createAuthURLForOtherAcc';
//import getAllAccMailIds from '@salesforce/apex/boxController.getAllAccMailIds';

export default class BoxIntegration extends LightningElement {
    myCustomIconUrl = boxIconResource;
    lastClickedDiv = null;  

    @track path = [{ label: 'Home', value: 'root' }];
    @track connected = false;
    @track isLoading = false;
    @track email;
    @track username;
    @track profileImage;
    @track viewUser = false;
    @track recordsPresent;
    @track folderAndFile;
    @track isNotEmpty;
    @track expiresTime;
    @track refreshToken;
    @track fetchedAccessToken;
    @track createFolderModal = false;
    @track uploadFileModal = false;
    @track newFolderName = '';
    @track fileNameFromUi = '';
    @track fileContentFromUi;
    @track folderName;
    clientId = 'mym7rb5cn43lnz9tnzd0gl6l65w0da9l';
    clientSecret = 'uzuMt3CPI2e2QarxKwy8UZwdBzW0h5nd';

    connectedCallback() {
        console.log('111---');
        this.handleConnect();
    }

    handleConnect() {
        this.isLoading = true;
        console.log('221---');
        const urlParams = new URLSearchParams(window.location.search);
        const authcode = urlParams.get('code');
        console.log(authcode);
        if (!authcode) {
            console.log('enter');
            createAuthURL()
            .then(result=>{
                let jsonResponse = JSON.parse(result);
                let redirect = false;
                let uri = '';
                for(let key in jsonResponse){
                    if(key =='isRedirect'){
                        redirect=jsonResponse[key];
                    }else if(key == 'authUri'){
                        uri = jsonResponse[key];
                    }
                    else if(key == 'haveAccessToken'){
                        this.fetchedAccessToken = jsonResponse[key];
                    }
                    else if(key == 'expiresIn'){
                        this.expiresTime = jsonResponse[key];
                    }
                    else if(key == 'refreshtoken'){
                        this.refreshToken = jsonResponse[key];
                    }
                    else{
                        this.email=jsonResponse[key];
                    }
                }
                if(redirect){
                    console.log(redirect);
                    window.location.href= uri; 
                }
                else{
                    console.log('entered to get files');
                    console.log(this.email);
                    console.log(this.fetchedAccessToken);
                    this.isLoading=false;
                    this.connected = true; 
                    this.recordsPresent=true;
                    this.showCurrentFoldersAndFiles();
                    getAllAccMailIds()
                    .then(result => {
                        this.ConnectedAccMailIds = result;
                        if (this.ConnectedAccMailIds.length > 0) {
                            this.email = this.ConnectedAccMailIds[0]; 
                        }
                    })
                    userDetails({accessToken : this.fetchedAccessToken})
                    .then(user => {
                        this.username = user.username;
                        this.email = user.email;
                        console.log('User details set:', this.username, this.email);
                    })
                    .catch(error => {
                        console.error('Error retrieving user details:', error);
                    });
                }
            })      
            .catch(error => {
                this.isLoading = false;
                //this.showToast('Error', error.body.message, 'error');
            });
        }else {
            console.log('222---');
            console.log(authcode);
            getAccessToken({code: authcode})
            .then(result => {
                this.email = result.email;  
                this.username = result.username;
                console.log(this.email);
                console.log(this.username);
                this.isLoading=false;
                this.connected = true; 
                this.recordsPresent=true;
                this.showCurrentFoldersAndFiles();
                getAllAccMailIds()
                .then(result => {
                    this.ConnectedAccMailIds = result;
                })
                userDetails({accessToken : this.fetchedAccessToken})
                .then(user => {
                    this.username = user.username;
                    this.email = user.email;
                    console.log('User details set:', this.username, this.email);
                })
                .catch(error => {
                    console.error('Error retrieving user details:', error);
                });
            })
            .catch(error => {
                this.isLoading=false;
                //this.showToast('Error', error.body.message, 'error');
            });
        }
    }

    doAuthOtherAcc(){
        this.isLoading=true;
        console.log('hiii');
        createAuthURLForOtherAcc()
        .then(result=>{
            window.location.href = result;
            this.isLoading=false;
            // getAccessToken({code: authcode})
            // .then(result => {
            //     this.email = result.email;  
            //     this.username = result.username;
            //     console.log(this.email);
            //     this.isLoading=false;
            //     this.recordsPresent=true;
            //     // getAllAccMailIds()
            //     // .then(result =>{
            //     //     this.ConnectedAccMailIds = result;
            //     // })
            //     this.showCurrentFoldersAndFiles();  
            // })            
            // .catch(error => {
            //     this.isLoading=false;
            //     //this.showToast('Error', error.body.message, 'error');
            // });
        })
        .catch(error => {
            this.isLoading = false;
            //this.showToast('Error', error.body.message, 'error');
        });
    }

    showCurrentFoldersAndFiles(){
        this.isLoading=true;
        let currentFolder = this.path[this.path.length-1].value;
        console.log(this.email);
        console.log(this.refreshToken);
        console.log(this.expiresTime);
        let currentTime = new Date().toISOString();
        console.log(currentTime);
        if (currentTime > this.expiresTime) {
            console.log('go to take accessToken from Refresh Token');
            accessTokenWithRefreshToken({ 
                clientId: this.clientId,
                clientSecret: this.clientSecret,
                refreshToken: this.refreshToken,
                email: this.email
            })
            .then(result => {
                if (result.redirectUrl) {
                    window.location.href = result.redirectUrl;
                } else {
                    console.log('in else');
                    console.log('Access token response:', result);
                    getFilesANdFolders({accessToken : '', currentFolder : currentFolder, isNew : false, email:this.email})
                    .then(result=>{
                        console.log(result);
                        if(result.length > 0){
                            if(result[0].redirectUri){
                                window.location.href = result[0].redirectUri;
                            }
                            this.folderAndFile = result;
                            console.log('total no of object-->',result.length);  
                            this.isNotEmpty = true;      
                        }
                        else{
                            this.isNotEmpty = false;
                        }
                        console.log(this.email);
                        this.isLoading = false;
                    })
                    .catch(error => {
                        this.isLoading=false
                        //this.showToast('Error', error.body.message, 'error');
                    });
                }
            })
        }
        else {
            console.log('in main else');
            getFilesANdFolders({accessToken : '', currentFolder : currentFolder, isNew : false, email:this.email})
            .then(result=>{
                console.log(result);
                if(result.length > 0){
                    if(result[0].redirectUri){
                        window.location.href = result[0].redirectUri;
                    }
                    this.folderAndFile = result;
                    console.log('total no of object-->',result.length);  
                    this.isNotEmpty = true;      
                }
                else{
                    this.isNotEmpty = false;
                }
                console.log(this.email);
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading=false
                //this.showToast('Error', error.body.message, 'error');
            });
        }

        }

    handleDivClick(event) {
        let currentFolder = this.path[this.path.length-1].value;
        const div = event.currentTarget;
        if (this.lastClickedDiv && this.lastClickedDiv !== div) {
            this.lastClickedDiv.classList.remove('highlighted');
        }
        div.classList.toggle('highlighted');
        this.lastClickedDiv = div;
        console.log("Div clicked, performing action...");
        let folderId = event.currentTarget.dataset.id;
        console.log(folderId);
        if(folderId == 'files-section'){
            this.showCurrentFoldersAndFiles();
            console.log('all folders/files');
        }
        else if(folderId == 'photos-section'){
            getFilesANdFolders({accessToken : '', currentFolder : currentFolder, isNew : false, email:this.email})
            .then(allFiles=>{
                console.log(allFiles);
                let result =[];
                for(let i=0;i<allFiles.length;i++){
                    if(allFiles[i].type == "doctype:image"){
                        result.push(allFiles[i]);
                    }
                }
                console.log(result);
                if(result.length > 0){
                    this.isNotEmpty = true; 
                    this.folderAndFile = result;     
                }
                else{
                    this.isNotEmpty = false;
                }
            })
            console.log('all photos');
        }
        else if(folderId == 'videos-section'){
            getFilesANdFolders({accessToken : '', currentFolder : currentFolder, isNew : false, email:this.email})
            .then(allFiles=>{
                console.log(allFiles);
                let result =[];
                for(let i=0;i<allFiles.length;i++){
                    if(allFiles[i].type == "doctype:video"){
                        result.push(allFiles[i]);
                    }
                }
                console.log(result);
                if(result.length > 0){
                    this.isNotEmpty = true; 
                    this.folderAndFile = result;     
                }
                else{
                    this.isNotEmpty = false;
                }
            })
            console.log('all videos');
        }
        else if(folderId == 'docs-section'){
            getFilesANdFolders({accessToken : '', currentFolder : currentFolder, isNew : false, email:this.email})
            .then(allFiles=>{
                console.log(allFiles);
                let result =[];
                for(let i=0;i<allFiles.length;i++){
                    console.log(allFiles[i].type);
                    if(allFiles[i].type == "doctype:pdf" || allFiles[i].type == "doctype:doc" || allFiles[i].type == "doctype:docx" || allFiles[i].type == "doctype:ppt" || allFiles[i].type == "doctype:pptx"|| allFiles[i].type == "doctype:txt"|| allFiles[i].type == "doctype:csv"|| allFiles[i].type == "doctype:html"||  allFiles[i].type == "doctype:excel"){        
                        result.push(allFiles[i]);
                    }
                }
                console.log(result);
                if(result.length > 0){
                    this.isNotEmpty = true; 
                    this.folderAndFile = result;     
                }
                else{
                    this.isNotEmpty = false;
                }
            })
            console.log('all documents');
        }
        else{
            this.showCurrentFoldersAndFiles();
        }
    }

    viewUserDetails(){
        if(this.viewUser){
            this.viewUser = false;
            this.togglePointerEvents(false); // Enable pointer events when modal is closed
        }
        else{
            this.viewUser = true;
            this.togglePointerEvents(true); // Disable pointer events when modal is open
        }
    }

    // hideviewUser(){
    //     this.viewUser = false;
    //     this.togglePointerEvents(false); // Enable pointer events when modal is closed
    // }

    // dowload a file
    fileDownload(event) {
        console.log('download link');
        let folderId = event.currentTarget.dataset.id;    
        console.log(folderId);  
        downloadFile({accessToken : '', fileId : folderId, email:this.email})
        .then(result => {
            const link = document.createElement('a');
            link.href = result;
            link.target = '_self';
            link.click();
        })
        .catch(error => {
            this.isLoading = false;
            // this.showToast('Error', error.body.message, 'error');
        });
    }

    // preview a file 
    filePreview(event) {
        console.log('preview link');
        let folderId = event.currentTarget.dataset.id;
        console.log(folderId);
        previewFile({accessToken : '', fileId : folderId, email:this.email})
        .then(result => {
                const link = document.createElement('a');
                link.href = result;
                link.target = '_blank';
                link.click();
            })
        .catch(error => {
            this.isLoading = false;
            // this.showToast('Error', error.body.message, 'error');
        });
    }

    createFolderInBox(){
        this.createFolderModal = true;
        this.togglePointerEvents(true); // Disable pointer events when modal is open
    }

    uploadFileToBox(){
        this.uploadFileModal = true;
        this.togglePointerEvents(true); // Disable pointer events when modal is open
    }

    hideCreateFolderModal() {
        this.createFolderModal = false;
        this.newFolderName = ''; 
        this.togglePointerEvents(false); // Enable pointer events when modal is closed
    }

    handleFolderNameChange(event) {
        this.newFolderName = event.detail.value;
        console.log(this.newFolderName); 
    }

    togglePointerEvents(disable) {
        const elementsToDisable = this.template.querySelectorAll('.left-sidebar, .box, .breadcrum, .btns, .table');
        console.log(elementsToDisable);
        console.log(disable);
        elementsToDisable.forEach(element => {
            if (disable) {
                element.classList.add('no-pointer-events');
            } else {
                element.classList.remove('no-pointer-events');
            }
        });
    }

    get isCreateDisabled() {
        if(this.newFolderName ==''){
            return true;
        }
        else{
            return false;
        }
    }


    createFolder() {
        this.isLoading = true;
        let currentFolderFromUi = this.path[this.path.length-1].value;
        console.log(currentFolderFromUi);
        console.log(this.newFolderName); 
        createFolderInBox({accessToken : '', fileName : this.newFolderName, current : currentFolderFromUi, email:this.email})
            .then(result=>{
                this.isLoading = false;
                this.showCurrentFoldersAndFiles();
                this.hideCreateFolderModal();
            })
        .catch(error => {
            this.isLoading = false;
            // this.showToast('Error', error.body.message, 'error');
        });
    }

    hideUploadFolderModal(){
        this.uploadFileModal = false;
        this.togglePointerEvents(false); // Enable pointer events when modal is closed
    }

    onUpload(event) {
        const file = event.target.files[0];
        console.log(file);
        if (file) {
            this.fileNameFromUi = file.name; 
            this.type = file.type;
            const reader = new FileReader();
            reader.onload = () => {
                this.fileContentFromUi = reader.result.split(',')[1];
                console.log(this.fileContentFromUi);
            };
            reader.readAsDataURL(file);
        }
        console.log(this.fileNameFromUi);
        console.log(this.type);
    }
    
    uploadFile() {
        const currentFolder = this.path[this.path.length - 1].value;
        console.log(currentFolder);
        console.log(this.type);
        console.log(this.fileContentFromUi);
        if (this.fileContentFromUi) {
            this.isLoading = true;
            uploadFileBox({ accessToken : '', mimeType: this.type, current : currentFolder, fileName : this.fileNameFromUi,  fileContent : this.fileContentFromUi, email: this.email })
            .then(result => {
                console.log('Hi');
                console.log(result);
                //this.showToast('Success', 'File Uploaded Successfully', 'success');
                this.fileNameFromUi = '';
                this.fileContentFromUi = null;
                this.type = '';
                this.isLoading = false; 
                this.showCurrentFoldersAndFiles();  
                this.hideUploadFolderModal();            
            })
            .catch(error => {
                this.isLoading=false;
                //this.showToast('Error', error.body.message, 'error');
            });
        } else {
            console.log('error');
            //this.showToast('Warning','Please select a file to upload.','warning');
        }
    }

    openFolder(event) {
        this.isLoading = true;
        console.log(event);
        let currentFolder = event.currentTarget.dataset.id;
        console.log(currentFolder);
        let folderName = event.currentTarget.title;
        console.log(folderName);
        getFilesANdFolders({accessToken : '', currentFolder : currentFolder, isNew : false, email:this.email})
        .then(result=>{
            console.log(result);
            if(result.length > 0){
                this.isNotEmpty = true; 
                this.folderAndFile = result;     
            }
            else{
                this.isNotEmpty = false;
            }
            this.isLoading = false;
            let path = this.path;
            path.push({ label : folderName, value : currentFolder });
            this.path = path;
        })
        .catch(error => {
            this.isLoading=false
            //this.showToast('Error', error.body.message, 'error');
        });
    }

    // delete file
    deleteFile(event) {
        this.isLoading = true;
        let folderId = event.currentTarget.dataset.id;
        console.log('id: ' + folderId);
        let type = event.currentTarget.dataset.type;
        console.log(type);        
        let currentFolder = this.path[this.path.length - 1].value;
        console.log(currentFolder);
        let fileType = 'files';
        if(type === 'doctype:folder'){
            fileType = 'folders'; 
        }
        console.log(fileType);
        deleteFileOrFolder({accessToken :'', current : currentFolder, fileId : folderId, type : fileType, email:this.email})
        .then(result => {
            console.log(result);
            if(result === true){
                // this.showToast('Success', 'Deletion Successful', 'success');
                this.showCurrentFoldersAndFiles();  
            }
        })
        .catch(error => {
            this.isLoading = false;
            // this.showToast('Error', error.body.message, 'error');
        });
    }

    handlePath(event) {
        const folderPath = event.target.dataset.value;
        console.log(folderPath);
        this.isLoading = true; 
        const index = this.path.findIndex(item => item.value === folderPath);
        if (index === -1 || index === this.path.length - 1) {
            this.isLoading = false;
            return;
        }
        getFilesANdFolders({accessToken : '', currentFolder : folderPath, isNew : false, email:this.email})
        .then(result=>{
            console.log(result);
            if(result.length > 0){
                this.isNotEmpty = true; 
                this.folderAndFile = result;     
            }
            else{
                this.isNotEmpty = false;
            }
            this.isLoading = false;
            const path = this.path.slice(0, index + 1);
            this.path = path;
        })
        .catch(error => {
            this.isLoading=false
            //this.showToast('Error', error.body.message, 'error');
        });
    }


}