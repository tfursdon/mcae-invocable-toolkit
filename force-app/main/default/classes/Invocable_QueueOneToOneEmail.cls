/* Description: Queues a one-to-one email in MCAE by calling the queueable class Queueable_QueryProspectAndSendEmail.
 * This runs the email send asynchronously to avoid potential errors caused by HTTP callouts while work is pending.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 12 Feb 2025: Initial version.
 */

public with sharing class Invocable_QueueOneToOneEmail {
    @InvocableMethod(label = 'MCAE - Queue One-to-One Email' description='All-in-one action to send an email using MCAE to a prospect asynchronously.')
    public static List<String> queueEmail(List<QueuedEmailDetails> queuedEmailDetailsList) {
        QueuedEmailDetails queuedEmailDetails = queuedEmailDetailsList[0];

        //We map all properties to equivalent parameters in the queueable job.
        Queueable_QueryProspectAndSendEmail queueableEmailSend = new Queueable_QueryProspectAndSendEmail();
        queueableEmailSend.recordName = queuedEmailDetails.recordName;
        queueableEmailSend.firstName = queuedEmailDetails.firstName ?? null;
        queueableEmailSend.lastName = queuedEmailDetails.lastName ?? null;
        queueableEmailSend.emailAddress = queuedEmailDetails.emailAddress;
        queueableEmailSend.subject = queuedEmailDetails.subject;
        queueableEmailSend.emailTemplateName = queuedEmailDetails.emailTemplateName;
        queueableEmailSend.senderName = queuedEmailDetails.senderName;
        queueableEmailSend.senderEmailAddress = queuedEmailDetails.senderEmailAddress;
        queueableEmailSend.replyEmailAddress = queuedEmailDetails.replyEmailAddress ?? null;

        try {
            Id jobId = system.enqueueJob(queueableEmailSend);
            return new List<String>{jobId}; //If an email is successfully queued, the Id of the queued job will be returned.
        } catch (Exception e) {
            system.debug(e.getMessage());
            return new List<String>{null}; //If an error occurs, return null.
        }
    }

    public class QueuedEmailDetails {
        @invocableVariable(label='Record Name'
        description='This will be the name of the email send when saved against the prospect.'
        required=true)
        public String recordName;

        @invocableVariable(label='First Name'
        description='The first name of the prospect. This will be used to create a new prospect if one matching the email address is not found.'
        required=false)
        public String firstName;

        @invocableVariable(label='Last Name'
        description='The last name of the prospect. This will be used to create a new prospect if one matching the email address is not found.'
        required=false)
        public String lastName;

        @invocableVariable(label='Prospect Email Address'
        description='The email address of the prospect you wish to send the email to.'
        required=true)
        public String emailAddress;

        @invocableVariable(label='Subject'
        description='This is the subject of the email.'
        required=true)
        public String subject;

        @invocableVariable(label='Email Template Name'
        description='The name of the email template. This can either be the unique name of a template in MCAE or the unique name of an Email Content record in Salesforce.'
        required=true) 
        public String emailTemplateName;

        @invocableVariable(label='Sender Name'
        description='This is the name the name that will be displayed as the sender of the email to the recipient.'
        required=true)
        public String senderName;

        @invocableVariable(label='Sender Email Address'
        description='The email will appear to come from this email address.'
        required=true)
        public String senderEmailAddress;

        @invocableVariable(label='Reply Email Address'
        description='If replies to the email should go somewhere other than to the sender email address, specify the email address here.'
        required=false)
        public String replyEmailAddress;
    }
}