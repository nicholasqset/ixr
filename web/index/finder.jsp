<%@page import="com.qset.gui.Gui"%>
<%
    
   Gui gui = new Gui(); 

    String html = "";
//    html += "<!DOCTYPE html>";
    html += gui.formStart("frmFind", "void%200", "post", "onSubmit=\"javascript:return false;\"");
    html += "<table cellpadding=\"3\"  cellspacing=\"0\"   width=\"100%\" border=\"0\">";

    html += "<tr>";
    html += "<td nowrap>";
//    html += gui.formInput("text", "txtFind", 23, "", "", "autofocus");
    html += "<input type=\"text\" name=\"txtFind\" id=\"txtFind\" autofocus/>";
    html += "&nbsp;";
    html += gui.formButton(request.getContextPath(), "button", "btnFind", "Find", "", "onclick = \"module.find();\"", "");
    html += "</td>";
    html += "</tr>";

    html += "</table>";
    html += gui.formEnd();
//    html += "</html>";

    out.print(html);

%>