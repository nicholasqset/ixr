<%@page import="org.json.JSONObject"%>
<%@page import="bean.user.User"%>
<%@page import="bean.sys.Sys"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.gui.Gui"%>
<%

final class UserRight{
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
    String table        = session.getAttribute("comCode")+".SYSUSRPVGS";

    String userId       = request.getParameter("userId");
    String roleCode     = request.getParameter("roleCode");
    String rightStatus  = request.getParameter("rightStatus");
    
    public String getModule(){

        Gui gui = new Gui();

        String html = "";

        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

        html += "<table width = \"70%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

        html += "<tr>";
//	html += "<td width = \"20%\" nowrap><i class=\"fa fa-user\"></i>"+ gui.formLabel("userId", "User ID")+ "</td>";
        html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"user.png", "", "")+" "+gui.formLabel("userId", "User ID")+"</td>";
//        html += "<td>"+gui.formSelect("userId", ""+this.comCode+".SYSUSRS", "USERID", "USERNAME", "", "", "", "onchange = \"userRight.getUserGrpRights();\"", true)+"</td>";
        html += "<td>"+gui.formSelect("userId", session.getAttribute("comCode")+".SYSUSRS", "USERID", "USERNAME", "", "", "", "onchange = \"userRight.getUserGrpRights();\"", true)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td id = \"tdRightsUI\">&nbsp;</td>";
	html += "</tr>";

        html += "</table>";
        html += gui.formEnd();

        return html;
    }
    
    public Object getUserGrpRights() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.userId != ""){
            obj.put("success", new Integer(1));
            obj.put("message", "ok");
        }else{
            obj.put("success", new Integer(0));
            obj.put("message", "Select User Please.");
        }
        
        return obj;
    }
    
    public String getSystemRoles(){
        String html = "";
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        Integer recordCount = sys.getRecordCount(""+this.comCode+".SYSROLES", "");
        if(recordCount > 0){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query = "SELECT * FROM "+this.comCode+".SYSROLES ORDER BY ROLENAME ";
                ResultSet rs = stmt.executeQuery(query);
                
                Integer count = 0;
                
                html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

                html += "<tr>";
                html += "<th width = \"91%\" nowrap>Role</th>";
                html += "<th nowrap>Option</th>";
                html += "</tr>";

                while(rs.next()){
                    count++;
                    
                    String roleCode = rs.getString("ROLECODE");
                    String roleName = rs.getString("ROLENAME");
                    
                    Boolean roleExists = sys.recordExists(this.table, "ROLECODE = '"+ roleCode+"' AND USERID = '"+ this.userId+ "'");
//                    if(roleExists){
//                        this.rightStatus = "checked";
//                    }
                    
                    this.rightStatus = roleExists ? "checked": "";
                    
//                    String checkBox = gui.formCheckBox("allowDeny["+roleCode+"]", this.rightStatus, "", "onchange = \"userRight.save('"+ roleCode+ "');\"", "", "");
                    String checkBox = gui.formCheckBox("allowDeny["+roleCode+"]", this.rightStatus, "", "onchange = \"userRight.save('"+ roleCode+ "');\"", "", "");
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";
                    
                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td nowrap>"+ roleName+ "</td>";
                    html += "<td>"+ checkBox+ "</td>";
                    html += "</tr>";
                    
                }
                
                html += "</table>";

            }catch(Exception e){
                html += e.getMessage();
            }
        }else{
            html += "No defined roles found";
        }
        
        
        return html;
    }
    
    public Object save() throws Exception{
        JSONObject obj  = new JSONObject();

        Sys sys = new Sys();
        HttpSession session     = request.getSession();
        User user       = new User(sys.getLogUser(session), session.getAttribute("comCode").toString());

        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query;
            Integer saved   = 0;
            String allowDeny;
            
            String purgeQuery = null;

            if(this.rightStatus.equals("on")){
                purgeQuery = "DELETE FROM "+this.table+" WHERE "
                                    + "USERID       = '"+this.userId+"' AND "
                                    + "ROLECODE     = '"+this.roleCode+"' ";
                
                Integer purged = stmt.executeUpdate(purgeQuery);
                
                
                query = "INSERT INTO "+this.table+" "
                        + "(USERID, ROLECODE)"
                        + "VALUES"
                        + "("
//                        + id+","
                        + "'"+this.userId+"', "
                        + "'"+this.roleCode+"'"
                        + ")";
                
                allowDeny = "allow";
                
            }else{
                query = "DELETE FROM "+this.table+" WHERE "
                        + "USERID   = '"+this.userId+"' AND "
                        + "ROLECODE = '"+this.roleCode+"' ";
                        
                allowDeny = "deny";
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                if(user.userId.equals(this.userId)){
                    obj.put("reloadMenu", new Integer(1));
                }else{
                    obj.put("reloadMenu", new Integer(0));
                }
                obj.put("allowDeny", allowDeny);
                obj.put("success", new Integer(1));
                obj.put("message", "Privilege allowed.");
            }else{
                obj.put("purgeQuery", purgeQuery);
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
            }
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }

        return obj;
    }

}

%>