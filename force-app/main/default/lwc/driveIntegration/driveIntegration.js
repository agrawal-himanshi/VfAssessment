import { LightningElement, track } from 'lwc';
import driveIcon from '@salesforce/resourceUrl/driveIcon';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createAuthURL from '@salesforce/apex/driveController.createAuthURL';
import getAccessToken from '@salesforce/apex/driveController.getAccessToken';
import createAuthURLForOtherAcc from '@salesforce/apex/driveController.createAuthURLForOtherAcc';
import getFilesANdFolders from '@salesforce/apex/driveController.getFilesANdFolders';
import deleteFileOrFolder from '@salesforce/apex/driveController.deleteFileOrFolder';
import createFolderInGoogleDrive from '@salesforce/apex/driveController.createFolderInGoogleDrive';
import getAllAccMailIds from '@salesforce/apex/driveController.getAllAccMailIds';
import uploadFile from '@salesforce/apex/driveController.uploadFile';
import userDetails from '@salesforce/apex/driveController.userDetails';
import getTokens from '@salesforce/apex/driveController.getTokens';

export default class DriveIntegration extends NavigationMixin(LightningElement) {
    myCustomIconUrl = driveIcon;

    @track isLoading = false;
    @track username;
    @track email;
    @track fetchedAccessToken;
    @track type;
    @track isSettingsVisible = false;
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
    @track fileNameFromUi = '';
    @track fileContentFromUi;
    @track folderName;
    @track connectedAccountTokens = {}; 

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
                    else if(key == 'haveAccessToken'){
                        this.fetchedAccessToken = jsonResponse[key];
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
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/settings'
                }
            });
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
        getTokens({mailId : this.email})
        .then(result => {
            console.log(result);
            this.fetchedAccessToken = result.Access_Token__c;
            console.log(this.fetchedAccessToken);
            userDetails({accessToken : this.fetchedAccessToken})
            .then(user => {
                console.log(user);
                this.username = user.username;
                this.email = user.email;
                console.log('User details set:', this.username, this.email);
            })
            this.showCurrentFoldersAndFiles();
        })
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
    }

    hideUserModal(){
        this.viewUserModal= false;
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
                //console.log(this.fileContentFromUi);
            };
            reader.readAsDataURL(file);
        }
        console.log(this.fileNameFromUi);
        // console.log(this.fileContentFromUi);
        console.log(this.type);
    }
    
    uploadFile() {
        const currentFolder = this.path[this.path.length - 1].value;
        console.log(currentFolder);
        console.log(this.type);
        console.log(this.fileContentFromUi);
        if (this.fileContentFromUi) {
            this.isLoading = true;
            uploadFile({ accessToken : '', mimeType: this.type, current : currentFolder, fileName : this.fileNameFromUi,  fileContent : this.fileContentFromUi, email: this.email })
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

    handlePath(event) {
        const folderPath = event.target.dataset.value;
        this.isLoading = true; 
        const index = this.path.findIndex(item => item.value === folderPath);
        if (index === -1 || index === this.path.length - 1) {
            this.isLoading = false;
            return;
        }
        getFilesANdFolders({accessToken : '', currentFolder : folderPath, isNew : false, email:this.email})
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
            const path = this.path.slice(0, index + 1);
            this.path = path;
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false
            this.showToast('Error', error.body.message, 'error');
        });
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
