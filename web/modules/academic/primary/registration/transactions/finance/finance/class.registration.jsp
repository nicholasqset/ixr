<%@page import="org.json.JSONObject"%>
<%@page import="com.qset.primary.PrimaryCalendar"%>
<%@page import="com.qset.primary.PRStudentProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class Registration{
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        String table            = comCode+".PRREGISTRATION";
    String view             = comCode+".VIEWPRREGISTRATION";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String studentNo        = request.getParameter("studentNo");
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    Double feesBal          = (request.getParameter("feesBalance") != null && ! request.getParameter("feesBalance").toString().trim().equals(""))? Double.parseDouble(request.getParameter("feesBalance")): 0.0;
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
        Integer recordCount = sys.getRecordCount(this.view, "");
        
        if(recordCount > 0){
        
            String gridSql;
            String filterSql        = "";
            Integer startRecord     = 0;
            Integer maxRecord       = 10;

            Integer maxRecordHidden = request.getParameter("maxRecord") != null? Integer.parseInt(request.getParameter("maxRecord")): null;
            Integer pageSize        = maxRecordHidden != null? maxRecordHidden: maxRecord;
            maxRecord               = maxRecordHidden != null? maxRecordHidden: maxRecord;

            HttpSession session     = request.getSession();
            session.setAttribute("maxRecord", maxRecord);

            String act              = request.getParameter("act");

            if(act != null){
                if(act.equals("find")){
                    String find = request.getParameter("find");
                    if(find != null){
                        session.setAttribute("startRecord", startRecord);

                        ArrayList<String> list = new ArrayList();

                        list.add("STUDENTNO");
                        list.add("FULLNAME");
                        list.add("ACADEMICYEAR");
                        list.add("TERMNAME");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+find+"%' ";
                            }else{
                                filterSql += " OR ( UPPER("+list.get(i)+") LIKE '%"+find+"%' ";
                            }
                            filterSql += ")";
                        }
                    }
                }
            }

            Integer useGrid         = request.getParameter("maxRecord") != null? Integer.parseInt(request.getParameter("maxRecord")): null;
            String gridAction       = request.getParameter("gridAction");

            if(useGrid != null){
                if(gridAction.equals("gridNext")){
                    if (session.getAttribute("startRecord") != null) {
                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) >= startRecord){
                            session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) + pageSize);
                        }else{
                            session.setAttribute("startRecord", startRecord);
                        }

                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) == recordCount){
                            session.setAttribute("startRecord", startRecord);
                        }

                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) > recordCount){
                            session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) - pageSize);
                        }
                    }else{
                        session.setAttribute("startRecord", startRecord);
                    }
                }else if(gridAction.equals("gridPrevious")){
                    if (session.getAttribute("startRecord") != null) {
                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) > startRecord){
                            session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) - pageSize);
                        }else{
                            session.setAttribute("startRecord", startRecord);
                        }
                    }else{
                        session.setAttribute("startRecord", startRecord);
                    }
                }else if(gridAction.equals("gridFirst")){
                    session.setAttribute("startRecord", startRecord);
                }else if(gridAction.equals("gridLast")){
                    session.setAttribute("startRecord", recordCount - pageSize);
                }else{
                    session.setAttribute("startRecord", 0);
                }
            }else{
                session.setAttribute("startRecord", 0);
            }

            String orderBy = "ACADEMICYEAR DESC, TERMCODE DESC, STUDENTNO ";
            String limitSql = "";

            switch(dbType){
                case "mysql":
                    limitSql = "LIMIT "+ session.getAttribute("startRecord")+ " , "+ session.getAttribute("maxRecord");
                    break;
                case "postgres":
                    limitSql = "OFFSET "+ session.getAttribute("startRecord")+ " LIMIT "+ session.getAttribute("maxRecord");
                    break;
            }

            gridSql = "SELECT * FROM "+ this.view+ " "+ filterSql+ " ORDER BY "+ orderBy+ limitSql;

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(gridSql);

                Integer startRecordHidden = Integer.parseInt(session.getAttribute("startRecord").toString()) + Integer.parseInt(session.getAttribute("maxRecord").toString());

                html += gui.formInput("hidden", "maxRecord", 10, session.getAttribute("maxRecord").toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                html += "<table class = \"grid\" width=\"100%\" cellpadding=\"2\" cellspacing=\"0\" border=\"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Student No</th>";
                html += "<th>Name</th>";
                html += "<th>Academic Year</th>";
                html += "<th>Term</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id              = rs.getInt("ID");
                    String studentNo        = rs.getString("STUDENTNO");
                    String fullName         = rs.getString("FULLNAME");
                    String academicYear     = rs.getString("ACADEMICYEAR");
                    String termName         = rs.getString("TERMNAME");
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String view = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "view", "view", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ studentNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ academicYear+ "</td>";
                    html += "<td>"+ termName+ "</td>";
                    html += "<td>"+ view+ "</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
            }catch(SQLException e){
                html += e.getMessage();
            }catch(Exception e){
                html += e.getMessage();
            }
        }else{
            html += "No records found.";
        }
        
        return html;
    }
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getRegistrationTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
        
        if(this.id == null){
            html += gui.formButton(request.getContextPath(), "button", "btnRegister", "Register", "save.png", "onclick = \"registration.save('studentNo academicYear term feesBalance'); return false;\"", "");
        }
        
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Registration\'), 0, 625, 420, Array(false));";
        html += "</script>";
        
        
        return html;
    }
    
    public String getRegistrationTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        String fullName     = "";
        String studPrdName  = "";
        String studTypeName = "";
        
        if(this.id != null){
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.view+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.studentNo      = rs.getString("STUDENTNO");		
                    
                    PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo, this.comCode);
                    
                    fullName            = pRStudentProfile.fullName;
                    studPrdName         = pRStudentProfile.studPrdName;
                    studTypeName        = pRStudentProfile.studTypeName;
                    
                    this.academicYear   = rs.getInt("ACADEMICYEAR");		
                    this.termCode       = rs.getString("TERMCODE");
                    this.feesBal        = rs.getDouble("FEESBAL");
                    
                }
            }catch(SQLException e){
                html += e.getMessage();
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        PrimaryCalendar primaryCalendar = new PrimaryCalendar(this.comCode);
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("studentNo", " Student No")+ "</td>";
        html += "<td width = \"35%\">"+ gui.formAutoComplete("studentNo", 15, this.id != null? this.studentNo: "", "registration.searchStudent", "studentNoHd", this.id != null? this.studentNo: "")+ "</td>";
	
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdFullName\">"+ fullName+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ " Student Period</td>";
        html += "<td id = \"tdStudentPeriod\">"+ studPrdName+ "</td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Student Type</td>";
	html += "<td id = \"tdStudentType\">"+ studTypeName+ "</td>";
	html += "</tr>";
               
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("academicYear", " Academic Year")+ "</td>";
        html += "<td >"+ gui.formSelect("academicYear", ""+this.comCode+".PRACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", this.id != null? ""+ this.academicYear: ""+ primaryCalendar.academicYear, "", false)+ "</td>";
	
	html += "<td >"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("term", " Term")+ "</td>";
	html += "<td>"+ gui.formSelect("term", ""+this.comCode+".PRTERMS", "TERMCODE", "TERMNAME", "", "", this.id != null? this.termCode: primaryCalendar.termCode, "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("feesBalance", " Fees Balance")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "feesBalance", 15, this.id != null? ""+ this.feesBal: "", "", "disabled")+"</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchStudent(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.studentNo = request.getParameter("studentNoHd");
        
        html += gui.getAutoColsSearch(""+this.comCode+".PRSTUDENTS", "STUDENTNO, FULLNAME", "", this.studentNo);
        
        return html;
    }
    
    public Object getStudentProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.studentNo == null || this.studentNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo, this.comCode);
            
            obj.put("fullName", pRStudentProfile.fullName);
            
            obj.put("studentPeriod", pRStudentProfile.studPrdName);
            obj.put("studentType", pRStudentProfile.studTypeName);
            obj.put("feesBalance", pRStudentProfile.getFeesBalance());
            
            obj.put("success", new Integer(1));
            obj.put("message", "Student No '"+pRStudentProfile.studentNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object save() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        String invAmountStr = sys.getOne(""+this.comCode+".VIEWPROBS", "AMOUNT", "STUDENTNO = '"+ this.studentNo+ "' AND "
                + "ACADEMICYEAR = "+ this.academicYear+ " AND "
                + "TERMCODE     = '"+ this.termCode+ "'");
        
        try{
            if(this.feesBal <= 0 && invAmountStr != null){
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                Integer id = sys.generateId(this.table, "ID");

                String query = "INSERT INTO "+ this.table+ " "
                            + "(ID, STUDENTNO, ACADEMICYEAR, TERMCODE, FEESBAL, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + id+ ", "
                            + "'"+ this.studentNo+ "', "
                            + this.academicYear+ ", "
                            + "'"+ this.termCode+ "', "
                            + this.feesBal+ ", "
                            + "'"+ sys.getLogUser(session)+"', "
                            + "'"+ sys.getLogDate()+ "', "
                            + "'"+ sys.getLogTime()+ "', "
                            + "'"+ sys.getClientIpAdr(request)+ "'"
                            + ")";

                Integer saved = stmt.executeUpdate(query);

                if(saved == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Registration failed. Fees not cleared or Student not invoiced.");
            }
            

        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
}

%>