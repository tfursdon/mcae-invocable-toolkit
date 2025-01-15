/* Description: Creates mock Http responses for test classes that require Http callouts.
 * Author: Thomas Fursdon (Merkle)
 * History:
 * 13 Jan 2025: Initial version.
 */

@isTest
global class Test_MockHttpResponseGenerator implements HttpCalloutMock {
    Integer statusCode;
    String responseBody;

    public Test_MockHttpResponseGenerator(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if(this.responseBody != null) {
            res.setBody(this.responseBody);
        } else {
            res.setBody('{"example": "test"}');
        }

        if(this.statusCode != null) {
            res.setStatusCode(this.statusCode);
        } else {
            res.setStatusCode(this.statusCode);
        }

        return res;
    }
}