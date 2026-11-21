import { LightningElement, wire } from 'lwc';
import getSnapshot from '@salesforce/apex/HealthAccessDashboardController.getSnapshot';

export default class HealthAccessDashboard extends LightningElement {

    snapshot;
    error;
    stockRows = [];
    visitRows = [];

    stockColumns = [
        { label: 'Facility', fieldName: 'facility' },
        { label: 'Medicine', fieldName: 'medicine' },
        { label: 'Quantity', fieldName: 'qty', type: 'number' },
        { label: 'Status', fieldName: 'status' }
    ];

    visitColumns = [
        { label: 'Prep', fieldName: 'prep' },
        { label: 'Citizen', fieldName: 'citizen' },
        { label: 'Facility', fieldName: 'facility' },
        { label: 'Service', fieldName: 'service' },
        { label: 'Date', fieldName: 'visitDate', type: 'date-local' },
        { label: 'Status', fieldName: 'status' }
    ];

    @wire(getSnapshot)
    wiredSnapshot({ data, error }) {
        if (data) {
            this.snapshot = data;

            this.stockRows = (data.attentionStock || []).map(r => ({
                id: r.Id,
                facility: r.Healthcare_Facility__r?.Name,
                medicine: r.Name,
                qty: r.Quantity_On_Hand__c,
                status: r.Stock_Status__c
            }));

            this.visitRows = (data.nextVisits || []).map(r => ({
                id: r.Id,
                prep: r.Name,
                citizen: r.Citizen_Name__c,
                facility: r.Healthcare_Facility__r?.Name,
                service: r.Medical_Service__r?.Name,
                visitDate: r.Planned_Visit_Date__c,
                status: r.Prep_Status__c
            }));

            this.error = undefined;

        } else if (error) {
            this.error = error;
            this.snapshot = undefined;
        }
    }
}