<%@page import="com.qset.sys.Sys"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.hr.StaffProfile"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%

final class Staff{
        
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
    
    String catCode      = request.getParameter("category");
    
    public String getModule(){
        String html = "";
        Gui gui = new Gui();
        Sys system = new Sys();
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        String defaultDate = system.getLogDate();

        try{
            java.util.Date today = originalFormat.parse(defaultDate);
            defaultDate = targetFormat.format(today);
        }catch (Exception e){
            html += e.getMessage();
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<table width = \"75%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+ gui.formLabel("staffStatus", " Staff Status")+"</td>";
	html += "<td>"+ gui.formSelect("staffStatus", this.comCode+".HRSTATUS", "STATUSCODE", "STATUSNAME", "", "", "", "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"stock.print('entryDate');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
}

%>