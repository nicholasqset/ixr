<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.high.HighCalendar"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class PresetExam{
         HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String formCode         = request.getParameter("studentForm");
    String examCode         = request.getParameter("exam");
    String subjectCode      = request.getParameter("subject");
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getStudentsTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style = \"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Preset", "cog.png", "onclick = \"presetExam.process('academicYear term studentForm exam subject'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Preset Exam\'), 0, 625, 420, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getStudentsTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        HighCalendar highCalendar = new HighCalendar(this.comCode);
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("academicYear", " Academic Year")+ "</td>";
        html += "<td>"+ gui.formSelect("academicYear", ""+this.comCode+".HGACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", ""+ highCalendar.academicYear, "onchange = \"presetExam.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("term", " Term")+ "</td>";
	html += "<td>"+ gui.formSelect("term", ""+this.comCode+".HGTERMS", "TERMCODE", "TERMNAME", "", "", highCalendar.termCode, "onchange = \"presetExam.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("studentForm", " Student Form")+ "</td>";
	html += "<td>"+ gui.formSelect("studentForm", ""+this.comCode+".HGFORMS", "FORMCODE", "FORMNAME", "", "", "", "onchange = \"presetExam.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "book-pencil.png", "", "")+ gui.formLabel("exam", " Exam")+ "</td>";
	html += "<td>"+ gui.formSelect("exam", ""+this.comCode+".HGEXAMS", "EXAMCODE", "EXAMNAME", "", "", "", "onchange = \"presetExam.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "book-open.png", "", "")+ gui.formLabel("subject", " Subject")+ "</td>";
	html += "<td>"+ gui.formSelect("subject", ""+this.comCode+".HGSUBJECTS", "SUBJECTCODE", "SUBJECTNAME", "ID", "", "", "onchange = \"presetExam.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td><div id = \"progress\">&nbsp;</div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\"><div id = \"dvStudents\">"+ this.getStudents()+ "</div></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String getStudents(){
        String html = "";
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        if(sys.recordExists(""+this.comCode+".VIEWHGSTUDSUBJECTS", "ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND FORMCODE = '"+ this.formCode+ "' AND SUBJECTCODE = '"+ this.subjectCode+ "'")){
            
            String checkAll = gui.formCheckBox("checkall", "", "", "onchange = \"presetExam.checkAll();\"", "", "");
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>"+ checkAll+ "</th>";
            html += "<th>Student No</th>";
            html += "<th>Name</th>";
            html += "</tr>";
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+this.comCode+".VIEWHGSTUDSUBJECTS WHERE ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND FORMCODE = '"+ this.formCode+ "' AND SUBJECTCODE = '"+ this.subjectCode+ "'";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String studentNo    = rs.getString("STUDENTNO");
                    String fullName     = rs.getString("FULLNAME");
                    
                    String registered   = sys.getOne(""+this.comCode+".HGSTUDENTMARKS", "STUDENTNO", "STUDENTNO = '"+ studentNo+ "' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = '"+ this.subjectCode+ "' ");
                    
                    String checked      = registered != null? "checked": ""; 
                    
                    String checkEach = gui.formArrayCheckBox("checkEach", checked, studentNo, "", "", "");
                    
                    html += "<tr>";
                    html += "<td>"+ checkEach+ "</td>";
                    html += "<td>"+ studentNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "</tr>";
                    
                    
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "</table>";
        }else{
            html += "No students record found.";
        }
        
        return html;
    }
    
}

%>