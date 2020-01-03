<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="javax.jws.soap.SOAPBinding.Use"%>
<%@page import="com.africastalking.sms.Recipient"%>
<%@page import="java.util.List"%>
<%@page import="com.africastalking.SmsService"%>
<%@page import="com.africastalking.AfricasTalking"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
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

final class ResetPwd{
    
    public String getModule(){
        String html = "";
        
        return html;
    }
    
    public Object save(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        String cellphone        = request.getParameter("cellphone");
        
        if(! phoneNoValid(cellphone)){
            obj.put("success", 0);
            obj.put("message", "Invalid Cell Phone No.");
            
            return obj;
        }
        
        Boolean phoneExists = sys.recordExists("sys.coms", "cellphone = '"+cellphone+"'");
        if(! phoneExists){
            obj.put("success", 0);
            obj.put("message", "Cell Phone No. not found");
            
            return obj;
        }
        
        Random pn = new Random();
        String pinNo = String.format("%04d", pn.nextInt(10000));
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "UPDATE sys.coms SET optfld2 = '"+pinNo+"' WHERE cellphone = '"+cellphone+"'";
            
            Integer saved = stmt.executeUpdate(query);
            if(saved > 0){
                sendSms(cellphone, pinNo);

                obj.put("success", 1);
                obj.put("message", "success");
            }
        }catch(Exception e){
            obj.put("success", 0);
            obj.put("message", "Invalid Cell Phone No.");
            
            return obj;
        }

        return obj;
    }
    
    
    public Boolean phoneNoValid(String phoneNo){
        Boolean phoneNoValid = true;
        
        
        
        return phoneNoValid;
    }
    
    public void sendSms(String phoneNo, String pinNo){
        try{
            String username = "qXR";
            String apiKey = "98e6dc9d6eb6659a384ed6734531f3123d65d4ef55e9fde4a15ab23ec5f1587d";
            AfricasTalking.initialize(username, apiKey);
            
            String sms = "Hi, your iXR password verification code is "+ pinNo+ ".";

            //Initialize a service eg SMS
            SmsService smsService = AfricasTalking.getService(AfricasTalking.SERVICE_SMS);

            //Use the service
//            List<Recipient> response2 = smsService.send("Hi, iXR verification code is ", new String[]{"+"+ "254725999504"}, true);
//            List<Recipient> response2 = smsService.send(sms, new String[]{"+"+ phoneNo}, true);
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