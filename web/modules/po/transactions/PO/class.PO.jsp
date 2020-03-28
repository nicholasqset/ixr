<%@page import="bean.finance.VAT"%>
<%@page import="bean.ic.ICItem"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.ap.APSupplierProfile"%>
<%@page import="bean.finance.FinConfig"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class PO{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    String table            = comCode+".POPOHDR";
    String view             = comCode+".VIEWPOPOHDR";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        
    String poNo             = request.getParameter("poNoHd") != null && ! request.getParameter("poNoHd").trim().equals("")? request.getParameter("poNoHd"): null;
    String entryDate        = request.getParameter("entryDate");
    String poDesc           = request.getParameter("poDesc");
    String supplierNo       = request.getParameter("supplierNo");
    Integer pYear           = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth          = request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    
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

                        list.add("PONO");
                        list.add("PODESC");
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

            String orderBy = "PONO DESC ";
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
                html += "<th>PO No</th>";
                html += "<th>Description</th>";
                html += "<th>Source</th>";
                html += "<th>Supplier No</th>";
                html += "<th>Name</th>";
                html += "<th>Amount</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id              = rs.getInt("ID");
                    String poNo             = rs.getString("PONO");
                    String poDesc           = rs.getString("PODESC");
                    String docSrc           = rs.getString("DOCSRC");
                    String supplierNo       = rs.getString("SUPPLIERNO");
//                    String fullName         = rs.getString("SUPPLIERNAME");
                    String supplierName     = rs.getString("SUPPLIERNAME");
                    
                    String amount_ = sys.getOneAgt(this.comCode+ ".VIEWPOPODTLS", "SUM", "AMOUNT", "SM", "PONO = '"+ poNo+ "'");
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ poNo+ "</td>";
                    html += "<td>"+ poDesc+ "</td>";
                    html += "<td>"+ docSrc+ "</td>";
                    html += "<td>"+ supplierNo+ "</td>";
//                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ supplierName+ "</td>";
                    html += "<td>"+ sys.numberFormat(amount_)+ "</td>";
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
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getPOTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"po.save('entryDate poDesc supplierNo pYear pMonth quantity item cost amount'); return false;\"", "");
	if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"po.print('poNo'); return false;\"", "");
        }
        html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Purchase Order\'), 0, 625, 420, Array(false));";
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
                    this.poNo       = rs.getString("PONO");
                    this.poDesc     = rs.getString("PODESC");
                    this.supplierNo = rs.getString("SUPPLIERNO");
                    fullName        = rs.getString("SUPPLIERNAME");
                    this.entryDate  = rs.getString("ENTRYDATE");
                    
                    java.util.Date entryDate = originalFormat.parse(this.entryDate);
                    this.entryDate = targetFormat.format(entryDate);
                    
                    this.pYear      = rs.getInt("PYEAR");		
                    this.pMonth     = rs.getInt("PMONTH");
                    
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
        
        html += "<div id = \"dvPoEntrySid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+this.sid, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("poNo", " PO No.")+"</td>";
	html += "<td width = \"35%\">"+ gui.formInput("text", "poNo", 15, this.id != null? this.poNo: "", "", "disabled")+ gui.formInput("hidden", "poNoHd", 15, this.id != null? this.poNo: "", "", "")+ "</td>";
                
        html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", " Date")+"</td>";
        html += "<td>"+gui.formDateTime(request.getContextPath(), "entryDate", 15, this.id != null? this.entryDate: defaultDate, false, "")+"</td>";
	html += "</tr>";
        
	html += "<tr>";
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"package.png", "", "")+ gui.formLabel("poDesc", " Description")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "poDesc", 30, this.id != null? this.poDesc: "", "", "")+"</td>";
	html += "</tr>";
              
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("supplierNo", " Supplier No.")+ "</td>";
        html += "<td>"+ gui.formAutoComplete("supplierNo", 13, this.id != null? this.supplierNo: "", "po.searchSupplier", "supplierNoHd", this.id != null? this.supplierNo: "")+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdFullName\">"+ fullName+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
        html += "<td>"+ gui.formSelect("pYear", comCode+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+sys.getPeriodYear(comCode), "", false)+"</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: sys.getPeriodMonth(comCode), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("item", " Item")+ "</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("item", comCode+".ICITEMS", "ITEMCODE", "ITEMNAME", "", "", "", "onchange = \"po.getItemAmount();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("quantity", " Quantity Ordered")+ "</td>";
	html += "<td id = \"tdQuantity\" colspan = \"3\">"+ gui.formInput("text", "quantity", 15, "", "onkeyup = \"po.getItemTotalAmount();\"", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("cost", " Cost")+ "</td>";
	html += "<td id = \"tdCost\" colspan = \"3\" nowrap>"+ gui.formInput("text", "cost", 15, "", "onkeyup = \"po.getItemTotalAmount();\"", "")+ "</td>";
	html += "</tr>";
        
        String taxInclUi = gui.formCheckBox("taxInclusive", "checked", "", "", "", "")+ gui.formLabel("taxInclusive", " Tax Inclusive");
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("amount", " Amount")+ "</td>";
	html += "<td id = \"tdAmount\" colspan = \"3\" nowrap>"+ gui.formInput("text", "amount", 15, "", "", "disabled")+ taxInclUi+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvPoEntries\">"+ this.getPoEntries()+"</div></td>";
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
    
    public Object getSupplierProfile(){
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
    
    public Object getItemAmount(){
        JSONObject obj = new JSONObject();
        
        ICItem iCItem = new ICItem(this.itemCode, comCode);
        
        obj.put("cost", iCItem.unitCost);
                    
        return obj;
    }
    
    public Object getItemTotalAmount(){
        JSONObject obj = new JSONObject();
        
//        ICItem iCItem = new ICItem(this.itemCode);
        
        Double itemTotalPrice = this.qty * this.unitCost;
        
        obj.put("amount", itemTotalPrice);
                    
        return obj;
    }
    
    public Object save(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        this.poNo = this.getPoNo();
        
        if(this.poNo != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query;
                Integer saved = 0;
                
                Boolean taxInclusive    = (this.taxIncl != null && this.taxIncl == 1)? true: false;
    
                VAT vAT = new VAT(this.amount, taxInclusive, comCode);
                
                if(this.sid == null){

                    Integer sid = sys.generateId(comCode+".POPODTLS", "ID");
                    
                    query = "INSERT INTO "+comCode+".POPODTLS "
                            + "(ID, PONO, ITEMCODE, "
                            + "QTY, UNITCOST, TAXINCL, "
                            + "TAXRATE, TAXAMOUNT, NETAMOUNT, AMOUNT, TOTAL, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + sid+ ", "
                            + "'"+ this.poNo+ "', "
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

                    query = "UPDATE "+comCode+".POPODTLS SET "
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
                    
                    obj.put("poNo", this.poNo);
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
    
    public String getPoNo(){
        Sys sys = new Sys();
        
        if(this.poNo == null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id = sys.generateId(this.table, "ID");
                this.poNo = sys.getNextNo(this.table, "ID", "", "PO", 7);
                
                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                java.util.Date entryDate = originalFormat.parse(this.entryDate);
                this.entryDate = targetFormat.format(entryDate);

                String query = "INSERT INTO "+ this.table+ " "
                        + "("
                        + "ID, PONO, PODESC, SUPPLIERNO, "
                        + "ENTRYDATE, PYEAR, PMONTH, DOCSRC"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + "'"+ this.poNo+ "', "
                        + "'"+ this.poDesc+ "', "
                        + "'"+ this.supplierNo+ "', "
                        + "'"+ this.entryDate+ "', "
                        + this.pYear+", "
                        + this.pMonth+ ", "
                        + "'D'"
                        + ")";

                Integer poHdrCreated = stmt.executeUpdate(query);
                
                if(poHdrCreated == 1){
                    //has purchase order no already
                }else{
                    this.poNo = null;
                }

            }catch(SQLException e){
                e.getMessage();
            }catch(Exception e){
                e.getMessage();
            }
        }
        
        return this.poNo;
    }
    
    public String getPoEntries(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(comCode+".VIEWPOPODTLS", "PONO = '"+ this.poNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Item</th>";
            html += "<th style = \"text-align: right;\">Quantity</th>";
            html += "<th style = \"text-align: right;\">Cost</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "<th style = \"text-align: right;\">Tax</th>";
            html += "<th style = \"text-align: right;\">PO Total</th>";
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
                
                String query = "SELECT * FROM "+comCode+".VIEWPOPODTLS WHERE PONO = '"+ this.poNo+ "'";
                
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
                    
                    String taxInclLbl   = taxIncl == 1? "Yes": "No";
                    
                    String editLink     = gui.formHref("onclick = \"po.editPoDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"po.purge("+ id +", '"+ itemName +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    
                    String opts = "";
                    opts = editLink+ " || "+ removeLink;
                    
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
            html += "No purchase order items record found.";
        }
        
        return html;
    }
    
    public Object editPoDtls(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists(comCode+".POPODTLS", "ID = "+ this.sid +"")){
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+comCode+".VIEWPOPODTLS WHERE ID = "+ this.sid +"";
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
    
    public Object purge(){
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+comCode+".POPODTLS WHERE ID = "+this.id;
            
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