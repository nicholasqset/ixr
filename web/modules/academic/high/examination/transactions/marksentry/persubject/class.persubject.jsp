<%@page import="bean.academic.Academic"%>
<%@page import="bean.high.HighCalendar"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class PerSubject{
    String table            = "HGSTUDENTMARKS";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String formCode         = request.getParameter("studentForm");
    String examCode         = request.getParameter("exam");
    String subjectCode      = request.getParameter("subject");
    Double score            = (request.getParameter("score") != null && ! request.getParameter("score").toString().trim().equals(""))? Double.parseDouble(request.getParameter("score")): 0.0;
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getStudentsTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style = \"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Marks Entry\'), 0, 625, 420, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getStudentsTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        HighCalendar highCalendar = new HighCalendar();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("academicYear", " Academic Year")+ "</td>";
        html += "<td width = \"35%\">"+ gui.formSelect("academicYear", "HGACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", ""+ highCalendar.academicYear, "onchange = \"perSubject.getStudents();\"", false)+ "</td>";
        
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("term", " Term")+ "</td>";
	html += "<td>"+ gui.formSelect("term", "HGTERMS", "TERMCODE", "TERMNAME", "", "", highCalendar.termCode, "onchange = \"perSubject.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("studentForm", " Student Form")+ "</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("studentForm", "HGFORMS", "FORMCODE", "FORMNAME", "", "", "", "onchange = \"perSubject.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "book-pencil.png", "", "")+ gui.formLabel("exam", " Exam")+ "</td>";
	html += "<td>"+ gui.formSelect("exam", "HGEXAMS", "EXAMCODE", "EXAMNAME", "", "", "", "onchange = \"perSubject.getStudents();\"", false)+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "book-open.png", "", "")+ gui.formLabel("subject", " Subject")+ "</td>";
	html += "<td>"+ gui.formSelect("subject", "HGSUBJECTS", "SUBJECTCODE", "SUBJECTNAME", "ID", "", "", "onchange = \"perSubject.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td colspan = \"3\"><div id = \"progress\">&nbsp;</div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvStudents\">"+ this.getStudents()+ "</div></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String getStudents(){
        String html = "";
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        if(system.recordExists("VIEWHGSTUDENTMARKS", "ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND FORMCODE = '"+ this.formCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = '"+ this.subjectCode+ "' ")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Student No</th>";
            html += "<th>Name</th>";
            html += "<th>Score</th>";
            html += "<th>Grade</th>";
            html += "</tr>";
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM VIEWHGSTUDENTMARKS WHERE ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND FORMCODE = '"+ this.formCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = '"+ this.subjectCode+ "'";
                ResultSet rs = stmt.executeQuery(query);
                
                Integer count = 1;

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String studentNo    = rs.getString("STUDENTNO");
                    String fullName     = rs.getString("FULLNAME");
                    Double score        = rs.getDouble("SCORE");
                    String grade        = rs.getString("GRADE");
                    
                    String scoreTxt = gui.formInput("text", "score["+ id+"]", 10, ""+ score, "onkeyup = \"perSubject.save("+ id+ ");\"", "");
                    String gradeTxt = gui.formInput("text", "grade["+ id+"]", 5, grade, "", "disabled");
                    
                    html += "<tr>";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ studentNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ scoreTxt+ "</td>";
                    html += "<td>"+ gradeTxt+ "</td>";
                    html += "</tr>";
                    
                    count++;
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
    
    public Object save(){
        
        JSONObject obj = new JSONObject();
        
        Academic academic = new Academic();
        String query = "";
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            
            Integer saved = 0;
            
            String grade = academic.getGrade(this.score);
            
            query = "UPDATE "+ this.table+ " SET "
                    + "SCORE        = "+ this.score+ ", "
                    + "GRADE        = '"+ grade+ "' "
                    + "WHERE ID     = "+ this.id;
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
                
                obj.put("grade", grade);
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "An unexpected error occured while saving record.");
            }
            
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage()+ query);
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
}

%>