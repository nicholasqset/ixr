<%@page import="bean.gui.Gui"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.ap.APSupplierProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Suppliers{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    String table            = comCode+".APSUPPLIERS";
    String view             = comCode+".VIEWAPSUPPLIERS";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    
    String supplierNo       = this.id != null? request.getParameter("supplierNoHd"): request.getParameter("supplierNo");
    String firstName        = request.getParameter("firstName");
    String middleName       = request.getParameter("middleName");
    String lastName         = request.getParameter("lastName");
    String supplierName     = request.getParameter("supplierName");
    String genderCode       = request.getParameter("gender");
    String dob              = request.getParameter("dob");
    String countryCode      = request.getParameter("country");
    String nationalId       = request.getParameter("nationalId");
    String passportNo       = request.getParameter("passportNo");
    String postalAdr        = request.getParameter("postalAdr");
    String postalCode       = request.getParameter("postalCode");
    String physicalAdr      = request.getParameter("physicalAdr");
    String telephone        = request.getParameter("telephone");
    String cellphone        = request.getParameter("cellphone");
    String email            = request.getParameter("email");
    
    String supGrpCode       = request.getParameter("supplierGroup");
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
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

                        list.add("SUPPLIERNO");
                        list.add("FULLNAME");
                        list.add("SUPPLIERNAME");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
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

            String orderBy = "SUPGRPCODE, SUPPLIERNO ";
            String limitSql = "";

            String dbType = ConnectionProvider.getDBType();

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
                html += "<th>Supplier No</th>";
                html += "<th>Name</th>";
//                html += "<th>Gender</th>";
                html += "<th>Supplier Group</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String supplierNo   = rs.getString("SUPPLIERNO");
//                    String fullName     = rs.getString("FULLNAME");
                    String supplierName = rs.getString("SUPPLIERNAME");
                    String genderName   = rs.getString("GENDERNAME");
                    String supGrpName   = rs.getString("SUPGRPNAME");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ supplierNo+ "</td>";
//                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ supplierName+ "</td>";
//                    html += "<td>"+ genderName+ "</td>";
                    html += "<td>"+ supGrpName+ "</td>";
                    html += "<td>"+ edit+ "</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
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
            
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript: return false;\"");
        
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getBioDataTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getContactTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getProcessingTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"suppliers.save('firstName lastName gender dob country supplierNo supplierName supplierGroup'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\', \'Processing\'), 0, 625, 350, Array(false, false, false));";
        html += "</script>";
        
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
                String query = "SELECT * FROM "+ this.table+ " WHERE ID = "+ this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.supplierNo           = rs.getString("SUPPLIERNO");		
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            APSupplierProfile aPSupplierProfile = new APSupplierProfile(this.supplierNo, comCode);
            
            this.firstName          = aPSupplierProfile.firstName;
            this.middleName         = aPSupplierProfile.middleName;
            this.lastName           = aPSupplierProfile.lastName;
            this.supplierName       = aPSupplierProfile.supplierName;
            this.genderCode         = aPSupplierProfile.genderCode;
            this.dob                = aPSupplierProfile.dob;
            this.countryCode        = aPSupplierProfile.countryCode;
            this.nationalId         = aPSupplierProfile.nationalId;
            this.passportNo         = aPSupplierProfile.passportNo;
            this.postalAdr          = aPSupplierProfile.postalAdr;
            this.postalCode         = aPSupplierProfile.postalCode;
            this.physicalAdr        = aPSupplierProfile.physicalAdr;
            this.telephone          = aPSupplierProfile.telephone;
            this.cellphone          = aPSupplierProfile.cellphone;
            this.email              = aPSupplierProfile.email;
            this.supGrpCode         = aPSupplierProfile.supGrpCode;
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

//            try{
//                java.util.Date dob = originalFormat.parse(this.dob);
//                this.dob = targetFormat.format(dob);
//            }catch (Exception e){
//                html += e.getMessage();
//            }
            
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        String defaultCountryCode = sys.getOne(comCode+".CSCOUNTRIES", "COUNTRYCODE", "ISDEFAULT = 1");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"doctor-male.png", "", "")+ gui.formLabel("supplierNo", " Supplier No")+"</td>";
        String supplierNoUi;
        if(this.id != null){
            supplierNoUi      = gui.formAutoComplete("supplierNo", 15, this.id != null? this.supplierNo: "", "suppliers.searchSupplier", "supplierNoHd", this.id != null? this.supplierNo: "");
        }else{
            supplierNoUi      = gui.formInput("text", "supplierNo", 15, "" , "", "");
        }
        
        html += "<td colspan = \"3\">"+ supplierNoUi+ "</td>";
	html += "</tr>";
        
//        html += "<tr>";
//	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("firstName", " First Name")+"</td>";
//	html += "<td colspan = \"3\">"+gui.formInput("text", "firstName", 25, this.id != null? this.firstName: "", "", "")+"</td>";
//	html += "</tr>";
//        
//        html += "<tr>";
//	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("middleName", " Middle Name")+"</td>";
//	html += "<td colspan = \"3\">"+gui.formInput("text", "middleName", 25, this.id != null? this.middleName: "", "", "")+"</td>";
//	html += "</tr>";
//        
//        html += "<tr>";
//	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("lastName", " Last Name")+"</td>";
//	html += "<td colspan = \"3\">"+gui.formInput("text", "lastName", 25, this.id != null? this.lastName: "", "", "")+"</td>";
//	html += "</tr>";
        
//        html += "<tr>";
//	html += "<td>"+gui.formIcon(request.getContextPath(),"gender.png", "", "")+ gui.formLabel("gender", " Gender")+"</td>";
//	html += "<td colspan = \"3\">"+gui.formSelect("gender", "CSGENDER", "GENDERCODE", "GENDERNAME", null, null, this.id != null? this.genderCode: "", null, false)+"</td>";
//	html += "</tr>";
//        
//        html += "<tr>";
//	html += "<td>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("dob", " Date of Birth")+"</td>";
//	html += "<td colspan = \"3\">"+gui.formDateTime(request.getContextPath(), "dob", 15, this.id != null? this.dob: "", false, "")+"</td>";
//	html += "</tr>";

        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+ gui.formLabel("supplierName", " Name")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "supplierName", 25, this.id != null? this.supplierName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"globe-medium-green.png", "", "")+ gui.formLabel("country", " Country")+"</td>";
	html += "<td colspan = \"3\">"+gui.formSelect("country", comCode+".CSCOUNTRIES", "COUNTRYCODE", "COUNTRYNAME", null, null, this.id != null? this.countryCode: defaultCountryCode, null, false)+"</td>";
	html += "</tr>";
        
//        html += "<tr>";
//	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("nationalId", " National ID")+"</td>";
//	html += "<td width = \"30%\">"+gui.formInput("text", "nationalId", 15, this.id != null? this.nationalId: "", "", "")+"</td>";
//	
//	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("passportNo", " Passport No")+"</td>";
//	html += "<td>"+gui.formInput("text", "passportNo", 15, this.id != null? this.passportNo: "", "", "")+"</td>";
//	html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public String searchSupplier(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.supplierNo = request.getParameter("supplierNoHd");
        
        html += gui.getAutoColsSearch(this.table, "SUPPLIERNO, FULLNAME", "", this.supplierNo);
        
        return html;
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
    
    public String getProcessingTab(){
        String html = "";
        Gui gui = new Gui();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"20%\" nowrap>"+ gui.formIcon(request.getContextPath(), "group.png", "", "")+ gui.formLabel("supplierGroup", " Supplier Group")+ "</td>";
        html += "<td width = \"30%\">"+ gui.formSelect("supplierGroup", comCode+".APSUPGRPS", "SUPGRPCODE", "SUPGRPNAME", "", "", this.id != null? this.supGrpCode: "", "", false)+ "</td>";
       
        html += "<td width = \"20%\">&nbsp;</td>";
        html += "<td>&nbsp;</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public Object getSupplierProfile(){
        JSONObject obj = new JSONObject();
        
        if(this.supplierNo == null || this.supplierNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            APSupplierProfile aPSupplierProfile = new APSupplierProfile(this.supplierNo, comCode);
            
            obj.put("id", aPSupplierProfile.id);
            obj.put("firstName", aPSupplierProfile.firstName);
            obj.put("middleName", aPSupplierProfile.middleName);
            obj.put("lastName", aPSupplierProfile.lastName);
            obj.put("gender", aPSupplierProfile.genderCode);
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            try{
                java.util.Date dob = originalFormat.parse(aPSupplierProfile.dob);
                aPSupplierProfile.dob = targetFormat.format(dob);
            }catch(ParseException e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }
            
            obj.put("dob", aPSupplierProfile.dob);
            obj.put("country", aPSupplierProfile.countryCode);
            obj.put("postalAdr", aPSupplierProfile.postalAdr);
            obj.put("postalCode", aPSupplierProfile.postalCode);
            obj.put("physicalAdr", aPSupplierProfile.physicalAdr);
            obj.put("telephone", aPSupplierProfile.telephone);
            obj.put("cellphone", aPSupplierProfile.cellphone);
            obj.put("email", aPSupplierProfile.email);
            
            obj.put("supplierGroup", aPSupplierProfile.supGrpCode);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Supplier No '"+aPSupplierProfile.supplierNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object save(){
        JSONObject obj      = new JSONObject();
        Sys system       = new Sys();
        HttpSession session = request.getSession();
        
        String catch_ = "";
//        obj.put("zzz", "xxx");
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;
            stmt = conn.createStatement();
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
            SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

//            java.util.Date dob = originalFormat.parse(this.dob);
//            this.dob = targetFormat.format(dob);
            
            String query = "";
            Integer saved = 0;
//            obj.put("zzz", "xxx");
	            
            if(this.id == null){
                Integer id = system.generateId(this.table, "ID");
                
                query += "INSERT INTO "+this.table+" "
                        + "(ID, SUPPLIERNO, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, SUPPLIERNAME, "
                        + "GENDERCODE, DOB, COUNTRYCODE, NATIONALID, PASSPORTNO, "
                        + "POSTALADR, POSTALCODE, PHYSICALADR, TELEPHONE, CELLPHONE, EMAIL, SUPGRPCODE, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ") "
                        + "VALUES"
                        + "("
                        + id+ ","
                        + "'"+ this.supplierNo+ "', "
                        + "'"+ this.firstName+ "', "
                        + "'"+ this.middleName+ "', "
                        + "'"+ this.lastName+ "', "
                        + "'"+ this.firstName+ " "+ this.middleName+ " " +this.lastName+ "', "
                        + "'"+ this.supplierName+ "', "
                        + "'"+ this.genderCode+ "', "
                        + this.dob+ ", "
                        + "'"+ this.countryCode+ "', "
                        + "'"+ this.nationalId+ "', "
                        + "'"+ this.passportNo+ "', "
                        + "'"+ this.postalAdr+ "', "
                        + "'"+ this.postalCode+ "', "
                        + "'"+ this.physicalAdr+ "', "
                        + "'"+ this.telephone+ "', "
                        + "'"+ this.cellphone+ "', "
                        + "'"+ this.email+ "', "
                        + "'"+ this.supGrpCode+ "', "
                        + "'"+ system.getLogUser(session)+ "', "
                        + "'"+ system.getLogDate()+ "', "
                        + "'"+ system.getLogTime()+ "', "
                        + "'"+ system.getClientIpAdr(request)+ "'"
                        + ")";
                
                obj.put("q", query);
                obj.put("supplierNo", this.supplierNo);
                
            }else{
                if(this.supplierNo == null || this.supplierNo.trim().equals("")){
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record. Could not retrieve Supplier No.");
//                    obj.put("zzz", "xxx");
                }else{
                    query = "UPDATE "+this.table+" SET "
                            
                            + "FIRSTNAME        = '"+ this.firstName+ "', "
                            + "MIDDLENAME       = '"+ this.middleName+ "', "
                            + "LASTNAME         = '"+ this.lastName+ "',"
                            + "FULLNAME         = '"+ this.firstName+ " "+this.middleName+ " "+this.lastName+ "', "
                            + "GENDERCODE       = '"+ this.genderCode+ "', "
                            + "SUPPLIERNAME     = '"+ this.supplierName+ "', "
//                            + "DOB              = '"+ this.dob+ "', "
                            + "COUNTRYCODE      = '"+ this.countryCode+ "', "
                            + "NATIONALID       = '"+ this.nationalId+ "', "
                            + "PASSPORTNO       = '"+ this.passportNo+ "', "
                            + "POSTALADR        = '"+ this.postalAdr+ "', "
                            + "POSTALCODE       = '"+ this.postalCode+ "', "
                            + "PHYSICALADR      = '"+ this.physicalAdr+ "', "
                            + "TELEPHONE        = '"+ this.telephone+ "', "
                            + "CELLPHONE        = '"+ this.cellphone+ "', "
                            + "EMAIL            = '"+ this.email+ "', "
                            + "SUPGRPCODE       = '"+ this.supGrpCode+ "', "
                            + "AUDITUSER        = '"+ system.getLogUser(session)+ "', "
                            + "AUDITDATE        = '"+ system.getLogDate()+ "', "
                            + "AUDITTIME        = '"+ system.getLogTime()+ "', "
                            + "AUDITIPADR       = '"+ system.getClientIpAdr(request)+ "' "
                            
                            + "WHERE SUPPLIERNO    = '"+ this.supplierNo+ "'";
//                    obj.put("zzz", query);
                }
            }
            
            saved = stmt.executeUpdate(query);
            
            catch_ = query;
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
//                obj.put("zzz", "xxx");
            }
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
//            obj.put("message", e.getMessage()+ catch_);
//            obj.put("message", catch_);
        }
        
        return obj;
    }
    
}

%>