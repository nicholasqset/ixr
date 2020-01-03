<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.ar.ARCustomerProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Customers{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    String table            = comCode+".ARCUSTOMERS";
    String view             = comCode+".VIEWARCUSTOMERS";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    
    String customerNo       = this.id != null? request.getParameter("customerNoHd"): request.getParameter("customerNo");
    String customerName     = request.getParameter("customerName");
    String firstName        = request.getParameter("firstName");
    String middleName       = request.getParameter("middleName");
    String lastName         = request.getParameter("lastName");
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
    
    String cusGrpCode       = request.getParameter("customerGroup");
    
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

                        list.add("CUSTOMERNO");
                        list.add("FULLNAME");
                        list.add("CUSTOMERNAME");
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

            String orderBy = "CUSGRPCODE, CUSTOMERNO ";
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
                html += "<th>Customer No</th>";
                html += "<th>Name</th>";
//                html += "<th>Gender</th>";
                html += "<th>Customer Group</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id              = rs.getInt("ID");
                    String customerNo       = rs.getString("CUSTOMERNO");
                    String customerName     = rs.getString("CUSTOMERNAME");
//                    String fullName     = rs.getString("FULLNAME");
//                    String genderName   = rs.getString("GENDERNAME");
                    String cusGrpName       = rs.getString("CUSGRPNAME");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ customerNo+ "</td>";
                    html += "<td>"+ customerName+ "</td>";
//                    html += "<td>"+ fullName+ "</td>";
//                    html += "<td>"+ genderName+ "</td>";
                    html += "<td>"+ cusGrpName+ "</td>";
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
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"customers.save('customerNo customerName customerGroup'); return false;\"", "");
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
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.customerNo           = rs.getString("CUSTOMERNO");		
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            ARCustomerProfile aRCustomerProfile = new ARCustomerProfile(this.customerNo, comCode);
            
            this.firstName          = aRCustomerProfile.firstName;
            this.middleName         = aRCustomerProfile.middleName;
            this.lastName           = aRCustomerProfile.lastName;
            this.customerName       = aRCustomerProfile.customerName;
            this.genderCode         = aRCustomerProfile.genderCode;
            this.dob                = aRCustomerProfile.dob;
            this.countryCode        = aRCustomerProfile.countryCode;
            this.nationalId         = aRCustomerProfile.nationalId;
            this.passportNo         = aRCustomerProfile.passportNo;
            this.postalAdr          = aRCustomerProfile.postalAdr;
            this.postalCode         = aRCustomerProfile.postalCode;
            this.physicalAdr        = aRCustomerProfile.physicalAdr;
            this.telephone          = aRCustomerProfile.telephone;
            this.cellphone          = aRCustomerProfile.cellphone;
            this.email              = aRCustomerProfile.email;
            this.cusGrpCode         = aRCustomerProfile.cusGrpCode;
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
            
            if(this.dob != null && !this.dob.trim().equals("")){
                try{
                    java.util.Date dob = originalFormat.parse(this.dob);
                    this.dob = targetFormat.format(dob);
                }catch(ParseException e){
                    html += e.getMessage();
                }catch (Exception e){
                    html += e.getMessage();
                }
            }else{
                this.dob = "";
            }
            
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        String defaultCountryCode = sys.getOne(comCode+".CSCOUNTRIES", "COUNTRYCODE", "ISDEFAULT = 1");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"doctor-male.png", "", "")+ gui.formLabel("customerNo", " Customer No")+"</td>";
        String customerNoUi;
        if(this.id != null){
            customerNoUi      = gui.formAutoComplete("customerNo", 15, this.id != null? this.customerNo: "", "customers.searchCustomer", "customerNoHd", this.id != null? this.customerNo: "");
        }else{
            customerNoUi      = gui.formInput("text", "customerNo", 15, "" , "", "");
        }
        
        html += "<td colspan = \"3\">"+ customerNoUi+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("customerName", " Name")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "customerName", 30, this.id != null? this.customerName: "", "", "")+"</td>";
	html += "</tr>";
//        
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
//        
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
    
    public String searchCustomer(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.customerNo = request.getParameter("customerNoHd");
        
//        html += gui.getAutoColsSearch("ARCUSTOMERS", "CUSTOMERNO, FULLNAME", "", this.customerNo);
        html += gui.getAutoColsSearch(comCode+".ARCUSTOMERS", "CUSTOMERNO, CUSTOMERNAME", "", this.customerNo);
        
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
	html += "<td width = \"20%\" nowrap>"+ gui.formIcon(request.getContextPath(), "group.png", "", "")+ gui.formLabel("customerGroup", " Customer Group")+ "</td>";
        html += "<td width = \"30%\">"+ gui.formSelect("customerGroup", comCode+".ARCUSGRPS", "CUSGRPCODE", "CUSGRPNAME", "", "", this.id != null? this.cusGrpCode: "", "", false)+ "</td>";
       
        html += "<td width = \"20%\">&nbsp;</td>";
        html += "<td>&nbsp;</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public Object getCustomerProfile(){
        JSONObject obj = new JSONObject();
        
        if(this.customerNo == null || this.customerNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            ARCustomerProfile aRCustomerProfile = new ARCustomerProfile(this.customerNo, comCode);
            
            obj.put("id", aRCustomerProfile.id);
            obj.put("firstName", aRCustomerProfile.firstName);
            obj.put("middleName", aRCustomerProfile.middleName);
            obj.put("lastName", aRCustomerProfile.lastName);
            obj.put("gender", aRCustomerProfile.genderCode);
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            try{
                java.util.Date dob = originalFormat.parse(aRCustomerProfile.dob);
                aRCustomerProfile.dob = targetFormat.format(dob);
            }catch(ParseException e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }
            
            obj.put("dob", aRCustomerProfile.dob);
            obj.put("country", aRCustomerProfile.countryCode);
            obj.put("postalAdr", aRCustomerProfile.postalAdr);
            obj.put("postalCode", aRCustomerProfile.postalCode);
            obj.put("physicalAdr", aRCustomerProfile.physicalAdr);
            obj.put("telephone", aRCustomerProfile.telephone);
            obj.put("cellphone", aRCustomerProfile.cellphone);
            obj.put("email", aRCustomerProfile.email);
            
            obj.put("customerGroup", aRCustomerProfile.cusGrpCode);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Customer No '"+aRCustomerProfile.customerNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object save(){
        JSONObject obj      = new JSONObject();
        Sys sys       = new Sys();
        HttpSession session = request.getSession();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.dob != null && !this.dob.trim().equals("")){
                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                java.util.Date dob = originalFormat.parse(this.dob);
                this.dob = targetFormat.format(dob);
            }else{
                this.dob = null;
            }
            
            String query = "";
            Integer saved = 0;
	            
            if(this.id == null){
                Integer id = sys.generateId(this.table, "ID");
                
                this.dob = this.dob == null? null+ ", ": "'"+ this.dob+ "', ";
                
                query += "INSERT INTO "+ this.table+ " "
                        + "(ID, CUSTOMERNO, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, CUSTOMERNAME, "
                        + "GENDERCODE, DOB, COUNTRYCODE, NATIONALID, PASSPORTNO, "
                        + "POSTALADR, POSTALCODE, PHYSICALADR, TELEPHONE, CELLPHONE, EMAIL, CUSGRPCODE, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ") "
                        + "VALUES"
                        + "("
                        + id+ ","
                        + "'"+ this.customerNo+ "', "
                        + "'"+ this.firstName+ "', "
                        + "'"+ this.middleName+ "', "
                        + "'"+ this.lastName+ "', "
                        + "'"+ this.firstName+ " "+ this.middleName+ " " +this.lastName+ "', "
                        + "'"+ this.customerName+ "', "
                        + "'"+ this.genderCode+ "', "
                        + this.dob
                        + "'"+ this.countryCode+ "', "
                        + "'"+ this.nationalId+ "', "
                        + "'"+ this.passportNo+ "', "
                        + "'"+ this.postalAdr+ "', "
                        + "'"+ this.postalCode+ "', "
                        + "'"+ this.physicalAdr+ "', "
                        + "'"+ this.telephone+ "', "
                        + "'"+ this.cellphone+ "', "
                        + "'"+ this.email+ "', "
                        + "'"+ this.cusGrpCode+ "', "
                        + "'"+ sys.getLogUser(session)+ "', "
                        + "'"+ sys.getLogDate()+ "', "
                        + "'"+ sys.getLogTime()+ "', "
                        + "'"+ sys.getClientIpAdr(request)+ "'"
                        + ")";
                
                obj.put("customerNo", this.customerNo);
                
            }else{
                
                if(this.customerNo == null || this.customerNo.trim().equals("")){
                    
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record. Could not retrieve Customer No.");
                    
                }else{
                    this.dob = this.dob == null? null+ ", ": "'"+ this.dob+ "', ";
                    query = "UPDATE "+this.table+" SET "
                            + "FIRSTNAME        = '"+ this.firstName+ "', "
                            + "MIDDLENAME       = '"+ this.middleName+ "', "
                            + "LASTNAME         = '"+ this.lastName+ "',"
                            + "FULLNAME         = '"+ this.firstName+ " "+this.middleName+ " "+this.lastName+ "', "
                            + "GENDERCODE       = '"+ this.genderCode+ "', "
                            + "CUSTOMERNAME     = '"+ this.customerName+ "', "
//                            + "DOB              = '"+ this.dob+ "', "
                            + "DOB              = "+ this.dob
                            + "COUNTRYCODE      = '"+ this.countryCode+ "', "
                            + "NATIONALID       = '"+ this.nationalId+ "', "
                            + "PASSPORTNO       = '"+ this.passportNo+ "', "
                            + "POSTALADR        = '"+ this.postalAdr+ "', "
                            + "POSTALCODE       = '"+ this.postalCode+ "', "
                            + "PHYSICALADR      = '"+ this.physicalAdr+ "', "
                            + "TELEPHONE        = '"+ this.telephone+ "', "
                            + "CELLPHONE        = '"+ this.cellphone+ "', "
                            + "EMAIL            = '"+ this.email+ "', "
                            + "CUSGRPCODE       = '"+ this.cusGrpCode+ "', "
                            + "AUDITUSER        = '"+ sys.getLogUser(session)+ "', "
                            + "AUDITDATE        = '"+ sys.getLogDate()+ "', "
                            + "AUDITTIME        = '"+ sys.getLogTime()+ "', "
                            + "AUDITIPADR       = '"+ sys.getClientIpAdr(request)+ "' "
                            
                            + "WHERE CUSTOMERNO    = '"+ this.customerNo+ "'";
                    
                    obj.put("query", query);
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
    
}

%>