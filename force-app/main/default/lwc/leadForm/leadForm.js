import { LightningElement } from 'lwc';
import createLeadWithCampaignMember from '@salesforce/apex/LeadController.createLeadWithCampaignMember';

export default class LeadForm extends LightningElement {
    firstName = '';
    lastName = '';
    email = '';
    phone = '';
    company = '';
    message = '';

    handleChange(event) {
        const field = event.target.dataset.id;
        if (field === 'firstName') {
            this.firstName = event.target.value;
        } else if (field === 'lastName') {
            this.lastName = event.target.value;
        } else if (field === 'email') {
            this.email = event.target.value;
        } else if (field === 'phone') {
            this.phone = event.target.value;
        } else if (field === 'company') {
            this.company = event.target.value;
        }
    }

    handleSubmit() {
        createLeadWithCampaignMember({
            firstName: this.firstName,
            lastName: this.lastName,
            email: this.email,
            phone: this.phone,
            company: this.company,
            
        })
        .then(result => {
            this.message = 'Lead and Campaign Member created successfully with Campaign Member Id:' + result;
            
        })
        .catch(error => {
            this.message = 'Error: ' + error.body.message;
        });
    }
}
