<%@page import="org.json.JSONObject"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.primary.PrimaryCalendar"%>
<%@page import="bean.primary.PRStudentProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Students{
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        String table            = comCode+".PRSTUDENTS";
    String view             = comCode+".VIEWPRSTUDENTPROFILE";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    
    String studentNo        = this.id != null? request.getParameter("studentNoHd"): request.getParameter("studentNo");
    Integer autoStudentNo   = request.getParameter("autoStudentNo") != null? 1: null;
    String firstName        = request.getParameter("firstName");
    String middleName       = request.getParameter("middleName");
    String lastName         = request.getParameter("lastName");
    String genderCode       = request.getParameter("gender");
    String dob              = request.getParameter("dob");
    String countryCode      = request.getParameter("country");
    String nationalId       = request.getParameter("nationalId");
    String passportNo       = request.getParameter("passportNo");
    Integer physChald       = request.getParameter("physChald") != null? 1: null;
    String disabCode        = request.getParameter("disability");
    String postalAdr        = request.getParameter("postalAdr");
    String postalCode       = request.getParameter("postalCode");
    String physicalAdr      = request.getParameter("physicalAdr");
    String telephone        = request.getParameter("telephone");
    String cellphone        = request.getParameter("cellphone");
    String email            = request.getParameter("email");
    
    String admGrp           = request.getParameter("admissionGroup");
    String streamCode       = request.getParameter("stream");
    String studPrdCode      = request.getParameter("studentPeriod");
    String studTypeCode     = request.getParameter("studentType");
    String statusCode       = request.getParameter("studentStatus");
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
        Integer recordCount = sys.getRecordCount(this.table, "");
        
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

//            gridSql = "SELECT * FROM "+this.view+" "+filterSql+" ORDER BY ADMGRP DESC, CLASSCODE DESC, STREAMCODE DESC, STUDENTNO LIMIT "
//                    + session.getAttribute("startRecord")
//                    + " , "
//                    + session.getAttribute("maxRecord");
            
            String orderBy = "ADMGRP DESC, CLASSCODE DESC, STREAMCODE DESC, STUDENTNO ";
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

                html += "<table class = \"grid\" width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" border = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Student No</th>";
                html += "<th>Name</th>";
                html += "<th>Gender</th>";
                html += "<th>Admission Group</th>";
                html += "<th>Class</th>";
                html += "<th>Term</th>";
                html += "<th>Stream</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String studentNo    = rs.getString("STUDENTNO");
                    String fullName     = rs.getString("FULLNAME");
                    String genderName   = rs.getString("GENDERNAME");
                    String admGrp       = rs.getString("ADMGRP");
                    String className    = rs.getString("CLASSNAME");
                    String termName     = rs.getString("TERMNAME");
                    String streamName   = rs.getString("STREAMNAME");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ studentNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ genderName+ "</td>";
                    html += "<td>"+ admGrp+ "</td>";
                    html += "<td>"+ className+ "</td>";
                    html += "<td>"+ termName+ "</td>";
                    html += "<td>"+ streamName+ "</td>";
                    html += "<td>"+ edit+ "</td>";
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
            
        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
        
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getBioDataTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getContactTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getAcademicTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"students.save('firstName lastName gender dob country admissionGroup stream studentPeriod studentType studentStatus'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\', \'Academic\'), 0, 625, 350, Array(false, false, false));";
        html += "</script>";
        
        html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
        
        return html;
    }
    
    public String getBioDataTab(){
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        String html = "";
        
        if(this.id != null){
            
            try{
                stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.studentNo           = rs.getString("STUDENTNO");		
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo);
            
            this.firstName          = pRStudentProfile.firstName;
            this.middleName         = pRStudentProfile.middleName;
            this.lastName           = pRStudentProfile.lastName;
            this.genderCode         = pRStudentProfile.genderCode;
            this.dob                = pRStudentProfile.dob;
            this.countryCode        = pRStudentProfile.countryCode;
            this.nationalId         = pRStudentProfile.nationalId;
            this.passportNo         = pRStudentProfile.passportNo;
            this.physChald          = pRStudentProfile.physChald;
            this.disabCode          = pRStudentProfile.disabCode;
            this.postalAdr          = pRStudentProfile.postalAdr;
            this.postalCode         = pRStudentProfile.postalCode;
            this.physicalAdr        = pRStudentProfile.physicalAdr;
            this.telephone          = pRStudentProfile.telephone;
            this.cellphone          = pRStudentProfile.cellphone;
            this.email              = pRStudentProfile.email;
            this.admGrp             = pRStudentProfile.admGrp;
            this.streamCode         = pRStudentProfile.streamCode;
            this.studPrdCode        = pRStudentProfile.studPrdCode;
            this.studTypeCode       = pRStudentProfile.studTypeCode;
            this.statusCode         = pRStudentProfile.statusCode;
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            try{
                java.util.Date dob = originalFormat.parse(this.dob);
                this.dob = targetFormat.format(dob);
            }catch(ParseException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        String defaultCountryCode = sys.getOne("CSCOUNTRIES", "COUNTRYCODE", "ISDEFAULT = 1");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"doctor-male.png", "", "")+" "+gui.formLabel("studentNo", "Student No")+"</td>";
        String studentNoUi;
        String autoStudentNoUi;
        if(this.id != null){
            studentNoUi      = gui.formAutoComplete("studentNo", 15, this.id != null? this.studentNo: "", "students.searchStudent", "studentNoHd", this.id != null? this.studentNo: "");
            autoStudentNoUi  = "";
        }else{
            studentNoUi      = gui.formInput("text", "studentNo", 15, "" , "", "disabled");
            autoStudentNoUi  = gui.formCheckBox("autoStudentNo", "checked", "", "onchange = \"students.toggleStudentNo();\"", "", "")+ "<span class = \"fade\"><label for = \"autoStudentNo\"> Auto Number</label></span>";
        }
        
        html += "<td colspan = \"3\">"+studentNoUi+" "+autoStudentNoUi+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("firstName", "First Name")+"</td>";
	html += "<td colspan = \"2\">"+gui.formInput("text", "firstName", 25, this.id != null? this.firstName: "", "", "")+"</td>";
         if(this.id != null){
            String imgPhotoSrc;
            if(hasPhoto(this.studentNo)){
                imgPhotoSrc = "photo.jsp?studentNo="+this.studentNo;
            }else{
                imgPhotoSrc = request.getContextPath()+"/images/emblems/places-user-identity.png";
            }
            
            html += "<td rowspan = \"5\">";
            html += "<div class = \"divPhoto\"><img id = \"imgPhoto\" src=\""+imgPhotoSrc+"\"></div>";
            html += "</td>";
        }
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("middleName", "Middle Name")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "middleName", 25, this.id != null? this.middleName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("lastName", "Last Name")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "lastName", 25, this.id != null? this.lastName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"gender.png", "", "")+" "+gui.formLabel("gender", "Gender")+"</td>";
	html += "<td colspan = \"3\">"+gui.formSelect("gender", "CSGENDER", "GENDERCODE", "GENDERNAME", null, null, this.id != null? this.genderCode: "", null, false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "")+" "+gui.formLabel("dob", "Date of Birth")+"</td>";
	html += "<td colspan = \"3\">"+gui.formDateTime(request.getContextPath(), "dob", 15, this.id != null? this.dob: "", false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"globe-medium-green.png", "", "")+ gui.formLabel("country", " Country")+"</td>";
	html += "<td colspan = \"3\">"+gui.formSelect("country", "CSCOUNTRIES", "COUNTRYCODE", "COUNTRYNAME", null, null, this.id != null? this.countryCode: defaultCountryCode, null, false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("nationalId", "National ID")+"</td>";
	html += "<td width = \"30%\">"+gui.formInput("text", "nationalId", 15, this.id != null? this.nationalId: "", "", "")+"</td>";
	
	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("passportNo", "Passport No")+"</td>";
	html += "<td>"+gui.formInput("text", "passportNo", 15, this.id != null? this.passportNo: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("physChald", "Physically Challenged")+"</td>";
	html += "<td>"+gui.formCheckBox("physChald", (this.id != null && this.physChald == 1)? "checked": "", null, "onchange = \"students.toggleDisab();\"", "", "")+"</td>";
	
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"apps-accessibility.png", "", "")+" "+gui.formLabel("disability", "Physical Disability")+"</td>";
	html += "<td>"+gui.formSelect("disability", "CSDISAB", "DISABCODE", "DISABNAME", null, null, this.id != null? this.disabCode: "", (this.id != null && this.physChald == 1) ? "": "disabled", false)+"</td>";
	html += "</tr>";
        
        html += "</table>";
        
        if(this.id != null){
            html += " <script type=\"text/javascript\">"
                    +   "Event.observe(\'imgPhoto\', \'mouseover\' , function(){"
                    +       "if($(\'divPhotoOptions\')){"
                    +           "$(\'divPhotoOptions\')"
                    +           ".absolutize()"
                    +           ".setStyle({display:\'table-cell\'})"
                    +           ".clonePosition($(\'imgPhoto\'));"
                    +       "}"
                    +   "});"
                    + "</script>";
                        
            html += "<div id = \"divPhotoOptions\" onmouseout = \"students.hidePhotoOptions();\" style = \"display: none; background-color: #000000; opacity: 0.4; text-align: center;\">";
            html += "<input name = \"photo\" id = \"photo\" type = \"file\" onchange = \"students.uploadPhoto();\" style = \"display: none;\">";
            html += "<div style = \"padding-top: 50px;\">";
            html += "<a href = \"javascript:;\" onclick = \"$('photo').click();\">upload</a>";
            html += "</div>";
            if(this.hasPhoto(this.studentNo)){
                html += "<div >";
                html += gui.formHref("onclick = \"students.purgePhoto('"+this.studentNo+"', '"+this.lastName+"')\"", request.getContextPath(), "", "remove", "remove", "", "");
                html += "</div>";
            }
            html += "</div>";
        }
        
        return html;
    }
    
    public String searchStudent(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.studentNo = request.getParameter("studentNoHd");
        
        html += gui.getAutoColsSearch("PRSTUDENTS", "STUDENTNO, FULLNAME", "", this.studentNo);
        
        return html;
    }
    
    public Boolean hasPhoto(String studentNo){
        Boolean hasPhoto = false;
        
        if(this.id != null){
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;
            
            Integer count = 0;
            
            try{
                stmt = conn.createStatement();
                String query = "SELECT COUNT(*)CT FROM PRSTUDPHOTOS WHERE STUDENTNO = '"+studentNo+"'";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    count      = rs.getInt("CT");		
                }
                
                if(count > 0){
                    hasPhoto = true;
                }
                
            }catch (SQLException e){
                e.getMessage();
            } 
        }
        
        return hasPhoto;
    }
    
    public String getContactTab(){
        String html = "";
        Gui gui = new Gui();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"20%\">"+gui.formIcon(request.getContextPath(),"email-open.png", "", "")+" "+gui.formLabel("postalAdr", "Postal Address")+"</td>";
	html += "<td width = \"30%\">"+gui.formInput("text", "postalAdr", 20, this.id != null? this.postalAdr: "", "", "")+"</td>";
	
	html += "<td width = \"20%\">"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("postalCode", "Postal Code")+"</td>";
	html += "<td>"+gui.formInput("text", "postalCode", 15, this.id != null? this.postalCode: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("physicalAdr", "Physical Address")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("textarea", "physicalAdr", 30, this.id != null? this.physicalAdr: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"telephone.png", "", "")+" "+gui.formLabel("telephone", "Telephone")+"</td>";
	html += "<td>"+gui.formInput("text", "telephone", 15, this.id != null? this.telephone: "", "", "")+"</td>";
	
	html += "<td>"+gui.formIcon(request.getContextPath(),"mobile-phone.png", "", "")+" "+gui.formLabel("cellphone", "Cell Phone")+"</td>";
	html += "<td>"+gui.formInput("text", "cellphone", 15, this.id != null? this.cellphone: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"email.png", "", "")+" "+gui.formLabel("email", "Email")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "email", 25, this.id != null? this.email: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String getAcademicTab(){
        String html = "";
        Gui gui = new Gui();
        
        HashMap<String, String> studentPeriods = new HashMap();
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM PRSTUDPRDS WHERE CLASSCODE IN(SELECT CLASSCODE FROM PRSTREAMS WHERE STREAMCODE = '"+ this.streamCode+ "')";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){

                    String studPrdCode = rs.getString("STUDPRDCODE");
                    String studPrdName = rs.getString("STUDPRDNAME");

                    studentPeriods.put(studPrdCode, studPrdName);

                }

            }catch(SQLException e){
                html += e.getMessage();
            }
        }
        
        PrimaryCalendar primaryCalendar = new PrimaryCalendar();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("admissionGroup", " Admission Group")+ "</td>";
        html += "<td>"+ gui.formSelect("admissionGroup", "PRACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", this.id != null? ""+ this.admGrp: ""+ primaryCalendar.academicYear, "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"20%\">"+ gui.formIcon(request.getContextPath(),"house.png", "", "")+ gui.formLabel("stream", " Class Stream")+"</td>";
        html += "<td width = \"30%\">"+ gui.formSelect("stream", "VIEWPRSTREAMS", "STREAMCODE", "STREAMNAME", "STUDYRLEVEL, STREAMCODE", "", this.id != null? this.streamCode: "", "onchange = \"students.getStudPrdsUi();\"", false)+ "</td>";
	
	html += "<td width = \"20%\">"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("studentPeriod", " Student Period")+"</td>";
	html += "<td id = \"tdStudentPeriod\">"+ gui.formArraySelect("studentPeriod", 150, studentPeriods, this.id != null? this.studPrdCode: "", false, "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("studentType", " Student Type")+ "</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("studentType", "PRSTUDTYPES", "STUDTYPECODE", "STUDTYPENAME", "", "", this.id != null? this.studTypeCode: "", "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("studentStatus", " Student Status")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("studentStatus", "PRSTUDSTATUS", "STATUSCODE", "STATUSNAME", "", "", this.id != null? this.statusCode: "", "", false)+ "</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public Object getStudentProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.studentNo == null || this.studentNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo);
            
            obj.put("id", pRStudentProfile.id);
            obj.put("firstName", pRStudentProfile.firstName);
            obj.put("middleName", pRStudentProfile.middleName);
            obj.put("lastName", pRStudentProfile.lastName);
            obj.put("gender", pRStudentProfile.genderCode);
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            try{
                java.util.Date dob = originalFormat.parse(pRStudentProfile.dob);
                pRStudentProfile.dob = targetFormat.format(dob);
            }catch(ParseException e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }
            
            obj.put("dob", pRStudentProfile.dob);
            obj.put("country", pRStudentProfile.countryCode);
            obj.put("physChald", pRStudentProfile.physChald);
            obj.put("disability", pRStudentProfile.disabCode);
            obj.put("postalAdr", pRStudentProfile.postalAdr);
            obj.put("postalCode", pRStudentProfile.postalCode);
            obj.put("physicalAdr", pRStudentProfile.physicalAdr);
            obj.put("telephone", pRStudentProfile.telephone);
            obj.put("cellphone", pRStudentProfile.cellphone);
            obj.put("email", pRStudentProfile.email);
            
            obj.put("stream", pRStudentProfile.streamCode);
            obj.put("studentPeriod", pRStudentProfile.studPrdCode);
            obj.put("studentType", pRStudentProfile.studTypeCode);
            obj.put("studentStatus", pRStudentProfile.statusCode);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Student No '"+pRStudentProfile.studentNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object getStudPrdsUi() throws Exception{
        JSONObject obj = new JSONObject();
        Gui gui = new Gui();
        HashMap<String, String> studentPeriods = new HashMap();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM PRSTUDPRDS WHERE CLASSCODE IN(SELECT CLASSCODE FROM PRSTREAMS WHERE STREAMCODE = '"+ this.streamCode+ "')";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                
                String studPrdCode = rs.getString("STUDPRDCODE");
                String studPrdName = rs.getString("STUDPRDNAME");
                
                studentPeriods.put(studPrdCode, studPrdName);
                
            }
            
        }catch(SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        if(this.id != null){
            PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo);
            this.studPrdCode = pRStudentProfile.studPrdCode;
        }
        
        String studPrdUi = gui.formArraySelect("studentPeriod", 150, studentPeriods, this.id != null? this.studPrdCode: "", false, "", true);
        obj.put("studPrdUi", studPrdUi);
        
        obj.put("success", new Integer(1));
        obj.put("message", "ok");
            
        return obj;
    }
    
    public Object save() throws Exception{
        
        JSONObject obj      = new JSONObject();
        Sys system       = new Sys();
        HttpSession session = request.getSession();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;
            stmt = conn.createStatement();
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
            SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

            java.util.Date dob = originalFormat.parse(this.dob);
            this.dob = targetFormat.format(dob);
            
            String query = "";
            Integer saved = 0;
	            
            if(this.id == null){
                Integer id = system.generateId(this.table, "ID");
                
                if(this.autoStudentNo == 1){
                    this.studentNo = this.getNextStudentNo();
                }
                
                query += "INSERT INTO "+this.table+" "
                        + "(ID, STUDENTNO, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, "
                        + "GENDERCODE, DOB, COUNTRYCODE, NATIONALID, PASSPORTNO, PHYSCHALD, DISABCODE, "
                        + "POSTALADR, POSTALCODE, PHYSICALADR, TELEPHONE, CELLPHONE, EMAIL, ADMGRP, STREAMCODE, "
                        + "STUDPRDCODE, STUDTYPECODE, STATUSCODE, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ") "
                        + "VALUES"
                        + "("
                        + id+ ","
                        + "'"+ this.studentNo+ "', "
                        + "'"+ this.firstName+ "', "
                        + "'"+ this.middleName+ "', "
                        + "'"+ this.lastName+ "', "
                        + "'"+ this.firstName+ " "+ this.middleName+ " " +this.lastName+ "', "
                        + "'"+ this.genderCode+ "', "
                        + "'"+ this.dob+ "', "
                        + "'"+ this.countryCode+ "', "
                        + "'"+ this.nationalId+ "', "
                        + "'"+ this.passportNo+ "', "
                        + this.physChald+ ", "
                        + "'"+ this.disabCode+ "', "
                        + "'"+ this.postalAdr+ "', "
                        + "'"+ this.postalCode+ "', "
                        + "'"+ this.physicalAdr+ "', "
                        + "'"+ this.telephone+ "', "
                        + "'"+ this.cellphone+ "', "
                        + "'"+ this.email+ "', "
                        + "'"+ this.admGrp+ "', "
                        + "'"+ this.streamCode+ "', "
                        + "'"+ this.studPrdCode+ "', "
                        + "'"+ this.studTypeCode+ "', "
                        + "'"+ this.statusCode+ "', "
                        + "'"+ system.getLogUser(session)+ "', "
                        + "'"+ system.getLogDate()+ "', "
                        + "'"+ system.getLogTime()+ "', "
                        + "'"+ system.getClientIpAdr(request)+ "'"
                        + ")";
                
                obj.put("studentNo", this.studentNo);
                
            }else{
                
                if(this.studentNo == null || this.studentNo.trim().equals("")){
                    
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record. Could not retrieve Student No.");
                    
                }else{
                    query = "UPDATE "+this.table+" SET "
                            
                            + "FIRSTNAME        = '"+ this.firstName+ "', "
                            + "MIDDLENAME       = '"+ this.middleName+ "', "
                            + "LASTNAME         = '"+ this.lastName+ "',"
                            + "FULLNAME         = '"+ this.firstName+ " "+this.middleName+ " "+this.lastName+ "', "
                            + "GENDERCODE       = '"+ this.genderCode+ "', "
                            + "DOB              = '"+ this.dob+ "', "
                            + "COUNTRYCODE      = '"+ this.countryCode+ "', "
                            + "NATIONALID       = '"+ this.nationalId+ "', "
                            + "PASSPORTNO       = '"+ this.passportNo+ "', "
                            + "PHYSCHALD        = "+ this.physChald+ ", "
                            + "DISABCODE        = '"+ this.disabCode+ "', "
                            + "POSTALADR        = '"+ this.postalAdr+ "', "
                            + "POSTALCODE       = '"+ this.postalCode+ "', "
                            + "PHYSICALADR      = '"+ this.physicalAdr+ "', "
                            + "TELEPHONE        = '"+ this.telephone+ "', "
                            + "CELLPHONE        = '"+ this.cellphone+ "', "
                            + "EMAIL            = '"+ this.email+ "', "
                            + "ADMGRP           = '"+ this.admGrp+ "', "
                            + "STREAMCODE       = '"+ this.streamCode+ "', "
                            + "STUDPRDCODE      = '"+ this.studPrdCode+ "', "
                            + "STUDTYPECODE     = '"+ this.studTypeCode+ "', "
                            + "STATUSCODE       = '"+ this.statusCode+ "', "
                            + "AUDITUSER        = '"+ system.getLogUser(session)+ "', "
                            + "AUDITDATE        = '"+ system.getLogDate()+ "', "
                            + "AUDITTIME        = '"+ system.getLogTime()+ "', "
                            + "AUDITIPADR       = '"+ system.getClientIpAdr(request)+ "' "
                            
                            + "WHERE STUDENTNO    = '"+ this.studentNo+ "'";
                }
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
                
                if(this.id == null && this.autoStudentNo == 1){
                    stmt.executeUpdate("UPDATE PRSTUDNOS SET CURNO = (CURNO + 1)");
                }
                
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
            }
            
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        catch (ParseException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public String getNextStudentNo(){
        String nextNo = null;
        
        PrimaryCalendar primaryCalendar = new PrimaryCalendar();
        
        Integer curNo = null;
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query   = "SELECT * FROM PRSTUDNOS WHERE ACADEMICYEAR = "+primaryCalendar.academicYear;
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                curNo = rs.getInt("CURNO");		
            }
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
        
        if(curNo == null){
            
            this.initStudNo(primaryCalendar.academicYear);
            
            curNo = 0;
        }
        
        curNo = curNo + 1;
        
        nextNo = String.format("%04d", curNo);
        
        String academicYear = ""+ primaryCalendar.academicYear;
        
        academicYear = academicYear.length() > 2? academicYear.substring(academicYear.length() - 2): academicYear;
        
        nextNo = nextNo+ "/"+ academicYear;
        
        return nextNo;
    }
    
    public Integer initStudNo(Integer academicYear){
        Integer noInitialised = 0;
        
        Sys sys = new Sys();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            Integer id = sys.generateId("PRSTUDNOS", "ID");
            String query = "INSERT INTO PRSTUDNOS "
                        + "(ID, ACADEMICYEAR, CURNO)"
                        + "VALUES"
                        + "("
                        + id+ ","
                        + academicYear+ ", "
                        + 0
                        + ")";
            
            noInitialised = stmt.executeUpdate(query);
            
        }catch(SQLException e){
            e.getMessage();
        }catch(Exception e){
            e.getMessage();
        }
        
        return noInitialised;
    }
    
    public Object purgePhoto() throws Exception{
         
         JSONObject obj = new JSONObject();
         
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.studentNo != null && ! this.studentNo.trim().equals("")){
                String query = "DELETE FROM PRSTUDPHOTOS WHERE STUDENTNO = '"+this.studentNo+"'";
            
                Integer purged = stmt.executeUpdate(query);
                if(purged == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully deleted.");
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured while deleting record.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "An error occured while deleting record.");
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