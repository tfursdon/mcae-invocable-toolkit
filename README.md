# MCAE Invocable Toolkit

Here you will find a collection of invocable methods to integrate Salesforce with Marketing Cloud Account Engagement (MCAE, previously known as Pardot) within the same org.

Some setup is required to achieve the integration before the code can be used.

## Org-specific prerequisites:

- Named Credential: Account Engagement API
- Self-signed Certificate: Account Engagement API (needs to be updated in Named Credential and Connected App when it is refreshed).
- Connected App: Account Engagement API
- Custom label: Account Engagement Business Unit Id
- Custom label: Account Engagement One-to-One Campaign Id

Resources used: https://thespotforpardot.com/2021/02/02/pardot-api-and-getting-ready-with-salesforce-sso-users-part-3a-connecting-to-pardot-api-from-apex/

## Apex classes

Each of the following Apex classes can be used as actions within a Flow, or called programmatically via other Apex. read below for a description on how to use each of them.

**TLDR; You can use the Invocable_QueueOneToOneEmail class as an all-in-one solution for sending an email with a single set of input parameters.**

---

### Invocable_GetAccountEngagementProspectId

This class will retrieve the MCAE Prospect Id that matches a provided email address. Assuming MCAE is syncing with Salesforce data, this will be the Prospect Id that matches a Lead or Contact in Salesforce.

The Prospect Id is required before a one-to-one email can be sent, so that MCAE knows which prospect to store the email send record against.

---

### Invocable_GetEmailTemplateId

This class will retrieve the MCAE Template Id for an email template that matches a provided template name. Note that this is used for legacy email templates stored in MCAE and not Email Content or Lightning Email Templates which are stored in Salesforce itself.

The returned template Id is required if sending a templated email to a prospect and the email template is in the older format. If using the Lightning Email Builder, then this class may not be required for your use case.

---

### Invocable_QueueOneToOneEmail

This is a one size fits all class that calls the Queueable_QueryProspectAndSendEmail class for asynchronous email sends. If all you want to do is send an email to a prospect using Salesforce information, this is likely the only class that you'll need to use, since the related queuable method will handle the orchestration and logic of all other classes/methods in the toolkit.

---

### Invocable_SendOneToOneEmail

This class will create the one-to-one email send in MCAE against a prospect. The Template Id and Prospect Id are required to send the email. Template Ids can either be MCAE Template Ids (stored as an integer), or the Salesforce Id of an Email Content record (if you're utilising the Lightning Email Builder).

---

### Invocable_UpsertProspectByEmail

This class will upsert prospect information against an email address in MCAE and return the prospect's Id.

Because the Salesforce to MCAE sync can sometimes take a few minutes to complete, it is possible that a prospect record does not yet exist when trying to send an email. When this occurs, this class can be used to upsert the prospect so that a Prospect Id can still be retrieved. The prospect record will then be matched to the relevant Salesforce Contact or Lead record by the MCAE connector as part of the next sync.

---

### Queueable_QueryProspectAndSendEmail

This class is designed as an all-in-one method of sending an email asynchronously. This is necessary to avoid unsaved work errors that can occur in record trigger Flows and Apex Triggers when making synchronous RESTful callouts.

The invocable version of this for use in flows is the Invocable_QueueOneToOneEmail class, but this version can be used directly if sending an email programmatically.

---

_Test classes are included to provide test coverage for all of the above Apex classes._

