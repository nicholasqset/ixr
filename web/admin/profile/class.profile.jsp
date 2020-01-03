<%@page import="java.sql.SQLException"%>
<%@page import="bean.security.Security"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.security.NoSuchAlgorithmException"%>
<%@page import="bean.user.User"%>
<%@page import="bean.gui.Gui"%>
<%

final class Profile{
    String table        = "sys.coms";
    String view         = "VIEWSYSUSERS";
    
    String userId       = request.getParameter("userId");
    String password     = request.getParameter("password");
        
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        HttpSession session     = request.getSession();
        
        User user = new User(session.getAttribute("userId").toString(), session.getAttribute("comCode").toString());
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript:return false;\"");
        
        html += gui.formInput("hidden", "userId", 30, ""+user.userId, "", "");
         html += "<div class=\" container\">";
          html += "<div class=\" row\">";
        html += "<div class=\"col-md-9 offset-0 card \">";
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
//        
//        html += "<tr>";
//	html += "<td class = \"bold\" width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(), "group.png", "", "")+"Name</td>";
//	html += "<td>"+user.name+"</td>";
//	html += "</tr>";
//        
//        html += "<tr>";
//	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+" Cell Phone</td>";
//	html += "<td>"+user.cellphone+"</td>";
//	html += "</tr>";
//        
//        html += "<tr>";
//	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(), "user-properties.png", "", "")+" Telephone</td>";
//	html += "<td>"+user.telephone+"</td>";
//	html += "</tr>";
//        
//        html += "<tr>";
//	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(), "email.png", "", "")+" Email</td>";
//	html += "<td>"+user.userId+"</td>";
//	html += "</tr>";
//        
//        html += "<tr>";
//	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(), "email.png", "", "")+" Website</td>";
//	html += "<td>"+user.website+"</td>";
//	html += "</tr>";
//        html += "<tr>";
//	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(), "email.png", "", "")+" Address</td>";
//	html += "<td>"+user.postaladr+"</td>";
//	html += "</tr>";
//        html += "<tr>";
//	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(), "email.png", "", "")+" Postal code</td>";
//	html += "<td>"+user.postalcode+"</td>";
//	html += "</tr>";
//        html += "<tr>";
//	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(), "email.png", "", "")+" Physical address</td>";
//	html += "<td>"+user.physicaladr+"</td>";
//	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(), "secrecy.png", "", "")+" "+gui.formLabel("password", "Password")+"</td>";
	html += "<td>"+gui.formInput("password", "password", 25, "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "reload.png", "onclick = \"profile.save('password');\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html +="</div>";
        html +="</div>";
        html +="</div>";
        html += gui.formEnd();
                
        return html;
    }
    
    public Object save() throws NoSuchAlgorithmException{
        Integer saved = 0;
        
        JSONObject obj = new JSONObject();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            Security security = new Security();
            
            String query = "UPDATE "+ this.table+ " SET "
                + "PASSWORD         = '"+security.md5(this.password)+"' "
                + "WHERE email     = '"+ this.userId+ "'";
            
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