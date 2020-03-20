<%@page import="java.util.HashMap"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.ic.ICItem"%>
<%@page import="bean.ar.AccountsReceivable"%>
<%@page import="bean.ar.ARInBatch"%>
<%@page import="bean.ar.ARDistribution"%>
<%@page import="bean.finance.VAT"%>
<%@page import="bean.finance.FinConfig"%>
<%@page import="bean.ar.ARCustomerProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Invoices{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    String table            = comCode+".ARINHDR";
    String view             = comCode+".VIEWARINHDR";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        
    String batchNo          = request.getParameter("batchNo");
    String inNo             = request.getParameter("invoiceNoHd") != null && ! request.getParameter("invoiceNoHd").trim().equals("")? request.getParameter("invoiceNoHd"): null;
    String invDesc          = request.getParameter("invoiceDesc");
    String customerNo       = request.getParameter("customerNo");
    String entryType        = request.getParameter("entryType");
    String entryDate        = request.getParameter("entryDate");
    Integer pYear           = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth          = request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    String poNo             = request.getParameter("poNo");
    String orderNo          = request.getParameter("orderNo");
    
    String itemCode         = request.getParameter("item");
    String dtbCode          = request.getParameter("distribution");
    Double qty              = (request.getParameter("quantity") != null && ! request.getParameter("quantity").trim().equals(""))? Double.parseDouble(request.getParameter("quantity")): 0.0;
    Double amount           = (request.getParameter("amount") != null && ! request.getParameter("amount").trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;
    Integer taxIncl         = request.getParameter("taxInclusive") != null? 1: null;
    
    Integer sid             = request.getParameter("sid") != null? Integer.parseInt(request.getParameter("sid")): null;
    
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
                        list.add("INNO");
                        list.add("INDESC");
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

            String orderBy = "INNO DESC ";
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
                html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                html += "<table class = \"grid\" width=\"100%\" cellpadding=\"1\" cellspacing=\"0\" border=\"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Batch No</th>";
                html += "<th>Description</th>";
                html += "<th>Invoice No</th>";
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
                    String inNo             = rs.getString("INNO");
                    String invDesc          = rs.getString("INDESC");
                    String customerNo       = rs.getString("CUSTOMERNO");
//                    String fullName         = rs.getString("FULLNAME");
                    String customerName     = rs.getString("CUSTOMERNAME");
                    
//                    String amountStr = sys.getOne("VIEWARINDTLS", "SUM(AMOUNT)", "BATCHNO = '"+ batchNo+ "' AND INNO = '"+ inNo+ "'");
//                    amountStr = (amountStr != null && ! amountStr.trim().equals(""))? amountStr: "0";
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit     = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");
//                    String print    = gui.formHref("onclick = \"module.printIn("+id+")\"", request.getContextPath(), "printer.png", "print", "print", "", "");
                    String print    = "";

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ batchNo+ "</td>";
                    html += "<td>"+ batchDesc+ "</td>";
                    html += "<td>"+ inNo+ "</td>";
                    html += "<td>"+ invDesc+ "</td>";
                    html += "<td>"+ customerNo+ "</td>";
//                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ customerName+ "</td>";
                    html += "<td>"+ sys.numberFormat(accountsReceivable.getInOrgAmount(inNo).toString())+ "</td>";
                    html += "<td>"+ edit+ " "+ print+ "</td>";
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
        
        Boolean rtp = false;
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.view+ " WHERE ID = "+ this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    rtp       = rs.getBoolean("RTP");
                }
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getInvoiceTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style = \"padding-left: 10px; padding-top: 37px; border: 0;\" >";
        if(! rtp){
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"invoices.save('batchNo invoiceDesc customerNo entryType pYear pMonth item amount'); return false;\"", "");
        }
        if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"invoices.print('batchNo invoiceNo'); return false;\"", "");
        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Invoice\'), 0, 625, 415, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getInvoiceTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        String customerName = "";
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
                    this.inNo           = rs.getString("INNO");
                    this.invDesc        = rs.getString("INDESC");
                    this.customerNo     = rs.getString("CUSTOMERNO");
                    customerName        = rs.getString("CUSTOMERNAME");
                    this.entryType      = rs.getString("ENTRYTYPE");
                    this.entryDate      = rs.getString("ENTRYDATE");
                    
                    java.util.Date entryDate = originalFormat.parse(this.entryDate);
                    this.entryDate = targetFormat.format(entryDate);
                    
                    this.pYear          = rs.getInt("PYEAR");		
                    this.pMonth         = rs.getInt("PMONTH");
                    
                    this.poNo           = rs.getString("PONO");
                    this.orderNo        = rs.getString("ORDERNO");
                }
            }catch(SQLException e){
                html += e.getMessage();
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        HashMap<String, String> entryTypes = new HashMap();
        entryTypes.put("I", "Item");
        entryTypes.put("S", "Summary");
        
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
        
        html += "<div id = \"divInEntrySid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+this.sid, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("batchNo", " Batch No.")+ "</td>";
        html += "<td width = \"35%\">"+ gui.formAutoComplete("batchNo", 13, this.id != null? this.batchNo: "", "invoices.searchBatch", "batchNoHd", this.id != null? this.batchNo: "")+ "</td>";
	
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Description</td>";
	html += "<td id = \"tdBatchDesc\">"+ batchDesc+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("invoiceNo", " Invoice No.")+"</td>";
	html += "<td>"+ gui.formInput("text", "invoiceNo", 15, this.id != null? this.inNo: "", "", "disabled")+ gui.formInput("hidden", "invoiceNoHd", 15, this.id != null? this.inNo: "", "", "")+ "</td>";
        
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"package.png", "", "")+ gui.formLabel("invoiceDesc", " Description")+"</td>";
	html += "<td>"+ gui.formInput("text", "invoiceDesc", 20, this.id != null? this.invDesc: "", "", "")+"</td>";
	html += "</tr>";
              
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("customerNo", " Customer No.")+ "</td>";
        html += "<td>"+ gui.formAutoComplete("customerNo", 13, this.id != null? this.customerNo: "", "invoices.searchCustomer", "customerNoHd", this.id != null? this.customerNo: "")+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdFullName\">"+ customerName+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("entryType", " Entry Type")+"</td>";
	html += "<td>"+ gui.formArraySelect("entryType", 100,  new HashMap(entryTypes), this.id != null? this.entryType: "I", false, "onchange = \"invoices.getEntryType();\"", false)+"</td>";
       
        html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", " Date")+"</td>";
        html += "<td>"+gui.formDateTime(request.getContextPath(), "entryDate", 15, this.id != null? this.entryDate: defaultDate, false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
        html += "<td>"+ gui.formSelect("pYear", comCode+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+sys.getPeriodYear(comCode), "", false)+"</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: sys.getPeriodMonth(comCode), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("poNo", " PO Number")+"</td>";
	html += "<td>"+gui.formInput("text", "poNo", 15, this.id != null? this.poNo: "", "", "")+"</td>";
        
        html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("orderNo", " Order No.")+"</td>";
	html += "<td>"+gui.formInput("text", "orderNo", 15, this.id != null? this.orderNo: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        String entryTypeLbl;
        String entryTypeSel;
        String quantityUi;
        String amountUi;
        
        if(this.id != null && this.entryType.equals("S")){
            entryTypeLbl    = gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("item", " Distribution");
            entryTypeSel    = gui.formSelect("item", comCode+".ARDTBS", "DTBCODE", "DTBNAME", "", "", "", "", false);
            quantityUi      = gui.formInput("text", "quantity", 15, "", "", "disabled");
            amountUi        = gui.formInput("text", "amount", 15, "", "", "") + gui.formCheckBox("taxInclusive", "checked", "", "", "", "")+ gui.formLabel("taxInclusive", " Tax Inclusive");
        }else{
            entryTypeLbl    = gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("item", " Item");
//            entryTypeSel    = gui.formSelect("item", "ARITEMS", "ITEMCODE", "ITEMNAME", "", "", "", "onchange = \"invoices.getItemAmount();\"", false);
            entryTypeSel    = gui.formSelect("item", comCode+".ICITEMS", "ITEMCODE", "ITEMNAME", "", "", "", "onchange = \"invoices.getItemAmount();\"", false);
            quantityUi      = gui.formInput("text", "quantity", 15, "", "onkeyup = \"invoices.getItemTotalAmount();\"", "");
            amountUi        = gui.formInput("text", "amount", 15, "", "", "")+ gui.formCheckBox("taxInclusive", "checked", "", "", "", "")+ gui.formLabel("taxInclusive", " Tax Inclusive");
        }
        
        html += "<tr>";
	html += "<td id = \"tdEntryTypeLbl\" nowrap>"+ entryTypeLbl+ "</td>";
	html += "<td id = \"tdEntryTypeSel\" colspan = \"3\">"+ entryTypeSel+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("quantity", " Quantity")+ "</td>";
	html += "<td id = \"tdQuantity\">"+ quantityUi+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("amount", " Amount")+ "</td>";
	html += "<td id = \"tdAmount\" nowrap>"+ amountUi+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvInEntries\">"+ this.getInEntries()+"</div></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchBatch(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.batchNo = request.getParameter("batchNoHd");
        
        html += gui.getAutoColsSearch(comCode+".ARINBATCHES", "BATCHNO, BATCHDESC", "", this.batchNo);
        
        return html;
    }
    
    public Object getBatchProfile(){
        JSONObject obj = new JSONObject();
        
        if(this.batchNo == null || this.batchNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            ARInBatch aRInBatch = new ARInBatch(this.batchNo, comCode);
            
            obj.put("batchDesc", aRInBatch.batchDesc);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Batch No '"+aRInBatch.batchNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String searchCustomer(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.customerNo = request.getParameter("customerNoHd");
        
//        html += gui.getAutoColsSearch("ARCUSTOMERS", "CUSTOMERNO, FULLNAME", "", this.customerNo);
        html += gui.getAutoColsSearch(comCode+".ARCUSTOMERS", "CUSTOMERNO, CUSTOMERNAME", "", this.customerNo);
        
        return html;
    }
    
    public Object getCustomerProfile(){
        JSONObject obj = new JSONObject();
        
        if(this.customerNo == null || this.customerNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            ARCustomerProfile aRCustomerProfile = new ARCustomerProfile(this.customerNo, comCode);
            
//            obj.put("fullName", aRCustomerProfile.fullName);
            obj.put("fullName", aRCustomerProfile.customerName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Customer No '"+aRCustomerProfile.customerNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object getEntryType(){
        JSONObject obj = new JSONObject();
        Gui gui = new Gui();
        
        String entryTypeLbl;
        String entryTypeSel;
        String quantityUi;
        String amountUi;
        
        if(this.entryType.equals("S")){
            entryTypeLbl    = gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("item", " Distribution");
            entryTypeSel    = gui.formSelect("item", comCode+".ARDTBS", "DTBCODE", "DTBNAME", "", "", "", "", false);
            quantityUi      = gui.formInput("text", "quantity", 15, "", "", "disabled");
            amountUi        = gui.formInput("text", "amount", 15, "", "", "") + gui.formCheckBox("taxInclusive", "checked", "", "", "", "")+ gui.formLabel("taxInclusive", " Tax Inclusive");
        }else{
            entryTypeLbl    = gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("item", " Item");
//            entryTypeSel    = gui.formSelect("item", "ARITEMS", "ITEMCODE", "ITEMNAME", "", "", "", "onchange = \"invoices.getItemAmount();\"", false);
            entryTypeSel    = gui.formSelect("item", comCode+".ICITEMS", "ITEMCODE", "ITEMNAME", "", "", "", "onchange = \"invoices.getItemAmount();\"", false);
            quantityUi      = gui.formInput("text", "quantity", 15, "", "onkeyup = \"invoices.getItemTotalAmount();\"", "");
            amountUi        = gui.formInput("text", "amount", 15, "", "", "")+ gui.formCheckBox("taxInclusive", "checked", "", "", "", "")+ gui.formLabel("taxInclusive", " Tax Inclusive");
        }
        
        obj.put("entryTypeLbl", entryTypeLbl);
        obj.put("entryTypeSel", entryTypeSel);
        obj.put("quantityUi", quantityUi);
        obj.put("amountUi", amountUi);
        obj.put("success", new Integer(1));
        
        return obj;
    }
    
    public Object getItemAmount(){
        JSONObject obj = new JSONObject();
        
//        ARItem aRItem = new ARItem(this.itemCode);
        ICItem iCItem = new ICItem(this.itemCode, comCode);
        
//        obj.put("amount", aRItem.unitPrice);
        obj.put("amount", iCItem.unitPrice);
                    
        return obj;
    }
    
    public Object getItemTotalAmount(){
        JSONObject obj = new JSONObject();
        
//        ARItem aRItem = new ARItem(this.itemCode);
        ICItem iCItem = new ICItem(this.itemCode, comCode);
        
//        Double itemTotalPrice = this.qty * aRItem.unitPrice;
        Double itemTotalPrice = this.qty * iCItem.unitPrice;
        
        obj.put("amount", itemTotalPrice);
                    
        return obj;
    }
    
    public Object save(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        this.inNo = this.getInvNo();
        
        if(this.inNo != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query ;
                Integer saved = 0;
                
                Double unitPrice = 1.0;
                
                if(this.entryType.equals("S")){
                    this.qty = 1.0;
                }else{
//                    ARItem aRItem = new ARItem(this.itemCode);
                    ICItem iCItem = new ICItem(this.itemCode, comCode);
//                    unitPrice = aRItem.unitPrice;
                    unitPrice = iCItem.unitPrice;
                }
                
                Boolean taxInclusive    = (this.taxIncl != null && this.taxIncl == 1)? true: false;
    
                VAT vAT = new VAT(this.amount, taxInclusive, comCode);
                
                if(this.sid == null){

                    Integer sid = sys.generateId(comCode+".ARINDTLS", "ID");
                    
                    String lineNo_ = sys.getNextNo(comCode+".ARINDTLS", "LINENO", "INNO = '"+ this.inNo+ "'", "", 1);
                    Integer lineNo = Integer.parseInt(lineNo_);
                    
                    query = "INSERT INTO "+comCode+".ARINDTLS "
                            + "(ID, INNO, LINENO, ITEMDTBCODE, "
                            + "QTY, UNITPRICE, TAXINCL, "
                            + "TAXRATE, TAXAMOUNT, NETAMOUNT, AMOUNT, TOTAL, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + sid+ ", "
                            + "'"+ this.inNo+ "', "
                            + lineNo+ ", "
                            + "'"+ this.itemCode+ "', "
                            + this.qty+ ", "
                            + unitPrice+ ", "
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

                    query = "UPDATE "+comCode+".ARINDTLS SET "
                            + "ITEMDTBCODE  = '"+ this.itemCode+ "', "
                            + "QTY          = "+ this.qty+ ", "
                            + "UNITPRICE    = "+ unitPrice+ ", "
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
                    
                    obj.put("invoiceNo", this.inNo);
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
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
    
    public String getInvNo(){
        Sys sys = new Sys();
        
        if(this.inNo == null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id = sys.generateId(this.table, "ID");
                this.inNo = sys.getNextNo(this.table, "ID", "", "IN", 7);
                
                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                java.util.Date entryDate = originalFormat.parse(this.entryDate);
                this.entryDate = targetFormat.format(entryDate);

                String query = "INSERT INTO "+ this.table+ " "
                        + "(ID, BATCHNO, INNO, INDESC, CUSTOMERNO, "
                        + "ENTRYTYPE, ENTRYDATE, PYEAR, PMONTH, PONO, ORDERNO"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ this.batchNo+ "', "
                        + "'"+ this.inNo+ "', "
                        + "'"+ this.invDesc+ "', "
                        + "'"+ this.customerNo+ "', "
                        + "'"+ this.entryType+ "', "
                        + "'"+ this.entryDate+ "', "
                        + this.pYear+", "
                        + "'"+ this.pMonth+ "', "
                        + "'"+ this.poNo+ "', "
                        + "'"+ this.orderNo+ "'"
                        + ")";

                Integer invHdrCreated = stmt.executeUpdate(query);
                
                if(invHdrCreated == 1){
                    //has invoice no already
                }else{
                    this.inNo = null;
                }

            }catch(SQLException e){
                e.getMessage();
            }catch(Exception e){
                e.getMessage();
            }
        }
        
        return this.inNo;
    }
    
    public String getInEntries(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(comCode+".VIEWARINDTLS", "INNO = '"+ this.inNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Invoice No</th>";
            html += "<th>Item</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "<th style = \"text-align: right;\">Tax</th>";
            html += "<th style = \"text-align: right;\">Invoice Total</th>";
            html += "<th style = \"text-align: center;\">Options</th>";
            html += "</tr>";
            
            Double sumAmount    = 0.0;
            Double sumTax       = 0.0;
            Double sumTotal     = 0.0;
            
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+comCode+".VIEWARINDTLS WHERE INNO = '"+ this.inNo+ "'";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String inNo         = rs.getString("INNO");
                    String entryType    = rs.getString("ENTRYTYPE");
                    String itemDtbCode  = rs.getString("ITEMDTBCODE");
                    Double taxAmount    = rs.getDouble("TAXAMOUNT");
                    Double amount       = rs.getDouble("AMOUNT");
                    Double total        = rs.getDouble("TOTAL");
                    Boolean rtp         = rs.getBoolean("RTP");
                    
                    String itemName;
                    
                    if(entryType.equals("S")){
                        ARDistribution aRDistribution = new ARDistribution(itemDtbCode, comCode);
                        itemName = aRDistribution.dtbName;
                    }else{
                        ICItem iCItem = new ICItem(itemDtbCode, comCode);
                        itemName = iCItem.itemName;
                    }
                    
                    String editLink     = gui.formHref("onclick = \"invoices.editInvDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"invoices.purge("+ id +", '"+ itemName +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    String lockLink     = gui.formHref("onclick = \"alert('locked');\"", request.getContextPath(), "lock.png", "", "locked", "", "");
                    
                    String opts = "";
                    if(! rtp){
                        opts = editLink+ " || "+ removeLink;
                    }else{
                        opts = lockLink;
                    }
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ inNo +"</td>";
                    html += "<td>"+ itemName +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(amount.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(taxAmount.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(total.toString()) +"</td>";
                    html += "<td style = \"text-align: center;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    sumAmount   = sumAmount + amount;
                    sumTax      = sumTax + taxAmount;
                    sumTotal    = sumTotal + total;

                    count++;
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"3\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumAmount.toString()) +"</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumTax.toString()) +"</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumTotal.toString()) +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No invoice items record found.";
        }
        
        return html;
    }
    
    public Object editInvDtls(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists(comCode+".ARINDTLS", "ID = "+ this.sid +"")){
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+comCode+".VIEWARINDTLS WHERE ID = "+ this.sid +"";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String itemDtbCode  = rs.getString("ITEMDTBCODE");
                    Double qty          = rs.getDouble("qty");
                    String amount       = rs.getString("AMOUNT");
                    Integer taxIncl     = rs.getInt("TAXINCL");
                    
                    obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                    obj.put("quantity", qty);
                    obj.put("item", itemDtbCode);
                    obj.put("amount", amount);
                    obj.put("taxInclusive", taxIncl);
                    
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
                String query = "DELETE FROM "+comCode+".ARINDTLS WHERE ID = "+this.id;
            
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