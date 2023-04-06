<%@page import="org.json.JSONObject"%>
<%@page import="java.util.Calendar"%>
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
final class VeriPwd{
    HttpSession session = request.getSession();
    
    String cellphone    = session.getAttribute("cellphone").toString();
    
    String pwdCode      = request.getParameter("pwdCode");

    public String getModule(){
        String html = "";
        
        return html;
    }
    
    public Object save() throws Exception{
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        String pinNo = sys.getOne("sys.coms", "optfld2", "cellphone = '"+ this.cellphone+ "'");
        
        if(pinNo != null){
            if(pwdCode.equals(pinNo)){ 
                obj.put("success", new Integer(1));
                obj.put("message", "success");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Invalid Pin");
            }     
        }else{
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving code.");
        }
    
        return obj;
    }
    
}

%>

