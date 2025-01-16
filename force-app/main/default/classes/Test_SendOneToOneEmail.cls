/* Description: Test class for Invocable_SendOneToOneEmail.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 16 Jan 2025: Initial version.
 */

 @isTest
 public with sharing class Test_SendOneToOneEmail {
 
     @isTest
     public static void testSendEmail() {
 
         //Simulate the expected response format as described in Account Engagement API documentation (https://developer.salesforce.com/docs/marketing/pardot/guide/email-v5.html)
         Map<String, Object> responseObject = new Map<String, Object>();
         responseObject.put('id', 123);
         String responseBody = JSON.serialize(responseObject);

         Invocable_SendOneToOneEmail.EmailDetails emailDetails = new Invocable_SendOneToOneEmail.EmailDetails();
         emailDetails.name = 'Test Send';
         emailDetails.subject = 'Test Email';
         emailDetails.prospectId = 234;
         emailDetails.emailTemplateId = '123';
         emailDetails.senderName = 'John Doe';
         emailDetails.senderAddress = 'noreply@example.com';
         emailDetails.replyAddress = 'test@example.com';
 
         Test.startTest();
 
         //Utilise a generic mock HTTP response generator
         Test.setMock(HttpCalloutMock.class, new Test_MockHttpResponseGenerator(200, responseBody));
         List<String> response = Invocable_SendOneToOneEmail.sendOneToOneEmail(new List<Invocable_SendOneToOneEmail.EmailDetails>{emailDetails});
         system.assertEquals('123', response[0]);
 
         Test.stopTest();
     }
 }