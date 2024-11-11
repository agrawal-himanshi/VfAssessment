import { LightningElement, track } from 'lwc';
import driveIcon from '@salesforce/resourceUrl/driveIcon';
import getAllAccMailIds from '@salesforce/apex/driveController.getAllAccMailIds';
import revokeGoogleDriveAccount from '@salesforce/apex/driveController.revokeGoogleDriveAccount';
import { NavigationMixin } from 'lightning/navigation';

export default class SettingsPageGoogleDrive extends NavigationMixin(LightningElement) {
    myCustomIconUrl = driveIcon;

    @track ConnectedAccMailIds = [];
    @track email;
    @track isLoading = false;

    connectedCallback() {
        console.log('111---');
        getAllAccMailIds()
        .then(result => {
            this.ConnectedAccMailIds = result;
            console.log(result);
        }) 
        .catch(error => {
            console.log(error);
        });
    }

    handleMenuSelect(event) {
        const selectedValue = event.detail.value;
        console.log(selectedValue);
         if (selectedValue === 'homePage') {
            window.location.href = 'https://briskmindssoftwaresoluti-6b-dev-ed.develop.my.site.com/driveCommunity/';
        } else if (selectedValue === 'logout') {
            // Handle logout
        }
    }

    handleActionClick(event) {
        const sourceElement = event.target;
        const recordId = sourceElement.dataset.id;
        console.log('Source element:', sourceElement);
        console.log('Record ID:', recordId);
        this.isLoading = true;
        this.revokeAccess(recordId);
    }

    revokeAccess(recordId) {
        revokeGoogleDriveAccount({IdOfRecord: recordId })
        .then(result => {
            console.log(result);
            if (result === 'Success') {
                console.log('Account revoked successfully.');
                getAllAccMailIds()
                .then(result => {
                    this.ConnectedAccMailIds = result;
                    console.log(result);
                    this.isLoading = false;
                }) 
            } 
            else {
                this.isLoading = false;
                console.error(result);
            }
        })
        .catch(error => {
            console.error('Error revoking account:', error);
        });
    }

}
