<%@page import="java.util.Calendar"%>
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
final class VeriPwd{
    HttpSession session = request.getSession();
    
    String cellphone    = session.getAttribute("cellphone").toString();
    
    String pwdCode      = request.getParameter("pwdCode");

    public String getModule(){
        String html = "";
        
        return html;
    }
    
    public Object save(){
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

