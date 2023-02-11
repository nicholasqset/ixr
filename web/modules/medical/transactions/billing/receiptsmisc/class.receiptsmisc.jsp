<%@page import="bean.ic.IC"%>
<%@page import="bean.ic.ICItem"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.medical.MedMiscRcptHeader"%>
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

final class MiscReceipts{
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
    String table        = comCode+".HMRCPTSMISCHDR";
    String view         = comCode+".VIEWHMMISCRCPTSHDR";
        
    String rcptmNo      = request.getParameter("miscReceiptNo");
    String itemCode     = request.getParameter("item");
    Double qty          = request.getParameter("quantity") != null? Double.parseDouble(request.getParameter("quantity")): 0.00;
    Double amount       = request.getParameter("amount") != null? Double.parseDouble(request.getParameter("amount")): 0.00;
    
    Integer rid         = request.getParameter("rid") != null? Integer.parseInt(request.getParameter("rid")): null;
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    
    String pmCode       = request.getParameter("payMode");
    String docNo        = request.getParameter("docNo");
    Double total        = request.getParameter("total") != null? Double.parseDouble(request.getParameter("total")): 0.00;
    
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

                        list.add("RCPTMNO");
                        list.add("PYEAR");
                        list.add("PMONTH");
                        list.add("RCPTMDATE");
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

            String orderBy = "RCPTMNO DESC ";
            String limitSql = "";

            switch(dbType){
                case "mysql":
                    limitSql = "LIMIT "+ session.getAttribute("startRecord")+ " , "+ session.getAttribute("maxRecord");
                    break;
                case "postgres":
                    limitSql = "OFFSET "+ session.getAttribute("startRecord")+ " LIMIT "+ session.getAttribute("maxRecord");
                    break;
            }

            gridSql = "SELECT * FROM "+ this.table+ " "+ filterSql+ " ORDER BY "+ orderBy+ limitSql;

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
                html += "<th>Misc. Receipt No</th>";
                html += "<th>Period Year</th>";
                html += "<th>Period Month</th>";
                html += "<th>Receipt Date</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    String rcptmNo      = rs.getString("RCPTMNO");
                    Integer pYear       = rs.getInt("PYEAR");
                    Integer pMonth      = rs.getInt("PMONTH");
                    String rcptmDate    = rs.getString("RCPTMDATE");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"miscReceipt.editMiscReceipt('"+ rcptmNo +"')\"", request.getContextPath(), "pencil.png", "view", "view", "", "");

                    html += "<tr bgcolor = \""+ bgcolor +"\">";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ rcptmNo +"</td>";
                    html += "<td>"+ pYear +"</td>";
                    html += "<td>"+ pMonth +"</td>";
                    html += "<td>"+ rcptmDate +"</td>";
                    html += "<td>"+ edit +"</td>";
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
        
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getMiscReceiptDtlsTab() +"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divMiscReceipts\">"+ this.getMiscReceiptTab() +"</div></div>";
        
        html += "</div>";
        
	html += "<div style = \"padding-left: 10px; padding-top: 40px; border: 0;\" >";
        
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"module.getGrid();\"", "");
	html += "</div>";
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Items\', \'Receipt\'), 0, 625, 350, Array(false, false));";
        html += "</script>";
        
        return html;
    }
    
    public String getMiscReceiptDtlsTab(){
        String html = "";
        Gui gui = new Gui();
        
        if(this.rid != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.comCode+".VIEWHMMISCRCPTSDTLS WHERE ID = '"+ this.rid +"'";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.rcptmNo        = rs.getString("RCPTMNO");		
                    this.itemCode       = rs.getString("ITEMCODE");		
                    this.qty            = rs.getDouble("QTY");	
                }
            }catch (Exception e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmMiscReceiptDtls", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        if(this.rcptmNo != null){
            html += gui.formInput("hidden", "miscReceiptNo", 15, this.rcptmNo, "", "");
        }
        
        html += "<div id = \"divHdMiscReceiptRid\">";
        if(this.rid != null){
            html += gui.formInput("hidden", "rid", 15, ""+this.rid, "", "");
        }
        html += "</div>";
          
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"22%\" nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "") + gui.formLabel("item", " Medical Item") +"</td>";
        html += "<td>"+ gui.formSelect("item", this.comCode+".icITEMS", "ITEMCODE", "ITEMNAME", "", "catcode in (select catcode from "+this.comCode+".hmcats)", this.rid != null? this.itemCode: "", "", false) +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td >"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "") + gui.formLabel("quantity", " Quantity") +"</td>";
	html += "<td>"+ gui.formInput("text", "quantity", 15, this.rid != null? ""+this.qty: "", "", "") +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td >"+ gui.formIcon(request.getContextPath(),"coins.png", "", "") + gui.formLabel("amount", " Amount")+"</td>";
//	html += "<td>"+ gui.formInput("text", "amount", 15, this.rid != null? ""+this.amount: "", "", "disabled") +"</td>";
	html += "<td>"+ gui.formInput("text", "amount", 15, this.rid != null? ""+this.amount: "", "", "") +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\"><div id = \"divMiscReceiptHdr\">"+ this.getMiscReceiptDtls()+"</div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSaveMiscReceiptHdr", "Save", "save.png", "onclick = \"miscReceipt.saveMiscReceiptDtls('item quantity');\"", "");
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
        
        html += gui.formEnd();
                
        return html;
    }
    
    public String getMiscReceiptDtls(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        MedMiscRcptHeader medMiscRcptHeader = new MedMiscRcptHeader(this.rcptmNo, this.comCode);
        
        if(sys.recordExists(""+this.comCode+".VIEWHMMISCRCPTSDTLS", "RCPTMNO = '"+ this.rcptmNo +"'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Item</th>";
            html += "<th>Quantity</th>";
            html += "<th style = \"text-align: right;\">Rate</th>";
            html += "<th style = \"text-align: right;\">VAT</th>";
            html += "<th style = \"text-align: right;\">Net</th>";
            html += "<th style = \"text-align: right;\">Gross</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            Double total   = 0.00;
            
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+this.comCode+".VIEWHMMISCRCPTSDTLS WHERE RCPTMNO = '"+ this.rcptmNo +"'";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String qty          = rs.getString("QTY");
                    String itemName     = rs.getString("ITEMNAME");
                    Double rate         = rs.getDouble("RATE");
                    Double vatAmount    = rs.getDouble("VATAMOUNT");
                    Double netAmount    = rs.getDouble("NETAMOUNT");
                    Double amount       = rs.getDouble("AMOUNT");
                    
                    String editLink     = gui.formHref("onclick = \"miscReceipt.editMiscReceiptDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"miscReceipt.deleteMiscReceiptDtls("+ id +", '"+ itemName +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    
                    String opts = "";
                    
                    if(medMiscRcptHeader.paid){
                        opts = gui.formIcon(request.getContextPath(), "lock.png", "", "");
                    }else{
                        opts = editLink+ " || "+ removeLink;
                    }
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ itemName +"</td>";
                    html += "<td>"+ qty +"</td>";
                    html += "<td style = \"text-align: right;\">"+ rate +"</td>";
                    html += "<td style = \"text-align: right;\">"+ vatAmount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ netAmount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ amount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    total = total + amount;

                    count++;
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"6\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ total +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No miscellaneous receipt items record found.";
        }
        
        return html;
    }
    
    public JSONObject editMiscReceiptDtls() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists(""+this.comCode+".VIEWHMMISCRCPTSDTLS", "ID = "+ this.rid +"")){
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+this.comCode+".VIEWHMMISCRCPTSDTLS WHERE ID = "+ this.rid +"";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String itemCode     = rs.getString("ITEMCODE");
                    String qty          = rs.getString("QTY");
                    String amount       = rs.getString("AMOUNT");
                    
                    obj.put("rid", id);
                    obj.put("ridUi", gui.formInput("hidden", "rid", 15, id, "", ""));
                    obj.put("item", itemCode);
                    obj.put("quantity", qty);
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
    
    public String getMiscReceiptHdr(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(this.view, "RCPTMNO = '"+ this.rcptmNo +"'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Receipt No.</th>";
            html += "<th>Amount</th>";
            html += "<th>Paid</th>";
            html += "<th>Options</th>";
            html += "</tr>";
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+ this.view+ " WHERE RCPTMNO = '"+ this.rcptmNo +"'";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String rcptmNo      = rs.getString("RCPTMNO");
                    Integer paid        = rs.getInt("PAID");
                    
                    Double amount       = Double.parseDouble(sys.getOneAgt(""+this.comCode+".VIEWHMMISCRCPTSDTLS", "SUM", "AMOUNT", "SM", "RCPTMNO = '"+ this.rcptmNo +"'"));
                    
                    String paidLbl      = paid == 1? gui.formIcon(request.getContextPath(), "tick.png", "", ""): gui.formIcon(request.getContextPath(), "cross.png", "", "");
                    
                    String opts = "";
                    
                    if(paid == 1){
                        opts += gui.formHref("onclick = \"miscReceipt.printMiscReceipt('"+ this.rcptmNo +"');\"", request.getContextPath(), "", "print", "print", "", "");
                    }else{
                        opts += gui.formHref("onclick = \"miscReceipt.editMiscReceiptHdr('"+ this.rcptmNo +"');\"", request.getContextPath(), "", "edit", "edit", "", "");
                    }
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ rcptmNo +"</td>";
                    html += "<td>"+ amount +"</td>";
                    html += "<td>"+ paidLbl +"</td>";
                    html += "<td>"+ opts +"</td>";
                    html += "</tr>";
                    
                    count++;
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "</table>";
            
        }else{
            html += "No miscellaneous receipt record found.";
        }
        
        return html;
    }
    
    public JSONObject saveMiscReceiptDtls() throws Exception{
        JSONObject obj = new JSONObject();
        HttpSession session = request.getSession();
        
        Sys sys = new Sys();
        
//        Medical medical = new Medical(this.comCode);
        
//        Double rate = medical.getItemRate(sys.getPeriodYear(this.comCode), sys.getPeriodMonth(this.comCode), this.itemCode);
//        obj.put("rate", rate);
         
//        ICItem medicalItem = new ICItem(itemCode, this.comCode);
        Double vatRate = 0.00;

//        if(medicalItem.vatable){
//            FinConfig finConfig = new FinConfig(this.comCode);
//            vatRate = finConfig.vatRate / 100;
//        }

//        this.amount = this.qty * rate;

        Double vatAmount = vatRate * this.amount;
        Double netAmount = this.amount - vatAmount;
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement  stmt = conn.createStatement();

            String query;
            
             Double rate = this.amount / this.qty;

            if(this.rcptmNo == null){

                this.rcptmNo = sys.getNextNo(this.table, "ID", "", "RCPM", 6);
                this.createMiscReceiptHdr(this.rcptmNo);

                Integer id      = sys.generateId(""+this.comCode+".HMRCPTSMISCDTLS", "ID");

                query = "INSERT INTO "+this.comCode+".HMRCPTSMISCDTLS "
                        + "(ID, RCPTMNO, ITEMCODE, QTY, RATE, VATRATE, VATAMOUNT, NETAMOUNT, AMOUNT, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id+", "
                        + "'"+ this.rcptmNo +"', "
                        + "'"+ this.itemCode +"', "
                        + this.qty +", "
                        + rate +", "
                        + vatRate +", "
                        + vatAmount +", "
                        + netAmount +", "
                        + this.amount +", "
                        + "'"+ sys.getLogUser(session) +"', "
                        + "'"+ sys.getLogDate() +"', "
                        + "'"+ sys.getLogTime() +"', "
                        + "'"+ sys.getClientIpAdr(request) +"'"
                        + ")";
            }else{
                if(this.rid == null){

                    Integer id      = sys.generateId(""+this.comCode+".HMRCPTSMISCDTLS", "ID");

                    query = "INSERT INTO "+this.comCode+".HMRCPTSMISCDTLS "
                            + "(ID, RCPTMNO, ITEMCODE, QTY, RATE, VATRATE, VATAMOUNT, NETAMOUNT, AMOUNT, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                            + "VALUES"
                            + "("
                            + id+", "
                            + "'"+ this.rcptmNo +"', "
                            + "'"+ this.itemCode +"', "
                            + this.qty +", "
                            + rate +", "
                            + vatRate +", "
                            + vatAmount +", "
                            + netAmount +", "
                            + this.amount +", "
                            + "'"+ sys.getLogUser(session) +"', "
                            + "'"+ sys.getLogDate() +"', "
                            + "'"+ sys.getLogTime() +"', "
                            + "'"+ sys.getClientIpAdr(request) +"'"
                            + ")";
                }else{
                    query = "UPDATE "+this.comCode+".HMRCPTSMISCDTLS SET "
                            + "ITEMCODE         = '"+ this.itemCode +"', "
                            + "QTY              = "+ this.qty +", "
                            + "RATE             = "+ rate +", "
                            + "VATRATE          = "+ vatRate +", "
                            + "VATAMOUNT        = "+ vatAmount +", "
                            + "NETAMOUNT        = "+ netAmount +", "
                            + "AMOUNT           = "+ this.amount +", "
                            + "AUDITUSER        = '"+ sys.getLogUser(session) +"', "
                            + "AUDITDATE        = '"+ sys.getLogDate() +"', "
                            + "AUDITTIME        = '"+ sys.getLogTime() +"', "
                            + "AUDITIPADR       = '"+ sys.getClientIpAdr(request) +"' "

                            + "WHERE ID         = '"+ this.rid +"'";
                }

            }

            Integer saved = stmt.executeUpdate(query);

            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");

                obj.put("miscReceiptNo", this.rcptmNo);
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
    
    public Integer createMiscReceiptHdr(String rcptmNo){
        Integer headerCreated = 0;
        
        HttpSession session = request.getSession();
        Sys sys = new Sys();
        
        if(! sys.recordExists(""+this.comCode+".HMRCPTSMISCHDR", "RCPTMNO = '"+ rcptmNo +"'")){
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt  = conn.createStatement();
                
                Integer id      = sys.generateId(""+this.comCode+".HMRCPTSMISCHDR", "ID");

                String query = "INSERT INTO "+this.comCode+".HMRCPTSMISCHDR "
                        + "(ID, RCPTMNO, PYEAR, PMONTH, RCPTMDATE, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id +", "
                        + "'"+ rcptmNo +"', "
                        + sys.getPeriodYear(this.comCode)+ ", "
                        + sys.getPeriodMonth(this.comCode)+ ", "
                        + "'"+ sys.getLogDate() +"', "
                        + "'"+ sys.getLogUser(session) +"', "
                        + "'"+ sys.getLogDate() +"', "
                        + "'"+ sys.getLogTime() +"', "
                        + "'"+ sys.getClientIpAdr(request) +"'"
                        + ")";

                headerCreated = stmt.executeUpdate(query);
            
            }catch(Exception e){

            }
        }
        
        return headerCreated;
    }
    
    public String getMiscReceiptTab(){
        String html = "";
        
        html += this.getMiscReceiptHdr();
       
        return html;
    }
    
    public JSONObject deleteMiscReceiptDtls() throws Exception{
         
         JSONObject obj = new JSONObject();
         
         try{
             Connection conn = ConnectionProvider.getConnection();
             Statement stmt = conn.createStatement();
            
            if(this.rid != null){
                String query = "DELETE FROM "+this.comCode+".HMRCPTSMISCDTLS WHERE ID = "+this.rid;
            
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
                obj.put("message", "An error occured while deleting record.");
            }
            
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
         return obj;
        
    }
    
    public String editMiscReceiptHdr(){
        String html = "";
        
        Gui gui = new Gui();
        
        MedMiscRcptHeader medMiscRcptHeader = new MedMiscRcptHeader(this.rcptmNo, this.comCode);
        
        html += gui.formStart("frmMiscReceiptHdr", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"22%\" class = \"bold\">"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+gui.formLabel("rcptmNo", " Receipt No.")+"</td>";
	html += "<td >"+ gui.formInput("text", "miscReceiptNoDisb", 15, this.rcptmNo, "", "disabled") + gui.formInput("hidden", "miscReceiptNo", 15, this.rcptmNo, "", "") +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+gui.formLabel("payMode", " Payment Mode")+"</td>";
	html += "<td >"+gui.formSelect("payMode", ""+this.comCode+".FNPAYMODES", "PMCODE", "PMNAME", "", "", medMiscRcptHeader.pmCode != null? medMiscRcptHeader.pmCode: "", "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+gui.formLabel("docNo", " Document No.")+"</td>";
	html += "<td >"+gui.formInput("text", "docNo", 15, medMiscRcptHeader.docNo != null? medMiscRcptHeader.docNo: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"coins.png", "", "")+gui.formLabel("totalDisb", " Total")+"</td>";
	html += "<td >"+ gui.formInput("text", "totalDisb", 15, medMiscRcptHeader.amount != null? ""+medMiscRcptHeader.amount: "", "", "disabled") + gui.formInput("hidden", "total", 15, medMiscRcptHeader.amount != null? ""+medMiscRcptHeader.amount: "", "", "") +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"miscReceipt.save('payMode');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancelMiscReceipt", "Back", "arrow-left.png", "onclick = \"miscReceipt.getMiscReceiptHdr('"+this.rcptmNo+"');\"", "");
        html += "</td>";
	html += "</tr>";
   
        html += "</table>";
        
        html += gui.formEnd();
        
        return html;
    }
    
    public JSONObject save() throws Exception{
        JSONObject obj = new JSONObject();
        HttpSession session = request.getSession();
        
        Sys sys = new Sys();
        
        try{
            if(sys.recordExists(this.table, "RCPTMNO = '"+ this.rcptmNo +"'")){
                if(this.getStockAvailability(this.rcptmNo).trim().equals("")){
                    Connection conn = ConnectionProvider.getConnection();
                    Statement  stmt = conn.createStatement();

                    String query;

                    query = "UPDATE "+ this.table +" SET "
                                    + "PMCODE           = '"+ this.pmCode +"', "
                                    + "DOCNO            = '"+ this.docNo +"', "
                                    + "PAID             = "+ 1 +", "
                                    + "AUDITUSER        = '"+ sys.getLogUser(session) +"', "
                                    + "AUDITDATE        = '"+ sys.getLogDate() +"', "
                                    + "AUDITTIME        = '"+ sys.getLogTime() +"', "
                                    + "AUDITIPADR       = '"+ sys.getClientIpAdr(request) +"' "

                                    + "WHERE RCPTMNO    = '"+ this.rcptmNo +"'";

                    Integer saved = stmt.executeUpdate(query);

                    if(saved == 1){
                        obj.put("success", new Integer(1));
                        obj.put("message", "Entry successfully made.");

                        obj.put("miscReceiptNo", this.rcptmNo);
                        
                        this.validateStock(rcptmNo);
                        
                    }else{
                        obj.put("success", new Integer(0));
                        obj.put("message", "Oops! An Un-expected error occured while saving record.");
                    }
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", this.getStockAvailability(this.rcptmNo));
                }
                
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
    
    public String getStockAvailability(String rcptmNo){
        String message = "";
        
        Sys sys = new Sys();
        
        Integer count  = 1;
            
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

//            String query = "SELECT * FROM "+this.comCode+".VIEWHMMISCRCPTSDTLS WHERE RCPTMNO = '"+ rcptmNo +"' AND ISDRUG = 1";
            String query = "SELECT * FROM "+this.comCode+".VIEWHMMISCRCPTSDTLS WHERE RCPTMNO = '"+ rcptmNo +"' ";

            ResultSet rs = stmt.executeQuery(query);

            while(rs.next()){
                Double qty          = rs.getDouble("QTY");
                String itemCode     = rs.getString("ITEMCODE");
                String itemName     = rs.getString("ITEMNAME");

                String balStr = sys.getOne(this.comCode+".HMINVENTBAL", "BAL", "PYEAR = "+ sys.getPeriodYear(this.comCode)+" AND PMONTH = "+ sys.getPeriodMonth(this.comCode)+" AND ITEMCODE = '"+ itemCode +"'");
                balStr = (balStr != null && ! balStr.trim().equals(""))? balStr: "0";

                Double qtyBal = Double.parseDouble(balStr);

                if(qty > qtyBal){
//                    message += count +". Medication '"+ itemName+"' out of stock. Deficit = '"+ (qty - qtyBal) +"'.";
//                    message += "<br>";
                }

                count++;
            }

        }catch (Exception e){
            message += e.getMessage();
        }
            
        
        return message;
    }
    
    public Integer validateStock(String rcptNo){
        Integer validateStock = null;
        
//        HttpSession session = request.getSession();
//        Medical medical = new Medical(this.comCode);

        IC iC = new IC(this.comCode);
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT * FROM "+this.comCode+".VIEWHMMISCRCPTSDTLS WHERE RCPTMNO = '"+ rcptmNo +"'";
            ResultSet rs = stmt.executeQuery(query);

            while(rs.next()){
                Double qty          = rs.getDouble("QTY");
                String itemCode     = rs.getString("ITEMCODE");

//                if(this.createItemDed(rcptNo, itemCode, qty) == 1){
//                    medical.reduceItemBalance(itemCode, qty, session, request);
//                }
                
                iC.effectItemQty(itemCode, qty, false, comCode);

            }
        }catch (Exception e){

        }
        
        return validateStock;
    }
    
    public Integer createItemDed(String docNo, String itemCode, Double qty){
        Integer createItem = 0;
        HttpSession session = request.getSession();
        Sys sys = new Sys();
        
        Integer pYear   = sys.getPeriodYear(this.comCode);
        Integer pMonth  = sys.getPeriodMonth(this.comCode);
        
        if(! sys.recordExists(""+this.comCode+".HMINVENTDED", "DOCNO = '"+ docNo +"' AND ITEMCODE = '"+ itemCode +"'")){
            try{
                Connection conn  = ConnectionProvider.getConnection();
                Statement stmt  = conn.createStatement();
                
                Integer id      = sys.generateId("HMINVENTDED", "ID");

                String query = "INSERT INTO "+this.comCode+".HMINVENTDED "
                        + "(ID, DOCNO, PYEAR, PMONTH, ITEMCODE, QTY, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id +", "
                        + "'"+ docNo +"', "
                        + pYear+ ", "
                        + pMonth +", "
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
    
    
        
}

%>