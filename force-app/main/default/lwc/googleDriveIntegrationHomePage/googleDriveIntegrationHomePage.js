import { LightningElement, track } from 'lwc';
import driveIcon from '@salesforce/resourceUrl/driveIcon';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class googleDriveIntegrationHomePage extends LightningElement {
    myCustomIconUrl = driveIcon;

    @track isSidebarExpanded = true;
    @track folderAndFile = [];
    @track createFolderModal = false;
    @track uploadFolderModal = false;
    @track newFolderName = '';
    @track recordsPresent = false; // Change this to true if you have records
    @track path = [{ label: 'Home/', value: 'root' }];
    @track fileName = '';
    @track fileContent;
    @track selectedResource = '';

    get sidebarClass() {
        return `sidebar ${this.isSidebarExpanded ? 'expanded' : 'collapsed'}`;
    }

    // Lifecycle hook
    connectedCallback() {
        this.doInit();
    }

    doInit() {
        // Initialize any data or states here
    }

    handleMenuSelect(event) {
        const selectedValue = event.detail.value;
        if (selectedValue === 'User Details') {
            this.viewUser();
        } else if (selectedValue === 'settings') {
            // Handle settings
        } else if (selectedValue === 'logout') {
            // Handle logout
        }
    }

    toggleSidebar() {
        this.isSidebarExpanded = !this.isSidebarExpanded;
    }

    handleAddSelect(event) {
        const selectedValue = event.detail.value;
        if (selectedValue === 'createFolder') {
            this.createFolderModal = true;
        } else if (selectedValue === 'uploadFolder') {
            this.uploadFolderModal = true;
        }
    }

    doAuth() {
        // Implement authentication logic
    }

    hideCreateFolderModal() {
        this.createFolderModal = false;
        this.newFolderName = ''; // Reset folder name
    }

    createFolder() {
        // Implement folder creation logic here
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Folder created successfully!',
                variant: 'success',
            })
        );
        this.hideCreateFolderModal();
    }

    hideUploadFolderModal() {
        this.uploadFolderModal = false;
        this.fileName = ''; // Reset uploaded file name
    }

    onUpload(event) {
        const file = event.target.files[0];
        if (file) {
            this.fileName = file.name; // Store the file name
        }
    }

    uploadFile() {
        // Implement file upload logic here
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'File uploaded successfully!',
                variant: 'success',
            })
        );
        this.hideUploadFolderModal();
    }

    openFolder(event) {
        // Implement folder opening logic
    }

    previewFile(event) {
        // Implement file preview logic
    }

    downloadFile(event) {
        // Implement file download logic
    }

    deleteFile(event) {
        // Implement file deletion logic
    }

    viewUser() {
        // Implement view user details logic
    }

    handlePath(event) {
        const selectedPath = event.target.dataset.value; // Adjust based on your actual data structure
        // Implement path handling logic (e.g., navigating back)
    }
}

