/* Description: Test class for Invocable_QueueOneToOneEmail and (by extension) Queueable_QueryProspectAndSendEmail.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 12 Feb 2025: Initial version.
 */

@isTest
public with sharing class Test_QueueOneToOneEmail {

    @isTest
    public static void testQueueEmail() {

        //Simulate the expected response format as described in Account Engagement API documentation (https://developer.salesforce.com/docs/marketing/pardot/guide/email-v5.html)
        Map<String, Object> responseObject = new Map<String, Object>();
        Map<String, Object> responseListObject = new Map<String, Object>();

        responseListObject.put('id', 123);
        responseListObject.put('email', 'test@example.com');
        responseListObject.put('firstName', 'John');
        responseListObject.put('name', 'Test Email Template');

        responseObject.put('id', 123);
        responseObject.put('email', 'test@example.com');
        responseObject.put('values', new List<Object>{responseListObject});

        String responseBody = JSON.serialize(responseObject);

        Invocable_QueueOneToOneEmail.QueuedEmailDetails emailDetails = new Invocable_QueueOneToOneEmail.QueuedEmailDetails();
        emailDetails.recordName = 'Test Send';
        emailDetails.firstName = 'John';
        emailDetails.lastName = 'Doe';
        emailDetails.emailAddress = 'john.doe@example.com';
        emailDetails.subject = 'Test Email';
        emailDetails.emailTemplateName = 'Test | Email Template Name';
        emailDetails.senderName = 'Admin';
        emailDetails.senderEmailAddress = 'noreply@example.com';
        emailDetails.replyEmailAddress = 'test@example.com';

        Test.startTest();

        //Utilise a generic mock HTTP response generator
        Test.setMock(HttpCalloutMock.class, new Test_MockHttpResponseGenerator(200, responseBody));

        Invocable_QueueOneToOneEmail.queueEmail(new List<Invocable_QueueOneToOneEmail.QueuedEmailDetails>{emailDetails});

        Test.stopTest();
    }
}