<%@page import="com.qset.hr.LeaveConfig"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class LeaveConf{
    String table        = "qset.HRLVCONF";

    Integer id          = 1;
    Boolean useRoster   = request.getParameter("useRoster") != null? true: false;
    
    public String getModule(){
        Gui gui = new Gui();
        
        LeaveConfig leaveConfig = new LeaveConfig();
        
        String html = "";

        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "pencil.png", "", "")+ gui.formLabel("useRoster", " Use Roster")+"</td>";
        html += "<td>"+ gui.formCheckBox("useRoster", leaveConfig.useRoster? "checked": "", null, "", "", "")+ "</td>";
	html += "</tr>";

        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"config.save(' ');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
        html += gui.formEnd();

        return html;
    }
    
    public Object save(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        
        Integer useRoster = this.useRoster? 1: 0;
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query;
            if(!system.recordExists(this.table, "")){
                query = "INSERT INTO "+this.table+" "
                        + "(ID, USEROSTER)"
                        + "VALUES"
                        + "("
                        + this.id+ ","
                        + useRoster+ " "
                        + ")";
                
            }else{
                query = "UPDATE "+ this.table+ " SET "
                        + "USEROSTER    = "+ useRoster+ " "
                        + "WHERE ID     = "+ this.id+ "";
            }
            
            Integer saved = stmt.executeUpdate(query);
            
            if(saved > 0){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oopss! An Un-expected error occured while saving record.");
            }
        }
        catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }

}

%>