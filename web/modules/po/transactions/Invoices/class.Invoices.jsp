<%@page import="org.json.JSONObject"%>
<%@page import="com.qset.po.PoInHdr"%>
<%@page import="com.qset.po.PO"%>
<%@page import="com.qset.finance.VAT"%>
<%@page import="com.qset.ic.ICItem"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.ap.APSupplierProfile"%>
<%@page import="com.qset.finance.FinConfig"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class Invoices{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    String table            = comCode+".POINHDR";
    String view             = comCode+".VIEWPOINHDR";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        
    String inNo             = request.getParameter("inNo") != null && ! request.getParameter("inNo").trim().equals("")? request.getParameter("inNo"): null;
    String entryDate        = request.getParameter("entryDate");
    String inDesc           = request.getParameter("inDesc");
    String supplierNo       = request.getParameter("supplierNo");
    Integer pYear           = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth          = request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    
    String pyNo             = request.getParameter("pyNo");
    
    String itemCode         = request.getParameter("item");
    Double qty              = (request.getParameter("quantity") != null && ! request.getParameter("quantity").trim().equals(""))? Double.parseDouble(request.getParameter("quantity")): 0.0;
    Double unitCost         = (request.getParameter("cost") != null && ! request.getParameter("cost").trim().equals(""))? Double.parseDouble(request.getParameter("cost")): 0.0;
    Double amount           = (request.getParameter("amount") != null && ! request.getParameter("amount").trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;
    Integer taxIncl         = request.getParameter("taxInclusive") != null? 1: null;
    
    Integer sid             = request.getParameter("sid") != null? Integer.parseInt(request.getParameter("sid")): null;
    
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

                        list.add("INNO");
                        list.add("INDESC");
                        list.add("SUPPLIERNO");
                        list.add("SUPPLIERNAME");
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
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                html += "<table class = \"grid\" width=\"100%\" cellpadding=\"1\" cellspacing=\"0\" border=\"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Invoice No</th>";
                html += "<th>Description</th>";
                html += "<th>Invoice No</th>";
                html += "<th>Supplier No</th>";
                html += "<th>Name</th>";
                html += "<th>Amount</th>";
                html += "<th>Posted</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id              = rs.getInt("ID");
                    String inNo             = rs.getString("INNO");
                    String inDesc           = rs.getString("INDESC");
                    String pyNo             = rs.getString("PYNO");
                    String supplierNo       = rs.getString("SUPPLIERNO");
//                    String fullName         = rs.getString("SUPPLIERNAME");
                    String supplierName     = rs.getString("SUPPLIERNAME");
                    
                    Integer posted          = rs.getInt("POSTED");
                    
                    String amount_ = sys.getOneAgt(comCode+".VIEWPOINDTLS", "SUM", "AMOUNT", "SM", "INNO = '"+ inNo+ "'");
                    
                    String postedUi = "";
                    
                    if(posted == 1){
                        postedUi = gui.formCheckBox("posted_"+ id, "checked", "", "", "disabled", "");
                    }else{
                        postedUi = gui.formCheckBox("posted_"+ id, "", "", "onchange = \"invoice.post("+ id+ ", '"+ inNo+ "', '"+ inDesc+ "');\"", "", "");
                    }
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ inNo+ "</td>";
                    html += "<td>"+ inDesc+ "</td>";
                    html += "<td>"+ pyNo+ "</td>";
                    html += "<td>"+ supplierNo+ "</td>";
//                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ supplierName+ "</td>";
                    html += "<td>"+ sys.numberFormat(amount_)+ "</td>";
                    html += "<td>"+ postedUi+ "</td>";
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
        Sys sys = new Sys();
        
        Boolean posted = false;
        
        if(this.id != null){
            this.inNo = sys.getOne(this.table, "INNO", "ID = "+ this.id);
            if(this.inNo != null){
                PoInHdr poInHdr = new PoInHdr(this.inNo, comCode);
                posted = poInHdr.posted;
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getPOTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
        if(! posted){
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"invoice.save('entryDate inDesc supplierNo pYear pMonth pyNo quantity item cost amount'); return false;\"", "");
        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'PO Invoice\'), 0, 625, 420, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getPOTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        String fullName     = "";
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.view+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.inNo       = rs.getString("INNO");
                    this.inDesc     = rs.getString("INDESC");
                    this.supplierNo = rs.getString("SUPPLIERNO");
                    fullName        = rs.getString("SUPPLIERNAME");
                    this.entryDate  = rs.getString("ENTRYDATE");
                    
                    java.util.Date entryDate = originalFormat.parse(this.entryDate);
                    this.entryDate = targetFormat.format(entryDate);
                    
                    this.pYear      = rs.getInt("PYEAR");		
                    this.pMonth     = rs.getInt("PMONTH");
                    
                    this.pyNo       = rs.getString("PYNO");
                    
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
        
        html += "<div id = \"dvInEntrySid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+this.sid, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("inNo", " Invoice No.")+"</td>";
	html += "<td width = \"35%\">"+ gui.formInput("text", "inNo", 15, this.id != null? this.inNo: "", "", "")+ "</td>";
                
        html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", " Date")+"</td>";
        html += "<td>"+gui.formDateTime(request.getContextPath(), "entryDate", 15, this.id != null? this.entryDate: defaultDate, false, "")+"</td>";
	html += "</tr>";
        
	html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"package.png", "", "")+ gui.formLabel("inDesc", " Description")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "inDesc", 30, this.id != null? this.inDesc: "", "", "")+"</td>";
	html += "</tr>";
              
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("supplierNo", " Supplier No.")+ "</td>";
        html += "<td>"+ gui.formAutoComplete("supplierNo", 13, this.id != null? this.supplierNo: "", "invoice.searchSupplier", "supplierNoHd", this.id != null? this.supplierNo: "")+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdFullName\">"+ fullName+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
        html += "<td>"+ gui.formSelect("pYear", comCode+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+ sys.getPeriodYear(comCode), "", false)+"</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: sys.getPeriodMonth(comCode), "", true)+ "</td>";
	html += "</tr>";
        
        String loadPoItemsUi = gui.formHref("onclick = \"invoice.loadPyItems('supplierNo pYear pMonth pyNo');\"", request.getContextPath(), "arrow-right-double.png", "", "", "", "");
        
        String poNoFilter = this.id != null? "SUPPLIERNO = '"+ this.supplierNo+ "' AND PYEAR = '"+ this.pYear+ "' AND PMONTH = '"+ this.pMonth+ "' AND (APPLIED IS NULL OR APPLIED = 0)": "(APPLIED IS NULL OR APPLIED = 0)";
        
        html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("pyNo", " Receipt No")+"</td>";
        html += "<td id = \"tdPoNo\" colspan = \"3\">"+ gui.formSelect("pyNo", comCode+".POPYHDR", "PYNO", "PYDESC", "", poNoFilter, this.id != null? this.pyNo: "", "onchange = \"invoice.getPyItems();\" style = \"width: 250px;\"", true)+ "<span style = \"padding-left: 10px;\">"+ loadPoItemsUi+ "</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        String itemFilter = this.id != null? "ITEMCODE IN (SELECT DISTINCT ITEMCODE FROM "+comCode+".POPYDTLS WHERE PYNO = '"+ this.pyNo+ "')": "";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("item", " Item")+ "</td>";
	html += "<td id = \"tdItems\" colspan = \"3\">"+ gui.formSelect("item", comCode+".ICITEMS", "ITEMCODE", "ITEMNAME", "", itemFilter, "", "onchange = \"invoice.getItemPyDtls();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("quantity", " Quantity Invoiced")+ "</td>";
	html += "<td id = \"tdQuantity\" colspan = \"3\">"+ gui.formInput("text", "quantity", 15, "", "onkeyup = \"invoice.getItemTotalAmount();\"", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("cost", " Cost")+ "</td>";
	html += "<td id = \"tdCost\" colspan = \"3\" nowrap>"+ gui.formInput("text", "cost", 15, "", "onkeyup = \"invoice.getItemTotalAmount();\"", "")+ "</td>";
	html += "</tr>";
        
        String taxInclUi = gui.formCheckBox("taxInclusive", "checked", "", "", "", "")+ gui.formLabel("taxInclusive", " Tax Inclusive");
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("amount", " Amount")+ "</td>";
	html += "<td id = \"tdAmount\" colspan = \"3\" nowrap>"+ gui.formInput("text", "amount", 15, "", "", "disabled")+ taxInclUi+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvInEntries\">"+ this.getInEntries()+"</div></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchSupplier(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.supplierNo = request.getParameter("supplierNoHd");
        
        html += gui.getAutoColsSearch(comCode+".APSUPPLIERS", "SUPPLIERNO, SUPPLIERNAME", "", this.supplierNo);
        
        return html;
    }
    
    public Object getSupplierProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.supplierNo == null || this.supplierNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            APSupplierProfile aPSupplierProfile = new APSupplierProfile(this.supplierNo, comCode);
            
            obj.put("fullName", aPSupplierProfile.supplierName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Supplier No '"+aPSupplierProfile.supplierNo+"' successfully retrieved.");
        }
        
        return obj;
    }
    
    public String getPyNoUi(){
        String html = "";
        
        Gui gui = new Gui();
        
        String loadPoItemsUi = gui.formHref("onclick = \"invoice.loadPyItems('supplierNo pYear pMonth pyNo');\"", request.getContextPath(), "arrow-right-double.png", "", "", "", "");
        
        html += gui.formSelect("pyNo", comCode+".POPYHDR", "PYNO", "PYDESC", "", "SUPPLIERNO = '"+ this.supplierNo+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " AND (APPLIED IS NULL OR APPLIED = 0)", this.id != null? this.pyNo: "", "onchange = \"invoice.getPyItems();\" style = \"width: 250px;\"", true)+ "<span style = \"padding-left: 10px;\">"+ loadPoItemsUi+ "</span>";
        
        return html;
    }
    
    public Object loadPyItems(){
        JSONObject obj = new JSONObject();
        
        
        
        return obj;
    }
    
    public String getPyItems(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formSelect("item", comCode+".ICITEMS", "ITEMCODE", "ITEMNAME", "", "ITEMCODE IN (SELECT DISTINCT ITEMCODE FROM "+comCode+".POPYDTLS WHERE PYNO = '"+ this.pyNo+ "')", "", "onchange = \"invoice.getItemPyDtls();\"", false);
        
        return html;
    }
    
    public Object getItemPyDtls() throws Exception{
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        ICItem iCItem = new ICItem(this.itemCode, comCode);
        
        obj.put("cost", iCItem.unitCost);
        
        String qty_         = sys.getOne(comCode+".POPYDTLS", "QTY", "PYNO = '"+ this.pyNo+ "' AND ITEMCODE = '"+ this.itemCode+ "'");
        String unitCost_    = sys.getOne(comCode+".POPYDTLS", "UNITCOST", "PYNO = '"+ this.pyNo+ "' AND ITEMCODE = '"+ this.itemCode+ "'");
        String amount_      = sys.getOne(comCode+".POPYDTLS", "AMOUNT", "PYNO = '"+ this.pyNo+ "' AND ITEMCODE = '"+ this.itemCode+ "'");
        
        qty_        = qty_ != null? qty_: "0";
        unitCost_   = unitCost_ != null? unitCost_: "0";
        amount_     = amount_ != null? amount_: "0";
        
        obj.put("quantity", qty_);
        obj.put("cost", unitCost_);
        obj.put("amount", amount_);
                    
        return obj;
    }
    
    public Object getItemTotalAmount() throws Exception{
        JSONObject obj = new JSONObject();
        
//        ICItem iCItem = new ICItem(this.itemCode);
        
        Double itemTotalPrice = this.qty * this.unitCost;
        
        obj.put("amount", itemTotalPrice);
                    
        return obj;
    }
    
    public Object save() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        String inNo_ = sys.getOne(this.table, "INNO", "INNO = '"+ this.inNo+ "' AND POSTED = 1");
        
        if(inNo_ == null){
            if(this.createInHeader() == 1){
                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;
                    Integer saved = 0;

                    Boolean taxInclusive    = (this.taxIncl != null && this.taxIncl == 1)? true: false;

                    VAT vAT = new VAT(this.amount, taxInclusive, comCode);

                    if(this.sid == null){

                        Integer sid = sys.generateId(comCode+".POINDTLS", "ID");

                        query = "INSERT INTO "+comCode+".POINDTLS "
                                + "(ID, INNO, ITEMCODE, "
                                + "QTY, UNITCOST, TAXINCL, "
                                + "TAXRATE, TAXAMOUNT, NETAMOUNT, AMOUNT, TOTAL, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + sid+ ", "
                                + "'"+ this.inNo+ "', "
                                + "'"+ this.itemCode+ "', "
                                + this.qty+ ", "
                                + this.unitCost+ ", "
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
                        query = "UPDATE "+comCode+".POINDTLS SET "
                                + "ITEMCODE     = '"+ this.itemCode+ "', "
                                + "QTY          = "+ this.qty+ ", "
                                + "UNITCOST     = "+ this.unitCost+ ", "
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

                        obj.put("inNo", this.inNo);
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
        }else{
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! Invoice no. already utilised. Use a different no.");
        }
        
        return obj;
    }
    
    public Integer createInHeader(){
        Integer inHdrCreated = 0;
        Sys sys = new Sys();
        
        String inNo_ = sys.getOne(this.table, "INNO", "INNO = '"+ this.inNo+ "'");
        
        if(inNo_ == null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id = sys.generateId(this.table, "ID");
//                this.inNo = sys.getNextNo(this.table, "ID", "", "PY", 7);
                
                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                java.util.Date entryDate = originalFormat.parse(this.entryDate);
                this.entryDate = targetFormat.format(entryDate);

                String query = "INSERT INTO "+ this.table+ " "
                        + "("
                        + "ID, INNO, INDESC, SUPPLIERNO, "
                        + "ENTRYDATE, PYEAR, PMONTH, PYNO"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ this.inNo+ "', "
                        + "'"+ this.inDesc+ "', "
                        + "'"+ this.supplierNo+ "', "
                        + "'"+ this.entryDate+ "', "
                        + this.pYear+", "
                        + this.pMonth+ ", "
                        + "'"+ this.pyNo+ "' "
                        + ")";

                inHdrCreated = stmt.executeUpdate(query);
                
                if(inHdrCreated == 1){
                    //has PO invoice no already
                }else{
                    this.inNo = null;
                }
            }catch(SQLException e){
                e.getMessage();
            }catch(Exception e){
                e.getMessage();
            }
        }else{
            inHdrCreated = 1;
        }
        
        return inHdrCreated;
    }
    
    public String getInEntries(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(comCode+".VIEWPOINDTLS", "INNO = '"+ this.inNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Item</th>";
            html += "<th style = \"text-align: right;\">Quantity</th>";
            html += "<th style = \"text-align: right;\">Cost</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "<th style = \"text-align: right;\">Tax</th>";
            html += "<th style = \"text-align: right;\">Invoice Total</th>";
            html += "<th style = \"text-align: center;\">Tax Incl.</th>";
            html += "<th style = \"text-align: center;\">Options</th>";
            html += "</tr>";
            
            Double sumAmount    = 0.0;
            Double sumTax       = 0.0;
            Double sumTotal     = 0.0;
            
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+comCode+".VIEWPOINDTLS WHERE INNO = '"+ this.inNo+ "'";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String itemName     = rs.getString("ITEMNAME");
                    Double qty          = rs.getDouble("QTY");
                    Double unitCost     = rs.getDouble("UNITCOST");
                    Double taxAmount    = rs.getDouble("TAXAMOUNT");
                    Double amount       = rs.getDouble("AMOUNT");
                    Double total        = rs.getDouble("TOTAL");
                    Integer taxIncl     = rs.getInt("TAXINCL");
                    Integer posted      = rs.getInt("POSTED");
                    
                    String taxInclLbl   = taxIncl == 1? "Yes": "No";
                    
                    String editLink     = gui.formHref("onclick = \"invoice.editInDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"invoice.purge("+ id +", '"+ itemName +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    
                    String opts = "";
                    if(posted == 1){
                        opts = gui.formIcon(request.getContextPath(), "lock.png", "", "");
                    }else{
                        opts = editLink+ " || "+ removeLink;
                    }
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ itemName +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(qty.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(unitCost.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(amount.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(taxAmount.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(total.toString()) +"</td>";
                    html += "<td style = \"text-align: center;\">"+ taxInclLbl+"</td>";
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
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"4\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumAmount.toString()) +"</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumTax.toString()) +"</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumTotal.toString()) +"</td>";
            html += "<td colspan = \"2\">&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No invoice items record found.";
        }
        
        return html;
    }
    
    public Object editInDtls() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists(comCode+".POINDTLS", "ID = "+ this.sid +"")){
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+comCode+".VIEWPOINDTLS WHERE ID = "+ this.sid +"";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String itemCode     = rs.getString("ITEMCODE");
                    Double qty          = rs.getDouble("QTY");
                    Double unitCost     = rs.getDouble("UNITCOST");
                    String amount       = rs.getString("AMOUNT");
                    Integer taxIncl     = rs.getInt("TAXINCL");
                    
                    obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                    obj.put("item", itemCode);
                    obj.put("quantity", qty);
                    obj.put("cost", unitCost);
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
    
    public Object purge() throws Exception{
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+comCode+".POINDTLS WHERE ID = "+this.id;
            
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
    
    public Object post() throws Exception{
        JSONObject obj = new JSONObject();
        HttpSession session = request.getSession();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            PO pO = new PO(comCode);
            
            Integer rts = 1;
            String msg = "";
            
            if(this.inNo == null){
                rts = 0;
                msg = "Invalid batch";
            }
            
            if(this.id == null){
                rts = 0;
                msg = "An unexpected error occured";
            }
            
            String inPosted = pO.postInvoice(this.inNo, session, request);
            if(! inPosted.equals("1")){
                rts = 0;
                msg = "Invoice could not be posted. "+ inPosted;
            }
            
            if(rts == 1){
                String query = "UPDATE "+this.table+" SET POSTED = 1 WHERE ID = "+this.id;
//                String query = "UPDATE "+this.table+" SET POSTED = NULL WHERE ID = "+this.id;
            
                Integer rtp = stmt.executeUpdate(query);
                
                if(rtp == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Invoice successfully posted.");
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured while posting invoice.");
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
        
        return obj;
    }
    
}

%>