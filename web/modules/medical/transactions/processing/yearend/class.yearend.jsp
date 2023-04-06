<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class YearEnd{
        
    public String getModule(){
        
        Gui gui = new Gui();
        
        String html = "";
        
        Sys sys = new Sys();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "") + gui.formLabel("yearFrom", " Fiscal Year From")+"</td>";
	html += "<td>"+ gui.formSelect("yearFrom", "FNFISCALYEAR", "FISCALYEAR", "", "", "", system.getFiscalYear(), "", false) +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "") + gui.formLabel("yearTo", " Fiscal Year To")+"</td>";
	html += "<td>"+ gui.formSelect("yearTo", "FNFISCALYEAR", "FISCALYEAR", "", "", "", "", "", false) +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td><div id = \"progress\">&nbsp;</div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Process", "cog.png", "onclick = \"leave.process('yearFrom yearTo');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
    
    
}

%>