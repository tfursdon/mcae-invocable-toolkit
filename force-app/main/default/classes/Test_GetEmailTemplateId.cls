/* Description: Test class for Invocable_getEmailTemplateId.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 15 Jan 2025: Initial version.
 */

@isTest
public with sharing class Test_GetEmailTemplateId {

    @isTest
    public static void testGetEmailTemplateId() {

        //Simulate the expected response format as described in Account Engagement API documentation (https://developer.salesforce.com/docs/marketing/pardot/guide/email-template-v5.html)
        Map<String, Object> responseObject = new Map<String, Object>();
        Map<String, Object> responseListObject = new Map<String, Object>();
        responseListObject.put('id', 123);
        responseListObject.put('name', 'Test Email Template');
        responseObject.put('values', new List<Object>{responseListObject});
        String responseBody = JSON.serialize(responseObject);

        Test.startTest();

        //Utilise a generic mock HTTP response generator
        Test.setMock(HttpCalloutMock.class, new Test_MockHttpResponseGenerator(200, responseBody));
        List<String> response = Invocable_GetEmailTemplateId.getEmailTemplateId(new List<String>{'Test Email Template'});
        system.assertEquals('123', response[0]);

        Test.stopTest();
    }
}