<%@page import="bean.sys.Threader"%>
<%@page import="com.africastalking.sms.Recipient"%>
<%@page import="java.util.List"%>
<%@page import="com.africastalking.SmsService"%>
<%@page import="com.africastalking.AfricasTalking"%>
<%@page import="java.io.IOException"%>
<%@page import="bean.user.User"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="bean.security.Security"%>
<%@page import="java.util.Random"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.commonsrv.Company"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
  
<%
final class ConfirmPwd{
    HttpSession session         = request.getSession();
    
    final String cellphone      = session.getAttribute("cellphone").toString();
    
    final String password       = request.getParameter("password");
    final String confPassword   = request.getParameter("confPassword");

    public String getModule(){
        String html = "";
        
        return html;
    }
    
    public Object save(){
        JSONObject obj      = new JSONObject();      
        
        if(! password.equals(confPassword)){
            obj.put("success", 0);
            obj.put("message", "Passwords not matching");
            
            return obj;
        }
        
        Sys sys = new Sys();
        String comCode  = sys.getOne("sys.coms", "comcode", "cellphone='"+cellphone+"'");
        
        Security security = new Security();
        
        try{
            Connection conn     = ConnectionProvider.getConnection();
            Statement stmt      = conn.createStatement();
            
//            String query = "UPDATE sys.coms SET password = '"+security.md5(password)+"' WHERE cellphone='"+ cellphone+ "'";
            String query = "UPDATE "+comCode+".sysusrs SET password = '"+security.md5(password)+"' WHERE cellphone='"+ cellphone+ "'";
                
            Integer updated = stmt.executeUpdate(query);

            if(updated == 1){
                String email    = sys.getOne("sys.coms", "email", "cellphone='"+cellphone+"'");
                sendSms(cellphone, email);        
                
                obj.put("success", new Integer(1));
                obj.put("message", "success");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! Failed to reset password.");
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
            
            String sms = "Hi, your iXR account password has been reset. Use your registered email i.e "+email+" and password to login the system. Thank you!";

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

