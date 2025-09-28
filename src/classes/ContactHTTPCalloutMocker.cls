global class ContactHTTPCalloutMocker implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint().contains('https://independent36-dev-ed.lightning.force.com/services/apexrest/ContactInformation/')){
            res.setBody('request caught');
            res.setStatusCode(200);
        }
        return res;
    }
}