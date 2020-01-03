<%@page import="bean.restaurant.Restaurant"%>
<%@page import="bean.restaurant.RtPyHdr"%>
<%@page import="java.util.HashMap"%>
<%@page import="bean.ic.IC"%>
<%@page import="bean.ar.ARCustomerProfile"%>
<%@page import="bean.finance.VAT"%>
<%@page import="bean.ic.ICItem"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.Gui"%>
<%
    final class Receipt{
        String table            = "RTPYHDR";
        String view             = "VIEWRTPYHDR";

        Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;

        String pyNo             = request.getParameter("receiptNoHd") != null && ! request.getParameter("receiptNoHd").trim().equals("")? request.getParameter("receiptNoHd"): null;
        String entryDate        = request.getParameter("entryDate");
        String pyDesc           = request.getParameter("pyDesc");
        String customerNo       = request.getParameter("customerNo");
        Integer pYear           = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth          = request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
        String tillNo           = request.getParameter("till");
        String tableNo          = request.getParameter("rTable");
        
        String itemCode         = request.getParameter("itemNo");
        Double qty              = (request.getParameter("quantity") != null && ! request.getParameter("quantity").trim().equals(""))? Double.parseDouble(request.getParameter("quantity")): 0.0;
        Double unitPrice        = (request.getParameter("price") != null && ! request.getParameter("price").trim().equals(""))? Double.parseDouble(request.getParameter("price")): 0.0;
        Double amount           = (request.getParameter("amount") != null && ! request.getParameter("amount").trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;
        Integer taxIncl         = request.getParameter("taxInclusive") != null? 1: null;

        Integer sid             = request.getParameter("sid") != null? Integer.parseInt(request.getParameter("sid")): null;
        
        Double bill             = (request.getParameter("bill") != null && ! request.getParameter("bill").trim().equals(""))? Double.parseDouble(request.getParameter("bill")): 0.0;
        String pmCode           = request.getParameter("payMode");
        String docNo            = request.getParameter("documentNo");
        Double tender           = (request.getParameter("tender") != null && ! request.getParameter("tender").trim().equals(""))? Double.parseDouble(request.getParameter("tender")): 0.0;
        Double change           = (request.getParameter("change") != null && ! request.getParameter("change").trim().equals(""))? Double.parseDouble(request.getParameter("change")): 0.0;
        
        public String getGrid(){
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            String dbType = ConnectionProvider.getDBType();

            Integer recordCount = system.getRecordCount(this.view, "");

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
                    html += "<th>Invoice/Order No</th>";
                    html += "<th>Description</th>";
                    html += "<th>Customer No</th>";
                    html += "<th>Name</th>";
                    html += "<th>Amount</th>";
                    html += "<th>Paid</th>";
                    html += "<th>Posted</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while(rs.next()){

                        Integer id              = rs.getInt("ID");
                        String pyNo             = rs.getString("PYNO");
                        String pyDesc           = rs.getString("PYDESC");
                        String customerNo       = rs.getString("CUSTOMERNO");
                        String fullName         = rs.getString("FULLNAME");
                        Integer cleared         = rs.getInt("CLEARED");
                        Integer posted          = rs.getInt("POSTED");

                        String amount_ = system.getOneAgt("VIEWRTPYDTLS", "SUM", "AMOUNT", "SM", "PYNO = '"+ pyNo+ "'");
                        
                        String clearedLbl    = cleared == 1? gui.formIcon(request.getContextPath(), "tick.png", "", ""): gui.formIcon(request.getContextPath(), "cross.png", "", "");

                        String postedUi = "";
                        if(posted == 1){
                            postedUi = gui.formCheckBox("posted_"+ id, "checked", "", "", "disabled", "");
                        }else{
                            if(cleared == 1){
                                postedUi = gui.formCheckBox("posted_"+ id, "", "", "onchange = \"receipt.post("+ id+ ", '"+ pyNo+ "', '"+ pyDesc+ "');\"", "", "");
                            }else{
                                postedUi = gui.formIcon(request.getContextPath(), "hourglass.png", "", "");
                            }
                        }

                        String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                        String edit = gui.formHref("onclick = \"module.editModule("+ id+ ")\"", request.getContextPath(), "money-pencil.png", "Payment", "Make Payment", "", "");

                        html += "<tr bgcolor = \""+ bgcolor+ "\">";
                        html += "<td>"+ count+ "</td>";
                        html += "<td>"+ pyNo+ "</td>";
                        html += "<td>"+ pyDesc+ "</td>";
                        html += "<td>"+ customerNo+ "</td>";
                        html += "<td>"+ fullName+ "</td>";
                        html += "<td>"+ system.numberFormat(amount_)+ "</td>";
                        html += "<td>"+ clearedLbl+ "</td>";
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

            Boolean cleared = false;

            if(this.id != null){
                this.pyNo = system.getOne(this.table, "PYNO", "ID = "+ this.id);
                if(this.pyNo != null){
                    RtPyHdr rtPyHdr = new RtPyHdr(this.pyNo);
                    cleared = rtPyHdr.cleared;
                }
            }

            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += "<div id = \"dhtmlgoodies_tabView1\">";

            html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getSalesTab()+ "</div>";

            html += "</div>";

            html += "<div style = \"padding-left: 10px; padding-top: 37px; border: 0;\" >";
            if(! cleared){
//                html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"receipt.save('entryDate pyDesc pYear pMonth till quantity itemNo price amount'); return false;\"", "");
            }
            if(this.id != null && cleared){
                html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"receipt.print('invoiceNo'); return false;\"", "");
            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getGrid(); return false;\"", "");
            html += "</div>";

            html += gui.formEnd();

            html += "<script type = \"text/javascript\">";
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Receipt\'), 0, 625, 420, Array(false));";
            html += "</script>";

            return html;
        }

        public String getSalesTab(){
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();
            
            HttpSession session = request.getSession();

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
                        this.pyNo       = rs.getString("PYNO");
                        this.pyDesc     = rs.getString("PYDESC");
                        this.customerNo = rs.getString("CUSTOMERNO");
                        fullName        = rs.getString("FULLNAME");
                        this.entryDate  = rs.getString("ENTRYDATE");

                        java.util.Date entryDate = originalFormat.parse(this.entryDate);
                        this.entryDate = targetFormat.format(entryDate);

                        this.pYear      = rs.getInt("PYEAR");		
                        this.pMonth     = rs.getInt("PMONTH");
                        this.tillNo     = rs.getString("TILLNO");
                        this.tableNo    = rs.getString("TABLENO");
                    }
                }catch(SQLException e){
                    html += e.getMessage();
                }catch(Exception e){
                    html += e.getMessage();
                }
            }

            String defaultDate = system.getLogDate();

            try{
                java.util.Date today = originalFormat.parse(defaultDate);
                defaultDate = targetFormat.format(today);
            }catch(ParseException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
//            HashMap<String, String> tills = system.getArray("SELECT TILLNO, TILLDESC FROM PSTILLS WHERE TILLNO IN (SELECT TILLNO FROM PSTILLS WHERE USERID = '"+system.getLogUser(session)+"')");
            HashMap<String, String> tills = system.getArray("SELECT TILLNO, TILLDESC FROM PSTILLS");

            String userDfltTillNo = system.getOne("PSTILLS", "TILLNO", "USERID = '"+system.getLogUser(session)+"'");
            
            if(this.id != null){
                html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
            }

            html += "<div id = \"dvPyEntrySid\">";
            if(this.sid != null){
                html += gui.formInput("hidden", "sid", 30, ""+ this.sid, "", "");
            }
            html += "</div>";

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("invoiceNo", " Invoice/Order No.")+"</td>";
            html += "<td width = \"35%\">"+ gui.formInput("text", "invoiceNo", 15, this.id != null? this.pyNo: "", "", "disabled")+ gui.formInput("hidden", "receiptNoHd", 15, this.id != null? this.pyNo: "", "", "")+ "</td>";

            html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", " Date")+"</td>";
            html += "<td>"+gui.formDateTime(request.getContextPath(), "entryDate", 15, this.id != null? this.entryDate: defaultDate, false, "")+"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"package.png", "", "")+ gui.formLabel("pyDesc", " Description")+"</td>";
            html += "<td colspan = \"3\">"+ gui.formInput("text", "pyDesc", 30, this.id != null? this.pyDesc: "** NEW SALE **", "", "")+"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("customerNo", " Customer No.")+ "</td>";
            html += "<td>"+ gui.formAutoComplete("customerNo", 13, this.id != null? this.customerNo: "", "receipt.searchCustomer", "customerNoHd", this.id != null? this.customerNo: "")+ "</td>";

            html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
            html += "<td id = \"tdFullName\">"+ fullName+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
            html += "<td>"+ gui.formSelect("pYear", "FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+ system.getPeriodYear(), "", false)+"</td>";

            html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
            html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: system.getPeriodMonth(), "", true)+ "</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page.png", "", "")+ gui.formLabel("till", " Till No")+"</td>";
            html += "<td>"+ gui.formArraySelect("till", 120, tills, this.id != null? this.tillNo: userDfltTillNo, true, "onchange = \"\"", true)+ "</td>";
            
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page.png", "", "")+ gui.formLabel("rTable", " Table No")+"</td>";
            html += "<td>"+ gui.formSelect("rTable", "RTTABLES", "TABLENO", "TABLEDESC", "", "", this.id != null? this.tableNo: "", "onchange = \"\"", true)+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
            html += "</tr>";

//            html += "<tr>";
//            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("itemNo", " Item No")+ "</td>";
//            html += "<td nowrap>"+ gui.formAutoComplete("itemNo", 13, "", "receipt.searchItem", "itemNoHd", "")+ "<span class = \"fade\"> e.g bar code </span></td>";
//            
//            html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ " Item Name</td>";
//            html += "<td id = \"tdItemName\">&nbsp;</td>";
//            html += "</tr>";
            
            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("itemNo", " Item")+ "</td>";
            html += "<td colspan = \"3\" nowrap>"+ gui.formSelect("itemNo", "ICITEMS", "ITEMCODE", "ITEMNAME", "", "CATCODE IN (SELECT CATCODE FROM RTCATS)", this.id != null? this.tableNo: "", "onchange = \"invoice.getItemProfile();\"", false)+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("quantity", " Quantity")+ "</td>";
            html += "<td id = \"tdQuantity\" colspan = \"3\">"+ gui.formInput("text", "quantity", 15, "", "onkeyup = \"receipt.getItemTotalAmount();\"", "")+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("price", " Price")+ "</td>";
            html += "<td id = \"tdCost\" colspan = \"3\" nowrap>"+ gui.formInput("text", "price", 15, "", "onkeyup = \"receipt.getItemTotalAmount();\"", "")+ "</td>";
            html += "</tr>";

            String taxInclUi = gui.formCheckBox("taxInclusive", "checked", "", "", "", "")+ gui.formLabel("taxInclusive", " Tax Inclusive");

            html += "<tr>";
            html += "<td>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("amount", " Amount")+ "</td>";
            html += "<td id = \"tdAmount\" colspan = \"3\" nowrap>"+ gui.formInput("text", "amount", 15, "", "", "disabled")+ taxInclUi+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"4\"><div id = \"dvPyEntries\">"+ this.getPyEntries()+"</div></td>";
            html += "</tr>";

            html += "</table>";

            return html;
        }

        public String searchCustomer(){
            String html = "";

            Gui gui = new Gui();

            this.customerNo = request.getParameter("customerNoHd");

            html += gui.getAutoColsSearch("ARCUSTOMERS", "CUSTOMERNO, FULLNAME", "", this.customerNo);

            return html;
        }

        public Object getCustomerProfile(){
            JSONObject obj = new JSONObject();

            if(this.customerNo == null || this.customerNo.equals("")){
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            }else{
                ARCustomerProfile aRCustomerProfile = new ARCustomerProfile(this.customerNo);

                obj.put("fullName", aRCustomerProfile.fullName);

                obj.put("success", new Integer(1));
                obj.put("message", "Customer No '"+aRCustomerProfile.customerNo+"' successfully retrieved.");
            }

            return obj;
        }
        
        public String searchItem(){
            String html = "";

            Gui gui = new Gui();

            this.itemCode = request.getParameter("itemNoHd");

            html += gui.getAutoColsSearch("ICITEMS", "ITEMCODE, ITEMNAME", "", this.itemCode);

            return html;
        }

        public Object getItemProfile(){
            JSONObject obj = new JSONObject();

            if(this.itemCode == null || this.itemCode.trim().equals("")){
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            }else{
                ICItem iCItem = new ICItem(this.itemCode);

                obj.put("itemName", iCItem.itemName);
                obj.put("quantity", 1.0);
                obj.put("price", iCItem.unitPrice);
                obj.put("amount", (1.0 * iCItem.unitPrice));

                obj.put("success", new Integer(1));
                obj.put("message", "Item No '"+ iCItem.itemCode+"' successfully retrieved.");
            }

            return obj;
        }

        public Object getItemTotalAmount(){
            JSONObject obj = new JSONObject();

    //        ICItem iCItem = new ICItem(this.itemCode);

            Double itemTotalPrice = this.qty * this.unitPrice;

            obj.put("amount", itemTotalPrice);

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

                    String query;
                    Integer saved = 0;
                    
                    ICItem iCItem = new ICItem(this.itemCode);

                    Boolean taxInclusive    = (this.taxIncl != null && this.taxIncl == 1)? true: false;

                    VAT vAT = new VAT(this.amount, taxInclusive);

                    if(this.sid == null){
                        Integer sid = system.generateId("RTPYDTLS", "ID");

                        query = "INSERT INTO RTPYDTLS "
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
                                + "'"+ system.getLogUser(session)+"', "
                                + "'"+ system.getLogDate()+ "', "
                                + "'"+ system.getLogTime()+ "', "
                                + "'"+ system.getClientIpAdr(request)+ "'"
                                + ")";

                    }else{

                        query = "UPDATE RTPYDTLS SET "
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

                        obj.put("invoiceNo", this.pyNo);
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

        public String getPyNo(){
            Sys sys = new Sys();
            HttpSession session = request.getSession();
            
            if(this.pyNo == null){
                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    Integer id = system.generateId(this.table, "ID");
//                    this.pyNo = system.getNextNo(this.table, "ID", "", "PY", 7);
                    this.pyNo = system.getNextNo(this.table, "ID", "", "", 7);

                    SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                    SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                    java.util.Date entryDate = originalFormat.parse(this.entryDate);
                    this.entryDate = targetFormat.format(entryDate);

                    String query = "INSERT INTO "+ this.table+ " "
                            + "("
                            + "ID, PYNO, PYDESC, CUSTOMERNO, "
                            + "ENTRYDATE, PYEAR, PMONTH, TILLNO, TABLENO, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + id+ ", "
                            + "'"+ this.pyNo+ "', "
                            + "'"+ this.pyDesc+ "', "
                            + "'"+ this.customerNo+ "', "
                            + "'"+ this.entryDate+ "', "
                            + this.pYear+", "
                            + this.pMonth+ ", "
                            + "'"+ this.tillNo+ "', "
                            + "'"+ this.tableNo+ "', "
                            + "'"+ system.getLogUser(session)+"', "
                            + "'"+ system.getLogDate()+ "', "
                            + "'"+ system.getLogTime()+ "', "
                            + "'"+ system.getClientIpAdr(request)+ "'"
                            + ")";

                    Integer pyHdrCreated = stmt.executeUpdate(query);

                    if(pyHdrCreated == 1){
                        //has receipt no already
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

            if(system.recordExists("VIEWRTPYDTLS", "PYNO = '"+ this.pyNo+ "'")){
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

                    String query = "SELECT * FROM VIEWRTPYDTLS WHERE PYNO = '"+ this.pyNo+ "'";

                    ResultSet rs = stmt.executeQuery(query);

                    while(rs.next()){
                        Integer id          = rs.getInt("ID");
                        String itemName     = rs.getString("ITEMNAME");
                        Double qty          = rs.getDouble("QTY");
                        Double unitPrice     = rs.getDouble("UNITPRICE");
                        Double taxAmount    = rs.getDouble("TAXAMOUNT");
                        Double amount       = rs.getDouble("AMOUNT");
                        Double total        = rs.getDouble("TOTAL");
                        Integer taxIncl     = rs.getInt("TAXINCL");
                        Integer cleared     = rs.getInt("CLEARED");
                        
                        Double taxAmountAlt = taxIncl == 1? taxAmount: 0;

                        String taxInclLbl   = taxIncl == 1? "Yes": "No";
                        
                        String editLink     = gui.formHref("onclick = \"receipt.editPoDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                        String removeLink   = gui.formHref("onclick = \"receipt.purge("+ id +", '"+ itemName +"');\"", request.getContextPath(), "", "delete", "delete", "", "");

                        String opts = "";
                        
                        /*
                        if(cleared == 1){
                            opts = gui.formIcon(request.getContextPath(), "lock.png", "", "");
                        }else{
                            opts = editLink+ " || "+ removeLink;
                        }
                        */
                        
                        opts = gui.formIcon(request.getContextPath(), "lock.png", "", "");

                        html += "<tr>";
                        html += "<td>"+ count +"</td>";
                        html += "<td>"+ itemName +"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(qty.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(unitPrice.toString()) +"</td>";
                        html += "<td style = \"text-align: center;\">"+ taxInclLbl+"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(taxAmountAlt.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(amount.toString()) +"</td>";
                        html += "<td style = \"text-align: center;\">"+ opts +"</td>";
                        html += "</tr>";

                        sumAmount   = sumAmount + amount;
                        sumTax      = sumTax + taxAmountAlt;
                        sumTotal    = sumTotal + total;

                        count++;
                    }
                }catch (SQLException e){
                    html += e.getMessage();
                }catch (Exception e){
                    html += e.getMessage();
                }

                html += "<tr>";
                html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"5\">Total</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumTax.toString()) +"</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumAmount.toString()) +"</td>";
                html += "<td>&nbsp;</td>";
                html += "</tr>";

                html += "</table>";
                
                html += "</div>";
                
                
                html += "<div id = \"dvPyEntries-b\">";
                
                RtPyHdr rtPyHdr = new RtPyHdr(this.pyNo);
                
                String paymentUi = "";
                
                if(! rtPyHdr.cleared){
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
                html += "No receipt items record found.";
            }

            return html;
        }

        public Object editPoDtls(){
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            Gui gui = new Gui();
            if(system.recordExists("RTPYDTLS", "ID = "+ this.sid +"")){
                try{

                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query = "SELECT * FROM VIEWRTPYDTLS WHERE ID = "+ this.sid +"";
                    ResultSet rs = stmt.executeQuery(query);

                    while(rs.next()){
                        String id           = rs.getString("ID");
                        String itemCode     = rs.getString("ITEMCODE");
                        Double qty          = rs.getDouble("QTY");
                        Double unitPrice    = rs.getDouble("UNITPRICE");
                        String amount       = rs.getString("AMOUNT");
                        Integer taxIncl     = rs.getInt("TAXINCL");

                        obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                        obj.put("itemNo", itemCode);
                        obj.put("quantity", qty);
                        obj.put("price", unitPrice);
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
                    String query = "DELETE FROM RTPYDTLS WHERE ID = "+ this.id;

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
        
        public String getPaymentUi(){
            String html = "";
            
            Gui gui = new Gui();
            Sys sys = new Sys();
            
            String cashPayMode = system.getOne("FNPAYMODES", "PMCODE", "ISCASH = 1");
            
            String amount_ = system.getOneAgt("VIEWRTPYDTLS", "SUM", "AMOUNT", "SM", "PYNO = '"+ this.pyNo+ "'");
            
            html += gui.formStart("frmPayment", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
            html += gui.formInput("hidden", "receiptNoHd", 30, ""+ this.pyNo, "", "");
            
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("bill", " Bill Total")+"</td>";
            html += "<td>"+ gui.formInput("text", "bill", 15, amount_, "", "disabled")+ "</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("payMode", " Payment Mode")+"</td>";
            html += "<td>"+ gui.formSelect("payMode", "FNPAYMODES", "PMCODE", "PMNAME", "", "", cashPayMode, "", false)+"</td>";
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
        
        public Object savePayment(){
            JSONObject obj = new JSONObject();
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                if(this.change >= 0){
                    String query = "UPDATE "+ this.table+ " SET "
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
                        
//                        obj.put("qtyEff", this.effectItemQty(this.pyNo));
                        
                        RtPyHdr rtPyHdr = new RtPyHdr(this.pyNo);
                        
                        obj.put("id", rtPyHdr.id);
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
            
            IC iC = new IC();
                    
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM RTPYDTLS WHERE PYNO = '"+ pyNo+"'";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    
                    String itemCode = rs.getString("ITEMCODE");
                    Double qty      = rs.getDouble("QTY");
                    
                    html += iC.effectItemQty(itemCode, qty, false);
                    
                }
            }catch(Exception e){
                html += e.getMessage();
            }
            
            return html;
        }

        public Object post(){
            JSONObject obj = new JSONObject();
            HttpSession session = request.getSession();

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                Restaurant restaurant = new Restaurant();

                Integer rts = 1;
                String msg = "";

                if(this.pyNo == null){
                    rts = 0;
                    msg = "Invalid batch";
                }

                if(this.id == null){
                    rts = 0;
                    msg = "An unexpected error occured";
                }

                String pyPosted = restaurant.postReceipt(this.pyNo, session, request);
                if(! pyPosted.equals("1")){
                    rts = 0;
                    msg = "Entry could not be posted. "+ pyPosted;
                }

                if(rts == 1){
//                    String query = "UPDATE "+ this.table+ " SET POSTED = 1 WHERE ID = "+ this.id;
                    String query = "UPDATE "+this.table+" SET POSTED = NULL WHERE ID = "+this.id;

                    Integer rtp = stmt.executeUpdate(query);

                    if(rtp == 1){
                        obj.put("success", new Integer(1));
                        obj.put("message", "Entry successfully posted.");
                    }else{
                        obj.put("success", new Integer(0));
                        obj.put("message", "An error occured while posting receipt.");
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