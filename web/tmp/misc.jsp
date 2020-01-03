<%-- 
    Document   : misc
    Created on : Sep 6, 2019, 4:16:15 PM
    Author     : eliblackmwafrika
--%>
<%@page import="java.io.IOException"%>
<%@page import="com.africastalking.sms.Recipient"%>
<%@page import="java.util.List"%>
<%@page import="com.africastalking.SmsService"%>
<%@page import="com.africastalking.AfricasTalking"%>
<%
//    try
    
//    Process p = Runtime.getRuntime().exec(new String[]{"csh","-c","touch /home/eliblackmwafrika/psm.txt"});
//    Process p = Runtime.getRuntime().exec(new String[]{"bash","-c","touch /home/eliblackmwafrika/elij.txt"});
//    Process p = Runtime.getRuntime().exec(new String[]{"bash","-c","pg_dump -U postgres --schema='l2348' ixr | sed 's/l2348/l2349/g' | psql -U postgres -d ixr"});
    
    String username =  "qXR";
            String apiKey = "fe5b1bffb9136965acba3d3ac25e5cba60751b7bf94bf71db354331f4bed3bce";
            AfricasTalking.initialize(username, apiKey);
            //Initialize a service eg SMS
            SmsService sms = AfricasTalking.getService(AfricasTalking.SERVICE_SMS);
           //Use the service
            try{
                List<Recipient> response2 = sms.send(" is your iXR velification code ", new String[]{"+"+ "254726715345"},true); 
//               System.out.print(response2.get(0).status+".........hello............");
//                System.out.println("inn");      
            }catch (IOException e) {
            e.printStackTrace();
        }


    
    
%>
