<%@page import="bean.primary.PrimaryCalendar"%>
<%@page import="java.util.*"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

    final class ProcessMarks {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();

        public String getModule() {
            String html = "";

            Gui gui = new Gui();

            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += "<div id = \"dhtmlgoodies_tabView1\">";

            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getProcessMarksTab() + "</div>";

            html += "</div>";

            html += "<div style = \"padding-left: 10px; padding-top: 40px; border: 0;\" >";
            html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Process", "cog.png", "onclick = \"processExam.process('academicYear term studentClass exam'); return false;\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
            html += "</div>";

            html += gui.formEnd();

            html += "<script type = \"text/javascript\">";
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Process Marks\'), 0, 625, 200, Array(false));";
            html += "</script>";

            return html;
        }

        public String getProcessMarksTab() {
            String html = "";

            Gui gui = new Gui();

            PrimaryCalendar primaryCalendar = new PrimaryCalendar(this.comCode);

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"15%\" nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("academicYear", " Academic Year") + "</td>";
            html += "<td>" + gui.formSelect("academicYear", "" + this.comCode + ".PRACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", "" + primaryCalendar.academicYear, "", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("term", " Term") + "</td>";
            html += "<td>" + gui.formSelect("term", "" + this.comCode + ".PRTERMS", "TERMCODE", "TERMNAME", "", "", primaryCalendar.termCode, "", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("studentClass", " Student Class") + "</td>";
            html += "<td>" + gui.formSelect("studentClass", "" + this.comCode + ".VIEWPRCLASSES", "CLASSCODE", "CLASSNAME", "", "", "", "", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "book-pencil.png", "", "") + gui.formLabel("exam", " Exam") + "</td>";
            html += "<td>" + gui.formSelect("exam", "" + this.comCode + ".PREXAMS", "EXAMCODE", "EXAMNAME", "", "", "", "", false) + "</td>";
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