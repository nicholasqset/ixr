<%@page import="com.qset.medical.Medical"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class Inventory{
    String table            = "HMINVENTADD";
    String view             = "VIEWHMINVENTORYADD";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String transId          = request.getParameter("transId") ;
    Integer autoTransId     = request.getParameter("autoTransId") != null? 1: null;
    Integer pYear           = request.getParameter("pYear") != null && !request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth          = request.getParameter("pMonth") != null && !request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    String itemCode         = request.getParameter("item");
    Double qty              = request.getParameter("quantity") != null? Double.parseDouble(request.getParameter("quantity")): 0.00;
    Double rate             = request.getParameter("rate") != null? Double.parseDouble(request.getParameter("rate")): 0.00;
    Double amount           = request.getParameter("amount") != null? Double.parseDouble(request.getParameter("amount")): 0.00;
    String vendId           = request.getParameter("vendor");
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        this.pYear  = system.getPeriodYear();
        this.pMonth = system.getPeriodMonth();
        
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

                        ArrayList<String> list = new ArrayList<String>();

                        list.add("TRANSID");
                        list.add("ITEMNAME");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+find+"%' ";
                            }else{
                                filterSql += " OR ( UPPER("+list.get(i)+") LIKE '%"+find+"%' ";
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
                }

            }else{
                if (session.getAttribute("startRecord") == null) {
                    session.setAttribute("startRecord", startRecord);
                }
            }

            gridSql = "SELECT * FROM "+ this.view +" "+ filterSql +" ORDER BY TRANSID LIMIT "
                    + session.getAttribute("startRecord")
                    + " , "
                    + session.getAttribute("maxRecord");

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(gridSql);

                Integer startRecordHidden = Integer.parseInt(session.getAttribute("startRecord").toString()) + Integer.parseInt(session.getAttribute("maxRecord").toString());

                html += gui.formInput("hidden", "maxRecord", 10, session.getAttribute("maxRecord").toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                html += "<table class = \"grid\" width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" border = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Transaction No</th>";
                html += "<th>Period Year</th>";
                html += "<th>Period Month</th>";
                html += "<th>Item</th>";
                html += "<th>Quantity</th>";
                html += "<th>Rate</th>";
                html += "<th>Amount</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String transId      = rs.getString("TRANSID");
                    String itemName     = rs.getString("ITEMNAME");
                    String qty          = rs.getString("QTY");
                    String rate         = rs.getString("RATE");
                    String amount       = rs.getString("AMOUNT");
                    
                    Integer pYear       = rs.getInt("PYEAR");
                    Integer pMonth      = rs.getInt("PMONTH");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";
                    
                    String editLbl = gui.formIcon(request.getContextPath(), "lock.png", "", "");
                    
                    if(this.pYear.equals(pYear) && this.pMonth == pMonth){
                        editLbl = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");
                    }
                    
                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ transId +"</td>";
                    html += "<td>"+ pYear +"</td>";
                    html += "<td>"+ pMonth +"</td>";
                    html += "<td>"+ itemName +"</td>";
                    html += "<td>"+ qty +"</td>";
                    html += "<td>"+ rate +"</td>";
                    html += "<td>"+ amount +"</td>";
                    html += "<td>"+ editLbl +"</td>";
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
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getProfileTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"inventory.save('pYear pMonth item quantity vendor'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Inventory\'), 0, 625, 350, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getProfileTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        this.pYear  = system.getPeriodYear();
        this.pMonth = system.getPeriodMonth();
        
        if(this.id != null){
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+ this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.transId        = rs.getString("TRANSID");		
                    this.pYear          = rs.getInt("PYEAR");		
                    this.pMonth         = rs.getInt("PMONTH");		
                    this.itemCode       = rs.getString("ITEMCODE");		
                    this.qty            = rs.getDouble("QTY");		
                    this.rate           = rs.getDouble("RATE");		
                    this.amount         = rs.getDouble("AMOUNT");		
                    this.vendId         = rs.getString("VENDID");		
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        String autoTransIdUi = "";
        
        if(this.id == null){
            autoTransIdUi  = gui.formCheckBox("autoTransId", "checked", "", "onchange = \"inventory.toggleTransId();\"", "", "")+ "<span class = \"fade\"><label for = \"autoTransId\"> No Auto</label></span>";
        }
        
        html += "<tr>";
	html += "<td width = \"22%\" nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "") + gui.formLabel("transId", "Transaction No") +"</td>";
        html += "<td>"+ gui.formInput("text", "transId", 15, this.id != null? this.transId: "" , "", "disabled") +" "+ autoTransIdUi +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Period Year")+"</td>";
        html += "<td>"+ gui.formSelect("pYear", "FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+system.getPeriodYear(), "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("pMonth", " Period Month")+"</td>";
        html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: system.getPeriodMonth(), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"pill.png", "", "") + gui.formLabel("item", " Item")+"</td>";
        html += "<td>"+gui.formSelect("item", "HMITEMS", "ITEMCODE", "ITEMNAME", "", "ISDRUG = 1", this.id != null? this.itemCode: "", "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td >"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "") + gui.formLabel("quantity", " Quantity")+"</td>";
	html += "<td>"+gui.formInput("text", "quantity", 15, this.id != null? ""+this.qty: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td >"+gui.formIcon(request.getContextPath(),"coins.png", "", "") + gui.formLabel("rate", " Cost")+"</td>";
	html += "<td>"+gui.formInput("text", "rate", 15, this.id != null? ""+this.rate: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td >"+gui.formIcon(request.getContextPath(),"coins.png", "", "") + gui.formLabel("amount", " Amount")+"</td>";
	html += "<td>"+gui.formInput("text", "amount", 15, this.id != null? ""+this.amount: "", "", "disabled")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(), "basket.png", "", "") + gui.formLabel("vendor", " Supplier")+"</td>";
        html += "<td>"+gui.formSelect("vendor", "HMVEN", "VENDID", "VENDNAME", "", "", this.id != null? this.vendId: "", "", false)+"</td>";
	html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public Object save(){
        
        JSONObject obj      = new JSONObject();
        System system       = new System();
        HttpSession session = request.getSession();
        Medical medical     = new Medical();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
	    String query = "";  
            
            this.amount = this.qty * this.rate;
            
            Double itemBalEffect = 0.0;
            
            if(this.id == null){
                Integer id = system.generateId(this.table, "ID");
                
                if(this.autoTransId != null && this.autoTransId == 1){
                    this.transId = system.getNextNo(this.table, "ID", "", "", 6);
                }
                
                query = "INSERT INTO "+ this.table +" "
                        + "(ID, TRANSID, PYEAR, PMONTH, "
                        + "ITEMCODE, QTY, RATE, AMOUNT, VENDID, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id +","
                        + "'"+ this.transId +"', "
                        + this.pYear +", "
                        + this.pMonth +", "
                        + "'"+ this.itemCode +"', "
                        + this.qty +", "
                        + this.rate +", "
                        + this.amount +", "
                        + "'"+ this.vendId +"', "
                        + "'"+ system.getLogUser(session) +"', "
                        + "'"+ system.getLogDate() +"', "
                        + "'"+ system.getLogTime() +"', "
                        + "'"+ system.getClientIpAdr(request) +"'"
                        + ")";
                
                obj.put("transId", this.transId);
                
            }else{
                
                Double qtyOld = Double.parseDouble(system.getOne(this.table, "QTY", "ID = "+ this.id));
                itemBalEffect = this.qty - qtyOld;
                query = "UPDATE "+ this.table +" SET "
                        + "ITEMCODE         = '"+ this.itemCode +"', "
                        + "QTY              = "+ this.qty +", "
                        + "RATE             = "+ this.rate +", "
                        + "AMOUNT           = "+ this.amount +", "
                        + "VENDID           = '"+ this.vendId +"', "
                        + "AUDITUSER        = '"+ system.getLogUser(session) +"', "
                        + "AUDITDATE        = '"+ system.getLogDate() +"', "
                        + "AUDITTIME        = '"+ system.getLogTime() +"', "
                        + "AUDITIPADR       = '"+ system.getClientIpAdr(request) +"' "

                        + "WHERE ID         = '"+ this.id +"'";
            }
            
            Integer saved  = stmt.executeUpdate(query);
            if(saved == 1){
                
                if(this.id == null){
                    medical.addItemBalance(this.itemCode, this.qty, session, request);
                }else{
                    if(itemBalEffect > 0){
                        medical.addItemBalance(this.itemCode, itemBalEffect, session, request);
                    }
                    else if(itemBalEffect < 0){
                        medical.reduceItemBalance(this.itemCode, (itemBalEffect * -1), session, request);
                    }
                }
                
                obj.put("amount", this.amount);
                
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
                
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
    
}

%>