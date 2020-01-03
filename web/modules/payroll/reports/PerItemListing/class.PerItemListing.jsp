<%@page import="bean.hr.StaffProfile"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class PerItemListing{
    HttpSession session = request.getSession();
    String schema       = session.getAttribute("comCode").toString();
        
    Integer pYear       = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth      = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
    
    public String getModule(){
        HttpSession session= request.getSession();
        
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<table width = \"75%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", "Payroll Year")+ "</td>";
	html += "<td>"+ gui.formSelect("pYear", ""+session.getAttribute("comCode")+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", ""+ sys.getPeriodYear(schema), "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", "Payroll Month")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", sys.getPeriodMonth(schema), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("item", "Payroll Item")+ "</td>";
	html += "<td>"+ gui.formSelect("item", ""+session.getAttribute("comCode")+".VIEWITEMS", "ITEMCODE", "ITEMNAME", "", "", "", "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"perItemListing.print('pYear pMonth');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
}

%>