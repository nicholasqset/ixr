<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.SQLException"%>
<%@page import="com.qset.security.Security"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="com.qset.user.User"%>
<%@page import="com.qset.gui.Gui"%>
<%

final class Profile{
    
    HttpSession session=request.getSession();
    
    String table        = session.getAttribute("comCode")+".SYSUSRS";
    String view         = session.getAttribute("comCode")+".VIEWSYSUSRS";
    
    String userId       = request.getParameter("userId");
    String password     = request.getParameter("password");
        
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        HttpSession session     = request.getSession();
        
        User user = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit =\"javascript:return false;\"");
        
        html += gui.formInput("hidden", "userId", 30, ""+user.userId, "", "");
        
        html += "<table width =\"100%\" class =\"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
//        html += "<tr>";
//	html += "<td class =\"bold\" width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(), "group.png", "", "")+" User Role</td>";
//	html += "<td>"+user.roleName+"</td>";
//	html += "</tr>";
        
        html += "<tr>";
	html += "<td class =\"bold\" width = \"15%\">"+gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+" User ID</td>";
	html += "<td>"+user.userId+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class =\"bold\">"+gui.formIcon(request.getContextPath(), "user-properties.png", "", "")+" User Name</td>";
	html += "<td>"+user.userName+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(), "email.png", "", "")+" Email</td>";
	html += "<td>"+user.email+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(), "phone.png", "", "")+" Phone</td>";
	html += "<td>"+user.cellphone+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(), "secrecy.png", "", "")+" "+gui.formLabel("password", "Password")+"</td>";
	html += "<td>"+gui.formInput("password", "password", 25, "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "reload.png", "onclick = \"profile.save('password', '"+ user.userName+"');\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
    public Object save() throws Exception{
        Integer saved = 0;
        
        JSONObject obj = new JSONObject();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            Security security = new Security();
            
            String query = "UPDATE "+ this.table+ " SET "
                + "PASSWORD         = '"+security.md5(this.password)+"' "
                + "WHERE USERID     = '"+ this.userId+ "'";
            
            saved = stmt.executeUpdate(query);
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
            }
            
         }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
       
}

%>