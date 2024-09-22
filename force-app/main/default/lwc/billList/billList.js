import { LightningElement, wire, track } from 'lwc';
import getBills from '@salesforce/apex/BillController.getBills';
import { NavigationMixin } from 'lightning/navigation';

export default class BillList extends NavigationMixin(LightningElement) {
    @track bills;
    @track error;
    searchKey = '';
    delayTimeout;

    @wire(getBills, { searchKey: '$searchKey' })
    wiredBills({ error, data }) {
        if (data) {
            this.bills = data;
            this.error = undefined;
        } else if (error) {
            this.bills = undefined;
            this.error = error;
        }
    }

    handleSearch(event) {
        // Debouncing technique
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        // Introduce a slight delay
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, 300);
    }


    navigateToAccount(event) {
        // Get the Account Id from the clicked element
        const accountId = event.target.closest('lightning-layout-item').dataset.accountId;

        // Navigate to the Account record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}
