<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class MonthEnd{
        
    public String getModule(){
        
        Gui gui = new Gui();
        
        String html = "";
        
        Sys sys = new Sys();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("yearFrom", " Year From")+"</td>";
	html += "<td width = \"35%\">"+ gui.formSelect("yearFrom", "FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", ""+ system.getPeriodYear(), "", false) +"</td>";
	
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "") + gui.formLabel("yearTo", " Year To")+"</td>";
	html += "<td width = \"35%\">"+ gui.formSelect("yearTo", "FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", "", "", false) +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("monthFrom", " Month From")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("monthFrom", system.getPeriodMonth(), "", true)+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("monthTo", " Month To")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("monthTo", null, "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td><div id = \"progress\">&nbsp;</div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Process", "cog.png", "onclick = \"leave.process('yearFrom yearTo monthFrom monthTo');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
}

%>