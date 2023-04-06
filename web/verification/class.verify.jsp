<%@page import="org.json.JSONObject"%>
<%@page import="java.util.Base64"%>
<%@page import="com.qset.sys.Threader"%>
<%@page import="com.africastalking.sms.Recipient"%>
<%@page import="java.util.List"%>
<%@page import="com.africastalking.SmsService"%>
<%@page import="com.africastalking.AfricasTalking"%>
<%@page import="java.io.IOException"%>
<%@page import="com.qset.user.User"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="com.qset.security.Security"%>
<%@page import="java.util.Random"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.commonsrv.Company"%>
<%@page import="com.qset.hr.StaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
  
<%
final class Verify{
    HttpSession session     = request.getSession();
    
    String comCode          = session.getAttribute("comCode").toString(); 
    final String cellphone  = session.getAttribute("cellphone").toString();
    final String email      = session.getAttribute("email").toString();
    final String password   = session.getAttribute("password").toString();
    String pinNo            = session.getAttribute("pinNo").toString();
    
    public String getModule(){
        String html = "";
        
        return html;
    }
    
    public Object verify() throws Exception{
        JSONObject obj      = new JSONObject();     
        
        try{
            String smsCode      = request.getParameter("code");
            
            Connection conn     = ConnectionProvider.getConnection();
            
            Statement stmt      = conn.createStatement();
            
            String query;
            
            Integer updated = 0;

            if(smsCode.equals(pinNo)){
                query   = "UPDATE sys.coms SET verify = '1' WHERE cellphone='"+ cellphone+ "'";
                updated = stmt.executeUpdate(query);
            }

            if(updated == 1){
                Threader threader = new Threader();
                
                if(threader.accountCreated(comCode, email, cellphone, password)){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Account verified successfully.");

                    sendSms(cellphone, email);
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops..! unable to create account.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! Failed to verify account.");
            }
        }catch(Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }

        return obj;
    }
    
    public void sendSms(String phoneNo, String email){
        try{
            String username = "qXR";
            String apiKey = "98e6dc9d6eb6659a384ed6734531f3123d65d4ef55e9fde4a15ab23ec5f1587d";
            AfricasTalking.initialize(username, apiKey);
            
            String sms = "Hi, your iXR account has been verified. Use your registered email i.e "+this.email+" and password to login the system. Thank you!";

            //Initialize a service eg SMS
            SmsService smsService = AfricasTalking.getService(AfricasTalking.SERVICE_SMS);

            //Use the service
//            List<Recipient> response2 = smsService.send("Hi, iXR verification code is ", new String[]{"+"+ "254725999504"}, true);
            List<Recipient> response2 = smsService.send(sms, new String[]{"+"+ phoneNo}, true);
            
            System.out.println("response2===="+ response2);
            System.out.print(response2.get(0).status+".........hello............");
            System.out.println("inn");
        }catch (IOException e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }
}

%>

