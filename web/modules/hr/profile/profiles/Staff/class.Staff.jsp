<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Staff{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    
    String table            = comCode+".HRSTAFFPROFILE";
    String view             = comCode+".VIEWSTAFFPROFILE";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String pfNo             = this.id != null? request.getParameter("pfNoHd"): request.getParameter("pfNo");
    String salutationCode   = request.getParameter("salutation");
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
    String postalAddr       = request.getParameter("postalAddr");
    String postalCode       = request.getParameter("postalCode");
    String physicalAddr     = request.getParameter("physicalAddr");
    String telephone        = request.getParameter("telephone");
    String cellphone        = request.getParameter("cellphone");
    String email            = request.getParameter("email");
    
    String branchCode       = request.getParameter("branch");
    String deptCode         = request.getParameter("department");
    String sectionCode      = request.getParameter("section");
    String statusCode       = request.getParameter("status");
    String gradeCode        = request.getParameter("grade");
    String positionCode     = request.getParameter("position");
    String engTrmCode       = request.getParameter("engTerms");
    String categoryCode     = request.getParameter("category");
    
    String pinNo            = request.getParameter("pinNo");
    String nhifNo           = request.getParameter("nhifNo");
    String nssfNo           = request.getParameter("nssfNo");
    String medicalNo        = request.getParameter("medicalNo");
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
        Integer recordCount = sys.getRecordCount(this.table, "");
        
        if(recordCount > 0){
            String gridSql;
            String filterSql = "";
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

                        list.add("PFNO");
                        list.add("FULLNAME");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                if(dbType.equals("postgres")){
                                    filterSql += " WHERE ( UPPER(CAST ("+ list.get(i) +" AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
                                }else{
                                    filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
                                }
                            }else{
                                filterSql += " OR ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
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

            String orderBy = "PFNO ";
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
//            System.out.println("gridSql=="+ gridSql);

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
                html += "<th>Pf No</th>";
                html += "<th>Name</th>";
                html += "<th>Gender</th>";
                html += "<th>Grade</th>";
                html += "<th>Engagement Terms</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String pfNo         = rs.getString("PFNO");
                    String fullName     = rs.getString("FULLNAME");
                    String genderName   = rs.getString("GENDERNAME");
                    String gradeName    = rs.getString("GRADENAME");
                    String engTrmName   = rs.getString("ENGTRMNAME");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ pfNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ genderName+ "</td>";
                    html += "<td>"+ gradeName+ "</td>";
                    html += "<td>"+ engTrmName+ "</td>";
                    html += "<td>"+ edit+ "</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
            }catch(SQLException e){
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
        
//        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
//        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" action = \"./upload/\" enctype = \"multipart/form-data\" target = \"_blank\">";
        
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getBioDataTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getContactTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getHRTab()+"</div>";
        
        if(this.id != null){
            html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getDependantsTab()+ "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getKinsTab()+ "</div>";
        }
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"profile.save('pfNo pfNoHd firstName lastName gender dob country grade position engTerms category branch department section '); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        if(this.id != null){
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\', \'HR\', \'Dependants\', \'Kins\'), 0, 625, 350, Array(false, false, false));";
        }else{
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\', \'HR\'), 0, 625, 350, Array(false, false, false));";
        }
        
        html += "</script>";
        
        html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
        
        return html;
    }
    public String getBioDataTab(){
        
        Gui gui = new Gui();
        
        Connection con = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        String html = "";
        
        if(this.id != null){
            
            try{
                stmt = con.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.pfNo           = rs.getString("PFNO");		
                }
            }catch (SQLException e){

            }
            
            StaffProfile staffProfile = new StaffProfile(this.pfNo, session.getAttribute("comCode").toString());
            
            this.salutationCode     = staffProfile.salutationCode;
            this.firstName          = staffProfile.firstName;
            this.middleName         = staffProfile.middleName;
            this.lastName           = staffProfile.lastName;
            this.genderCode         = staffProfile.genderCode;
            this.dob                = staffProfile.dob;
            this.countryCode        = staffProfile.countryCode;
            this.nationalId         = staffProfile.nationalId;
            this.passportNo         = staffProfile.passportNo;
            this.physChald          = staffProfile.physChald;
            this.disabCode          = staffProfile.disabCode;
            this.postalAddr         = staffProfile.postalAddr;
            this.postalCode         = staffProfile.postalCode;
            this.physicalAddr       = staffProfile.physicalAddr;
            this.telephone          = staffProfile.telephone;
            this.cellphone          = staffProfile.cellphone;
            this.email              = staffProfile.email;
            
            this.branchCode         = staffProfile.brancCode;			
            this.deptCode           = staffProfile.deptCode;			
            this.sectionCode        = staffProfile.sectionCode;			
            this.statusCode         = staffProfile.statusCode;			
            this.gradeCode          = staffProfile.gradeCode;			
            this.positionCode       = staffProfile.positionCode;				
            this.engTrmCode         = staffProfile.engTrmCode;				
            this.categoryCode       = staffProfile.categoryCode;
            
            this.pinNo              = staffProfile.pinNo;			
            this.nhifNo             = staffProfile.nhifNo;			
            this.nssfNo             = staffProfile.nssfNo;			
            this.medicalNo          = staffProfile.medicalNo;	
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            try{
                java.util.Date dob = originalFormat.parse(this.dob);
                this.dob = targetFormat.format(dob);
            }catch(ParseException e){
                html += e.getMessage();
            }
            
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+" "+gui.formLabel("pfNo", "PF No")+"</td>";
        String pfNoUi;
        if(this.id != null){
            pfNoUi = gui.formAutoComplete("pfNo", 15, this.id != null? this.pfNo: "", "profile.searchStaff", "pfNoHd", this.id != null? this.pfNo: "");
        }else{
            pfNoUi = gui.formInput("text", "pfNo", 15, "" , "", "");
        }
        
        html += "<td colspan = \"3\">"+pfNoUi+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(),"personal-information.png", "", "")+" "+gui.formLabel("salutation", "Salutation")+"</td>";
	html += "<td colspan = \"2\">"+ gui.formSelect("salutation", session.getAttribute("comCode")+".CSSALUTATION", "SALUTATIONCODE", "SALUTATIONNAME", null, null, this.id != null? this.salutationCode: "", null, false)+"</td>";
        if(this.id != null){
            String imgPhotoSrc;
            if(hasPhoto(this.pfNo)){
                imgPhotoSrc = "photo.jsp?pfNo="+ this.pfNo;
            }else{
                imgPhotoSrc = request.getContextPath()+"/images/emblems/places-user-identity.png";
            }
            
            html += "<td rowspan = \"5\">";
            html += "<div class = \"divPhoto\"><img id = \"imgPhoto\" src=\""+imgPhotoSrc+"\"></div>";
            html += "</td>";
        }
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("firstName", "First Name")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "firstName", 25, this.id != null? this.firstName: "", "", "")+"</td>";
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
	html += "<td colspan = \"3\">"+gui.formSelect("gender", session.getAttribute("comCode")+".CSGENDER", "GENDERCODE", "GENDERNAME", null, null, this.id != null? this.genderCode: "", null, false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "")+" "+gui.formLabel("dob", "Date of Birth")+"</td>";
	html += "<td colspan = \"3\">"+gui.formDateTime(request.getContextPath(), "dob", 15, this.id != null? this.dob: "", false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"globe-medium-green.png", "", "")+" "+gui.formLabel("country", "Country")+"</td>";
	html += "<td colspan = \"3\">"+gui.formSelect("country", session.getAttribute("comCode")+".CSCOUNTRIES", "COUNTRYCODE", "COUNTRYNAME", null, null, this.id != null? this.countryCode: "", null, false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("nationalId", "National ID")+"</td>";
	html += "<td width = \"30%\">"+gui.formInput("text", "nationalId", 15, this.id != null? this.nationalId: "", "", "")+"</td>";
	
	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("passportNo", "Passport No")+"</td>";
	html += "<td>"+gui.formInput("text", "passportNo", 15, this.id != null? this.passportNo: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("physChald", "Physically Challenged")+"</td>";
	html += "<td>"+gui.formCheckBox("physChald", (this.id != null && this.physChald == 1)? "checked": "", null, "onchange = \"profile.toggleDisab();\"", "", "")+"</td>";
	
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"apps-accessibility.png", "", "")+" "+gui.formLabel("disability", "Physical Disability")+"</td>";
	html += "<td>"+gui.formSelect("disability", session.getAttribute("comCode")+".CSDISAB", "DISABCODE", "DISABNAME", null, null, this.id != null? this.disabCode: "", (this.id != null && this.physChald == 1) ? ""+ " style = \"width: 165px;\"": "disabled"+ " style = \"width: 165px;\"", false)+"</td>";
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
                        
            html += "<div id = \"divPhotoOptions\" onmouseout = \"profile.hidePhotoOptions();\" style = \"display: none; background-color: #000000; opacity: 0.4; text-align: center;\">";
            html += "<input name = \"photo\" id = \"photo\" type = \"file\" onchange = \"profile.uploadPhoto();\" style = \"display: none;\">";
            html += "<div style = \"padding-top: 50px;\">";
            html += "<a href = \"javascript:;\" onclick = \"$('photo').click();\">upload</a>";
            html += "</div>";
            if(this.hasPhoto(this.pfNo)){
                html += "<div >";
                html += gui.formHref("onclick = \"profile.purgePhoto('"+this.pfNo+"', '"+this.lastName+"')\"", request.getContextPath(), "", "remove", "remove", "", "");
                html += "</div>";
            }
            html += "</div>";
        }
        
        
                
        return html;
    }
    
    public String searchStaff(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.pfNo = request.getParameter("pfNoHd");
        
        html += gui.getAutoColsSearch(comCode+".HRSTAFFPROFILE", "PFNO, FULLNAME", "", this.pfNo);
        
        return html;
    }
    
    public Boolean hasPhoto(String pfNo){
        Boolean hasPhoto = false;
        
        if(this.id != null){
            Connection con = ConnectionProvider.getConnection();
            Statement stmt = null;
            
            Integer count = 0;
            
            try{
                stmt = con.createStatement();
                String query = "SELECT COUNT(*)CT FROM "+ session.getAttribute("comCode")+ ".HRSTAFFPHOTOS WHERE PFNO = '"+pfNo+"'";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    count      = rs.getInt("CT");		
                }
                
                if(count > 0){
                    hasPhoto = true;
                }
                
            }catch (SQLException e){

            } 
        }
        
        return hasPhoto;
    }
    
    public String getContactTab(){
        String html = "";
        Gui gui = new Gui();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"20%\">"+gui.formIcon(request.getContextPath(),"email-open.png", "", "")+" "+gui.formLabel("postalAddr", "Postal Address")+"</td>";
	html += "<td width = \"30%\">"+gui.formInput("text", "postalAddr", 20, this.id != null? this.postalAddr: "", "", "")+"</td>";
	
	html += "<td width = \"20%\">"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("postalCode", "Postal Code")+"</td>";
	html += "<td>"+gui.formInput("text", "postalCode", 15, this.id != null? this.postalCode: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("physicalAddr", "Physical Address")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("textarea", "physicalAddr", 30, this.id != null? this.physicalAddr: "", "", "")+"</td>";
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
    
    public Object getStaffProfile(){
        JSONObject obj = new JSONObject();
        
        if(this.pfNo == null || this.pfNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            StaffProfile staffProfile = new StaffProfile(this.pfNo, session.getAttribute("comCode").toString());
            
            obj.put("salutation", staffProfile.salutationCode);
            obj.put("firstName", staffProfile.firstName);
            obj.put("middleName", staffProfile.middleName);
            obj.put("lastName", staffProfile.lastName);
            obj.put("gender", staffProfile.genderCode);
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            try{
                java.util.Date dob = originalFormat.parse(staffProfile.dob);
                staffProfile.dob = targetFormat.format(dob);
            }catch(ParseException e){

            }
            
            obj.put("dob", staffProfile.dob);
            obj.put("country", staffProfile.countryCode);
            obj.put("physChald", staffProfile.physChald);
            obj.put("disability", staffProfile.disabCode);
            obj.put("postalAddr", staffProfile.postalAddr);
            obj.put("postalCode", staffProfile.postalCode);
            obj.put("physicalAddr", staffProfile.physicalAddr);
            obj.put("telephone", staffProfile.telephone);
            obj.put("cellphone", staffProfile.cellphone);
            obj.put("email", staffProfile.email);
            
            obj.put("department", staffProfile.deptCode);
            obj.put("section", staffProfile.sectionCode);
            obj.put("grade", staffProfile.gradeCode);
            obj.put("position", staffProfile.positionCode);
            obj.put("engTerms", staffProfile.engTrmCode);
            obj.put("category", staffProfile.categoryCode);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Pf No '"+staffProfile.pfNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String getHRTab(){
        String html = "";
        Gui gui = new Gui();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+" "+gui.formLabel("status", "Staff Status")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("status", session.getAttribute("comCode")+".HRSTATUS", "STATUSCODE", "STATUSNAME", null, null, this.id != null? this.statusCode: "", "style = \"width: 165px;\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"20%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+" "+gui.formLabel("grade", "Grade")+"</td>";
	html += "<td width = \"30%\">"+ gui.formSelect("grade", session.getAttribute("comCode")+".HRGRADES", "GRADECODE", "GRADENAME", null, null, this.id != null? this.gradeCode: "",  "onchange = \"profile.getPositionsUI();\" style = \"width: 165px;\"", true)+ "</td>";
	
	html += "<td width = \"20%\">"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+gui.formLabel("position", "Position")+"</td>";
	html += "<td id = \"tdPositions\">"+ gui.formSelect("position", session.getAttribute("comCode")+".HRPOSITIONS", "POSITIONCODE", "POSITIONNAME", null, this.id != null? "GRADECODE = '"+ this.gradeCode+ "'": "", this.id != null? this.positionCode: "", "style = \"width: 165px;\"", true)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+" "+gui.formLabel("engTerms", "Engagement Terms")+"</td>";
	html += "<td>"+ gui.formSelect("engTerms", session.getAttribute("comCode")+".HRENGTERMS", "ENGTRMCODE", "ENGTRMNAME", null, null, this.id != null? this.engTrmCode: "", "style = \"width: 165px;\"", true)+"</td>";
	
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+gui.formLabel("category", "Staff Category")+"</td>";
	html += "<td>"+ gui.formSelect("category", session.getAttribute("comCode")+".HRCATEGORY", "CATEGORYCODE", "CATEGORYNAME", null, null, this.id != null? this.categoryCode: "", "style = \"width: 165px;\"", true)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "building.png", "", "")+" "+gui.formLabel("branch", "Branch")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("branch", session.getAttribute("comCode")+".CSBRANCHES", "BRANCHCODE", "BRANCHNAME", null, null, this.id != null? this.branchCode: "", "style = \"width: 165px;\"", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "house.png", "", "")+" "+gui.formLabel("department", "Department")+"</td>";
	html += "<td>"+ gui.formSelect("department", session.getAttribute("comCode")+".CSDEPTS", "DEPTCODE", "DEPTNAME", null, null, this.id != null? this.deptCode: "", "onchange = \"profile.getSectionsUI();\" style = \"width: 165px;\"", true)+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(),"house.png", "", "")+" "+ gui.formLabel("section", "Section")+"</td>";
	html += "<td id = \"tdSections\">"+ gui.formSelect("section", session.getAttribute("comCode")+".CSSECTIONS", "SECTIONCODE", "SECTIONNAME", null, this.id != null? "DEPTCODE = '"+ this.deptCode+ "'": "", this.id != null? this.sectionCode: "", "style = \"width: 165px;\"", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+" "+ gui.formLabel("pinNo", "Pin No")+"</td>";
	html += "<td>"+ gui.formInput("text", "pinNo", 15, this.id != null? this.pinNo: "", "", "")+"</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+ gui.formLabel("nhifNo", "NHIF No")+"</td>";
	html += "<td>"+ gui.formInput("text", "nhifNo", 15, this.id != null? this.nhifNo: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+" "+ gui.formLabel("nssfNo", "NSSF No")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "nssfNo", 15, this.id != null? this.nssfNo: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public Object getSectionsUI(){
        JSONObject obj      = new JSONObject();
        Gui gui = new Gui();
        
        if(this.deptCode == null || this.deptCode.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Select Department.");
        }else{
            
            String sectionUI = gui.formSelect("section", comCode+".CSSECTIONS", "SECTIONCODE", "SECTIONNAME", null, "DEPTCODE = '"+ this.deptCode+ "'", this.id != null? this.sectionCode: "", " style = \"width: 165px;\"", true);
            
            obj.put("sectionUI", sectionUI);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Department '"+ this.deptCode+ "' successfully retrieved");
        }
        
        return obj;
    }
    
    public Object getPositionsUI(){
        JSONObject obj      = new JSONObject();
        Gui gui = new Gui();
        
        if(this.gradeCode == null || this.gradeCode.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Select Grade.");
        }else{
            
            String positionsUI = gui.formSelect("position", comCode+".HRPOSITIONS", "POSITIONCODE", "POSITIONNAME", null, "GRADECODE = '"+ this.gradeCode+ "'", this.id != null? this.positionCode: "", " style = \"width: 165px;\"", true);
            
            obj.put("positionsUI", positionsUI);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Grade '"+ this.gradeCode+ "' successfully retrieved");
        }
        
        return obj;
    }
    
    public String getDependantsTab(){
        String html = "";
        
        return html;
    }
    
    public String getKinsTab(){
        String html = "";
        
        return html;
    }
    
    public Object save(){
        
        JSONObject obj      = new JSONObject();
        Sys sys       = new Sys();
        HttpSession session = request.getSession();
        
        try{
            Connection con = ConnectionProvider.getConnection();
            Statement stmt = con.createStatement();
            
            String query = "";
            Integer saved = 0;
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
            SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

            try{
                java.util.Date dob = originalFormat.parse(this.dob);
                this.dob = targetFormat.format(dob);
            }catch(ParseException e){

            }
	            
            if(this.id == null){
                Integer id;
                id = sys.generateId(this.table, "ID");
                
                query += "INSERT INTO "+this.table+" "
                        + "(ID, PFNO, SALUTATIONCODE, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, "
                        + "GENDERCODE, DOB, COUNTRYCODE, NATIONALID, PASSPORTNO, PHYSCHALD, DISABCODE, "
                        + "POSTALADDR, POSTALCODE, PHYSICALADDR, TELEPHONE, CELLPHONE, EMAIL,"
                        + "BRANCHCODE, DEPTCODE, SECTIONCODE, STATUSCODE, GRADECODE, POSITIONCODE, ENGTRMCODE, CATEGORYCODE, "
                        + "pinNo, NHIFNO, NSSFNO"
                        + ") "
                        + "VALUES"
                        + "("
                        + id+ ","
                        + "'"+this.pfNo+"',"
                        + "'"+this.salutationCode+"',"
                        + "'"+this.firstName+"',"
                        + "'"+this.middleName+"',"
                        + "'"+this.lastName+"',"
                        + "'"+this.firstName+" "+this.middleName+" "+this.lastName+"',"
                        + "'"+this.genderCode+"',"
                        + "'"+this.dob+"',"
                        + "'"+this.countryCode+"',"
                        + "'"+this.nationalId+"',"
                        + "'"+this.passportNo+"',"
                        +     this.physChald+","
                        + "'"+this.disabCode+"',"
                        + "'"+this.postalAddr+"',"
                        + "'"+this.postalCode+"',"
                        + "'"+this.physicalAddr+"',"
                        + "'"+this.telephone+"',"
                        + "'"+this.cellphone+"',"
                        + "'"+this.email+"',"
                        
                        + "'"+this.branchCode+"',"
                        + "'"+this.deptCode+"',"
                        + "'"+this.sectionCode+"',"
                        + "'"+this.statusCode+"',"
                        + "'"+this.gradeCode+"',"
                        + "'"+this.positionCode+"',"
                        + "'"+this.engTrmCode+"',"
                        + "'"+this.categoryCode+"',"
                        + "'"+this.pinNo+"',"
                        + "'"+this.nhifNo+"',"
                        + "'"+this.nssfNo+"'"
                        + ")";
            }else{
                
                if(this.pfNo == null || this.pfNo.equals("")){
                    
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record. Could not retrieve Pf No.");
                    
                }else{
                    query = "UPDATE "+this.table+" SET "
                            + "SALUTATIONCODE   = '"+this.salutationCode+"', "
                            + "FIRSTNAME        = '"+this.firstName+"', "
                            + "MIDDLENAME       = '"+this.middleName+"', "
                            + "LASTNAME         = '"+this.lastName+"',"
                            + "FULLNAME         = '"+this.firstName+" "+this.middleName+" "+this.lastName+"', "
                            + "GENDERCODE       = '"+this.genderCode+"', "
                            + "DOB              = '"+this.dob+"', "
                            + "COUNTRYCODE      = '"+this.countryCode+"', "
                            + "NATIONALID       = '"+this.nationalId+"', "
                            + "PASSPORTNO       = '"+this.passportNo+"', "
                            + "PHYSCHALD        = "+this.physChald+", "
                            + "DISABCODE        = '"+this.disabCode+"', "
                            + "POSTALADDR       = '"+this.postalAddr+"', "
                            + "POSTALCODE       = '"+this.postalCode+"', "
                            + "PHYSICALADDR     = '"+this.physicalAddr+"', "
                            + "TELEPHONE        = '"+this.telephone+"', "
                            + "CELLPHONE        = '"+this.cellphone+"', "
                            + "EMAIL            = '"+this.email+"', "
                            + "BRANCHCODE       = '"+this.branchCode+"', "
                            + "DEPTCODE         = '"+this.deptCode+"', "
                            + "SECTIONCODE      = '"+this.sectionCode+"', "
                            + "STATUSCODE       = '"+this.statusCode+"', "
                            + "GRADECODE        = '"+this.gradeCode+"', "
                            + "POSITIONCODE     = '"+this.positionCode+"', "
                            + "ENGTRMCODE       = '"+this.engTrmCode+"', "
                            + "CATEGORYCODE     = '"+this.categoryCode+"', "
                            + "pinNo            = '"+this.pinNo+"', "
                            + "NHIFNO           = '"+this.nhifNo+"', "
                            + "NSSFNO           = '"+this.nssfNo+"', "
                            + "AUDITUSER        = '"+sys.getLogUser(session)+"', "
                            + "AUDITDATE        = '"+sys.getLogDate()+"', "
                            + "AUDITTIME        = "+ sys.getLogTime()+ ", "
                            + "AUDITIPADR       = '"+sys.getClientIpAdr(request)+"' "
                            + "WHERE PFNO       = '"+ this.pfNo+ "'";
                }
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
            }
            
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public Object purgePhoto(){
        
         Connection con = ConnectionProvider.getConnection();
         Statement stmt = null;
         
         JSONObject obj = new JSONObject();
         
         try{
            stmt = con.createStatement();
            
            if(this.pfNo != null && ! this.pfNo.trim().equals("")){
                String query = "DELETE FROM "+comCode+".HRSTAFFPHOTOS WHERE PFNO = '"+this.pfNo+"'";
            
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

        }
         
         return obj;
        
    } 
    
}

%>