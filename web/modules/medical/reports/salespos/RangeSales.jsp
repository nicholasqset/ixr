<%@page import="java.util.HashMap"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class RangeSales{
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
//    Integer pYear       = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
//    Integer pMonth      = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
    
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
        hmPayMode.put("BANK", "OTHER");
        
        HashMap<String, String> hmPrintForm = new HashMap();
        hmPrintForm.put("web", "Web");
//        hmPrintForm.put("xls", "Excel");
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<table width = \"75%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate1", "First Date")+ "</td>";
	html += "<td width = \"35%\">"+ gui.formDateTime(request.getContextPath(), "entryDate1", 15, defaultDate, false, "")+"</td>";
        
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate2", "Second Date")+ "</td>";
	html += "<td>"+ gui.formDateTime(request.getContextPath(), "entryDate2", 15, defaultDate, false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("payMode", " Payment Mode")+"</td>";
	html += "<td>"+ gui.formArraySelect("payMode", 100, hmPayMode, "all", false, "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "printer.png", "", "")+ gui.formLabel("category", " Printing Output")+"</td>";
	html += "<td colspan=\"3\">"+ gui.formArraySelect("printForm", 100, hmPrintForm, "", false, "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td colspan = \"3\">";
	html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"rangeSales.print('entryDate1 entryDate2');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
}

%>