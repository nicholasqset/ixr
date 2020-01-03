<%-- 
    Document   : class.PeriodEnd
    Created on : Oct 15, 2018, 10:43:44 AM
    Author     : nicholas
--%>

<%@page import="bean.gui.Gui"%>
<%@page import="bean.sys.Sys"%>
<%
    final class PeriodEnd{
        public String getModule(){
            String html = "";
            
            Gui gui = new Gui();
        
            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += "<div id = \"dhtmlgoodies_tabView1\">";

            html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getProcessTab()+ "</div>";

            html += "</div>";

            html += "<div style = \"padding-left: 10px; padding-top: 40px; border: 0;\" >";
            html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Process", "cog.png", "onclick = \"periodEnd.process('pYear pMonth nextPyear nextPmonth'); return false;\"", "");
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
            html += "<td nowrap width = \"17%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Current Year")+ "</td>";
            html += "<td>"+ gui.formSelect("pYear", "qset.FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "PYEAR = "+ system.getPeriodYear(), ""+ system.getPeriodYear(), "", false)+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Current Month")+ "</td>";
            html += "<td>"+ gui.formOneMonthSelect("pMonth", system.getPeriodMonth(), "", true)+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"2\">&nbsp;</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td><div id = \"progress\">&nbsp;</div></td>";
            html += "</tr>";

            html += "</table>";

            return html;
        }
    }
%>
