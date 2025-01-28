/* Description: Triggers a One-to-One Email Send using Email Content, available in Salesforce with Account Engagement.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 16 Jan 2025: Initial version.
 */


public with sharing class Invocable_SendOneToOneEmail {
    @InvocableMethod(label = 'MCAE - Send One-to-One Email' description='Sends an email to a prospect using email content information.')
    public static List<String> sendOneToOneEmail(List<EmailDetails> emailDetailsList) {

        //Invocable methods expect a list of a single value from a Flow.
        if(emailDetailsList.size() == 0 || emailDetailsList.size() > 1) {
            system.debug('Error: Expected a single object. Received ' + emailDetailsList.size() + '.');
            return new List<String>{null};
        }

        EmailDetails emailDetails = EmailDetailsList[0];
        system.debug('Recieved request to send email: ' + emailDetails.name);

        //Set up request body in line with documentation (https://developer.salesforce.com/docs/marketing/pardot/guide/email-v5.html)
        Map<String,Object> senderOptions = new Map<String,Object>();
        senderOptions.put('type', 'general_user');
        senderOptions.put('name', emailDetails.senderName);
        senderOptions.put('address', emailDetails.senderAddress);

        Map<String,Object> replyToOptions = new Map<String,Object>();
        replyToOptions.put('type', 'general_address');
        replyToOptions.put('address', emailDetails.replyAddress != null ? emailDetails.replyAddress : emailDetails.senderAddress);

        Map<String,Object> requestBody = new Map<String,Object>();
        requestBody.put('name', emailDetails.name);
        requestBody.put('prospectId', Integer.valueOf(emailDetails.prospectId));
        requestBody.put('isOperational', true);
        requestBody.put('campaignId', Integer.valueOf(System.Label.Account_Engagement_One_to_One_Campaign_Id));
        requestBody.put('senderOptions', new List<Map<String, Object>>{senderOptions});
        requestBody.put('replyToOptions', new List<Map<String, Object>>{replyToOptions});

        /*** Other possible body parameters ***/
        //"folderId" : 500
        //"trackerDomainId": 5
        //"scheduledTime" : "2034-07-25T14:01:17-04:00"
        
        if(emailDetails.emailTemplateId.isNumeric()) { //Account Engagement Email Templates use strictly numberic Ids.
            requestBody.put('emailTemplateId', Integer.valueOf(emailDetails.emailTemplateId));
            if(emailDetails.subject != null && emailDetails.subject != '') {
                requestBody.put('subject', emailDetails.subject);
            }
            system.debug('Email Template Id is for an Account Engagement Email Template.');
        } else { //If a Salesforce Email Content Id has been supplied, we need to map its fields to the request

            EmailContent emailContent = [SELECT Id, Name, Subject, HtmlBody, TextBody FROM EmailContent WHERE Id = :emailDetails.emailTemplateId LIMIT 1];
            if(emailContent != null) {
                requestBody.put('subject', emailDetails.subject != null ? emailDetails.subject : emailContent.Subject);
                requestBody.put('htmlMessage', emailContent.HtmlBody);
                requestBody.put('textMessage', emailContent.TextBody);
            } else {
                return new List<String>{null}; //No email template found
            }
        }
        
        String requestBodyAsString = JSON.serialize(requestBody);
        system.debug('Request body: ' + requestBodyAsString);

        //Set up the Http request. The Named Crediential must be called 'Account_Engagement_API'. If this changes, then the callout endpoint should be updated.
        HttpRequest req = new HttpRequest();
        req.SetEndpoint('callout:Account_Engagement_API/v5/objects/emails?fields=id');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Pardot-Business-Unit-Id', System.Label.Account_Engagement_Business_Unit_Id);
        req.setMethod('POST');
        req.setBody(requestBodyAsString);

        //Call MCAE to send the email
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('Response: ' + res.getBody()); //The response will include any fields we specified in the callout, so we should expect an Id back if successful.

        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        return new List<String>{String.valueOf(responseBody.get('id'))};
    }

    public class EmailDetails {
        @invocableVariable(label='Name' required=true)
        public String name;

        @invocableVariable(label='Subject' required=false) //Optional subject override
        public String subject;

        @invocableVariable(label='MCAE Prospect Id' required=true)
        public String prospectId; //This should be an integer, but is configured as a String input as Ids are typically held in text fields, and for consistency with Invocable_GetAccountEngagementProspectId, which returns a String

        @invocableVariable(label='Email Template Id' required=true) 
        public String emailTemplateId; //This can be either a MCAE template Id, or an Email Content Id from Salesforce

        @invocableVariable(label='Sender Name' required=true)
        public String senderName;

        @invocableVariable(label='Sender Email Address' required=true)
        public String senderAddress;

        @invocableVariable(label='Reply Email Address' required=false)
        public String replyAddress;
    }
}