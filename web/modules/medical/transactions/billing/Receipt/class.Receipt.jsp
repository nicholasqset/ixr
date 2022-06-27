<%@page import="org.json.JSONObject"%>
<%@page import="bean.ic.IC"%>
<%@page import="bean.medical.HmPyHdr"%>
<%@page import="bean.finance.VAT"%>
<%@page import="bean.ic.ICItem"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.medical.Medical"%>
<%@page import="bean.medical.MedicalItem"%>
<%@page import="bean.finance.FinConfig"%>
<%@page import="bean.medical.HMStaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.medical.PatientProfile"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Receipt{
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
    String table        = comCode+".HMREGISTRATION";
    String view         = comCode+".VIEWHMREGOPDS";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String ptNo         = request.getParameter("ptNoHd");
    String drNo         = request.getParameter("drNoHd");
    String nrNo         = request.getParameter("nrNoHd");
    String regType      = request.getParameter("regType");
    Double total        = request.getParameter("total") != null? Double.parseDouble(request.getParameter("total")): null;
    
    String pyNo         = request.getParameter("billNoHd") != null && ! request.getParameter("billNoHd").trim().equals("")? request.getParameter("billNoHd"): null;
    
    String entryDate    = request.getParameter("entryDate");
    String pyDesc       = request.getParameter("pyDesc");
    Integer pYear       = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth      = request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    
    String itemCode     = request.getParameter("itemNo");
    Double qty          = (request.getParameter("quantity") != null && ! request.getParameter("quantity").trim().equals(""))? Double.parseDouble(request.getParameter("quantity")): 0.0;
    Double unitPrice    = (request.getParameter("price") != null && ! request.getParameter("price").trim().equals(""))? Double.parseDouble(request.getParameter("price")): 0.0;
    Double amount       = (request.getParameter("amount") != null && ! request.getParameter("amount").trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;

    Integer taxIncl     = 1;
    
    Integer sid         = request.getParameter("sid") != null? Integer.parseInt(request.getParameter("sid")): null;
    String regNo        = request.getParameter("regNo");
    
    Integer bid         = request.getParameter("bid") != null? Integer.parseInt(request.getParameter("bid")): null;
    
    Double bill         = (request.getParameter("bill") != null && ! request.getParameter("bill").trim().equals(""))? Double.parseDouble(request.getParameter("bill")): 0.0;
    String pmCode       = request.getParameter("payMode");
    String docNo        = request.getParameter("documentNo");
    Double tender       = (request.getParameter("tender") != null && ! request.getParameter("tender").trim().equals(""))? Double.parseDouble(request.getParameter("tender")): 0.0;
    Double change       = (request.getParameter("change") != null && ! request.getParameter("change").trim().equals(""))? Double.parseDouble(request.getParameter("change")): 0.0;

    
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

                        list.add("REGNO");
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

            String orderBy = "REGNO DESC ";
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
                html += "<th>Reg No</th>";
                html += "<th>Reg Type</th>";
                html += "<th>Patient No</th>";
                html += "<th>Patient Name</th>";
                html += "<th>Reg Date</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String regNo        = rs.getString("REGNO");
                    String regType      = rs.getString("REGTYPE");
                    String ptNo         = rs.getString("PTNO");
                    String fullName     = rs.getString("FULLNAME");
                    String regDate      = rs.getString("REGDATE");

                    String regTypeLbl = "Unknown";

                    if(regType.equals("N")){
                        regTypeLbl = "New Patient";
                    }else if(regType.equals("R")){
                        regTypeLbl = "Return Patient";
                    }

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "view", "view", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+count+"</td>";
                    html += "<td>"+regNo+"</td>";
                    html += "<td>"+regTypeLbl+"</td>";
                    html += "<td>"+ptNo+"</td>";
                    html += "<td>"+fullName+"</td>";
                    html += "<td>"+regDate+"</td>";
                    html += "<td>"+edit+"</td>";
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
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getRegistrationTab()+ "</div>";
        if(this.id != null){
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"dvBills\">"+ this.getBillingTab()+ "</div></div>";
        }
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
        
        if(this.id == null){
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Register", "save.png", "onclick = \"receipt.save('ptNo regType drNo nrNo');\"", "");
        }
        
//	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getGrid();\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"module.getGrid();\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        if(this.id != null){
           html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Registration\', \'Billing\'), 0, 625, 420, Array(false, false));"; 
        }else{
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Registration\'), 0, 625, 420, Array(false));";
        }
        html += "</script>";
        
        return html;
    }
    
    public String getRegistrationTab(){
        String html = "";
        Gui gui = new Gui();
//        Sys sys = new Sys();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;
        
        String fullName = "";
        String genderName = "";
        String dob = "";
        String cellphone = "";
        String email = "";
        
        String drName = "";
        String nrName = "";
        
//        this.regType = sys.getRecordCount("VIEWHMREGISTRATION", "PTNO = '"+ this.ptNo+ "'") > 0? "R": "N";
        
        if(this.id != null){
            try{
                stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.view+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.ptNo       = rs.getString("PTNO");
                    
                    PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);
                    fullName        = patientProfile.fullName;
                    genderName      = patientProfile.genderName;
                    dob             = patientProfile.dob;
                    cellphone       = patientProfile.cellphone;
                    email           = patientProfile.email;
                    
                    this.regType    = rs.getString("REGTYPE");
                    this.drNo       = rs.getString("DRNO");
                    this.nrNo       = rs.getString("NRNO");
                    drName          = rs.getString("DRNAME");
                    nrName          = rs.getString("NRNAME");
                    
                    this.regNo      = rs.getString("REGNO");
                }
            }catch (Exception e){
                html += e.getMessage();
            }
        }        
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+ this.id, "", "");
            html += gui.formInput("hidden", "regNo", 30, this.regNo, "", "");
        }
        
        HashMap<String, String> regTypes = new HashMap();
        regTypes.put("N", "New Patient");
        regTypes.put("R", "Return Patient");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("ptNo", "Patient")+"</td>";
	html += "<td>"+gui.formAutoComplete("ptNo", 15, this.id != null? this.ptNo: "", "receipt.searchPatient", "ptNoHd", this.id != null? this.ptNo: "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"patient-male.png", "", "")+" Name</td>";
	html += "<td id = \"ptName\">"+fullName+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"gender.png", "", "")+" Gender</td>";
	html += "<td id = \"ptGender\">"+genderName+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "")+" Date of Birth</td>";
	html += "<td id = \"ptDob\">"+dob+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"mobile-phone.png", "", "")+" Cellphone</td>";
	html += "<td id = \"ptCellphone\">"+cellphone+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"email.png", "", "")+" Email</td>";
	html += "<td id = \"ptEmail\">"+email+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+gui.formLabel("regType", "Registration Type")+"</td>";
        html += "<td>"+gui.formArraySelect("regType", 150,  new  HashMap(regTypes), this.regType, false, "", true)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"doctor-male.png", "", "")+" "+gui.formLabel("drNo", "Doctor")+"</td>";
	html += "<td>"+gui.formAutoComplete("drNo", 15, this.id != null? this.drNo: "", "receipt.searchDoctor", "drNoHd", this.id != null? this.drNo: "")+" <span id = \"spDoctor\">"+drName+"</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"doctor-female.png", "", "")+" "+gui.formLabel("nrNo", "Nurse")+"</td>";
	html += "<td>"+gui.formAutoComplete("nrNo", 15, this.id != null? this.nrNo: "", "receipt.searchNurse", "nrNoHd", this.id != null? this.nrNo: "")+" <span id = \"spNurse\">"+nrName+"</span></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchPatient(){
        String html = "";
        
        Gui gui = new Gui();
        html += gui.getAutoColsSearch("HMPTPROFILE", "PTNO, FULLNAME", "", this.ptNo);
        
        return html;
    }
    
    public Object getPatientProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.ptNo == null || this.ptNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);
            
            obj.put("fullName", patientProfile.fullName);
            obj.put("gender", patientProfile.genderName);
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            try{
                java.util.Date dob = originalFormat.parse(patientProfile.dob);
                patientProfile.dob = targetFormat.format(dob);
            }catch(ParseException e){

            }
            
            obj.put("dob", patientProfile.dob);
            obj.put("cellphone", patientProfile.cellphone);
            obj.put("email", patientProfile.email);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Patient No '"+patientProfile.ptNo+"' details successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String searchDoctor(){
        String html = "";
        
        Gui gui = new Gui();
        html += gui.getAutoColsSearch("VIEWHMDOCTORS", "STAFFNO, FULLNAME", "", this.drNo);
        
        return html;
    }
    
    public Object getDoctorProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.drNo == null || this.drNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            HMStaffProfile hMStaffProfile = new HMStaffProfile(this.drNo, this.comCode);
            
            obj.put("fullName", hMStaffProfile.fullName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Doctor No '"+hMStaffProfile.staffNo+"' details successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String searchNurse(){
        String html = "";
        
        Gui gui = new Gui();
        html += gui.getAutoColsSearch("VIEWHMNURSES", "STAFFNO, FULLNAME", "", this.nrNo);
        
        return html;
    }
    
    public Object getNurseProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.nrNo == null || this.nrNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            HMStaffProfile hMStaffProfile = new HMStaffProfile(this.nrNo, this.comCode);
            
            obj.put("fullName", hMStaffProfile.fullName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Nurse No '"+hMStaffProfile.staffNo+"' details successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object save() throws Exception{    
        HttpSession session = request.getSession();
        
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            Integer saved = 0;
            
            Integer id      = sys.generateId(this.table, "ID");
            String regNo    = sys.getNextNo(this.table, "ID", "", "R", 7);
            
            String query;
            
            Integer rts = 1;
            
            String saveErrMsg = "";
            
            if(sys.recordExists("VIEWHMREGISTRATION", "PTNO = '"+ this.ptNo+ "'")){
                if(this.regType.equals("N")){
                    rts = 0;
                    saveErrMsg = "Try 'Return Patient'";
                }
            }else{
                if(this.regType.equals("R")){
                    rts = 0;
                    saveErrMsg = "Try 'New Patient'";
                }
            }
            
            if(rts == 1){
                query = "INSERT INTO "+ this.table+ " "
                        + ""
                        + "(ID, REGNO, REGTYPE, PTNO, PTTYPE, PYEAR, PMONTH, REGDATE, DRNO, "
                            + "NRNO, AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id+", "
                        + "'"+regNo+"', "
                        + "'"+this.regType+"', "
                        + "'"+this.ptNo+"', "
                        + "'OUT', "
                        + sys.getPeriodYear(this.comCode)+ ", "
                        + sys.getPeriodMonth(this.comCode)+ ", "
                        + "'"+sys.getLogDate()+"', "
                        + "'"+this.drNo+"', "
                        + "'"+this.nrNo+"', "
                        + "'"+sys.getLogUser(session)+"', "
                        + "'"+sys.getLogDate()+"', "
                        + "'"+sys.getLogTime()+"', "
                        + "'"+sys.getClientIpAdr(request)+"'"
                        + ")";

                saved = stmt.executeUpdate(query);

                if(saved == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");

    //                this.invoicePatient(regNo);
                    obj.put("rid", id);
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", saveErrMsg);
            }
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public String getBillingTab(){
        String html = "";
        
        html += this.listBills();
        
        return html;
    }
    
    public String listBills(){
        String html = "";
        
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        String regNo = sys.getOne(this.table, "REGNO", "ID = "+ this.id);
        
        if(sys.recordExists(""+this.comCode+".VIEWHMPYHDR", "REGNO = '"+ regNo +"'")){
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Bill No</th>";
            html += "<th>Bill Date</th>";
            html += "<th>Paid</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            Double total = 0.00;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+this.comCode+".VIEWHMPYHDR WHERE REGNO = '"+ regNo +"' ORDER BY PYNO DESC ";
                ResultSet rs = stmt.executeQuery(query);
                
                Integer count  = 1;
                
                while(rs.next()){
                    Integer bid             = rs.getInt("ID");
                    String pyNo             = rs.getString("PYNO");
                    String entryDate        = rs.getString("ENTRYDATE");
                    Integer cleared         = rs.getInt("CLEARED");
                    
                    String invDateLbl       = entryDate;
                    
                    Double amount = 0.00;
                    
                    String amountInvDtls_    = sys.getOneAgt(""+this.comCode+".VIEWHMPYDTLS", "SUM", "AMOUNT", "SM", "PYNO = '"+ pyNo +"'");
                    
                    if(amountInvDtls_ != null){
                        amount = Double.parseDouble(amountInvDtls_);
                    }
                    
                    String clearedLbl = cleared == 1? gui.formIcon(request.getContextPath(), "tick.png", "", ""): gui.formIcon(request.getContextPath(), "cross.png", "", "");
                    
                    String editLink         = gui.formHref("onclick = \"receipt.editBill("+ this.id +", "+ bid +", '"+ pyNo+ "');\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String printLink        = gui.formHref("onclick = \"receipt.print('"+ pyNo +"');\"", request.getContextPath(), "", "print", "print", "", "");
                    
                    String opts = editLink +" || "+ printLink;
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ pyNo +"</td>";
                    html += "<td>"+ invDateLbl +"</td>";
                    html += "<td>"+ clearedLbl +"</td>";
                    html += "<td style = \"text-align: right;\">"+ amount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    total = total + amount;
                    
                    count++;
                }
                
            }catch(Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"4\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ total +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
        }else{
           html += "No records found.";
        }
        
        html += "<div style = \"padding: 7px 0;\">"+ gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "math-add.png", "onclick = \"receipt.manageBill(); return false;\"", "")+ "</div>";
        
        return html;
    }
    
    public String manageBill(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        String defaultDate = sys.getLogDate();

        try{
            java.util.Date today = originalFormat.parse(defaultDate);
            defaultDate = targetFormat.format(today);
        }catch(ParseException e){
            html += e.getMessage();
        }catch (Exception e){
            html += e.getMessage();
        }
        
        if(this.bid != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.comCode+".VIEWHMPYHDR WHERE ID = "+ this.bid;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.pyNo           = rs.getString("PYNO");
                    this.entryDate      = rs.getString("ENTRYDATE");
                    
                    java.util.Date entryDate = originalFormat.parse(this.entryDate);
                    this.entryDate = targetFormat.format(entryDate);
                    
                    this.pyDesc         = rs.getString("PYDESC");
                    this.pMonth         = rs.getInt("PMONTH");
                    this.pYear          = rs.getInt("PYEAR");
                }
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        html += "<div id = \"dvPyEntrySid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+ this.sid, "", "");
        }
        html += "</div>";
        
        PatientProfile patientProfile= new PatientProfile(this.ptNo, this.comCode);
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("billNo", " Bill No.")+"</td>";
	html += "<td>"+ gui.formInput("text", "billNo", 15, this.bid != null? this.pyNo: "", "", "disabled")+ gui.formInput("hidden", "billNoHd", 15, this.bid != null? this.pyNo: "", "", "")+ "</td>";
        
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", " Date")+"</td>";
	html += "<td>"+ gui.formDateTime(request.getContextPath(), "entryDate", 13, this.bid != null? this.entryDate: defaultDate, false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"package.png", "", "")+ gui.formLabel("pyDesc", " Description")+"</td>";
        html += "<td colspan = \"3\">"+ gui.formInput("text", "pyDesc", 30, this.bid != null? this.pyDesc: this.ptNo+ "-"+ patientProfile.fullName, "", "")+"</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
        html += "<td width = \"35%\">"+ gui.formSelect("pYear", ""+this.comCode+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.bid != null? ""+ this.pYear: ""+sys.getPeriodYear(this.comCode), "", false)+"</td>";
	
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", this.bid != null? this.pMonth: sys.getPeriodMonth(this.comCode), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("itemNo", " Item No")+ "</td>";
        html += "<td nowrap>"+ gui.formAutoComplete("itemNo", 13, "", "receipt.searchItem", "itemNoHd", "")+ "</td>";

        html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ " Item Name</td>";
        html += "<td id = \"tdItemName\">&nbsp;</td>";
        html += "</tr>";

        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("quantity", " Quantity")+ "</td>";
        html += "<td id = \"tdQuantity\" colspan = \"3\">"+ gui.formInput("text", "quantity", 15, "", "onkeyup = \"receipt.getItemTotalAmount();\"", "")+ "</td>";
        html += "</tr>";

        html += "<tr>";
        html += "<td>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("price", " Price")+ "</td>";
        html += "<td id = \"tdCost\" colspan = \"3\" nowrap>"+ gui.formInput("text", "price", 15, "", "onkeyup = \"receipt.getItemTotalAmount();\"", "")+ "</td>";
        html += "</tr>";

        html += "<tr>";
        html += "<td>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("amount", " Amount")+ "</td>";
        html += "<td id = \"tdAmount\" colspan = \"3\" nowrap>"+ gui.formInput("text", "amount", 15, "", "", "disabled")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
        html += "<td colspan = \"4\"><div id = \"dvPyEntries\">"+ this.getPyEntries()+"</div></td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td colspan = \"3\">"; 
        html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"receipt.saveBill('entryDate pyDesc pYear pMonth till quantity itemNo price amount'); return false;\"", "");
        html += "&nbsp;";
        html += gui.formButton(request.getContextPath(), "button", "btnBack", "Back", "arrow-left-2.png", "onclick = \"receipt.listBills(); return false;\"", "");
        html += "</td>";
	html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public String getPyEntries(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
//        html += this.pyNo;

        if(sys.recordExists(""+this.comCode+".VIEWHMPYDTLS", "PYNO = '"+ this.pyNo+ "'")){
            html += "<div id = \"dvPyEntries-a\">";

            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";

            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Item</th>";
            html += "<th style = \"text-align: right;\">Quantity</th>";
            html += "<th style = \"text-align: right;\">Price</th>";
            html += "<th style = \"text-align: center;\">Tax Incl.</th>";
            html += "<th style = \"text-align: right;\">Tax</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";

            html += "<th style = \"text-align: center;\">Options</th>";
            html += "</tr>";

            Double sumAmount    = 0.0;
            Double sumTax       = 0.0;
            Double sumTotal     = 0.0;

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                Integer count  = 1;

                String query = "SELECT * FROM "+this.comCode+".VIEWHMPYDTLS WHERE PYNO = '"+ this.pyNo+ "'";

                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String itemName     = rs.getString("ITEMNAME");
                    Double qty          = rs.getDouble("QTY");
                    Double unitPrice    = rs.getDouble("UNITPRICE");
                    Double taxAmount    = rs.getDouble("TAXAMOUNT");
                    Double amount       = rs.getDouble("AMOUNT");
                    Double total        = rs.getDouble("TOTAL");
                    Integer taxIncl     = rs.getInt("TAXINCL");
                    Integer cleared     = rs.getInt("CLEARED");

                    Double taxAmountAlt = taxIncl == 1? taxAmount: 0;

                    String taxInclLbl   = taxIncl == 1? "Yes": "No";

                    String editLink     = gui.formHref("onclick = \"receipt.editPyDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"receipt.purge("+ id +", '"+ itemName +"');\"", request.getContextPath(), "", "delete", "delete", "", "");

                    String opts = "";
                    if(cleared == 1){
                        opts = gui.formIcon(request.getContextPath(), "lock.png", "", "");
                    }else{
                        opts = editLink+ " || "+ removeLink;
                    }

                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ itemName +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(qty.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(unitPrice.toString()) +"</td>";
                    html += "<td style = \"text-align: center;\">"+ taxInclLbl+"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(taxAmountAlt.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(amount.toString()) +"</td>";

                    html += "<td style = \"text-align: center;\">"+ opts +"</td>";
                    html += "</tr>";

                    sumAmount   = sumAmount + amount;
                    sumTax      = sumTax + taxAmountAlt;
                    sumTotal    = sumTotal + total;

                    count++;
                }
            }catch (Exception e){
                html += e.getMessage();
            }

            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"5\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumTax.toString()) +"</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumAmount.toString()) +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";

            html += "</table>";

            html += "</div>";
            
            html += "<div id = \"dvPyEntries-b\">";
                
                HmPyHdr hmPyHdr = new HmPyHdr(this.pyNo, this.comCode);
                
                String paymentUi = "";
                
                if(! hmPyHdr.cleared){
                    paymentUi = gui.formButton(request.getContextPath(), "button", "btnPayment", "Payment", "cross.png", "onclick = \"receipt.getPaymentUi('"+ this.pyNo+ "');\"", "");
                }else{
                    paymentUi = gui.formButton(request.getContextPath(), "button", "btnPayment", "Paid", "tick.png", "onclick = \"alert('Already Paid.');\"", "");
                }
                
                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";
                
                html += "<tr>";
                html += "<td style = \"text-align: right;\">"+ paymentUi+ "</td>";
                html += "</tr>";
                
                html += "</table>";
                
                html += "</div>";
        }else{
            html += "No bill items record found.";
        }

        return html;
    }
    
    public String searchItem(){
        String html = "";

        Gui gui = new Gui();

        this.itemCode = request.getParameter("itemNoHd");

//        html += gui.getAutoColsSearch("VIEWHMITEMS", "ITEMCODE, ITEMNAME", "", this.itemCode);
        html += gui.getAutoColsSearch(""+this.comCode+".ICITEMS", "ITEMCODE, ITEMNAME", "", this.itemCode);

        return html;
    }

    public Object getItemProfile() throws Exception{
        JSONObject obj = new JSONObject();

        if(this.itemCode == null || this.itemCode.trim().equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            ICItem iCItem = new ICItem(this.itemCode, this.comCode);

            obj.put("itemName", iCItem.itemName);
            obj.put("quantity", 1.0);
            obj.put("price", iCItem.unitPrice);
            obj.put("amount", (1.0 * iCItem.unitPrice));

            obj.put("success", new Integer(1));
            obj.put("message", "Item No '"+ iCItem.itemCode+"' successfully retrieved.");
        }

        return obj;
    }
    
    public Object getItemTotalAmount() throws Exception{
        JSONObject obj = new JSONObject();

        Double itemTotalPrice = this.qty * this.unitPrice;

        obj.put("amount", itemTotalPrice);

        return obj;
    }
    public Object saveBill() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        HttpSession session = request.getSession();

        this.pyNo = this.getPyNo();
        
        if(this.pyNo != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query;
                Integer saved = 0;

                ICItem iCItem = new ICItem(this.itemCode, this.comCode);

                Boolean taxInclusive    = (this.taxIncl != null && this.taxIncl == 1)? true: false;

                VAT vAT = new VAT(this.amount, taxInclusive, this.comCode);

                if(this.sid == null){
                    Integer sid = sys.generateId(""+this.comCode+".HMPYDTLS", "ID");

                    query = "INSERT INTO "+this.comCode+".HMPYDTLS "
                            + "(ID, PYNO, ITEMCODE, "
                            + "QTY, UNITCOST, UNITPRICE, TAXINCL, "
                            + "TAXRATE, TAXAMOUNT, NETAMOUNT, AMOUNT, TOTAL, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + sid+ ", "
                            + "'"+ this.pyNo+ "', "
                            + "'"+ this.itemCode+ "', "
                            + this.qty+ ", "
                            + iCItem.unitCost+ ", "
                            + this.unitPrice+ ", "
                            + this.taxIncl+ ", "
                            + vAT.vatRate+ ", "
                            + vAT.vatAmount+ ", "
                            + vAT.netAmount+ ", "
                            + this.amount+ ", "
                            + vAT.total+ ", "
                            + "'"+ sys.getLogUser(session)+"', "
                            + "'"+ sys.getLogDate()+ "', "
                            + "'"+ sys.getLogTime()+ "', "
                            + "'"+ sys.getClientIpAdr(request)+ "'"
                            + ")";
                }else{
                    query = "UPDATE "+this.comCode+".HMPYDTLS SET "
                            + "ITEMCODE     = '"+ this.itemCode+ "', "
                            + "QTY          = "+ this.qty+ ", "
                            + "UNITPRICE     = "+ this.unitPrice+ ", "
                            + "TAXINCL      = "+ this.taxIncl+ ", "
                            + "TAXRATE      = "+ vAT.vatRate+ ", "
                            + "TAXAMOUNT    = "+ vAT.vatAmount+ ", "
                            + "NETAMOUNT    = "+ vAT.netAmount+ ", "
                            + "AMOUNT       = "+ this.amount+ ", "
                            + "TOTAL        = "+ vAT.total+ " "
                            + "WHERE ID     = "+this.sid;
                }

                saved = stmt.executeUpdate(query);

                if(saved == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");

                    obj.put("billNo", this.pyNo);
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }
            }catch (Exception e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }
        }else{
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while saving record header.");
        }

        return obj;
    }

    public String getPyNo(){
        Sys sys = new Sys();
        HttpSession session = request.getSession();

        if(this.pyNo == null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                Integer id = sys.generateId(""+this.comCode+".HMPYHDR", "ID");
                this.pyNo = sys.getNextNo(""+this.comCode+".HMPYHDR", "ID", "", "", 7);
                
                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                java.util.Date entryDate = originalFormat.parse(this.entryDate);
                this.entryDate = targetFormat.format(entryDate);
                
                String query = "INSERT INTO "+this.comCode+".HMPYHDR "
                        + "("
                        + "ID, REGNO, PYNO, PYDESC, "
                        + "ENTRYDATE, PYEAR, PMONTH, TILLNO, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ this.regNo+ "', "
                        + "'"+ this.pyNo+ "', "
                        + "'"+ this.pyDesc+ "', "
                        + "'"+ this.entryDate+ "', "
                        + this.pYear+", "
                        + this.pMonth+ ", "
                        + "'0', "
                        + "'"+ sys.getLogUser(session)+"', "
                        + "'"+ sys.getLogDate()+ "', "
                        + sys.getLogTime()+ ", "
                        + "'"+ sys.getClientIpAdr(request)+ "'"
                        + ")";
                
                Integer pyHdrCreated = stmt.executeUpdate(query);

                if(pyHdrCreated == 1){
                    //
                }else{
                    this.pyNo = null;
                }
            }catch(Exception e){
                e.getMessage();
            }
        }

        return this.pyNo;
    }
    
    public Object editPyDtls() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists(""+this.comCode+".HMPYDTLS", "ID = "+ this.sid +"")){
            try{

                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query = "SELECT * FROM "+this.comCode+".VIEWHMPYDTLS WHERE ID = "+ this.sid +"";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String itemCode     = rs.getString("ITEMCODE");
                    Double qty          = rs.getDouble("QTY");
                    Double unitPrice    = rs.getDouble("UNITPRICE");
                    String amount       = rs.getString("AMOUNT");

                    obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                    obj.put("itemNo", itemCode);
                    obj.put("quantity", qty);
                    obj.put("price", unitPrice);
                    obj.put("amount", amount);

                    obj.put("success", new Integer(1));
                    obj.put("message", "Record retrieved successfully.");
                }
            }catch (Exception e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }
        }else{
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }

        return obj;
    }
    
    public Object purge() throws Exception{
             JSONObject obj = new JSONObject();

             try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if(this.id != null){
                    String query = "DELETE FROM "+this.comCode+".HMPYDTLS WHERE ID = "+ this.id;

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
                    obj.put("message", "An unexpected error occured while deleting record.");
                }
            }catch (Exception e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }
    
    public String getPaymentUi(){
        String html = "";

        Gui gui = new Gui();
        Sys sys = new Sys();

        String cashPayMode = sys.getOne(""+this.comCode+".FNPAYMODES", "PMCODE", "ISCASH = 1");

        String amount_ = sys.getOneAgt(""+this.comCode+".VIEWHMPYDTLS", "SUM", "AMOUNT", "SM", "PYNO = '"+ this.pyNo+ "'");

        html += gui.formStart("frmPayment", "void%200", "post", "onSubmit=\"javascript:return false;\"");

        html += gui.formInput("hidden", "billNoHd", 30, ""+ this.pyNo, "", "");

        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";

        html += "<tr>";
        html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("bill", " Bill Total")+"</td>";
        html += "<td>"+ gui.formInput("text", "bill", 15, amount_, "", "disabled")+ "</td>";
        html += "</tr>";

        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("payMode", " Payment Mode")+"</td>";
        html += "<td>"+ gui.formSelect("payMode", ""+this.comCode+".FNPAYMODES", "PMCODE", "PMNAME", "", "", cashPayMode, "", false)+"</td>";
        html += "</tr>";

        html += "<tr>";
        html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("documentNo", " Document No.")+"</td>";
        html += "<td nowrap>"+gui.formInput("text", "documentNo", 15, "", "", "")+ "</td>";
        html += "</tr>";

        html += "<tr>";
        html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("tender", " Amount Tendered")+"</td>";
        html += "<td nowrap>"+gui.formInput("text", "tender", 15, "", "onkeyup = receipt.getChange();", "")+ "</td>";
        html += "</tr>";

        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins-delete.png", "", "")+ gui.formLabel("change", " Change")+"</td>";
        html += "<td>"+ gui.formInput("text", "change", 15, "", "", "disabled")+ "</td>";
        html += "</tr>";

        html += "<tr>";
        html += "<td colspan = \"2\">&nbsp;</td>";
        html += "</tr>";

        html += "<tr>";
        html += "<td>&nbsp;</td>";
        html += "<td>"+ gui.formButton(request.getContextPath(), "button", "btnSettle", "Settle", "tick.png", "onclick = \"receipt.savePayment('payMode tender');\"", "")+ "</td>";
        html += "</tr>";

        html += "</table>";

        html += gui.formEnd();

        return html;
    }
    
    public Object savePayment() throws Exception{
        JSONObject obj = new JSONObject();

        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            if(this.change >= 0){
                String query = "UPDATE "+this.comCode+".HMPYHDR SET "
                        + "BILL     = "+ this.bill+ ", "
                        + "PMCODE   = '"+ this.pmCode+ "', "
                        + "DOCNO    = '"+ this.docNo+ "', "
                        + "TENDER   = "+ this.tender+ ", "
                        + "CHANGE   = "+ this.change+ ", "
                        + "CLEARED  = 1 "
                        + "WHERE PYNO = '"+ this.pyNo+ "'";

                Integer saved = stmt.executeUpdate(query);
                if(saved == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully deleted.");

                    obj.put("qtyEff", this.effectItemQty(this.pyNo));
                    obj.put("billNo", this.pyNo);
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured while deleting record.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Invalid payment amount.");
            }
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }

        return obj;
    }
    
    public String effectItemQty(String pyNo){
        String html = "";

        IC iC = new IC(this.comCode);

        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+this.comCode+".HMPYDTLS WHERE PYNO = '"+ pyNo+"'";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){

                String itemCode = rs.getString("ITEMCODE");
                Double qty      = rs.getDouble("QTY");

                html += iC.effectItemQty(itemCode, qty, false, comCode);

            }
        }catch(Exception e){
            html += e.getMessage();
        }

        return html;
    }
    
}

%>