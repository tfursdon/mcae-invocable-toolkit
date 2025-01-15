/* Description: Test class for invocable_UpsertProspectByEmail.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 15 Jan 2025: Initial version.
 */

 @isTest
 public with sharing class Test_UpsertProspectByEmail {
 
     @isTest
     public static void testUpsertProspect() {
 
         //Simulate the expected response format as described in Account Engagement API documentation (https://developer.salesforce.com/docs/marketing/pardot/guide/prospect-v5.html)
         Map<String, Object> responseObject = new Map<String, Object>();
         responseObject.put('id', 123);
         responseObject.put('email', 'test@example.com');
         String responseBody = JSON.serialize(responseObject);

         Invocable_UpsertProspectByEmail.Prospect prospect = new Invocable_UpsertProspectByEmail.Prospect();
         prospect.email = 'test@example.com';
         prospect.firstName = 'John';
         prospect.lastName = 'Doe';
 
         Test.startTest();
 
         //Utilise a generic mock HTTP response generator
         Test.setMock(HttpCalloutMock.class, new Test_MockHttpResponseGenerator(200, responseBody));
         List<String> response = Invocable_UpsertProspectByEmail.upsertProspect(new List<Invocable_UpsertProspectByEmail.Prospect>{prospect});
         system.assertEquals('123', response[0]);
 
         Test.stopTest();
     }
 }