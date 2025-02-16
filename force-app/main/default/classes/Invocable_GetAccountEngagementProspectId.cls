/* Description: Queries Account Engagement for the first prospect that matches a supplied email address. API Documentation: https://developer.salesforce.com/docs/marketing/pardot/guide/prospect-v5.html
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 13 Jan 2025: Initial version.
 */

public with sharing class Invocable_GetAccountEngagementProspectId {

    @InvocableMethod(label = 'MCAE - Get Prospect Id' description='Returns a prospect Id using an email address if the prospect exists in Account Engagement.')
    public static List<String> getProspectId(List<ProspectDetails> prospectDetailsList) {

        //Invocable methods expect a list of a single value from a Flow.
        if(prospectDetailsList.size() == 0 || prospectDetailsList.size() > 1) {
            system.debug('Error: Expected a single email value. Received ' + prospectDetailsList.size() + '.');
            return new List<String>{null};
        }

        String prospectEmail = prospectDetailsList[0].email;
        List<String> emailSections = prospectEmail.split('@');

        if(emailSections.size() != 2) {
            system.debug('Email address invalid. Returning null.');
            return new List<String>{null};
        }

        //Encode the email address before @ to ensure any special characters can be used in the callout URL (e.g. '+' characters)
        String encodedEmail = EncodingUtil.urlEncode(emailSections[0], 'UTF-8') + '@' + emailSections[1];
        String prospectId = null;

        //Set up the Http request. The Named Crediential must be called 'Account_Engagement_API'. If this changes, then the callout endpoint should be updated.
        HttpRequest req = new HttpRequest();
        req.SetEndpoint('callout:Account_Engagement_API/v5/objects/prospects?fields=id,firstName&email=' + encodedEmail + '&orderBy=updatedAt%20desc');
        req.setHeader('Pardot-Business-Unit-Id', System.Label.Account_Engagement_Business_Unit_Id);
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        system.debug('Callout response: ');
        system.debug(res.getBody());

        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        List<Object> responseValues = (List<Object>)responseBody.get('values');

        if(responseValues.size() > 0) {
            Map<String,Object> prospect = null;

            //Filter returned results to just one matching a supplied prospect first name
            if(prospectDetailsList[0].firstName != null) {
                for(Integer i = 0; i < responseValues.size(); i++) {
                    Map<String,Object> loopProspect = (Map<String,Object>)(responseValues[i]);
                    if(loopProspect.get('firstName') == prospectDetailsList[0].firstName) {
                        prospectId = String.valueOf(loopProspect.get('id'));
                    }
                }
            } else { //Use the first value returned if not filtering by name
                prospect = (Map<String,Object>)(responseValues[0]);
                prospectId = String.valueOf(prospect.get('id'));
            }
        }
        return new List<String>{prospectId};
    }

    public class ProspectDetails {
        @invocableVariable(label='First Name' required=false)
        public String firstName;

        @invocableVariable(label='Email Address' required=true)
        public String email;
    }
}