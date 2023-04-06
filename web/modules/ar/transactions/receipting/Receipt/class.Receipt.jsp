<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.ar.ARInHdr"%>
<%@page import="com.qset.ar.AccountsReceivable"%>
<%@page import="com.qset.ar.ARPyBatch"%>
<%@page import="com.qset.ar.ARDistribution"%>
<%@page import="com.qset.finance.VAT"%>
<%@page import="com.qset.finance.FinConfig"%>
<%@page import="com.qset.ar.ARCustomerProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class Receipt{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    String table            = comCode+".ARPYHDR";
    String view             = comCode+".VIEWARPYHDR";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        
    String batchNo          = request.getParameter("batchNo");
    String pyNo             = request.getParameter("receiptNoHd") != null && ! request.getParameter("receiptNoHd").trim().equals("")? request.getParameter("receiptNoHd"): null;
    String pyDesc           = request.getParameter("receiptDesc");
    String customerNo       = request.getParameter("customerNo");
    String entryDate        = request.getParameter("entryDate");
    Integer pYear           = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth          = request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    String pmCode           = request.getParameter("payMode");
    String cqrNo            = request.getParameter("cqrNo");
    String bkBranchCode     = request.getParameter("bankBranch");
    Double amount           = (request.getParameter("amount") != null && ! request.getParameter("amount").trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;
    String docNo            = request.getParameter("documentNo");
    
    Integer sid             = request.getParameter("sid") != null? Integer.parseInt(request.getParameter("sid")): null;
    
    Integer srcBatchNo      = (request.getParameter("srcBatch") != null && ! request.getParameter("srcBatch").trim().equals(""))? Integer.parseInt(request.getParameter("srcBatch")): null;
    Double aplAmount        = (request.getParameter("appliedAmount") != null && ! request.getParameter("appliedAmount").trim().equals(""))? Double.parseDouble(request.getParameter("appliedAmount")): 0.0;
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
        AccountsReceivable accountsReceivable = new AccountsReceivable(comCode);
        
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
                        list.add("CUSTOMERNO");
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
                html += "<th>Receipt No</th>";
                html += "<th>Description</th>";
                html += "<th>Customer No</th>";
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
                    String customerNo       = rs.getString("CUSTOMERNO");
//                    String customerName         = rs.getString("FULLNAME");
                    String customerName     = rs.getString("CUSTOMERNAME");
//                    Double amount           = rs.getDouble("AMOUNT");
                    
//                    String aplAmount_ = sys.getOne("ARPYDTLS", "APLAMOUNT", "BATCHNO = "+ batchNo+ " AND PYNO = '"+ pyNo+ "'");
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ batchNo+ "</td>";
                    html += "<td>"+ batchDesc+ "</td>";
                    html += "<td>"+ pyNo+ "</td>";
                    html += "<td>"+ pyDesc+ "</td>";
                    html += "<td>"+ customerNo+ "</td>";
//                    html += "<td>"+ customerName+ "</td>";
                    html += "<td>"+ customerName+ "</td>";
                    html += "<td>"+ sys.numberFormat(accountsReceivable.getPyAmount(pyNo).toString())+ "</td>";
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
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript: return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getReceiptTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"receipt.save('batchNo receiptDesc pYear pMonth customerNo payMode item srcBatch documentNo appliedAmount'); return false;\"", "");
	if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"receipt.print('batchNo receiptNo'); return false;\"", "");
        }
        html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Receipt\'), 0, 700, 420, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getReceiptTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        String customerName     = "";
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
                    this.customerNo     = rs.getString("CUSTOMERNO");
                    customerName        = rs.getString("CUSTOMERNAME");
                    
                    this.pmCode         = rs.getString("PMCODE");
                    this.cqrNo          = rs.getString("CQRNO");
                    this.bkBranchCode   = rs.getString("BKBRANCHCODE");
                }
            }catch(SQLException e){
                html += e.getMessage();
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
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<div id = \"dvPyEntrySid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+this.sid, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("batchNo", " Batch No.")+ "</td>";
        html += "<td width = \"35%\">"+ gui.formAutoComplete("batchNo", 13, this.id != null? this.batchNo: "", "receipt.searchBatch", "batchNoHd", this.id != null? this.batchNo: "")+ "</td>";
	
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Description</td>";
	html += "<td id = \"tdBatchDesc\">"+ batchDesc+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("receiptNo", " Receipt No.")+"</td>";
	html += "<td>"+ gui.formInput("text", "receiptNo", 15, this.id != null? this.pyNo: "", "", "disabled")+ gui.formInput("hidden", "receiptNoHd", 15, this.id != null? this.pyNo: "", "", "")+ "</td>";
        
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"package.png", "", "")+ gui.formLabel("receiptDesc", " Description")+"</td>";
	html += "<td>"+ gui.formInput("text", "receiptDesc", 25, this.id != null? this.pyDesc: "", "", "")+"</td>";
	html += "</tr>";
              
        html += "<tr>";
        html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", " Date")+"</td>";
        html += "<td colspan = \"3\">"+gui.formDateTime(request.getContextPath(), "entryDate", 15, this.id != null? this.entryDate: defaultDate, false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
        html += "<td>"+ gui.formSelect("pYear", comCode+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+sys.getPeriodYear(comCode), "", false)+"</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: sys.getPeriodMonth(comCode), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("customerNo", " Customer No.")+ "</td>";
        html += "<td>"+ gui.formAutoComplete("customerNo", 13, this.id != null? this.customerNo: "", "receipt.searchCustomer", "customerNoHd", this.id != null? this.customerNo: "")+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdFullName\">"+ customerName+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("payMode", " Payment Mode")+"</td>";
	html += "<td>"+ gui.formSelect("payMode", comCode+".FNPAYMODES", "PMCODE", "PMNAME", "", "", this.id != null? this.pmCode: "", "", false)+"</td>";
        
        html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("cqrNo", " Document No.")+"</td>";
	html += "<td nowrap>"+gui.formInput("text", "cqrNo", 15, this.id != null? this.cqrNo: "", "", "")+ "<span class = \"fade\"> i.e. cheque no</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"building.png", "", "")+ gui.formLabel("bankBranch", " Bank")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("bankBranch", comCode+".VIEWFNCOBANKS", "BKBRANCHCODE", "BKBRANCHNAME", "", "", this.id != null? this.bkBranchCode: "", "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        String srcBatchUi;
        String documentNoUi;
        String batchDocsFilter = "";
        
        if(this.id != null){
            String batchFilter  = "BATCHNO IN (SELECT BATCHNO FROM "+comCode+".ARINHDR WHERE CUSTOMERNO = '"+ this.customerNo+ "' AND (APPLIED = 0 OR APPLIED IS NULL))";
            srcBatchUi   = gui.formSelect("srcBatch", comCode+".ARINBATCHES", "BATCHNO", "BATCHDESC", "", batchFilter, this.id != null? this.srcBatchNo+ "": "", "onchange = \"receipt.getInBatchDocs();\"", true);
            
//             batchDocsFilter = "BATCHNO = "+ this.srcBatchNo+" AND CUSTOMERNO = '"+ this.customerNo+ "' AND (APPLIED = 0 OR APPLIED IS NULL)";
            batchDocsFilter = batchFilter+" AND CUSTOMERNO = '"+ this.customerNo+ "' AND (APPLIED = 0 OR APPLIED IS NULL)";
            documentNoUi = gui.formSelect("documentNo", comCode+".ARINHDR", "INNO", "INDESC", "", batchDocsFilter, this.id != null? this.docNo: "", "onchange = \"receipt.getPyUnAplAmount();\" style = \"width: 178px;\"", true);
        }else{
            srcBatchUi = gui.formSelect("srcBatch", comCode+".ARINBATCHES", "BATCHNO", "BATCHDESC", "", "", this.id != null? this.srcBatchNo+ "": "", "onchange = \"receipt.getInBatchDocs();\"", true);
            documentNoUi = gui.formSelect("documentNo", comCode+".ARINHDR", "INNO", "INDESC", "", "", this.id != null? this.docNo: "", "onchange = \"receipt.getPyUnAplAmount();\" style = \"width: 178px;\"", true);
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
        
        this.batchNo = request.getParameter("batchNoHd");
        
        html += gui.getAutoColsSearch(comCode+".ARPYBATCHES", "BATCHNO, BATCHDESC", "", this.batchNo);
        
        return html;
    }
    
    public Object getBatchProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.batchNo == null || this.batchNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            ARPyBatch aRPyBatch = new ARPyBatch(this.batchNo, comCode);
            
            obj.put("batchDesc", aRPyBatch.batchDesc);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Batch No '"+ aRPyBatch.batchNo+ "' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String searchCustomer(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.customerNo = request.getParameter("customerNoHd");
        
//        html += gui.getAutoColsSearch("ARCUSTOMERS", "CUSTOMERNO, CUSTOMERNAME", "", this.customerNo);
        html += gui.getAutoColsSearch(comCode+".ARCUSTOMERS", "CUSTOMERNO, CUSTOMERNAME", "", this.customerNo);
        
        return html;
    }
    
    public Object getCustomerProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.customerNo == null || this.customerNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            ARCustomerProfile aRCustomerProfile = new ARCustomerProfile(this.customerNo, comCode);
            
//            obj.put("customerName", aRCustomerProfile.customerName);
//            obj.put("customerName", aRCustomerProfile.customerName);
            obj.put("fullName", aRCustomerProfile.customerName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Customer No '"+aRCustomerProfile.customerNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object getSrcBatch() throws Exception{
        JSONObject obj = new JSONObject();
        Gui gui = new Gui();
        
        String batchFilter  = "BATCHNO IN (SELECT BATCHNO FROM "+comCode+".ARINHDR WHERE CUSTOMERNO = '"+ this.customerNo+ "' AND (APPLIED = 0 OR APPLIED IS NULL))";
        String srcBatchUi   = gui.formSelect("srcBatch", comCode+".ARINBATCHES", "BATCHNO", "BATCHDESC", "", batchFilter, this.id != null? this.srcBatchNo+ "": "", "onchange = \"receipt.getInBatchDocs();\"", true);

        obj.put("srcBatchUi", srcBatchUi);

        obj.put("success", new Integer(1));
        obj.put("message", "Document for batch No '"+ this.srcBatchNo+ "' successfully retrieved.");
        
        return obj;
    }
    
    public Object getInBatchDocs() throws Exception{
        JSONObject obj = new JSONObject();
        Gui gui = new Gui();
        
        if(this.srcBatchNo == null || this.srcBatchNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            String batchDocsFilter = "BATCHNO = "+ this.srcBatchNo+" AND CUSTOMERNO = '"+ this.customerNo+ "' AND (APPLIED = 0 OR APPLIED IS NULL)";
            
            String documentNoUi = gui.formSelect("documentNo", comCode+".ARINHDR", "INNO", "INDESC", "", batchDocsFilter, this.id != null? this.docNo: "", "onchange = \"receipt.getPyUnAplAmount();\" style = \"width: 178px;\"", true);
            
            obj.put("documentNoUi", documentNoUi);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Document for batch No '"+ this.srcBatchNo+ "' successfully retrieved.");
        }
        
        return obj;
    }
    
    public Object getPyUnAplAmount() throws Exception{
        JSONObject obj = new JSONObject();
        AccountsReceivable accountsReceivable = new AccountsReceivable(comCode);
        
        Double unAplAmount = accountsReceivable.getPyUnAplAmount(this.docNo, this.pyNo);
        obj.put("appliedAmount", unAplAmount);

        obj.put("success", new Integer(1));
        obj.put("message", "Un applied appliedAmount of '"+ unAplAmount+ "' successfully retrieved.");
        
        return obj;
    }
    
    public Object save() throws Exception{
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
                
                AccountsReceivable accountsReceivable = new AccountsReceivable(comCode);
                
                Double unAplAmount;
                Double netBal = 0.0;
                        
                Integer suc = 1;
                String msg  = "";
                
                if(this.sid == null){
                    Integer sid = sys.generateId(comCode+".ARPYDTLS", "ID");
                    String lineNo = sys.getNextNo(comCode+".ARPYDTLS", "LINENO", "BATCHNO = "+ this.batchNo+ " AND PYNO = '"+ this.pyNo+ "' AND SRCBATCHNO = "+ this.srcBatchNo+ " AND DOCNO = '"+ this.docNo+ "'", "", 1);
                    
                    unAplAmount = accountsReceivable.getPyUnAplAmount(this.docNo, this.pyNo);
                    netBal = unAplAmount - this.aplAmount;
                    
                    if(this.aplAmount == 0){
                        suc = 0;
                        msg = "Invalid Applied Amount";
                    }
                    
                    query = "INSERT INTO "+comCode+".ARPYDTLS "
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
                    String sidAplAmountStr = sys.getOne(comCode+".ARPYDTLS", "APLAMOUNT", "ID = "+ this.sid);
                    sidAplAmountStr = (sidAplAmountStr != null && ! sidAplAmountStr.trim().equals(""))? sidAplAmountStr: "0";
                    
                    Double sidAplAmount = Double.parseDouble(sidAplAmountStr);
                    
                    String sidNetBalStr = sys.getOne(comCode+".ARPYDTLS", "NETBAL", "ID = "+ this.sid);
                    sidNetBalStr = (sidNetBalStr != null && ! sidNetBalStr.trim().equals(""))? sidNetBalStr: "0";
                    
                    Double sidNetBal = Double.parseDouble(sidNetBalStr);
                    
                    netBal = sidNetBal + sidAplAmount - this.aplAmount;
                    
                    unAplAmount = this.aplAmount + netBal;
                    
                    query = "UPDATE "+comCode+".ARPYDTLS SET "
                            + "SRCBATCHNO   = '"+ this.srcBatchNo+ "', "
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

                        obj.put("receiptNo", this.pyNo);
                        
                        if(netBal == 0){
                            stmt.executeUpdate("UPDATE "+comCode+".ARINHDR SET APPLIED = 1 WHERE BATCHNO = "+ this.srcBatchNo+ " AND INNO = '"+ this.docNo+ "'");
                        }
                        
                    }else{
                        obj.put("success", new Integer(0));
                        obj.put("message", "Oops! An Un-expected error occured while saving record.");
                    }
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", msg);
                }
            }catch (SQLException e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
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
        HttpSession session = request.getSession();
        Sys sys = new Sys();
        
        if(this.pyNo == null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id = sys.generateId(this.table, "ID");
                
                this.pyNo = sys.getNextNo(this.table, "ID", "", "ARPY", 7);
                
                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                java.util.Date entryDate = originalFormat.parse(this.entryDate);
                this.entryDate = targetFormat.format(entryDate);

                AccountsReceivable accountsReceivable = new AccountsReceivable(comCode);
                
                String query = "INSERT INTO "+ this.table+ " "
                        + "(ID, BATCHNO, PYNO, PYDESC, "
                        + "ENTRYDATE, PYEAR, PMONTH, "
                        + "CUSTOMERNO, "
                        + "PMCODE, CQRNO, BKBRANCHCODE, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
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
                        + "'"+ this.customerNo+ "', "
                        + "'"+ this.pmCode+ "', "
                        + "'"+ this.cqrNo+ "', "
                        + "'"+ this.bkBranchCode+ "', "
                        + "'"+ sys.getLogUser(session)+ "', "
                        + "'"+ sys.getLogDate()+ "', "
                        + "'"+ sys.getLogTime()+ "', "
                        + "'"+ sys.getClientIpAdr(request)+ "'"
                        + ")";

                Integer pyHdrCreated = stmt.executeUpdate(query);
                
                if(pyHdrCreated == 1){
                    //has payment no already
                }else{
                    this.pyNo = null;
                }

            }catch(SQLException e){
                e.getMessage();
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
        
        if(sys.recordExists(comCode+".VIEWARPYDTLS", "PYNO = '"+ this.pyNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";
            
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
                
                String query = "SELECT * FROM "+comCode+".VIEWARPYDTLS WHERE PYNO = '"+ this.pyNo+ "'";
                
                ResultSet rs = stmt.executeQuery(query);
                
                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String docNo        = rs.getString("DOCNO");
                    
                    Double curBal       = rs.getDouble("CURBAL");
                    Double aplAmount    = rs.getDouble("APLAMOUNT");
                    Double netBal       = rs.getDouble("NETBAL");
                    Boolean rtp         = rs.getBoolean("RTP");
                    
                    AccountsReceivable accountsReceivable     = new AccountsReceivable(comCode);
                    Double orgAmount = accountsReceivable.getInOrgAmount(docNo);
                    
                    String editLink     = gui.formHref("onclick = \"receipt.editReceiptDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"receipt.purge("+ id +", '"+ docNo +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    String lockLink     = gui.formHref("onclick = \"alert('locked');\"", request.getContextPath(), "lock.png", "", "locked", "", "");
                    
                    String opts = "";
                    
                    ARInHdr ARInHdr = new ARInHdr(docNo, comCode);
                    
                    if(ARInHdr.applied){
//                    if(rtp){
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
            }catch (SQLException e){
                html += e.getMessage();
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
            html += "No receipt items record found.";
        }
        
        return html;
    }
    
    public Object editReceiptDtls() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists("ARPYDTLS", "ID = "+ this.sid+ "")){
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM VIEWARPYDTLS WHERE ID = "+ this.sid +"";
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
            }catch (SQLException e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
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
                String query = "DELETE FROM ARPYDTLS WHERE ID = "+this.id;
            
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