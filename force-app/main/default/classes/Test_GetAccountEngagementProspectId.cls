/* Description: Test class for Invocable_getAccountEngagementProspectId.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 13 Jan 2025: Initial version.
 */

@isTest
public with sharing class Test_GetAccountEngagementProspectId {

    @isTest
    public static void testGetProspectId() {

        //Simulate the expected response format as described in Account Engagement API documentation (https://developer.salesforce.com/docs/marketing/pardot/guide/prospect-v5.html)
        Map<String, Object> responseObject = new Map<String, Object>();
        Map<String, Object> responseListObject = new Map<String, Object>();
        responseListObject.put('id', 123);
        responseListObject.put('firstName', 'Test');
        responseListObject.put('email', 'test@example.com');
        responseObject.put('values', new List<Object>{responseListObject});
        String responseBody = JSON.serialize(responseObject);

        Test.startTest();

        //Utilise a generic mock HTTP response generator
        Test.setMock(HttpCalloutMock.class, new Test_MockHttpResponseGenerator(200, responseBody));

        Invocable_GetAccountEngagementProspectId.ProspectDetails prospectDetails = new Invocable_GetAccountEngagementProspectId.ProspectDetails();
        prospectDetails.firstName = 'Test';
        prospectDetails.email = 'test@example.com';

        List<String> response = Invocable_GetAccountEngagementProspectId.getProspectId(new List<Invocable_GetAccountEngagementProspectId.ProspectDetails>{prospectDetails});
        system.assertEquals('123', response[0]);

        Test.stopTest();
    }
}