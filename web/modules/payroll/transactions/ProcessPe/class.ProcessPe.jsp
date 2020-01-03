<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class ProcessPe{
    HttpSession session = request.getSession();
    
    Integer pYear       = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth      = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
        
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getProcessTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style = \"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Process", "cog.png", "onclick = \"processPe.process('pYear pMonth nextPyear nextPmonth'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Period End\'), 0, 625, 142, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getProcessTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">&nbsp;</td>";
	html += "<td class = \"bold\">From</td>";
	html += "<td class = \"bold\">To</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", "Payroll Year")+ "</td>";
	html += "<td>"+ gui.formSelect("pYear", "qset.FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "PYEAR = "+ sys.getPeriodYear(session.getAttribute("comCode").toString()), ""+ sys.getPeriodYear(session.getAttribute("comCode").toString()), "", false)+ "</td>";
	html += "<td>"+ gui.formSelect("nextPyear", "qset.FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "PYEAR = "+ sys.getNextPeriodYear(session.getAttribute("comCode").toString()), ""+ sys.getNextPeriodYear(session.getAttribute("comCode").toString()), "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", "Payroll Month")+ "</td>";
	html += "<td>"+ gui.formOneMonthSelect("pMonth", sys.getPeriodMonth(session.getAttribute("comCode").toString()), "", true)+ "</td>";
	html += "<td>"+ gui.formOneMonthSelect("nextPmonth", sys.getNextPeriodMonth(session.getAttribute("comCode").toString()), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"3\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td colspan = \"2\"><div id = \"progress\">&nbsp;</div></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
}

%>