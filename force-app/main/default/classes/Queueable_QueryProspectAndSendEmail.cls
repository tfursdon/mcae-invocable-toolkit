/* Description: This class contains a method that is designed to perform all actions required to asynchronously send a one-to-one email to a Contact or Lead record using MCAE.
 * This may be required due to uncommitted work errors when attempting to synchronously send emails inside a flow/trigger loop.
 * Tested by Test_QueueOneToOneEmail.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 11 Feb 2025: Initial version.
 */

public class Queueable_QueryProspectAndSendEmail implements Queueable, Database.AllowsCallouts {

    public String recordName; //This is what the MCAE record will be named once sent.
    public String firstName; //Used to upsert a prospect into MCAE if one is not found.
    public String lastName; //Used to upsert a prospect into MCAE if one is not found.
    public String emailAddress; //The email address to send to.
    public String subject; //The subject of the email.
    public String emailTemplateName; //The name of either the MCAE email template or Email Content (Lightning). This should be unique.
    public String senderName; //This will appear as the name of the sender to the recipient.
    public String senderEmailAddress; //The sender email address to use. This will appear as the sender to the email recipient.
    public String replyEmailAddress; //The reply to email address (if different from the sender email address).

    //Constructor
    public Queueable_QueryProspectAndSendEmail() {
        this.recordName = null;
        this.firstName = null;
        this.lastName = null;
        this.emailAddress = null;
        this.subject = null;
        this.emailTemplateName = null;
        this.senderName = null;
        this.senderEmailAddress = null;
        this.replyEmailAddress = null;
    }

    public void execute(System.QueueableContext context) {

        if(this.emailAddress == null || this.emailTemplateName == null || this.senderName == null || this.senderEmailAddress == null) {
            system.debug('Required fields missing. Terminating.');
            return;
        }

        //Retrieve the prospect Id using an email address.
        Invocable_GetAccountEngagementProspectId.ProspectDetails prospectDetails = new Invocable_GetAccountEngagementProspectId.ProspectDetails();
        prospectDetails.firstName = this.firstName;
        prospectDetails.email = this.emailAddress;
        
        List<String> prospectIds = Invocable_GetAccountEngagementProspectId.getProspectId(new List<Invocable_GetAccountEngagementProspectId.ProspectDetails>{prospectDetails});
        if(prospectIds.isEmpty() || prospectIds[0] == null || Test.isRunningTest()) {

            //This is a fallback in case MCAE hasn't synced a new prospect yet, should this be called on creation of a Contact or Lead record
            if(this.firstName != null && this.lastName != null) {
                system.debug('No prospect found. Creating a new prospect.');

                Invocable_UpsertProspectByEmail.Prospect prospect = new Invocable_UpsertProspectByEmail.Prospect();
                prospect.firstName = this.firstName;
                prospect.lastName = this.lastName;
                prospect.email = this.emailAddress;

                prospectIds = Invocable_UpsertProspectByEmail.upsertProspect(new List<Invocable_UpsertProspectByEmail.Prospect>{prospect});

            } else {
                system.debug('No prospect found and no name details to create a new one. Terminating.');
                return;
            }
        }

        //Retrieve the email template Id, which can either be an Email Content (Lightning) template or an MCAE email template.
        String templateId = null;
        List<EmailContent> emailContent = [SELECT Id FROM EmailContent WHERE Name = :this.emailTemplateName LIMIT 1];
        if(emailContent.isEmpty()) {
            List<String> mcaeTemplateIds = Invocable_GetEmailTemplateId.getEmailTemplateId(new List<String>{this.emailTemplateName});

            if(mcaeTemplateIds.isEmpty() || mcaeTemplateIds[0] == null) {
                system.debug('Email template not found. Terminating.');
                return;

            } else {
                templateId = mcaeTemplateIds[0];
            }

        } else {
            templateId = emailContent[0].Id;
        }

        //Once both the prospect Id and the email template Id are known, we can send the email
        Invocable_SendOneToOneEmail.EmailDetails emailDetails = new Invocable_SendOneToOneEmail.EmailDetails();
        emailDetails.name = this.recordName;
        emailDetails.subject = this.subject;
        emailDetails.prospectId = prospectIds[0];
        emailDetails.emailTemplateId = templateId;
        emailDetails.senderName = this.senderName;
        emailDetails.senderAddress = this.senderEmailAddress;
        emailDetails.replyAddress = this.replyEmailAddress;

        Invocable_SendOneToOneEmail.sendOneToOneEmail(new List<Invocable_SendOneToOneEmail.EmailDetails>{emailDetails});
    }
}