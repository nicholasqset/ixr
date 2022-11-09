<%@page import="org.json.JSONObject"%>
<%@page import="bean.primary.PRStudentProfile"%>
<%@page import="bean.primary.PrimaryCalendar"%>
<%@page import="bean.academic.Academic"%>
<%@page import="java.util.*"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class PerStudent{
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        String table            = comCode+".PRSTUDENTMARKS";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String studentNo        = request.getParameter("studentNo");
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
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
        
        PrimaryCalendar primaryCalendar = new PrimaryCalendar();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("studentNo", " Student No")+ "</td>";
        html += "<td width = \"35%\">"+ gui.formAutoComplete("studentNo", 15, this.id != null? this.studentNo: "", "perStudent.searchStudent", "studentNoHd", this.id != null? this.studentNo: "")+ "</td>";
	
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdFullName\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ " Student Period</td>";
        html += "<td id = \"tdStudentPeriod\">&nbsp;</td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Student Type</td>";
	html += "<td id = \"tdStudentType\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("academicYear", " Academic Year")+ "</td>";
        html += "<td>"+ gui.formSelect("academicYear", "PRACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", ""+ primaryCalendar.academicYear, "onchange = \"perStudent.getSubjects();\"", false)+ "</td>";
        
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("term", " Term")+ "</td>";
	html += "<td>"+ gui.formSelect("term", "PRTERMS", "TERMCODE", "TERMNAME", "", "", primaryCalendar.termCode, "onchange = \"perStudent.getSubjects();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "book-pencil.png", "", "")+ gui.formLabel("exam", " Exam")+ "</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("exam", "PREXAMS", "EXAMCODE", "EXAMNAME", "", "", "", "onchange = \"perStudent.getSubjects();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td colspan = \"3\"><div id = \"progress\">&nbsp;</div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvSubjects\">"+ this.getSubjects()+ "</div></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchStudent(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.studentNo = request.getParameter("studentNoHd");
        
        html += gui.getAutoColsSearch("PRSTUDENTS", "STUDENTNO, FULLNAME", "", this.studentNo);
        
        return html;
    }
    
    public Object getStudentProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.studentNo == null || this.studentNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo);
            
            obj.put("fullName", pRStudentProfile.fullName);
            
            obj.put("studentPeriod", pRStudentProfile.studPrdName);
            obj.put("studentType", pRStudentProfile.studTypeName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Student No '"+pRStudentProfile.studentNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String getSubjects(){
        String html = "";
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        if(sys.recordExists("VIEWPRSTUDENTMARKS", "STUDENTNO = '"+ this.studentNo+ "' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' ")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Subject Code</th>";
            html += "<th>Name</th>";
            html += "<th>Score</th>";
            html += "<th>Grade</th>";
            html += "</tr>";
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM VIEWPRSTUDENTMARKS WHERE STUDENTNO = '"+ this.studentNo+ "' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' ORDER BY SBJID ";
                ResultSet rs = stmt.executeQuery(query);
                
                Integer count = 1;

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String subjectCode  = rs.getString("SUBJECTCODE");
                    String subjectName  = rs.getString("SUBJECTNAME");
                    Double score        = rs.getDouble("SCORE");
                    String grade        = rs.getString("GRADE");
                    
                    String scoreTxt = gui.formInput("text", "score["+ id+"]", 10, ""+ score, "onkeyup = \"perStudent.save("+ id+ ");\"", "");
                    String gradeTxt = gui.formInput("text", "grade["+ id+"]", 5, grade, "", "disabled");
                    
                    html += "<tr>";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ subjectCode+ "</td>";
                    html += "<td>"+ subjectName+ "</td>";
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
    
    public Object save() throws Exception{
        
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