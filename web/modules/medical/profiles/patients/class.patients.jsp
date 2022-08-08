<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.medical.PatientProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Patients{
//    String table            = "HMPTPROFILE";
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
    String table        = comCode+".HMPTPROFILE";
    String view         = comCode+".VIEWPATIENTPROFILE";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String ptNo             = this.id != null? request.getParameter("ptNoHd"): request.getParameter("ptNo");
    Integer autoPtNo        = request.getParameter("autoPtNo") != null? 1: null;
    String salutationCode   = request.getParameter("salutation");
    String firstName        = request.getParameter("firstName");
    String middleName       = request.getParameter("middleName");
    String lastName         = request.getParameter("lastName");
    String genderCode       = request.getParameter("gender");
    String age              = request.getParameter("age");
    String dob              = request.getParameter("dob");
    String countryCode      = request.getParameter("country");
    String nationalId       = request.getParameter("nationalId");
    String passportNo       = request.getParameter("passportNo");
    String bloodGrpCode     = request.getParameter("bloodGroup");
    Integer physChald       = request.getParameter("physChald") != null? 1: null;
    String disabCode        = request.getParameter("disability");
    String postalAddr       = request.getParameter("postalAddr");
    String postalCode       = request.getParameter("postalCode");
    String physicalAddr     = request.getParameter("physicalAddr");
    String telephone        = request.getParameter("telephone");
    String cellphone        = request.getParameter("cellphone");
    String email            = request.getParameter("email");
    String allergies        = request.getParameter("allergies");
    String warns            = request.getParameter("warns");
    String familyHist       = request.getParameter("familyHist");
    String selfHist         = request.getParameter("selfHist");
    String pastMedHist      = request.getParameter("pastMedHist");
    String socialHist       = request.getParameter("socialHist");
    
    String nhifNo           = request.getParameter("nhifNo");
    
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

                        list.add("PTNO");
                        list.add("FULLNAME");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                if(dbType.equals("postgres")){
                                    filterSql += " WHERE ( UPPER(CAST ("+ list.get(i) +" AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
                                }else{
                                    filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
                                }
                            }else{
                                if(dbType.equals("postgres")){
                                    filterSql += " OR ( UPPER(CAST ("+ list.get(i) +" AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
                                }else{
                                    filterSql += " OR ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
                                }
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

            String orderBy = "PTNO ";
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
                html += "<th>Age</th>";
//                html += "<th>DOB</th>";
                html += "<th>Blood Group</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String ptNo         = rs.getString("PTNO");
                    String fullName     = rs.getString("FULLNAME");
                    String genderName   = rs.getString("GENDERNAME");
                    String age          = rs.getString("AGE");
                    String dob          = rs.getString("DOB");
                    String bloodGrpName = rs.getString("BLOODGRPNAME");
                    
                    SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                    SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

                    try{
                        java.util.Date dob_ = originalFormat.parse(dob);
                        dob = targetFormat.format(dob_);
                    }catch(ParseException e){
                        html += e.getMessage();
                    }

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ ptNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ genderName+ "</td>";
                    html += "<td>"+ age+ "</td>";
//                    html += "<td>"+ dob+ "</td>";
                    html += "<td>"+ bloodGrpName+ "</td>";
                    html += "<td>"+ edit+ "</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
            }catch (Exception e){
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
            
        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
//        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" enctype = \"multipart/form-data\" target = \"_blank\">";
        
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getBioDataTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getContactTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getMedHistoryTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"patients.save('firstName lastName gender dob country'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\', \'Medical History\'), 0, 625, 365, Array(false, false, false));";
        html += "</script>";
        
        html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
        
        return html;
    }
    public String getBioDataTab(){
        
        Gui gui = new Gui();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        String html = "";
        
        if(this.id != null){
            
            try{
                stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.ptNo           = rs.getString("PTNO");		
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);
            
            this.salutationCode     = patientProfile.salutationCode;
            this.firstName          = patientProfile.firstName;
            this.middleName         = patientProfile.middleName;
            this.lastName           = patientProfile.lastName;
            this.genderCode         = patientProfile.genderCode;
            this.dob                = patientProfile.dob;
            this.age                = patientProfile.age;
            this.countryCode        = patientProfile.countryCode;
            this.nationalId         = patientProfile.nationalId;
            this.bloodGrpCode       = patientProfile.bloodGrpCode;
            this.passportNo         = patientProfile.passportNo;
            this.physChald          = patientProfile.physChald;
            this.disabCode          = patientProfile.disabCode;
            this.postalAddr         = patientProfile.postalAddr;
            this.postalCode         = patientProfile.postalCode;
            this.physicalAddr       = patientProfile.physicalAddr;
            this.telephone          = patientProfile.telephone;
            this.cellphone          = patientProfile.cellphone;
            this.email              = patientProfile.email;
            this.allergies          = patientProfile.allergies;
            this.warns              = patientProfile.warns;
            this.familyHist         = patientProfile.familyHist;
            this.selfHist           = patientProfile.selfHist;
            this.pastMedHist        = patientProfile.pastMedHist;
            this.socialHist         = patientProfile.socialHist;
            this.nhifNo             = patientProfile.nhifNo;
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            try{
                java.util.Date dob = originalFormat.parse(this.dob);
                this.dob = targetFormat.format(dob);
            }catch(ParseException e){

            }
            
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        
        html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"patient-male.png", "", "")+" "+gui.formLabel("ptNo", "Patient No")+"</td>";
        String ptNoUi;
        String autoPtNoUi;
        if(this.id != null){
            ptNoUi      = gui.formAutoComplete("ptNo", 15, this.id != null? this.ptNo: "", "patients.searchPatient", "ptNoHd", this.id != null? this.ptNo: "");
            autoPtNoUi  = "";
        }else{
            ptNoUi      = gui.formInput("text", "ptNo", 15, "" , "", "disabled");
            autoPtNoUi  = gui.formCheckBox("autoPtNo", "checked", "", "onchange = \"patients.togglePtNo();\"", "", "")+ "<span class = \"fade\"><label for = \"autoPtNo\"> No Auto</label></span>";
        }
        
        html += "<td colspan = \"3\">"+ptNoUi+" "+autoPtNoUi+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"personal-information.png", "", "")+" "+gui.formLabel("salutation", "Salutation")+"</td>";
	html += "<td colspan = \"2\">"+gui.formSelect("salutation", comCode+".CSSALUTATION", "SALUTATIONCODE", "SALUTATIONNAME", null, null, this.id != null? this.salutationCode: "", null, false)+"</td>";
        if(this.id != null){
            String imgPhotoSrc;
            if(hasPhoto(this.ptNo)){
                imgPhotoSrc = "photo.jsp?ptNo="+this.ptNo;
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
	html += "<td colspan = \"3\">"+gui.formSelect("gender", comCode+".CSGENDER", "GENDERCODE", "GENDERNAME", null, null, this.id != null? this.genderCode: "", null, false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "")+" "+gui.formLabel("age", "Age")+"</td>";
	html += "<td>"+gui.formInput("text", "age", 25, this.id != null? this.age: "", "", "")+"</td>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "")+" "+gui.formLabel("dob", "Date of Birth")+"</td>";
	html += "<td>"+gui.formDateTime(request.getContextPath(), "dob", 15, this.id != null? this.dob: "", false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"globe-medium-green.png", "", "")+" "+gui.formLabel("country", "Country")+"</td>";
	html += "<td colspan = \"3\">"+gui.formSelect("country", comCode+".CSCOUNTRIES", "COUNTRYCODE", "COUNTRYNAME", null, null, this.id != null? this.countryCode: "", null, false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("nationalId", "National ID")+"</td>";
	html += "<td width = \"30%\">"+gui.formInput("text", "nationalId", 15, this.id != null? this.nationalId: "", "", "")+"</td>";
	
	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("passportNo", "Passport No")+"</td>";
	html += "<td>"+gui.formInput("text", "passportNo", 15, this.id != null? this.passportNo: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+" "+gui.formLabel("nhifNo", "NHIF No")+"</td>";
	html += "<td>"+gui.formInput("text", "nhifNo", 15, this.id != null? this.nhifNo: "", "", "")+"</td>";
        
	html += "<td>"+gui.formIcon(request.getContextPath(),"blood-drop.png", "", "")+" "+gui.formLabel("bloodGroup", "Blood Group")+"</td>";
	html += "<td>"+gui.formSelect("bloodGroup", comCode+".HMBLOODGRPS", "BLOODGRPCODE", "BLOODGRPNAME", "", "", this.id != null? this.bloodGrpCode: "", null, false)+"</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("physChald", "Physically Challenged")+"</td>";
	html += "<td>"+gui.formCheckBox("physChald", (this.id != null && this.physChald == 1)? "checked": "", null, "onchange = \"patients.toggleDisab();\"", "", "")+"</td>";
	
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"apps-accessibility.png", "", "")+" "+gui.formLabel("disability", "Physical Disability")+"</td>";
	html += "<td>"+gui.formSelect("disability", comCode+".CSDISAB", "DISABCODE", "DISABNAME", null, null, this.id != null? this.disabCode: "", (this.id != null && this.physChald == 1) ? "": "disabled", false)+"</td>";
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
                        
            html += "<div id = \"divPhotoOptions\" onmouseout = \"patients.hidePhotoOptions();\" style = \"display: none; background-color: #000000; opacity: 0.4; text-align: center;\">";
            html += "<input name = \"photo\" id = \"photo\" type = \"file\" onchange = \"patients.uploadPhoto();\" style = \"display: none;\">";
            html += "<div style = \"padding-top: 50px;\">";
            html += "<a href = \"javascript:;\" onclick = \"$('photo').click();\">upload</a>";
            html += "</div>";
            if(this.hasPhoto(this.ptNo)){
                html += "<div >";
                html += gui.formHref("onclick = \"patients.purgePhoto('"+this.ptNo+"', '"+this.lastName+"')\"", request.getContextPath(), "", "remove", "remove", "", "");
                html += "</div>";
            }
            html += "</div>";
        }
        
        
                
        return html;
    }
    
    public String searchPatient(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.ptNo = request.getParameter("ptNoHd");
        
        html += gui.getAutoColsSearch("HMPTPROFILE", "PTNO, FULLNAME", "", this.ptNo);
        
        return html;
    }
    
    public Boolean hasPhoto(String ptNo){
        Boolean hasPhoto = false;
        
        if(this.id != null){
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;
            
            Integer count = 0;
            
            try{
                stmt = conn.createStatement();
                String query = "SELECT COUNT(*) FROM HMPTPHOTOS WHERE PTNO = '"+ptNo+"'";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    count      = rs.getInt("COUNT(*)");		
                }
                
                if(count > 0){
                    hasPhoto = true;
                }
                
            }catch (Exception e){
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
    
    public String getMedHistoryTab(){
        String html = "";
        Gui gui = new Gui();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"20%\" style = \"vertical-align: top;\">"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" "+gui.formLabel("allergies", "Allergies")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("textarea", "allergies", 30, this.id != null? this.allergies: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td style = \"vertical-align: top;\" nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" "+gui.formLabel("warns", "Warnings")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("textarea", "warns", 30, this.id != null? this.warns: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td style = \"vertical-align: top;\" nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" "+gui.formLabel("familyHist", "Family History")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("textarea", "familyHist", 30, this.id != null? this.familyHist: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td style = \"vertical-align: top;\" nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" "+gui.formLabel("selfHist", "Personal History")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("textarea", "selfHist", 30, this.id != null? this.selfHist: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td style = \"vertical-align: top;\" nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" "+gui.formLabel("pastMedHist", "Past Medical History")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("textarea", "pastMedHist", 30, this.id != null? this.pastMedHist: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td style = \"vertical-align: top;\" nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" "+gui.formLabel("socialHist", "Social History")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("textarea", "socialHist", 30, this.id != null? this.socialHist: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public Object getPatientProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.ptNo == null || this.ptNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);
            
            obj.put("salutation", patientProfile.salutationCode);
            obj.put("firstName", patientProfile.firstName);
            obj.put("middleName", patientProfile.middleName);
            obj.put("lastName", patientProfile.lastName);
            obj.put("gender", patientProfile.genderCode);
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            try{
                java.util.Date dob = originalFormat.parse(patientProfile.dob);
                patientProfile.dob = targetFormat.format(dob);
            }catch(ParseException e){

            }
            
            obj.put("dob", patientProfile.dob);
            obj.put("country", patientProfile.countryCode);
            obj.put("physChald", patientProfile.physChald);
            obj.put("disability", patientProfile.disabCode);
            obj.put("postalAddr", patientProfile.postalAddr);
            obj.put("postalCode", patientProfile.postalCode);
            obj.put("physicalAddr", patientProfile.physicalAddr);
            obj.put("telephone", patientProfile.telephone);
            obj.put("cellphone", patientProfile.cellphone);
            obj.put("email", patientProfile.email);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Pt No '"+patientProfile.ptNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object save(){
        
        JSONObject obj      = new JSONObject();
        Sys system       = new Sys();
        HttpSession session = request.getSession();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        String query = "";
        
        Integer saved = 0;
        
        try{
            stmt = conn.createStatement();
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
            SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

            try{
                java.util.Date dob = originalFormat.parse(this.dob);
                this.dob = targetFormat.format(dob);
            }catch(ParseException e){

            }
	            
            if(this.id == null){
                Integer id;
                id = system.generateId(this.table, "ID");
                
                if(this.autoPtNo == 1){
//                    this.ptNo = this.getNextPtNo();
                    this.ptNo = system.getNextNo(this.table, "ID", "", "PT", 6);
                }
                
                query += "INSERT INTO "+this.table+" "
                        + "("
                        + "ID, PTNO, SALUTATIONCODE, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, "
                        + "GENDERCODE, DOB, AGE, COUNTRYCODE, NATIONALID, PASSPORTNO, BLOODGRPCODE, PHYSCHALD, DISABCODE, "
                        + "POSTALADDR, POSTALCODE, PHYSICALADDR, TELEPHONE, CELLPHONE, EMAIL, "
                        + "ALLERGIES, WARNS, FAMILYHIST, SELFHIST, PASTMEDHIST, SOCIALHIST,"
                        + "NHIFNO"
                        + ") "
                        + "VALUES"
                        + "("
                        + id+","
                        + "'"+this.ptNo+"',"
                        + "'"+this.salutationCode+"',"
                        + "'"+this.firstName+"',"
                        + "'"+this.middleName+"',"
                        + "'"+this.lastName+"',"
                        + "'"+this.firstName+" "+this.middleName+" "+this.lastName+"',"
                        + "'"+this.genderCode+"',"
                        + "'"+this.dob+"',"
                        + "'"+this.age+"',"
                        + "'"+this.countryCode+"',"
                        + "'"+this.nationalId+"',"
                        + "'"+this.passportNo+"',"
                        + "'"+this.bloodGrpCode+"',"
                        +     this.physChald+","
                        + "'"+this.disabCode+"',"
                        + "'"+this.postalAddr+"',"
                        + "'"+this.postalCode+"',"
                        + "'"+this.physicalAddr+"',"
                        + "'"+this.telephone+"',"
                        + "'"+this.cellphone+"',"
                        + "'"+this.email+"',"
                        + "'"+this.allergies+"',"
                        + "'"+this.warns+"',"
                        + "'"+this.familyHist+"',"
                        + "'"+this.selfHist+"',"
                        + "'"+this.pastMedHist+"',"
                        + "'"+this.socialHist+"',"
                        + "'"+this.nhifNo+"'"
                        + ")";
                
                obj.put("ptNo", this.ptNo);
                
            }else{
                
                if(this.ptNo == null || this.ptNo.equals("")){
                    
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
                            + "AGE              = '"+this.age+"', "
                            + "COUNTRYCODE      = '"+this.countryCode+"', "
                            + "NATIONALID       = '"+this.nationalId+"', "
                            + "PASSPORTNO       = '"+this.passportNo+"', "
                            + "BLOODGRPCODE     = '"+this.bloodGrpCode+"', "
                            + "PHYSCHALD        = "+this.physChald+", "
                            + "DISABCODE        = '"+this.disabCode+"', "
                            + "POSTALADDR       = '"+this.postalAddr+"', "
                            + "POSTALCODE       = '"+this.postalCode+"', "
                            + "PHYSICALADDR     = '"+this.physicalAddr+"', "
                            + "TELEPHONE        = '"+this.telephone+"', "
                            + "CELLPHONE        = '"+this.cellphone+"', "
                            + "EMAIL            = '"+this.email+"', "
                            + "ALLERGIES        = '"+this.allergies+"', "
                            + "WARNS            = '"+this.warns+"', "
                            + "FAMILYHIST       = '"+this.familyHist+"', "
                            + "SELFHIST         = '"+this.selfHist+"', "
                            + "PASTMEDHIST      = '"+this.pastMedHist+"', "
                            + "SOCIALHIST       = '"+this.socialHist+"', "
                            + "NHIFNO           = '"+this.nhifNo+"', "
                            + "AUDITUSER        = '"+system.getLogUser(session)+"', "
                            + "AUDITDATE        = '"+system.getLogDate()+"', "
                            + "AUDITTIME        = '"+system.getLogTime()+"', "
                            + "AUDITIP          = '"+system.getClientIpAdr(request)+"' "
                            + "WHERE PTNO       = '"+this.ptNo+"'";
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

        }
        
        return obj;
    }
    
    public String getNextPtNo(){
        String nextNo = "";
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;
        String query;
        Integer ptNoMax = 0;
        try{
            stmt    = conn.createStatement();
            query   = "SELECT MAX(ID) FROM "+this.table;
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                ptNoMax = rs.getInt("MAX(ID)");		
            }
            
        }catch(Exception e){
            nextNo += e.getMessage();
        }
        ptNoMax = ptNoMax + 1;
        
        nextNo = "PT"+String.format("%06d", ptNoMax);
        
        return nextNo;
    }
    
    public Object purgePhoto(){
        
         Connection conn = ConnectionProvider.getConnection();
         Statement stmt = null;
         
         JSONObject obj = new JSONObject();
         
         try{
            stmt = conn.createStatement();
            
            if(this.ptNo != null && ! this.ptNo.trim().equals("")){
                String query = "DELETE FROM HMPTPHOTOS WHERE PTNO = '"+this.ptNo+"'";
            
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
            
        }catch (Exception e){

        }
         
         return obj;
        
    } 
    
}

%>