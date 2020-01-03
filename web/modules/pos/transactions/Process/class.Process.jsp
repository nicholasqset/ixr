<%@page import="bean.gui.Gui"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Process{
        
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style = \"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Process", "cog.png", "onclick = \"post.process('pYear pMonth'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Process\'), 0, 625, 130, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys system = new Sys();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("pYear", " Year")+ "</td>";
//        html += "<td>"+ gui.formYearSelect("pYear", 2015, 2016, 2016, "", false)+ "</td>";
        html += "<td>"+ gui.formSelect("pYear", "FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "PYEAR = "+ system.getPeriodYear(), ""+ system.getPeriodYear(), "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Month")+ "</td>";
//	html += "<td>"+ gui.formMonthSelect( "pMonth", 7, "" ,false)+ "</td>";
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