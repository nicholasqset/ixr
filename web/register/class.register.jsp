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

final class Register{
    
    public String getModule(){
        String html = "";
        
        return html;
    }
    
    public Object save(){
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        String cellphone        = request.getParameter("cellphone");
        String email            = request.getParameter("email");
        String password         = request.getParameter("password");
        String confPassword     = request.getParameter("confPassword");
        
        if(! phoneNoValid(cellphone)){
            obj.put("success", 0);
            obj.put("message", "Invalid Cell Phone No.");
            
            return obj;
        }
        
        if(! sys.emailValid(email)){
            obj.put("success", 0);
            obj.put("message", "Invalid Email");
            
            return obj;
        }
        
           
        if(! password.equals(confPassword)){
            obj.put("success", 0);
            obj.put("message", "Passwords not matching");
            
            return obj;
        }
        
        obj.put("success", 1);
        obj.put("message", "success");

        return obj;
    }
    
    
    public Boolean phoneNoValid(String phoneNo){
        Boolean phoneNoValid = true;
        
        
        
        return phoneNoValid;
    }
    
 
    
}

%>