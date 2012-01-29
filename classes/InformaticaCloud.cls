public with sharing class InformaticaCloud {

  @future (callout=true) 

  public static void RunJob(String username, String password, String jobName, String jobType) {

    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    Http http = new Http(); 

    req.setEndpoint('https://app.informaticaondemand.com/saas/api/1/runjob?username=' + 
                     EncodingUtil.urlEncode(username, 'UTF-8') +
                    '&password='+EncodingUtil.urlEncode(password, 'UTF-8') +
                    '&jobName='+EncodingUtil.urlEncode(jobName, 'UTF-8') +
                    '&jobType='+EncodingUtil.urlEncode(jobType, 'UTF-8'));
        
    req.setMethod('POST');

    try{
      res = http.send(req);
    }
    catch(System.CalloutException e)
    {
      System.debug('Job Error: '+ e);
      System.debug(res.toString());
    }
  }
}