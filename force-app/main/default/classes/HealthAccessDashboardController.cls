/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : HealthAccessDashboardController
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


public with sharing class HealthAccessDashboardController {

    public class Snapshot {
        @AuraEnabled public Integer facilityCount;
        @AuraEnabled public Integer lowStockCount;
        @AuraEnabled public Integer outOfStockCount;
        @AuraEnabled public Integer upcomingVisits;
        @AuraEnabled public List<Medicine_Inventory__c> attentionStock;
        @AuraEnabled public List<Visit_Preparation__c> nextVisits;
    }

    @AuraEnabled(cacheable=true)
    public static Snapshot getSnapshot() {
        Snapshot s = new Snapshot();

        s.facilityCount = [SELECT COUNT() FROM Healthcare_Facility__c WHERE Verified__c = true WITH USER_MODE];

        s.lowStockCount = [SELECT COUNT() FROM Medicine_Inventory__c WHERE Stock_Status__c = 'Low Stock' WITH USER_MODE];

        s.outOfStockCount = [SELECT COUNT() FROM Medicine_Inventory__c WHERE Stock_Status__c = 'Out of Stock' WITH USER_MODE];

        s.upcomingVisits = [SELECT COUNT() FROM Visit_Preparation__c WHERE Planned_Visit_Date__c >= TODAY AND Prep_Status__c IN ('Draft', 'Ready') WITH USER_MODE];

        s.attentionStock = [SELECT Id, Name, Quantity_On_Hand__c, Stock_Status__c, Healthcare_Facility__r.Name FROM Medicine_Inventory__c WHERE Stock_Status__c IN ('Out of Stock', 'Low Stock') WITH USER_MODE ORDER BY Quantity_On_Hand__c ASC LIMIT 10];

        s.nextVisits = [SELECT Id, Name, Citizen_Name__c, Planned_Visit_Date__c, Prep_Status__c, Healthcare_Facility__r.Name, Medical_Service__r.Name FROM Visit_Preparation__c WHERE Planned_Visit_Date__c >= TODAY AND Prep_Status__c IN ('Draft', 'Ready') WITH USER_MODE ORDER BY Planned_Visit_Date__c ASC LIMIT 10];

        return s;
    }
}