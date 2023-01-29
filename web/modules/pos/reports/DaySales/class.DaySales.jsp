<%@page import="java.util.HashMap"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class DaySales{
        
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
        
        HashMap<String, String> hmPayMode = new HashMap();
        hmPayMode.put("all", "All");
        hmPayMode.put("CASH", "CASH");
        hmPayMode.put("MPESA", "MPESA");
        hmPayMode.put("BANK", "BANK");
        
        HashMap<String, String> hmPrintForm = new HashMap();
        hmPrintForm.put("web", "Web");
        hmPrintForm.put("xls", "Excel");
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<table width = \"75%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", "Date of Sales")+ "</td>";
	html += "<td>"+ gui.formDateTime(request.getContextPath(), "entryDate", 15, defaultDate, false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("payMode", " Payment Mode")+"</td>";
	html += "<td>"+ gui.formArraySelect("payMode", 100, hmPayMode, "all", false, "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "printer.png", "", "")+ gui.formLabel("printForm", " Printing Output")+"</td>";
	html += "<td>"+ gui.formArraySelect("printForm", 100, hmPrintForm, "", false, "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"daySales.print('entryDate');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
}

%>