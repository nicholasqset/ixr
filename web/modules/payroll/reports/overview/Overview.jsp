<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.hr.StaffProfile"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class Overview{
    HttpSession session = request.getSession();
    String schema       = session.getAttribute("comCode").toString();
    
    Integer pYear       = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth      = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
    String pfNo         = request.getParameter("staff");
    
    public String getModule(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<table width = \"75%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", "Payroll Year")+ "</td>";
	html += "<td>"+ gui.formSelect("pYear", schema+ ".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", ""+ sys.getPeriodYear(schema), "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", "Payroll Month")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", sys.getPeriodMonth(schema), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"rptEs.print('pYear pMonth');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
}

%>