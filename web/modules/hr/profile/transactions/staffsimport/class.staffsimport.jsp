<%@page import="com.qset.gui.Gui"%>
<%@page import="java.io.File"%>
<%@page import="java.io.UnsupportedEncodingException"%>
<%@page import="com.qset.security.EncryptionUtil"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="com.qset.user.User"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class StaffsImport{
    String table        = "MODRPTS";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
//        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" enctype = \"multipart/form-data\" target = \"_blank\">";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(), "attach.png", "", "")+" "+gui.formLabel("impfile", "Import File")+" <span class = \"fade\">(excel only)</span></td>";
	html += "<td><input type = \"file\" name = \"impfile\" id = \"impfile\" onchange = \"staffsImport.import(' ');\" > <span><a href = \"./template/template.xls\">template</a></span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
         
        html += gui.formEnd();
        
        html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
        
        return html;
    }
    
}

%>