<%@page import="java.util.HashMap"%>
<%@page import="bean.sys.Sys"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%

final class ExpStock{
        
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
        
        HashMap<String, String> hmStockGroup = new HashMap();
//        hmStockGroup.put("all", "All");
//        hmStockGroup.put("low", "Low Stock");
        hmStockGroup.put("exp", "Expired");
        
        HashMap<String, String> hmPrintForm = new HashMap();
        hmPrintForm.put("web", "Web");
//        hmPrintForm.put("xls", "Excel");
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<table width = \"75%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", "Date Between")+ "</td>";
	html += "<td>"
                + gui.formDateTime(request.getContextPath(), "startDate", 15, defaultDate, false, "")
                + " and "
                + gui.formDateTime(request.getContextPath(), "endDate", 15, defaultDate, false, "")
                +"</td>";
	html += "</tr>";
        
//        html += "<tr>";
//	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("stockGroup", " Stock Group")+"</td>";
//	html += "<td>"+ gui.formArraySelect("stockGroup", 100, hmStockGroup, "", false, "", false)+ "</td>";
//	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"printer.png", "", "")+ gui.formLabel("category", " Printing Output")+"</td>";
	html += "<td>"+ gui.formArraySelect("printForm", 100, hmPrintForm, "", false, "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"stock.print('entryDate');\"", "");
	html += " ";
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
}

%>