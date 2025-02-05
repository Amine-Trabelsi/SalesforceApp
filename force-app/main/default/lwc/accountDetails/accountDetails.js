import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

// Define fields to fetch
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import ACCOUNT_NUMBER from '@salesforce/schema/Account.AccountNumber';

export default class AccountDetails extends LightningElement {
    @api recordId; // Auto-detects the Account record ID

    accountName;
    accountNumber;

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME, ACCOUNT_NUMBER] })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountName = data.fields.Name.value;
            this.accountNumber = data.fields.AccountNumber ? data.fields.AccountNumber.value : 'N/A';
        } else if (error) {
            console.error('Error fetching account data:', error);
        }
    }
}