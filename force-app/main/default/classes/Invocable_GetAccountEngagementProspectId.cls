/* Description: Queries Account Engagement for the first prospect that matches a supplied email address.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 13 Jan 2025: Initial version.
 */

public with sharing class Invocable_GetAccountEngagementProspectId {
    @InvocableMethod(label = 'Get Account Engagement Prospect Id' description='Returns a prospect Id using an email address if the prospect exists in Account Engagement.')
    public static List<String> getProspectId(List<String> prospectEmailList) {

        //Invocable methods expect a list of a single value from a Flow.
        if(prospectEmailList.size() == 0 || prospectEmailList.size() > 1) {
            system.debug('Error: Expected a single email value. Received ' + prospectEmailList.size() + '.');
            return new List<String>{null};
        }

        String prospectEmail = prospectEmailList[0];
        String prospectId = null;

        system.debug('Recieved request to query Account Engagement prospects with email: ' + prospectEmail);

        //Set up the Http request. The Named Crediential must be called 'Account_Engagement_API'. If this changes, then the callout endpoint should be updated.
        HttpRequest req = new HttpRequest();
        req.SetEndpoint('callout:Account_Engagement_API/v5/objects/prospects?fields=id&email='+ prospectEmail);
        req.setHeader('Pardot-Business-Unit-Id', System.Label.Account_Engagement_Business_Unit_Id);
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        system.debug('Callout response: ');
        system.debug(res.getBody());

        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        List<Object> responseValues = (List<Object>)responseBody.get('values');

        if(responseValues.size() > 0) {
            Map<String,Object> prospect = (Map<String,Object>)(responseValues[0]);
            prospectId = String.valueOf(prospect.get('id'));
            system.debug('Prospect found with Id: ' + prospectId);
        }
        return new List<String>{prospectId};
    }
}