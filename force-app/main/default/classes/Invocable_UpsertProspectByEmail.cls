/* Description: Upserts a prospect to Account Engagement using a supplied email address, first name and last name.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 15 Jan 2025: Initial version.
 */

public with sharing class Invocable_UpsertProspectByEmail {
    @InvocableMethod(label = 'Upsert Account Engagement Prospect' description='Upserts an Account Engagement prospect by email address.')
    public static List<String> upsertProspect(List<Prospect> prospectList) {

        //Invocable methods expect a list of a single value from a Flow.
        if(prospectList.size() == 0 || prospectList.size() > 1) {
            system.debug('Error: Expected a single prospect. Received ' + prospectList.size() + '.');
            return new List<String>{null};
        }

        Prospect prospect = prospectList[0];
        system.debug('Recieved request to upsert prospect with name: ' + prospect.firstName + ' ' + prospect.lastName + ' and email: ' + prospect.email);

        //Set up request body in line with documentation (https://developer.salesforce.com/docs/marketing/pardot/guide/prospect-v5.html)
        Map<String,Object> prospectObject = new Map<String,Object>();
        prospectObject.put('email', prospect.email);
        prospectObject.put('firstName', prospect.firstName);
        prospectObject.put('lastName', prospect.lastName);

        Map<String,Object> requestBody = new Map<String,Object>();
        requestBody.put('matchEmail', prospect.email);
        requestBody.put('prospect', prospectObject);
        requestBody.put('fields', new List<String>{'id', 'email'}); //Specifies which fields should be returned in the response body
        requestBody.put('secondaryDeletedSearch', true); //Includes deleted prospects in search. If one is found, it is undeleted and updated
        
        String requestBodyAsString = JSON.serialize(requestBody);
        system.debug('Request body: ' + requestBodyAsString);

        //Set up the Http request. The Named Crediential must be called 'Account_Engagement_API'. If this changes, then the callout endpoint should be updated.
        HttpRequest req = new HttpRequest();
        req.SetEndpoint('callout:Account_Engagement_API/v5/objects/prospects/do/upsertLatestByEmail');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Pardot-Business-Unit-Id', System.Label.Account_Engagement_Business_Unit_Id);
        req.setMethod('POST');
        req.setBody(requestBodyAsString);

        //Call MCAE to upsert the prospect record
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('Response: ' + res.getBody());

        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String prospectId = String.valueOf(responseBody.get('id'));

        if(prospectId != null) {
            system.debug('Prospect upserted successfully against id: ' + prospectId);
        } else {
            system.debug('Upsert unsuccessful. Id not received in MCAE response.');
        }

        return new List<String>{prospectId};
    }

    public class Prospect {
        @invocableVariable(label='Email' required=true)
        public String email;

        @invocableVariable(label='First Name' required=true)
        public String firstName;

        @invocableVariable(label='Last Name' required=true)
        public String lastName;
    }
}