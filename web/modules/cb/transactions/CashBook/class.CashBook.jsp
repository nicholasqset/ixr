<%@page import="com.qset.cb.CBBatch"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.gl.GLAccount"%>
<%@page import="com.qset.finance.VAT"%>
<%@page import="com.qset.finance.FinConfig"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class CashBook{
    String table            = "CBHDR";
    String view             = "VIEWCBHDR";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        
    String batchNo          = (request.getParameter("batchNo") != null && ! request.getParameter("batchNo").trim().equals(""))? request.getParameter("batchNo"): null;
    String entryNo          = request.getParameter("entryNoHd") != null && ! request.getParameter("entryNoHd").trim().equals("")? request.getParameter("entryNoHd"): null;
    String entryDesc        = request.getParameter("entryDesc");
    String entryDate        = request.getParameter("entryDate");
    Integer pYear           = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth          = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
    
    String refNo            = request.getParameter("reference");
    String refDesc          = request.getParameter("referenceDesc");
    String docType          = request.getParameter("documentType");
    String accountCode      = request.getParameter("glAccount");
    String normalBal        = request.getParameter("normalBal");
    Double amount           = (request.getParameter("amount") != null && ! request.getParameter("amount").trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;
    
    Integer sid             = request.getParameter("sid") != null? Integer.parseInt(request.getParameter("sid")): null;
    
    String batchDesc        = "";
    String bank             = "";
    
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

                        list.add("BATCHNO");
                        list.add("BATCHDESC");
                        list.add("ENTRYNO");
                        list.add("ENTRYDESC");
                        list.add("ENTRYDATE");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                if(dbType.equals("postgres")){
                                    filterSql += " WHERE ( UPPER(CAST ("+ list.get(i) +" AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
                                }else{
                                    filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
                                }
                            }else{
                                if(dbType.equals("postgres")){
                                    filterSql += " OR ( UPPER(CAST("+list.get(i)+" AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
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

            String orderBy = "BATCHNO DESC, ENTRYNO ";
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
                html += "<th>Batch No</th>";
                html += "<th>Description</th>";
                html += "<th>Entry No</th>";
                html += "<th>Description</th>";
//                html += "<th>Reference</th>";
                html += "<th>Dr Amount</th>";
                html += "<th>Cr Amount</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id              = rs.getInt("ID");
                    Integer batchNo         = rs.getInt("BATCHNO");
                    String batchDesc        = rs.getString("BATCHDESC");
                    Integer entryNo         = rs.getInt("ENTRYNO");
                    String entryDesc        = rs.getString("ENTRYDESC");
//                    String refNo            = rs.getString("REFNO");
                    
                    String drAmount_ = sys.getOneAgt("VIEWCBDTLS", "SUM", "DRAMOUNT", "SM", "BATCHNO = '"+ batchNo+ "' AND ENTRYNO = '"+ entryNo+ "'");
                    drAmount_ = drAmount_ != null? drAmount_: "0";
                    String crAmount_ = sys.getOneAgt("VIEWCBDTLS", "SUM", "CRAMOUNT", "SM", "BATCHNO = '"+ batchNo+ "' AND ENTRYNO = '"+ entryNo+ "'");
                    crAmount_ = crAmount_ != null? crAmount_: "0";
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ batchNo+ "</td>";
                    html += "<td>"+ batchDesc+ "</td>";
                    html += "<td>"+ entryNo+ "</td>";
                    html += "<td>"+ entryDesc+ "</td>";
//                    html += "<td>"+ refNo+ "</td>";
                    html += "<td>"+ sys.numberFormat(drAmount_)+ "</td>";
                    html += "<td>"+ sys.numberFormat(crAmount_)+ "</td>";
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
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        Boolean rtp = false;
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.view+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.batchNo            = rs.getString("BATCHNO");		
                    this.batchDesc          = rs.getString("BATCHDESC");		
                    String bKBranchCode     = rs.getString("BKBRANCHCODE");		
                    String bKBranchName     = rs.getString("BKBRANCHNAME");		
                    this.bank               = bKBranchCode+ " - "+ bKBranchName;		
                    rtp                     = rs.getBoolean("RTP");		
                    this.entryNo            = rs.getString("ENTRYNO");
                    this.entryDesc          = rs.getString("ENTRYDESC");
                    this.entryDate          = rs.getString("ENTRYDATE");
                    
                    java.util.Date entryDate = originalFormat.parse(this.entryDate);
                    this.entryDate = targetFormat.format(entryDate);
                    
                    this.pYear              = rs.getInt("PYEAR");		
                    this.pMonth             = rs.getInt("PMONTH");
                }
            }catch(SQLException e){
                html += e.getMessage();
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getJETab()+ "</div>";
        
        html += "</div>";
        
	html += "<div id = \"dvBtns\" style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
        if(!rtp){
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"cb.save('batchNo entryDesc entryDate pYear pMonth reference referenceDesc documentType glAccount normalBal amount'); return false;\"", "");
        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Cash Book\'), 0, 625, 420, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getJETab(){
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
        
        HashMap<String, String> docTypes = new HashMap();
        docTypes.put("AD", "Adjustments");
        docTypes.put("BC", "Bank Charges");
        docTypes.put("CK", "Cheques");
        docTypes.put("CS", "Cash");
        docTypes.put("DP", "Deposits");
        docTypes.put("GE", "General Entries");
        docTypes.put("SD", "Sundry Debits");
        docTypes.put("SP", "Sundry Purchases");
        docTypes.put("VD", "Void Cheques");
        
        HashMap<String, String> normalBal = new HashMap();
        normalBal.put("DR", "Debit");
        normalBal.put("CR", "Credit");
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+ this.id, "", "");
        }
        
        html += "<div id = \"dvCBEntrySid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+ this.sid, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("batchNo", " Batch No.")+ "</td>";
        html += "<td width = \"35%\">"+ gui.formAutoComplete("batchNo", 13, this.id != null? ""+ this.batchNo: "", "cb.searchBatch", "batchNoHd", this.id != null? ""+ this.batchNo: "")+ "</td>";
	
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Description</td>";
	html += "<td id = \"tdBatchDesc\">"+ batchDesc+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "building.png", "", "")+ " Bank</td>";
	html += "<td id = \"tdBatchSource\" colspan = \"3\">"+ bank+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("entryNo", " Entry No.")+"</td>";
	html += "<td>"+ gui.formInput("text", "entryNo", 15, this.id != null? this.entryNo: "", "", "disabled")+ gui.formInput("hidden", "entryNoHd", 15, this.id != null? this.entryNo: "", "", "")+ "</td>";
        
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "package.png", "", "")+ gui.formLabel("entryDesc", " Description")+"</td>";
	html += "<td>"+ gui.formInput("text", "entryDesc", 25, this.id != null? this.entryDesc: "", "", "")+"</td>";
	html += "</tr>";
              
        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", " Date")+"</td>";
        html += "<td colspan = \"3\">"+ gui.formDateTime(request.getContextPath(), "entryDate", 15, this.id != null? this.entryDate: defaultDate, false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
        html += "<td>"+ gui.formSelect("pYear", "FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+sys.getPeriodYear(), "", false)+"</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: sys.getPeriodMonth(), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("reference", " Reference No.")+ "</td>";
	html += "<td >"+ gui.formInput("text", "reference", 15, "", "", "")+ "</td>";
        
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("documentType", " Document Type")+ "</td>";
	html += "<td>"+ gui.formArraySelect("documentType", 150, docTypes, "", false, "", true)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "package.png", "", "")+ gui.formLabel("referenceDesc", " Description")+ "</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "referenceDesc", 25, "", "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("glAccount", " Account")+ "</td>";
        html += "<td>"+ gui.formAutoComplete("glAccount", 13, "", "cb.searchGLAccount", "glAccountHd", "")+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdAccountName\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("normalBal", " Balance Type")+"</td>";
	html += "<td>"+ gui.formArraySelect("normalBal", 100, normalBal, "", false, "", true)+"</td>";
	
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("amount", " Amount")+ "</td>";
	html += "<td>"+ gui.formInput("text", "amount", 15, "", "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvJeEntries\">"+ this.getCbEntries()+ "</div></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchBatch(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.batchNo = (request.getParameter("batchNoHd") != null && ! request.getParameter("batchNoHd").trim().equals(""))? request.getParameter("batchNoHd"): null;
        
        html += gui.getAutoColsSearch("CBBATCHES", "BATCHNO, BATCHDESC", "", this.batchNo+ "");
        
        return html;
    }
    
    public Object getBatchProfile(){
        JSONObject obj = new JSONObject();
        Gui gui = new Gui();
        
        if(this.batchNo == null || this.batchNo.trim().equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            CBBatch cBBatch = new CBBatch(Integer.parseInt(this.batchNo));
            
            obj.put("batchDesc", cBBatch.batchDesc);
            obj.put("batchBank", cBBatch.bkBranchCode+ " - "+ cBBatch.bkBranchName);
            
            String btns = "";
            
            if(cBBatch.rtp){
                btns += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
            }else{
                btns += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"cb.save('batchNo entryDesc entryDate pYear pMonth reference glAccount normalBal amount'); return false;\"", "");
                btns += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
            }
            
            obj.put("btns", btns);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Batch No '"+ cBBatch.batchNo+ "' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String searchGLAccount(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.accountCode = request.getParameter("glAccountHd");
        
        html += gui.getAutoColsSearch("GLACCOUNTS", "ACCOUNTCODE, ACCOUNTNAME", "", this.accountCode);
        
        return html;
    }
    
    public Object getGLAccount(){
        JSONObject obj = new JSONObject();
        
        if(this.accountCode == null || this.accountCode.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            GLAccount gLAccount = new GLAccount(this.accountCode);
            
            obj.put("accountName", gLAccount.accountName);
            obj.put("normalBal", gLAccount.normalBal);
            
            obj.put("success", new Integer(1));
            obj.put("message", "GL Account '"+ gLAccount.accountCode+ "' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object save(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        this.entryNo = this.getEntryNo();
        
        if(this.entryNo != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query ;
                Integer saved = 0;
                
                Double crAmount = 0.0;
                Double drAmount = 0.0;
                
                if(this.normalBal.equals("DR")){
                    drAmount = this.amount;
                }else if(this.normalBal.equals("CR")){
                    crAmount = this.amount;
                }
                
                Integer suc = 1;
                String msg  = "";
                
                if(this.sid == null){
                    Integer sid = sys.generateId("CBDTLS", "ID");
                    
                    if(this.amount == 0){
                        suc = 0;
                        msg = "Invalid Amount";
                    }
                    
                    query = "INSERT INTO CBDTLS "
                            + "("
                            + "ID, BATCHNO, ENTRYNO, "
                            + "REFNO, REFDESC, DOCTYPE, ACCOUNTCODE, "
                            + "NORMALBAL, DRAMOUNT, CRAMOUNT, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + sid + ", "
                            + this.batchNo+ ", "
                            + this.entryNo+ ", "
                            + "'"+ this.refNo+ "', "
                            + "'"+ this.refDesc+ "', "
                            + "'"+ this.docType+ "', "
                            + "'"+ this.accountCode+ "', "
                            + "'"+ this.normalBal+ "', "
                            + drAmount + ", "
                            + crAmount + ", "
                            + "'"+ sys.getLogUser(session)+ "', "
                            + "'"+ sys.getLogDate()+ "', "
                            + sys.getLogTime()+ ", "
                            + "'"+ sys.getClientIpAdr(request)+ "'"
                            + ")";

                }else{
                    
                    query = "UPDATE CBDTLS SET "
                            + "REFNO        = '"+ this.refNo+ "', "
                            + "REFDESC      = '"+ this.refDesc+ "', "
                            + "DOCTYPE      = '"+ this.docType+ "', "
                            + "ACCOUNTCODE  = '"+ this.accountCode+ "', "
                            + "NORMALBAL    = '"+ this.normalBal+ "', "
                            + "DRAMOUNT     = "+ drAmount+ ", "
                            + "CRAMOUNT     = "+ crAmount+ ", "
                            + "AUDITUSER    = '"+ sys.getLogUser(session)+ "', "
                            + "AUDITDATE    = '"+ sys.getLogDate()+ "', "
                            + "AUDITTIME    = "+ sys.getLogTime()+ ", "
                            + "AUDITIPADR   = '"+ sys.getClientIpAdr(request)+ "' "
                            
                            + "WHERE ID     = "+ this.sid;
                }
                
                if(suc == 1){
                    saved = stmt.executeUpdate(query);
                    
                    if(saved == 1){
                        obj.put("success", new Integer(1));
                        obj.put("message", "Entry successfully made.");

                        obj.put("entryNo", this.entryNo);
                        
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
    
    public String getEntryNo(){
        HttpSession session = request.getSession();
        Sys sys = new Sys();
        
        if(this.entryNo == null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id = sys.generateId(this.table, "ID");
                
                this.entryNo = sys.getNextNo(this.table, "ID", "", "", 1);
                
                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                java.util.Date entryDate = originalFormat.parse(this.entryDate);
                this.entryDate = targetFormat.format(entryDate);

                String query = "INSERT INTO "+ this.table+ " "
                        + "("
                        + "ID, BATCHNO, ENTRYNO, ENTRYDESC, "
                        + "ENTRYDATE, PYEAR, PMONTH, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ this.batchNo+ "', "
                        + "'"+ this.entryNo+ "', "
                        + "'"+ this.entryDesc+ "', "
                        + "'"+ this.entryDate+ "', "
                        + this.pYear+", "
                        + this.pMonth+ ", "
                        + "'"+ sys.getLogUser(session)+"', "
                        + "'"+ sys.getLogDate()+ "', "
                        + "'"+ sys.getLogTime()+ "', "
                        + "'"+ sys.getClientIpAdr(request)+ "'"
                        + ")";

                Integer entryHdrCreated = stmt.executeUpdate(query);
                
                if(entryHdrCreated == 1){
                    //has je entry no already
                }else{
                    this.entryNo = null;
                }

            }catch(SQLException e){
                e.getMessage();
            }catch(Exception e){
                e.getMessage();
            }
        }
        
        return this.entryNo;
    }
    
    public String getCbEntries(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists("VIEWCBDTLS", "BATCHNO = '"+ this.batchNo+ "' AND ENTRYNO = '"+ this.entryNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Reference</th>";
            html += "<th>Account</th>";
            html += "<th>Document Type</th>";
            html += "<th style = \"text-align: right;\">Debit</th>";
            html += "<th style = \"text-align: right;\">Credit</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            Double sumDrAmount = 0.0;
            Double sumCrAmount = 0.0;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                CBBatch cBBatch = new CBBatch(Integer.parseInt(this.batchNo));
                
                String query = "SELECT * FROM VIEWCBDTLS WHERE BATCHNO = '"+ this.batchNo+ "' AND ENTRYNO = '"+ this.entryNo+ "' ORDER BY REFNO";
                ResultSet rs = stmt.executeQuery(query);
                
                Integer count  = 1;
                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String refNo        = rs.getString("REFNO");
                    String refDesc      = rs.getString("REFDESC");
                    String accountCode  = rs.getString("ACCOUNTCODE");
                    String accountName  = rs.getString("ACCOUNTNAME");
                    String docType      = rs.getString("DOCTYPE");
                    
                    Double drAmount       = rs.getDouble("DRAMOUNT");
                    Double crAmount       = rs.getDouble("CRAMOUNT");
                    
                    String editLink     = gui.formHref("onclick = \"cb.editCbDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"cb.purge("+ id +", '"+ refDesc +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    String lockLink     = gui.formHref("onclick = \"alert('locked');\"", request.getContextPath(), "lock.png", "", "locked", "", "");
                    
                    String opts = "";
                    if(cBBatch.rtp){
                        opts = lockLink;
                    }else{
                        opts = editLink+ " || "+ removeLink;opts = editLink+ " || "+ removeLink;
                    }
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ refNo +" - "+ refDesc+ "</td>";
                    html += "<td>"+ accountCode +" - "+ accountName+ "</td>";
                    html += "<td>"+ docType +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(drAmount.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(crAmount.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    sumDrAmount = sumDrAmount + drAmount;
                    sumCrAmount = sumCrAmount + crAmount;
                    
                    count++;
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"4\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumDrAmount.toString()) +"</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumCrAmount.toString()) +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No cash book entry records found.";
        }
        
        return html;
    }
    
    public Object editCbDtls(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists("CBDTLS", "ID = "+ this.sid+ "")){
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM VIEWCBDTLS WHERE ID = "+ this.sid +"";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String refNo        = rs.getString("REFNO");
                    String refDesc      = rs.getString("REFDESC");
                    String docType      = rs.getString("DOCTYPE");
                    String accountCode  = rs.getString("ACCOUNTCODE");
                    String accountName  = rs.getString("ACCOUNTNAME");
                    String normalBal    = rs.getString("NORMALBAL");
                    
                    Double drAmount     = rs.getDouble("DRAMOUNT");
                    Double crAmount     = rs.getDouble("CRAMOUNT");
                    
                    Double amount = 0.0;
                    
                    if(normalBal.equals("DR")){
                        amount = drAmount;
                    }else if(normalBal.equals("CR")){
                        amount = crAmount;
                    }
                    
                    obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                    obj.put("reference", refNo);
                    obj.put("referenceDesc", refDesc);
                    obj.put("documentType", docType);
                    obj.put("glAccount", accountCode);
                    obj.put("accountName", accountName);
                    obj.put("normalBal", normalBal);
                    obj.put("amount", amount);
                    
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
    
    public Object purge(){
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM CBDTLS WHERE ID = "+this.id;
            
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