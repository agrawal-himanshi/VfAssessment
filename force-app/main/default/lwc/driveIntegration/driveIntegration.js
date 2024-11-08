import { LightningElement, track } from 'lwc';
import driveIcon from '@salesforce/resourceUrl/driveIcon';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAuthURL from '@salesforce/apex/driveController.createAuthURL';
import getAccessToken from '@salesforce/apex/driveController.getAccessToken';
import createAuthURLForOtherAcc from '@salesforce/apex/driveController.createAuthURLForOtherAcc';
import getFilesANdFolders from '@salesforce/apex/driveController.getFilesANdFolders';
import deleteFileOrFolder from '@salesforce/apex/driveController.deleteFileOrFolder';
import createFolderInGoogleDrive from '@salesforce/apex/driveController.createFolderInGoogleDrive';
import getAllAccMailIds from '@salesforce/apex/driveController.getAllAccMailIds';
import uploadFile from '@salesforce/apex/driveController.uploadFile';

export default class DriveIntegration extends LightningElement {
    myCustomIconUrl = driveIcon;

    @track isLoading = false;
    @track username;
    @track email;
    @track accesstoken;
    @track type;
    @track folderAndFileLength;
    @track isSidebarExpanded = true;
    @track ConnectedAccMailIds = [];
    @track folderAndFile = [];
    @track createFolderModal = false;
    @track uploadFolderModal = false;
    @track viewUserModal = false;
    @track newFolderName = '';
    @track recordsPresent = false;
    @track path = [{ label: 'Home', value: 'root' }];
    @track fileName = '';
    @track fileContent;
    @track folderName;

    get sidebarClass() {
        return `sidebar ${this.isSidebarExpanded ? 'expanded' : 'collapsed'}`;
    }

    connectedCallback() {
        console.log('111---');
        this.doAuth();
    }

    doAuth() {
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
                    this.isLoading=false;
                    this.recordsPresent=true;
                    getAllAccMailIds()
                    .then(result =>{
                        this.ConnectedAccMailIds = result;
                    })
                    this.showCurrentFoldersAndFiles();  
                }
            })      
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', error.body.message, 'error');
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
                this.recordsPresent=true;
                getAllAccMailIds()
                .then(result =>{
                    this.ConnectedAccMailIds = result;
                })
                this.showCurrentFoldersAndFiles();  
            })            
            .catch(error => {
                this.isLoading=false;
                this.showToast('Error', error.body.message, 'error');
            });
        }
    }

    doAuthOtherAccount(){
        this.isLoading=true;
        createAuthURLForOtherAcc()
        .then(result=>{
            window.location.href = result;
            this.isLoading=false;
            getAccessToken({code: authcode})
            .then(result => {
                this.email = result.email;  
                this.username = result.username;
                console.log(this.email);
                this.isLoading=false;
                this.recordsPresent=true;
                getAllAccMailIds()
                .then(result =>{
                    this.ConnectedAccMailIds = result;
                })
                this.showCurrentFoldersAndFiles();  
            })            
            .catch(error => {
                this.isLoading=false;
                this.showToast('Error', error.body.message, 'error');
            });
        })
        .catch(error => {
            this.isLoading = false;
            this.showToast('Error', error.body.message, 'error');
        });
    }

    handleMenuSelect(event) {
        const selectedValue = event.detail.value;
        if (selectedValue === 'User Details') {
            this.viewUserModal= true;
        } else if (selectedValue === 'settings') {
            // Handle settings
        } else if (selectedValue === 'logout') {
            // Handle logout
        }
    }

    toggleSidebar() {
        this.isSidebarExpanded = !this.isSidebarExpanded;
    }

    handleEmailClick(event) {
        const previouslySelected = this.template.querySelector('.selected-email');
        if (previouslySelected) {
            previouslySelected.classList.remove('selected-email');
        }
        const clickedEmail = event.target;
        clickedEmail.classList.add('selected-email');
        this.email = event.target.dataset.email; 
        console.log(this.email);        
        this.showCurrentFoldersAndFiles();
    }
    
    showCurrentFoldersAndFiles(){
        this.isLoading=true;
        let currentFolder = this.path[this.path.length-1].value;
        console.log(this.email);
        getFilesANdFolders({accessToken : '', currentFolder : currentFolder, isNew : false, email:this.email})
        .then(result=>{
            if(result.length > 0){
                if(result[0].redirectUri){
                    window.location.href = result[0].redirectUri;
                }
                this.folderAndFile = result.map(record => {
                    console.log(record.fileType);
                    if (record.fileType === 'folder') {
                        record.isFolderfromhere = true;
                    } else {
                        record.isFolderfromhere = false;
                    }
                    console.log(record.isFolderfromhere);
                    let iconNameFromMethod;
                    iconNameFromMethod = this.getIconNameForMimeType(record.fileType);
                    console.log(iconNameFromMethod);
                    return {
                        ...record,
                        isFolder: Boolean(record.isFolderfromhere),
                        iconName: iconNameFromMethod,
                    };
                });
                this.folderAndFileLength = this.folderAndFile?.length ?? 0;
                console.log('total no of object-->',this.folderAndFileLength);        
            }
            console.log(this.email);
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading=false
            this.showToast('Error', error.body.message, 'error');
        });
    }

    handleAddSelect(event) {
        const selectedValue = event.detail.value;
        if (selectedValue === 'createFolder') {
            this.createFolderModal = true;
        } else if (selectedValue === 'uploadFolder') {
            this.uploadFolderModal = true;
        }
    }

    hideCreateFolderModal() {
        this.createFolderModal = false;
        this.newFolderName = ''; 
    }

    handleFolderNameChange(event) {
        this.newFolderName = event.detail.value;
        console.log(this.newFolderName); 
    }

    createFolder() {
        this.isLoading = true;
        let currentFolderFromUi = this.path[this.path.length-1].value;
        console.log(currentFolderFromUi);
        console.log(this.newFolderName); 
        createFolderInGoogleDrive({accessToken : '', fileName : this.newFolderName, current : currentFolderFromUi, email:this.email})
            .then(result=>{
                this.isLoading = false;
                this.showCurrentFoldersAndFiles();
                this.hideCreateFolderModal();
            })
        .catch(error => {
            this.isLoading = false;
            this.showToast('Error', error.body.message, 'error');
        });
    }

    hideUploadFolderModal() {
        this.uploadFolderModal = false;
        this.fileName = ''; 
        this.fileContent = '';
    }

    hideUserModal(){
        this.viewUserModal= false;
    }

    onUpload(event) {
        const file = event.target.files[0];
        console.log(file);
        if (file) {
            this.fileName = file.name; 
            const reader = new FileReader();
            reader.onload = () => {
                this.fileContent = reader.result.split(',')[1];
            };
            reader.readAsDataURL(file);
            this.type = file.type;
        }
        console.log(this.fileName);
        console.log(this.type);
    }

    uploadFile() {
        const currentFolder = this.path[this.path.length - 1].value;
        console.log(this.type);
        if (this.fileContent) {
            this.isLoading = true;
            uploadFile({ accessToken : '', mimeType: this.type, current : currentFolder, fileName : this.fileName,  fileContent : this.fileContent, email: this.email })
            .then(result => {
                console.log('Hi');
                console.log(result);
                //this.showToast('Success', 'File Uploaded Successfully', 'success');
                this.showCurrentFoldersAndFiles();
                this.fileName = '';
                this.fileContent = null;
                this.type = '';
                this.isLoading = false;   
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
            this.folderAndFile = result.map(record => {
                console.log(record.fileType);
                if (record.fileType === 'folder') {
                    record.isFolderfromhere = true;
                } else {
                    record.isFolderfromhere = false;
                }
                console.log(record.isFolderfromhere);
                let iconNameFromMethod;
                iconNameFromMethod = this.getIconNameForMimeType(record.fileType);
                console.log(iconNameFromMethod);
                return {
                    ...record,
                    isFolder: Boolean(record.isFolderfromhere),
                    iconName: iconNameFromMethod,
                };
            });
            this.folderAndFileLength = this.folderAndFile?.length ?? 0;
            console.log('total no of object-->',this.folderAndFileLength);        
            this.isLoading = false;
            let path = this.path;
            path.push({ label : folderName, value : currentFolder });
            this.path = path;
        })
        .catch(error => {
            this.isLoading=false
            this.showToast('Error', error.body.message, 'error');
        });
    }

    deleteFile(event) {
        // console.log(event.currentTarget);
        console.log('in delete file');
        this.isLoading = true;
        let folderId = event.currentTarget.dataset.id;
        console.log(folderId);
        let type = event.currentTarget.dataset.type;
        console.log(type);
        let currentFolder = this.path[this.path.length - 1].value;
        let fileType = 'files';
        if(type === 'true'){
            fileType = 'folders'; 
        }
        deleteFileOrFolder({accessToken :'', current : currentFolder, fileId : folderId, type : fileType , email : this.email})
        .then(result => {
            console.log(result);
            if(result == true){
                this.showToast('Success', 'Deletion Successful', 'success');
                this.isLoading = false;
                this.showCurrentFoldersAndFiles();
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.showToast('Error', error.body.message, 'error');
        });
    }

    // handlePath(event) {
    //     this.loadSpinner = true; 
    //     const folderPath = event.target.name;
    //     const index = this.path.findIndex(item => item.value === folderPath);
    //     if (index === -1 || index === this.path.length - 1) {
    //         this.loadSpinner = false;
            
    //         return;
    //     }
    //     getFileANdFolders({accessToken : '', currentFolder : folderPath, isNew : false})
    //     .then(result=>{
    //         this.folderAndFile = result;
    //         if(this.folderAndFile.length > 0){
    //             this.isEmptyFolderAndFile = false;
    //         }
    //         else{
    //             this.isEmptyFolderAndFile = true;
    //         }
    //         const path = this.path.slice(0, index + 1);
    //         this.path = path;
    //         this.loadSpinner = false;
    //     })
    //     .catch(error => {
    //         this.loadSpinner = false
    //         this.showToast('Error', error.body.message, 'error');
    //     });
    // }

    handlePath(event) {
        console.log(event);
        const selectedPath = event.target.dataset.value;
    }

    getIconNameForMimeType(mimeType) {
        switch (mimeType) {
            case 'application/pdf':
                return 'doctype:pdf';
            case 'image/jpeg':
            case 'image/jpg':
            case 'image/png':
                return 'doctype:image';
            case 'text/plain':
                return 'doctype:txt';
            case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
                return 'doctype:word';
            case 'application/vnd.google-apps.spreadsheet':
                return 'doctype:excel';
            case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
                return 'doctype:ppt';
            case 'folder':
                return 'doctype:folder';
            default:
                return 'doctype:unknown';
        }
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant,
        });
        this.dispatchEvent(event);
    }

}
