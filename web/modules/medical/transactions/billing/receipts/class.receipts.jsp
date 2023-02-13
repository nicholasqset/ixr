<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.medical.Medical"%>
<%@page import="bean.medical.MedicalReceipt"%>
<%@page import="bean.medical.MedInvHeader"%>
<%@page import="bean.finance.FinConfig"%>
<%@page import="bean.medical.HMStaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.medical.PatientProfile"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Receipts{
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
    String table        = comCode+".HMRCPTS";
    String view         = comCode+".VIEWHMREGISTRATION";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String regNo        = request.getParameter("regNo");
    
    String regType      = "";
    String ptNo         = "";
    String drNo         = "";
    String nrNo         = "";
    
    String invNo        = request.getParameter("invNo");
    String receiptNo    = request.getParameter("receiptNo");
    String pmCode       = request.getParameter("payMode");
    String docNo        = request.getParameter("docNo");
    Double amount       = request.getParameter("amount") != null? Double.parseDouble(request.getParameter("amount")): 0.00;
    
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
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String regNo        = rs.getString("REGNO");
                    String regType      = rs.getString("REGTYPE");
                    String ptNo         = rs.getString("PTNO");
                    String fullName     = rs.getString("FULLNAME");

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
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getRegistrationTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divReceipts\">"+this.getReceiptTab()+"</div></div>";
        
        html += "</div>";
        
	html += "<div style = \"padding-left: 10px; padding-top: 40px; border: 0;\" >";
        
//        html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"receipt.save('invNo payMode amount');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"module.getGrid();\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Registration\', \'Receipt\'), 0, 625, 350, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getRegistrationTab(){
        String html = "";
        Gui gui = new Gui();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;
        
        String drNo = "";
        String drName = "";
        String nrNo = "";
        String nrName = "";
//        String invType = "";
        
        try{
            stmt = conn.createStatement();
            String query = "SELECT * FROM "+this.view+" WHERE ID = "+ this.id;
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.regNo      = rs.getString("REGNO");		
                this.regType    = rs.getString("REGTYPE");		
                this.ptNo       = rs.getString("PTNO");		
                drNo            = rs.getString("DRNO");		
                drName          = rs.getString("DRNAME");		
                nrNo            = rs.getString("NRNO");		
                nrName          = rs.getString("NRNAME");
            }
        }catch (Exception e){
            html += e.getMessage();
        }
        
        html += gui.formInput("hidden", "id", 15, ""+this.id, "", "");
          
        PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);
        
        String regTypeLbl = "Unknown";
                    
        if(this.regType.equals("N")){
            regTypeLbl = "New Patient";
        }else if(this.regType.equals("R")){
            regTypeLbl = "Return Patient";
        }
        
//        String invTypeLbl = "Unknown";
//                    
//        if(invType.equals("R")){
//            invTypeLbl = "Registration";
//        }else if(invType.equals("A")){
//            invTypeLbl = "Any other Invoice";
//        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td class = \"bold\" width = \"22%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" Registration No.</td>";
        html += "<td>"+this.regNo + gui.formInput("hidden", "regNo", 15, this.regNo, "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" Registration Type</td>";
	html += "<td>"+regTypeLbl +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"patient-male.png", "", "")+" Patient</td>";
	html += "<td nowrap>"+this.ptNo + " - " + patientProfile.fullName +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"gender.png", "", "")+" Gender</td>";
	html += "<td>"+patientProfile.genderName+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "")+" Date of Birth</td>";
	html += "<td>"+patientProfile.dob+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"mobile-phone.png", "", "")+" Cellphone</td>";
	html += "<td>"+patientProfile.cellphone+"</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"doctor-male.png", "", "")+" Doctor</td>";
	html += "<td nowrap>"+drNo + " - " + drName +"</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"doctor-female.png", "", "")+" Nurse</td>";
	html += "<td nowrap>"+nrNo + " - " + nrName +"</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    
    
    public String getReceiptTab(){
        String html = "";
        
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        if(sys.recordExists("VIEWHMINVSDETAILS", "REGNO = '"+this.regNo+"'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Invoice No</th>";
            html += "<th>Receipt No</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            Double total   = 0.00;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT REGNO, INVNO, SUM(AMOUNT) AMOUNT FROM VIEWHMINVSDETAILS WHERE REGNO = '"+this.regNo+"' GROUP BY REGNO, INVNO ORDER BY INVNO DESC ";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String invNo        = rs.getString("INVNO");
                    Double amount       = rs.getDouble("AMOUNT");
                    
                    String rcptNo       = sys.getOne("HMRCPTS", "RCPTNO", "INVNO = '"+ invNo +"'");
                    
                    String rcptNoLbl    = rcptNo != null? rcptNo: "unpaid";
                    
                    String viewLink     = gui.formHref("onclick = \"receipt.getInvDtls('"+ this.regNo +"', '"+ invNo +"');\"", request.getContextPath(), "", "view", "view", "", "");
                    String editLink     = gui.formHref("onclick = \"receipt.editReceipt('"+ this.regNo +"', '"+ invNo +"', "+ amount +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String printLink    = gui.formHref("onclick = \"receipt.printReceipt('"+ rcptNo +"');\"", request.getContextPath(), "", "print", "print", "", "");
                    
                    String opts;
                    if(rcptNo != null){
                        opts = viewLink +" || "+editLink +" || "+ printLink;
                    }else{
                        opts = viewLink +" || "+ editLink;
                    }
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ invNo +"</td>";
                    html += "<td>"+ rcptNoLbl +"</td>";
                    html += "<td style = \"text-align: right;\">"+ amount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    total = total + amount;

                    count++;
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"3\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+total+"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No invoice items record found.";
        }
       
        return html;
    }
    
    public String getInvDtls(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists("VIEWHMINVSDETAILS", "INVNO = '"+ this.invNo +"'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Item</th>";
            html += "<th>Quantity</th>";
            html += "<th style = \"text-align: right;\">VAT</th>";
            html += "<th style = \"text-align: right;\">Net</th>";
            html += "<th style = \"text-align: right;\">Gross</th>";
            html += "</tr>";
            
            Double total   = 0.00;
            
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM VIEWHMINVSDETAILS WHERE INVNO = '"+ invNo +"'";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String qty          = rs.getString("QTY");
                    String itemName     = rs.getString("ITEMNAME");
                    Double vatAmount    = rs.getDouble("VATAMOUNT");
                    Double netAmount    = rs.getDouble("NETAMOUNT");
                    Double amount       = rs.getDouble("AMOUNT");
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ itemName +"</td>";
                    html += "<td>"+ qty +"</td>";
                    html += "<td style = \"text-align: right;\">"+ vatAmount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ netAmount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ amount +"</td>";
                    html += "</tr>";
                    
                    total = total + amount;

                    count++;
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"5\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ total +"</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No invoice items record found.";
        }
        
        html += "<br>";
        html += gui.formButton(request.getContextPath(), "button", "btnCancelRcp", "Back", "arrow-left.png", "onclick = \"receipt.getReceipts('"+this.regNo+"');\"", "");
        
        return html;
    }
    
    public String editReceipt(){
        String html = "";
        
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        if(sys.recordExists(this.table, "INVNO = '"+this.invNo+"'")){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE INVNO = '"+this.invNo+"'";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.invNo      = rs.getString("INVNO");	
                    this.receiptNo  = rs.getString("RCPTNO");	
                    this.pmCode     = rs.getString("PMCODE");
                    this.docNo      = rs.getString("DOCNO");
                    this.amount     = rs.getDouble("AMOUNT");
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
        }else{
            this.receiptNo  = "";	
            this.pmCode     = "";
            this.docNo      = "";
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"22%\" class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+gui.formLabel("invNoDisb", " Invoice No.")+"</td>";
	html += "<td >"+ gui.formInput("text", "invNoDisb", 15, this.invNo, "", "disabled") + gui.formInput("hidden", "invNo", 15, this.invNo, "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+gui.formLabel("receiptNo", " Receipt No.")+"</td>";
	html += "<td >"+gui.formInput("text", "receiptNo", 15, this.receiptNo, "", "disabled")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+gui.formLabel("payMode", " Payment Mode")+"</td>";
	html += "<td >"+gui.formSelect("payMode", "FNPAYMODES", "PMCODE", "PMNAME", "", "", this.pmCode, "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+gui.formLabel("docNo", " Document No.")+"</td>";
	html += "<td >"+gui.formInput("text", "docNo", 15, this.docNo, "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"coins.png", "", "")+gui.formLabel("amountDisb", " Amount")+"</td>";
	html += "<td >"+ gui.formInput("text", "amountDisb", 15, ""+this.amount, "", "disabled") + gui.formInput("hidden", "amount", 15, ""+this.amount, "", "") +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"receipt.save('invNo payMode amount');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancelRcp", "Back", "arrow-left.png", "onclick = \"receipt.getReceipts('"+this.regNo+"');\"", "");
        html += "</td>";
	html += "</tr>";
   
        html += "</table>";
        
        html += "</table>";
        
        return html;
    }
    
    public JSONObject save() throws Exception{
        
        HttpSession session = request.getSession();
        
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        try{
            if(! sys.recordExists(this.table, "INVNO = '"+ this.invNo +"'")){
                if(this.getStockAvailability(this.invNo).trim().equals("")){
                    Connection conn = ConnectionProvider.getConnection();
                    Statement  stmt = conn.createStatement();

                    Integer id          = sys.generateId(this.table, "ID");
                    String receiptNo    = sys.getNextNo(this.table, "ID", "", "RCP", 7);

                    String query;

                    query = "INSERT INTO "+this.table+" "
                        + "(ID, INVNO, RCPTNO, RCPTDATE, PMCODE, DOCNO, AMOUNT, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id+", "
                        + "'"+ this.invNo +"', "
                        + "'"+ receiptNo +"', "
                        + "'"+ sys.getLogDate() +"', "
                        + "'"+ this.pmCode +"', "
                        + "'"+ this.docNo +"', "
                        + this.amount +", "
                        + "'"+ sys.getLogUser(session) +"', "
                        + "'"+ sys.getLogDate() +"', "
                        + "'"+ sys.getLogTime() +"', "
                        + "'"+ sys.getClientIpAdr(request) +"'"
                        + ")";

                    Integer saved = stmt.executeUpdate(query);

                    if(saved == 1){
                        obj.put("success", new Integer(1));
                        obj.put("message", "Entry successfully made.");

                        obj.put("receiptNo", receiptNo);
                        
                        this.validateStock(receiptNo);
                        
                        stmt.executeUpdate("UPDATE HMINVSHDR SET PAID = 1 WHERE INVNO = '"+this.invNo+"'");
                    }else{
                        obj.put("success", new Integer(0));
                        obj.put("message", "Oops! An Un-expected error occured while saving record.");
                    }
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", this.getStockAvailability(this.invNo));
                }
                
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Receipt entry already made.");
            }
            
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public String getStockAvailability(String invNo){
        String message = "";
        
        Sys sys = new Sys();
        
        MedInvHeader medInvHeader = new MedInvHeader(invNo);
        Integer count  = 1;
        if(medInvHeader.regNo != null){
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM VIEWPTMEDICATION WHERE REGNO = '"+ medInvHeader.regNo +"'";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Double qty          = rs.getDouble("QTY");
                    String itemCode     = rs.getString("DRUGCODE");
                    String itemName     = rs.getString("DRUGNAME");
                    
                    String balStr = sys.getOne("HMINVENTBAL", "BAL", "PYEAR = "+ sys.getPeriodYear(this.comCode)+" AND PMONTH = "+ sys.getPeriodMonth(this.comCode)+" AND ITEMCODE = '"+ itemCode +"'");
                    balStr = (balStr != null && ! balStr.trim().equals(""))? balStr: "0";
                    
                    Double qtyBal = Double.parseDouble(balStr);
                    
                    if(qty > qtyBal){
                        message += count +". Medication '"+ itemName+"' out of stock. Deficit = '"+ (qty - qtyBal) +"'.";
                        message += "<br>";
                    }
                    
                    count++;
                }
                
            }catch (Exception e){
                message += e.getMessage();
            }
            
        }
        
        return message;
    }
    
    public Integer validateStock(String rcptNo){
        Integer validateStock = null;
        
        HttpSession session = request.getSession();
        
        Medical medical = new Medical(this.comCode);
        
        MedicalReceipt medicalReceipt = new MedicalReceipt(rcptNo);
        MedInvHeader medInvHeader = new MedInvHeader(medicalReceipt.invNo);
        
        if(medInvHeader.regNo != null){
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM VIEWPTMEDICATION WHERE REGNO = '"+ medInvHeader.regNo +"'";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Double qty          = rs.getDouble("QTY");
                    String itemCode     = rs.getString("DRUGCODE");
                    
                    if(this.createItemDed(rcptNo, itemCode, qty) == 1){
                        medical.reduceItemBalance(itemCode, qty, session, request);
                    }
                    
                }
            }catch (Exception e){
                
            }
            
        }
        
        return validateStock;
    }
    
    public Integer createItemDed(String docNo, String itemCode, Double qty){
        Integer createItem = 0;
        HttpSession session = request.getSession();
        Sys sys = new Sys();
        
        Integer pYear   = sys.getPeriodYear(this.comCode);
        Integer pMonth  = sys.getPeriodMonth(this.comCode);
        
        if(! sys.recordExists("HMINVENTDED", "DOCNO = '"+ docNo +"' AND ITEMCODE = '"+ itemCode +"'")){
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt  = conn.createStatement();
                
                Integer id      = sys.generateId("HMINVENTDED", "ID");

                String query = "INSERT INTO HMINVENTDED "
                        + "(ID, DOCNO, PYEAR, PMONTH, ITEMCODE, QTY, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id +", "
                        + "'"+ docNo +"', "
                        + pYear+ ", "
                        + pMonth+ ", "
                        + "'"+ itemCode +"', "
                        + qty +", "
                        + "'"+ sys.getLogUser(session) +"', "
                        + "'"+ sys.getLogDate() +"', "
                        + "'"+ sys.getLogTime() +"', "
                        + "'"+ sys.getClientIpAdr(request) +"'"
                        + ")";

                createItem = stmt.executeUpdate(query);
            
            }catch(Exception e){

            }
        }
        
        return createItem;
    }
    
    public String getReceipts(){
        String html = "";
        html += this.getReceiptTab();
        return html;
    }
        
}

%>