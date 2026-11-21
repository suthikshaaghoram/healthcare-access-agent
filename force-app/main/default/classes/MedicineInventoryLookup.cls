/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : MedicineInventoryLookup
 * Author          : <YourName>
 * Created Date    : Nov 21, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Nov 21, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Nov 21, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public with sharing class MedicineInventoryLookup {
    public class Request {
        @InvocableVariable(label='Facility ID' required=true)
        public String facilityId;

        @InvocableVariable(label='Medicine Name' required=true)
        public String medicineName;
    }

    public class Result {
        @InvocableVariable
        public String stockStatus;

        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Look Up Medicine Stock' description='Checks the sample inventory record for a medicine at a facility.')
    public static List<Result> getMedicineStock(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result result = new Result();

            if (req == null || String.isBlank(req.facilityId) || String.isBlank(req.medicineName)) {
                result.stockStatus = 'Not Checked';
                result.message = 'Enter a facility ID and medicine name to check the sample inventory.';
                results.add(result);
                continue;
            }

            String medicineSearch = '%' + req.medicineName.trim() + '%';

            List<Medicine_Inventory__c> inventory = [SELECT Name, Strength__c, Stock_Status__c, Last_Stock_Check__c, Healthcare_Facility__r.Name FROM Medicine_Inventory__c WHERE Healthcare_Facility__r.Facility_ID__c = :req.facilityId AND Name LIKE :medicineSearch WITH USER_MODE LIMIT 1];

            if (inventory.isEmpty()) {
                result.stockStatus = 'Not Listed';
                result.message = 'No sample inventory record was found for this medicine at the selected facility. ' + 'Please contact the facility to check availability.';
            } else {
                Medicine_Inventory__c medicine = inventory[0];
                result.stockStatus = medicine.Stock_Status__c;
                String lastChecked = medicine.Last_Stock_Check__c == null ? 'not recorded' : medicine.Last_Stock_Check__c.format();
                result.message = medicine.Name + ' ' + medicine.Strength__c +' at ' + medicine.Healthcare_Facility__r.Name +' is listed as ' + medicine.Stock_Status__c +' in the sample inventory. Last checked: ' + lastChecked + '. Please contact the facility to confirm current availability.';
            }

            results.add(result);
        }

        return results;
    }
}