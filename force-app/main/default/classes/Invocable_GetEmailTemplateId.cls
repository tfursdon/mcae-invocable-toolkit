/* Description: Queries Account Engagement for the first email template that matches a supplied name. The email template must be available for one-to-one emails.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 15 Jan 2025: Initial version.
 */

public with sharing class Invocable_GetEmailTemplateId {
    @InvocableMethod(label = 'MCAE - Get Email Template Id' description='Returns a one-to-one email template Id using its name if the template exists in Account Engagement.')
    public static List<String> getEmailTemplateId(List<String> templateNames) {

        //Invocable methods expect a list of a single value from a Flow.
        if(templateNames.size() == 0 || templateNames.size() > 1) {
            system.debug('Error: Expected a single value. Received ' + templateNames.size() + '.');
            return new List<String>{null};
        }

        String templateId = null;
        String templateName = EncodingUtil.urlEncode(templateNames[0], 'UTF-8');
        templateName = templateName.replaceAll('\\+', '%20'); //urlEncode returns an encoded URL that uses the '+' character for spaces.

        //Set up the Http request. The Named Crediential must be called 'Account_Engagement_API'. If this changes, then the callout endpoint should be updated.
        HttpRequest req = new HttpRequest();
        req.SetEndpoint('callout:Account_Engagement_API/v5/objects/email-templates?fields=id,name,isOneToOneEmail&name=' + templateName);
        req.setHeader('Pardot-Business-Unit-Id', System.Label.Account_Engagement_Business_Unit_Id);
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        try {
            List<Object> responseValues = (List<Object>)responseBody.get('values');
            if(responseValues.size() > 0) {
                Map<String,Object> template = (Map<String,Object>)(responseValues[0]);
                templateId = String.valueOf(template.get('id'));
            }
        } catch (Exception e) {
            system.debug('Values missing from callout. Response: ');
            system.debug(res.getBody());
        }
        
        return new List<String>{templateId};
    }
}