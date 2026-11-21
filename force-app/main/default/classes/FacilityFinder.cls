/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : FacilityFinder
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


public with sharing class FacilityFinder {

    public class Request {
        @InvocableVariable(label='Service Keyword' required=true)
        public String serviceKeyword;

        @InvocableVariable(label='Locality (optional)')
        public String locality;

        @InvocableVariable(label='Maximum Fee in INR (optional)')
        public Decimal maxFee;
    }

    public class Result {
        @InvocableVariable
        public Integer matchCount;

        @InvocableVariable
        public String topFacilityId;

        @InvocableVariable
        public String topServiceId;

        @InvocableVariable
        public String summary;
    }

    @InvocableMethod(
        label='Find Facilities For Service'
        description='Finds verified government facilities that offer a service.'
    )
    public static List<Result> findFacilities(List<Request> requests) {

        List<Result> results = new List<Result>();

        for (Request req : requests) {
            results.add(search(req));
        }

        return results;
    }

    private static Result search(Request req) {

        Result result = new Result();
        result.matchCount = 0;

        if (req == null || String.isBlank(req.serviceKeyword)) {
            result.summary = 'Please provide a healthcare service to search for.';
            return result;
        }

        String keyword = '%' + req.serviceKeyword.trim() + '%';

        List<Medical_Service__c> services = [SELECT Id, Name, Service_ID__c, Fee_Type__c, Service_Fee__c, Appointment_Required__c, Fasting_Needed__c, Healthcare_Facility__c, Healthcare_Facility__r.Facility_ID__c, Healthcare_Facility__r.Name, Healthcare_Facility__r.Locality__c, Healthcare_Facility__r.Opening_Hours__c, Healthcare_Facility__r.Distance_From_City_Centre_km__c FROM Medical_Service__c WHERE (Name LIKE :keyword OR Service_Category__c LIKE :keyword) AND Verified__c = true AND Healthcare_Facility__r.Verified__c = true WITH USER_MODE ORDER BY Healthcare_Facility__r.Distance_From_City_Centre_km__c ASC NULLS LAST LIMIT 25];

        List<String> facilityDetails = new List<String>();

        for (Medical_Service__c service : services) {

            if (req.maxFee != null && (service.Service_Fee__c == null || service.Service_Fee__c > req.maxFee)) {
                continue;
            }

            String locality = service.Healthcare_Facility__r.Locality__c;

            if (String.isNotBlank(req.locality) && (String.isBlank(locality) || !locality.toLowerCase().contains(req.locality.trim().toLowerCase()))) {
                continue;
            }

            if (result.topFacilityId == null) {
                result.topFacilityId = service.Healthcare_Facility__c;
                result.topServiceId = service.Id;
            }

            result.matchCount++;

            if (facilityDetails.size() < 5) {

                String facilityName = service.Healthcare_Facility__r.Name;
                String serviceName = service.Name;
                String feeType = service.Fee_Type__c;
                String openingHours = service.Healthcare_Facility__r.Opening_Hours__c;
                Decimal distance = service.Healthcare_Facility__r.Distance_From_City_Centre_km__c;
                String distanceText = distance == null ? 'Distance not available' : distance + ' km';
                String hoursText = String.isBlank(openingHours) ? 'Opening hours not available' : openingHours;
                facilityDetails.add(facilityName + ' - ' + serviceName + ' (' + feeType + '), ' + hoursText + ', ' + distanceText);
            }
        }

        if (result.matchCount == 0) {
            result.summary = 'No verified sample records matched your request. ' + 'Try another service or locality, or check with your local health office.';

        } else {
            result.summary = String.join(facilityDetails, '\n') +  '\nSample records only. Please confirm the details with the facility.';
        }

        return result;
    }
}