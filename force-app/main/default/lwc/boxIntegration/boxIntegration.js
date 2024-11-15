import { LightningElement, track } from 'lwc';
import boxIconResource from '@salesforce/resourceUrl/boxIconResource';
import createAuthURL from '@salesforce/apex/boxController.createAuthURL';
import getAccessToken from '@salesforce/apex/BoxController.getAccessToken';
// import getAllAccMailIds from '@salesforce/apex/BoxController.getAllAccMailIds';
import getFilesANdFolders from '@salesforce/apex/boxController.getFilesANdFolders';
import userDetails from '@salesforce/apex/boxController.userDetails';
import accessTokenWithRefreshToken from '@salesforce/apex/boxController.accessTokenWithRefreshToken';

export default class BoxIntegration extends LightningElement {
    myCustomIconUrl = boxIconResource;
    lastClickedDiv = null;  

    @track path = [{ label: 'Home', value: 'root' }];
    @track connected = false;
    @track isLoading = false;
    @track email;
    @track username;
    @track recordsPresent;
    @track folderAndFile;
    @track isNotEmpty;
    @track expiresTime;
    @track refreshToken;
    @track fetchedAccessToken;
    @track createFolderModal = false;
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
                    // getAllAccMailIds()
                    // .then(result => {
                    //     this.ConnectedAccMailIds = result;
                    //     if (this.ConnectedAccMailIds.length > 0) {
                    //         this.email = this.ConnectedAccMailIds[0]; 
                    //     }
                    // })
                    // userDetails({accessToken : this.fetchedAccessToken})
                    // .then(user => {
                    //     this.username = user.username;
                    //     this.email = user.email;
                    //     console.log('User details set:', this.username, this.email);
                    // })
                    // .catch(error => {
                    //     console.error('Error retrieving user details:', error);
                    // });
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
                this.connected = true; 
                this.recordsPresent=true;
                this.showCurrentFoldersAndFiles();
                // // getAllAccMailIds()
                // // .then(result => {
                // //     this.ConnectedAccMailIds = result;
                // // })
                // // userDetails({accessToken : this.fetchedAccessToken})
                // // .then(user => {
                // //     this.username = user.username;
                // //     this.email = user.email;
                // //     console.log('User details set:', this.username, this.email);
                // // })
                // .catch(error => {
                //     console.error('Error retrieving user details:', error);
                // });
            })
            .catch(error => {
                this.isLoading=false;
                this.showToast('Error', error.body.message, 'error');
            });
        }
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
                    console.log('Access token response:', result);
                }
            })
        }
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
            this.showToast('Error', error.body.message, 'error');
        });
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
            this.getRelatedFiles(folderId, currentFolder);
            console.log('all files');
        }
        else if(folderId == 'photos-section'){
            this.getRelatedFiles(folderId, currentFolder);
            console.log('all photos');
        }
        else if(folderId == 'videos-section'){
            this.getRelatedFiles(folderId, currentFolder);
            console.log('all videos');
        }
        else if(folderId == 'documents-section'){
            this.getRelatedFiles(folderId, currentFolder);
            console.log('all documents');
        }
        else{
            this.showCurrentFoldersAndFiles();
        }
    }

    getRelatedFiles(folderId, currentFolder) {
        const allFiles = getFilesANdFolders({accessToken : '', currentFolder : currentFolder, isNew : false, email:this.email})
        // let result =[];
        // allFiles.forEach(file => {
        //     if (file.type == folderId) {
        //         result.push(file);
        //     }
        // });
        // this.folderAndFile = result;
    }

    createFolderInBox(){
        this.createFolderModal = true;
    }

}