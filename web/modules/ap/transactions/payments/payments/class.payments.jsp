<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.ap.APInHdr"%>
<%@page import="bean.ap.AccountsPayable"%>
<%@page import="bean.ap.APSupplierGroup"%>
<%@page import="bean.ap.APSupplierProfile"%>
<%@page import="bean.ap.APPyBatch"%>
<%@page import="bean.finance.VAT"%>
<%@page import="bean.finance.FinConfig"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Payments{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    String table            = comCode+".APPYHDR";
    String view             = comCode+".VIEWAPPYHDR";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        
    String batchNo          = (request.getParameter("batchNo") != null && ! request.getParameter("batchNo").trim().equals(""))? request.getParameter("batchNo"): null;
    String pyNo             = request.getParameter("paymentNoHd") != null && ! request.getParameter("paymentNoHd").trim().equals("")? request.getParameter("paymentNoHd"): null;
    String pyDesc           = request.getParameter("paymentDesc");
    String supplierNo       = request.getParameter("supplierNo");
    String entryDate        = request.getParameter("entryDate");
    Integer pYear           = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth          = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
    String pmCode           = request.getParameter("payMode");
    String refNo            = request.getParameter("reference");
    String bkBranchCode     = request.getParameter("bankBranch");
    Double aplAmount        = (request.getParameter("appliedAmount") != null && ! request.getParameter("appliedAmount").trim().equals(""))? Double.parseDouble(request.getParameter("appliedAmount")): 0.0;
    
    Integer srcBatchNo      = (request.getParameter("srcBatch") != null && ! request.getParameter("srcBatch").trim().equals(""))? Integer.parseInt(request.getParameter("srcBatch")): null;
    String docNo            = request.getParameter("documentNo");
    
    Integer sid             = request.getParameter("sid") != null? Integer.parseInt(request.getParameter("sid")): null;
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
        AccountsPayable accountsPayable = new AccountsPayable(comCode);
        
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

                        list.add("BATCHNO");
                        list.add("BATCHDESC");
                        list.add("PYNO");
                        list.add("PYDESC");
                        list.add("SUPPLIERNO");
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

            String orderBy = "PYNO DESC ";
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

                html += "<table class = \"grid\" width=\"100%\" cellpadding=\"1\" cellspacing=\"0\" border=\"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Batch No</th>";
                html += "<th>Description</th>";
                html += "<th>Payment No</th>";
                html += "<th>Description</th>";
                html += "<th>Supplier No</th>";
                html += "<th>Name</th>";
                html += "<th>Amount</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id              = rs.getInt("ID");
                    Integer batchNo         = rs.getInt("BATCHNO");
                    String batchDesc        = rs.getString("BATCHDESC");
                    String pyNo             = rs.getString("PYNO");
                    String pyDesc           = rs.getString("PYDESC");
                    String supplierNo       = rs.getString("SUPPLIERNO");
//                    String fullName         = rs.getString("FULLNAME");
                    String supplierName     = rs.getString("SUPPLIERNAME");
                    
//                    String amount_ = sys.getOne("VIEWAPPYDTLS", "SUM(APLAMOUNT)", "BATCHNO = '"+ batchNo+ "' AND PYNO = '"+ pyNo+ "'");
//                    amount_ = (amount_ != null && ! amount_.trim().equals(""))? amount_: "0";
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ batchNo+ "</td>";
                    html += "<td>"+ batchDesc+ "</td>";
                    html += "<td>"+ pyNo+ "</td>";
                    html += "<td>"+ pyDesc+ "</td>";
                    html += "<td>"+ supplierNo+ "</td>";
//                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ supplierName+ "</td>";
                    html += "<td>"+ sys.numberFormat(accountsPayable.getPyAmount(pyNo).toString())+ "</td>";
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
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getPaymentTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"payments.save('batchNo paymentDesc entryDate pYear pMonth supplierNo payMode appliedAmount srcBatch documentNo'); return false;\"", "");
	if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print Cheque", "printer.png", "onclick = \"payments.print('batchNo paymentNo'); return false;\"", "");
        }
        html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Payment\'), 0, 625, 420, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getPaymentTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        String supplierName = "";
        String batchDesc    = "";
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.view+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.batchNo        = rs.getString("BATCHNO");		
                    batchDesc           = rs.getString("BATCHDESC");		
                    this.pyNo           = rs.getString("PYNO");
                    this.pyDesc         = rs.getString("PYDESC");
                    this.entryDate      = rs.getString("ENTRYDATE");
                    
                    java.util.Date entryDate = originalFormat.parse(this.entryDate);
                    this.entryDate = targetFormat.format(entryDate);
                    
                    this.pYear          = rs.getInt("PYEAR");		
                    this.pMonth         = rs.getInt("PMONTH");
                    this.supplierNo       = rs.getString("SUPPLIERNO");
                    supplierName            = rs.getString("SUPPLIERNAME");
                    
                    this.pmCode         = rs.getString("PMCODE");
                    this.refNo          = rs.getString("REFNO");
                    this.bkBranchCode   = rs.getString("BKBRANCHCODE");
                }
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        String defaultDate = sys.getLogDate();
        
        try{
            java.util.Date today = originalFormat.parse(defaultDate);
            defaultDate = targetFormat.format(today);
        }catch(ParseException e){
            html += e.getMessage();
        }catch (Exception e){
            html += e.getMessage();
        }
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+ this.id, "", "");
        }
        
        html += "<div id = \"dvPyEntrySid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+ this.sid, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("batchNo", " Batch No.")+ "</td>";
        html += "<td width = \"35%\">"+ gui.formAutoComplete("batchNo", 13, this.id != null? ""+ this.batchNo: "", "payments.searchBatch", "batchNoHd", this.id != null? ""+ this.batchNo: "")+ "</td>";
	
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Description</td>";
	html += "<td id = \"tdBatchDesc\">"+ batchDesc+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("paymentNo", " Payment No.")+"</td>";
	html += "<td>"+ gui.formInput("text", "paymentNo", 15, this.id != null? this.pyNo: "", "", "disabled")+ gui.formInput("hidden", "paymentNoHd", 15, this.id != null? this.pyNo: "", "", "")+ "</td>";
        
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "package.png", "", "")+ gui.formLabel("paymentDesc", " Description")+"</td>";
	html += "<td>"+ gui.formInput("text", "paymentDesc", 23, this.id != null? this.pyDesc: "", "", "")+"</td>";
	html += "</tr>";
              
        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", " Date")+"</td>";
        html += "<td colspan = \"3\">"+ gui.formDateTime(request.getContextPath(), "entryDate", 15, this.id != null? this.entryDate: defaultDate, false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
        html += "<td>"+ gui.formSelect("pYear", comCode+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+sys.getPeriodYear(comCode), "", false)+"</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: sys.getPeriodMonth(comCode), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("supplierNo", " Supplier No.")+ "</td>";
        html += "<td>"+ gui.formAutoComplete("supplierNo", 13, this.id != null? this.supplierNo: "", "payments.searchSupplier", "supplierNoHd", this.id != null? this.supplierNo: "")+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdFullName\">"+ supplierName+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("payMode", " Payment Mode")+"</td>";
	html += "<td>"+ gui.formSelect("payMode", comCode+".FNPAYMODES", "PMCODE", "PMNAME", "", "", this.id != null? this.pmCode: "", "", false)+"</td>";
        
        html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("reference", " Reference No.")+"</td>";
	html += "<td nowrap>"+gui.formInput("text", "reference", 15, this.id != null? this.refNo: "", "", "")+ "<span class = \"fade\">e.g. cheque no</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "building.png", "", "")+ gui.formLabel("bankBranch", " Bank")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("bankBranch", comCode+".VIEWFNCOBANKS", "BKBRANCHCODE", "BKBRANCHNAME", "", "", this.id != null? this.bkBranchCode: "", "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        String srcBatchUi;
        String documentNoUi;
        
        if(this.id != null){
            String batchFilter  = "BATCHNO IN (SELECT BATCHNO FROM "+comCode+".APINHDR WHERE SUPPLIERNO = '"+ this.supplierNo+ "' AND (APPLIED = 0 OR APPLIED IS NULL))";
            srcBatchUi   = gui.formSelect("srcBatch", comCode+".APINBATCHES", "BATCHNO", "BATCHDESC", "", batchFilter, this.id != null? this.srcBatchNo+ "": "", "onchange = \"payments.getInBatchDocs();\"", true);
            
            String batchDocsFilter = "BATCHNO = "+this.srcBatchNo+" AND SUPPLIERNO = '"+ this.supplierNo+ "' AND (APPLIED = 0 OR APPLIED IS NULL)";
            documentNoUi = gui.formSelect("documentNo", comCode+".APINHDR", "INNO", "INDESC", "", batchDocsFilter, this.id != null? this.docNo: "", "onchange = \"payments.getPyUnAplAmount();\"", true);
            
        }else{
            srcBatchUi = gui.formSelect("srcBatch", comCode+".APINBATCHES", "BATCHNO", "BATCHDESC", "", "", this.id != null? this.srcBatchNo+ "": "", "onchange = \"payments.getInBatchDocs();\"", true);
            documentNoUi = gui.formSelect("documentNo", comCode+".APINHDR", "INNO", "INDESC", "", "", this.id != null? this.docNo: "", "onchange = \"payments.getPyUnAplAmount();\" style=\"width: 150px;\"", true);
        }
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("srcBatch", " Source Batch")+"</td>";
	html += "<td id = \"tdSrcBatch\" colspan = \"3\">"+ srcBatchUi+ " <span class = \"fade\">i.e. for unapplied documents</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("documentNo", " Document No.")+"</td>";
	html += "<td id = \"tdDocumentNo\">"+ documentNoUi+ "</td>";
        
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("appliedAmount", " Applied Amount")+ "</td>";
	html += "<td>"+ gui.formInput("text", "appliedAmount", 15, "", "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvPyEntries\">"+ this.getPyEntries()+ "</div></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchBatch(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.batchNo = (request.getParameter("batchNoHd") != null && ! request.getParameter("batchNoHd").trim().equals(""))? request.getParameter("batchNoHd"): null;
        
        html += gui.getAutoColsSearch(comCode+".APPYBATCHES", "BATCHNO, BATCHDESC", "", this.batchNo+ "");
        
        return html;
    }
    
    public Object getBatchProfile(){
        JSONObject obj = new JSONObject();
        
        if(this.batchNo == null || this.batchNo.trim().equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            APPyBatch aPPyBatch = new APPyBatch(Integer.parseInt(this.batchNo), comCode);
            
            obj.put("batchDesc", aPPyBatch.batchDesc);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Batch No '"+ aPPyBatch.batchNo+ "' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String searchSupplier(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.supplierNo = request.getParameter("supplierNoHd");
        
//        html += gui.getAutoColsSearch("APSUPPLIERS", "SUPPLIERNO, FULLNAME", "", this.supplierNo);
        html += gui.getAutoColsSearch(comCode+".APSUPPLIERS", "SUPPLIERNO, SUPPLIERNAME", "", this.supplierNo);
        
        return html;
    }
    
    public Object getSupplierProfile(){
        JSONObject obj = new JSONObject();
        Gui gui = new Gui();
        
        if(this.supplierNo == null || this.supplierNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            APSupplierProfile aPSupplierProfile = new APSupplierProfile(this.supplierNo, comCode);
            APSupplierGroup aPSupplierGroup = new APSupplierGroup(aPSupplierProfile.supGrpCode, comCode);
            
//            obj.put("fullName", aPSupplierProfile.fullName);
            obj.put("fullName", aPSupplierProfile.supplierName);
            
            obj.put("bankBranch", aPSupplierGroup.bkBranchCode);
            obj.put("payMode", aPSupplierGroup.pmCode);
            
            String batchFilter = "BATCHNO IN (SELECT BATCHNO FROM "+comCode+".APINHDR WHERE SUPPLIERNO = '"+ this.supplierNo+ "' AND (APPLIED = 0 OR APPLIED IS NULL))";
            
            String srcBatchUi   = gui.formSelect("srcBatch", comCode+".APINBATCHES", "BATCHNO", "BATCHDESC", "", batchFilter, this.id != null? this.srcBatchNo+ "": "", "onchange = \"payments.getInBatchDocs();\"", true);
            
            obj.put("srcBatchUi", srcBatchUi);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Supplier No '"+ aPSupplierProfile.supplierNo+ "' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object getInBatchDocs(){
        JSONObject obj = new JSONObject();
        Gui gui = new Gui();
        
        if(this.srcBatchNo == null || this.srcBatchNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            String batchDocsFilter = "BATCHNO = "+this.srcBatchNo+" AND SUPPLIERNO = '"+ this.supplierNo+ "' AND (APPLIED = 0 OR APPLIED IS NULL)";
            
            String documentNoUi = gui.formSelect("documentNo", comCode+".APINHDR", "INNO", "INDESC", "", batchDocsFilter, this.id != null? this.docNo: "", "onchange = \"payments.getPyUnAplAmount();\" style=\"width: 150px;\"", true);
            
            obj.put("documentNoUi", documentNoUi);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Document for batch No '"+ this.srcBatchNo+ "' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object getPyUnAplAmount(){
        JSONObject obj = new JSONObject();
        AccountsPayable AccountsPayable = new AccountsPayable(comCode);
        
        Double unAplAmount = AccountsPayable.getPyUnAplAmount(this.docNo, this.pyNo);
        obj.put("appliedAmount", unAplAmount);

        obj.put("success", new Integer(1));
        obj.put("message", "Un applied appliedAmount of '"+ unAplAmount+ "' successfully retrieved.");
            
        
        return obj;
    }
    
    public Object save(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        this.pyNo = this.getPyNo();
        
        if(this.pyNo != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query ;
                Integer saved = 0;
                
                AccountsPayable AccountsPayable = new AccountsPayable(comCode);
                
                Double unAplAmount;
                Double netBal = 0.0;
                        
                Integer suc = 1;
                String msg  = "";
                
                if(this.sid == null){
                    Integer sid = sys.generateId(comCode+".APPYDTLS", "ID");
                    String lineNo = sys.getNextNo(comCode+".APPYDTLS", "LINENO", "PYNO = '"+ this.pyNo+ "' AND DOCNO = '"+ this.docNo+ "'", "", 1);
                    
                    unAplAmount = AccountsPayable.getPyUnAplAmount(this.docNo, this.pyNo);
                    netBal = unAplAmount - this.aplAmount;
                    
                    if(this.aplAmount == 0){
                        suc = 0;
                        msg = "Invalid Applied Amount";
                    }
                    
                    query = "INSERT INTO "+comCode+".APPYDTLS "
                            + "(ID, PYNO, LINENO, DOCNO, "
                            + "CURBAL, APLAMOUNT, NETBAL, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + sid + ", "
                            + "'"+ this.pyNo+ "', "
                            + "'"+ lineNo+ "', "
                            + "'"+ this.docNo+ "', "
                            + unAplAmount+ ", "
                            + this.aplAmount+ ", "
                            + netBal+ ", "
                            + "'"+ sys.getLogUser(session)+"', "
                            + "'"+ sys.getLogDate()+ "', "
                            + "'"+ sys.getLogTime()+ "', "
                            + "'"+ sys.getClientIpAdr(request)+ "'"
                            + ")";

                }else{
                    String sidAplAmountStr = sys.getOne(comCode+".APPYDTLS", "APLAMOUNT", "ID = "+ this.sid);
                    sidAplAmountStr = (sidAplAmountStr != null && ! sidAplAmountStr.trim().equals(""))? sidAplAmountStr: "0";
                    
                    Double sidAplAmount = Double.parseDouble(sidAplAmountStr);
                    
                    String sidNetBalStr = sys.getOne(comCode+".APPYDTLS", "NETBAL", "ID = "+ this.sid);
                    sidNetBalStr = (sidNetBalStr != null && ! sidNetBalStr.trim().equals(""))? sidNetBalStr: "0";
                    
                    Double sidNetBal = Double.parseDouble(sidNetBalStr);
                    
                    netBal = sidNetBal + sidAplAmount - this.aplAmount;
                    
                    unAplAmount = this.aplAmount + netBal;
                    
                    query = "UPDATE "+comCode+".APPYDTLS SET "
                            + "DOCNO        = '"+ this.docNo+ "', "
                            
                            + "CURBAL       = "+ unAplAmount+ ", "
                            + "APLAMOUNT    = "+ this.aplAmount+ ", "
                            + "NETBAL       = "+ netBal+ " "
                            
                            + "WHERE ID     = "+this.sid;
                }
                
                if(netBal < 0){
                    suc = 0;
                    msg = "Overpayment not allowed";
                }
                
                if(suc == 1){
                    saved = stmt.executeUpdate(query);
                    
                    if(saved == 1){
                        obj.put("success", new Integer(1));
                        obj.put("message", "Entry successfully made.");

                        obj.put("paymentNo", this.pyNo);
                        
                        if(netBal == 0){
                            stmt.executeUpdate("UPDATE "+comCode+".APINHDR SET APPLIED = 1 WHERE INNO = '"+ this.docNo+ "'");
                        }
                        
                    }else{
                        obj.put("success", new Integer(0));
                        obj.put("message", "Oops! An Un-expected error occured while saving record.");
                    }
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", msg);
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
        
        if(this.pyNo == null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id = sys.generateId(this.table, "ID");
                
                this.pyNo = sys.getNextNo(this.table, "ID", "", "APPY", 7);
                
                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                java.util.Date entryDate = originalFormat.parse(this.entryDate);
                this.entryDate = targetFormat.format(entryDate);

                AccountsPayable accountsPayable = new AccountsPayable(comCode);
                
                String query = "INSERT INTO "+ this.table+ " "
                        + "(ID, BATCHNO, PYNO, PYDESC, "
                        + "ENTRYDATE, PYEAR, PMONTH, "
                        + "SUPPLIERNO, "
                        + "PMCODE, REFNO, BKBRANCHCODE"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ this.batchNo+ "', "
                        + "'"+ this.pyNo+ "', "
                        + "'"+ this.pyDesc+ "', "
                        + "'"+ this.entryDate+ "', "
                        + this.pYear+", "
                        + this.pMonth+ ", "
                        + "'"+ this.supplierNo+ "', "
                        + "'"+ this.pmCode+ "', "
                        + "'"+ this.refNo+ "', "
                        + "'"+ this.bkBranchCode+ "' "
                        + ")";

                Integer pyHdrCreated = stmt.executeUpdate(query);
                
                if(pyHdrCreated == 1){
                    //has payment no already
                }else{
                    this.pyNo = null;
                }

            }catch(Exception e){
                e.getMessage();
            }
        }
        
        return this.pyNo;
    }
    
    public String getPyEntries(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(comCode+".VIEWAPPYDTLS", "PYNO = '"+ this.pyNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Document No</th>";
            html += "<th style = \"text-align: right;\">Original Amount</th>";
            html += "<th style = \"text-align: right;\">Current Balance</th>";
            html += "<th style = \"text-align: right;\">Applied Amount</th>";
            html += "<th style = \"text-align: right;\">Net Balance</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            Double sumAplAmount = 0.0;
            
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+comCode+".VIEWAPPYDTLS WHERE PYNO = '"+ this.pyNo+ "'";
                
                ResultSet rs = stmt.executeQuery(query);
                
                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String docNo        = rs.getString("DOCNO");
                    
                    Double curBal       = rs.getDouble("CURBAL");
                    Double aplAmount    = rs.getDouble("APLAMOUNT");
                    Double netBal       = rs.getDouble("NETBAL");
                    
                    AccountsPayable accountsPayable     = new AccountsPayable(comCode);
                    Double orgAmount = accountsPayable.getInOrgAmount(docNo);
                    
                    String editLink     = gui.formHref("onclick = \"payments.editPaymentDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"payments.purge("+ id +", '"+ docNo +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    String lockLink     = gui.formHref("onclick = \"alert('locked');\"", request.getContextPath(), "lock.png", "", "locked", "", "");
                    
                    String opts = "";
                    
                    APInHdr APInHdr = new APInHdr(docNo);
                    
                    if(APInHdr.applied){
                        opts = lockLink;
                    }else{
                        opts = editLink+ " || "+ removeLink;
                    }
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ docNo +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(orgAmount.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(curBal.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(aplAmount.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(netBal.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    sumAplAmount = sumAplAmount + aplAmount;
                    
                    count++;
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"4\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumAplAmount.toString()) +"</td>";
            html += "<td colspan = \"2\">&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No payment items record found.";
        }
        
        return html;
    }
    
    public Object editPaymentDtls(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists(comCode+".APPYDTLS", "ID = "+ this.sid+ "")){
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+comCode+".VIEWAPPYDTLS WHERE ID = "+ this.sid +"";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String srcBatchNo   = rs.getString("SRCBATCHNO");
                    String docNo        = rs.getString("DOCNO");
                    String aplAmount    = rs.getString("APLAMOUNT");
                    
                    obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                    obj.put("srcBatch", srcBatchNo);
                    obj.put("documentNo", docNo);
                    obj.put("appliedAmount", aplAmount);
                    
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
    
    public Object purge(){
         
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+comCode+".APPYDTLS WHERE ID = "+this.id;
            
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
    
}

%>