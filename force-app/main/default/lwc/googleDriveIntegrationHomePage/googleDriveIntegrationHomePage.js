import { LightningElement, track } from 'lwc';

export default class GoogleDriveIntegrationHomePage extends LightningElement {
    @track isSidebarExpanded = true;
    @track folderAndFile = [];
    @track createFolderModal = false;
    @track uploadFolderModal = false;
    @track newFolderName = '';
    @track recordsPresent = false;
    @track path = [{ label: 'Home/', value: 'root' }];
    @track fileName = '';
    @track fileContent;
    @track userView = false;
    @track selectedResource = '';
    @track resources = [
        { label: 'Google Drive', value: 'Google Drive', icon: 'path/to/googleDriveIcon', disabled: false },
        { label: 'Dropbox', value: 'Dropbox', icon: 'path/to/dropboxIcon', disabled: true },
        { label: 'Box', value: 'Box', icon: 'path/to/boxIcon', disabled: true },
        { label: 'Salesforce', value: 'Salesforce', icon: 'path/to/salesforceIcon', disabled: true }
    ];

    get sidebarClass() {
        return `sidebar ${this.isSidebarExpanded ? 'expanded' : 'collapsed'}`;
    }

    get sidebarIcon() {
        return this.isSidebarExpanded ? 'utility:chevrondown' : 'utility:chevronright';
    }

    // Lifecycle hook
    connectedCallback() {
        this.doInit();
    }

    doInit() {
    }

    handleMenuSelect(event) {
    }

    toggleSidebar() {
        this.isSidebarExpanded = !this.isSidebarExpanded;
    }

    selectResource(event) {
        this.selectedResource = event.currentTarget.dataset.selected;
    }

    handlePath(event) {
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
    }

    hideCreateFolderModal() {
        this.createFolderModal = false;
    }

    createFolder() {
        this.hideCreateFolderModal();
    }

    hideUploadFolderModal() {
        this.uploadFolderModal = false;
    }

    onUpload(event) {
        const file = event.target.files[0];
        if (file) {
            this.fileName = file.name;
        }
    }

    uploadFile() {
        this.hideUploadFolderModal();
    }

    openFolder(event) {
    }

    previewFile(event) {
    }

    downloadFile(event) {
    }

    deleteFile(event) {
    }

    viewUser() {
    }
}
