<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class RptPL{
        
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
        html += "<td>"+ gui.formSelect("pYear", "FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", system.getPeriodYear()+ "", "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Fiscal Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", system.getPeriodMonth(), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
        html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"rptPL.print('pYear pMonth'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
            
        html += gui.formEnd();
        
        return html;
    }
    
    
}

%>