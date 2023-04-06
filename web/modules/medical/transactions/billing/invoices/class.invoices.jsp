<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.medical.Medical"%>
<%@page import="com.qset.medical.MedInvHeader"%>
<%@page import="com.qset.finance.FinConfig"%>
<%@page import="com.qset.medical.HMStaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.medical.PatientProfile"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class Invoices{
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
    String table        = comCode+".HMINVSDTLS";
    String view         = comCode+".VIEWHMREGISTRATION";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String regNo        = request.getParameter("regNo");
    String regType      = request.getParameter("regType");
    String ptNo         = request.getParameter("ptNo");
    String drNo         = request.getParameter("drNo");
    String nrNo         = request.getParameter("nrNo");
    String invNo        = request.getParameter("invNo");
    Integer pYear       = request.getParameter("pYear") != null && !request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth      = request.getParameter("pMonth") != null && !request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    
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
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getRegistrationTab() +"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divInvoices\">"+this.getInvoiceTab()+"</div></div>";
        
        html += "</div>";
        
	html += "<div style = \"padding-left: 10px; padding-top: 40px; border: 0;\" >";
        
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"module.getGrid();\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Registration\', \'Invoice\'), 0, 625, 350, Array(false, false));";
        html += "</script>";
        
        return html;
    }
    
    public String getRegistrationTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        String drNo = "";
        String drName = "";
        String nrNo = "";
        String nrName = "";
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ this.view +" WHERE ID = "+this.id;
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.regNo      = rs.getString("REGNO");		
                this.regType    = rs.getString("REGTYPE");		
                this.ptNo       = rs.getString("PTNO");		
                drNo            = rs.getString("DRNO");		
                drName          = rs.getString("DRNAME");		
                nrNo            = rs.getString("NRNO");		
                nrName          = rs.getString("NRNAME");
                this.pYear      = rs.getInt("PYEAR");
                this.pMonth     = rs.getInt("PMONTH");
                
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
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"22%\" class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" Registration No.</td>";
	html += "<td >"+this.regNo + gui.formInput("hidden", "regNo", 15, this.regNo, "", "")+"</td>";
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
        
	html += "<tr>";
        html += "<td class = \"bold\">"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ " Period Year</td>";
	html += "<td>"+ this.pYear +"</td>";
	html += "</tr>";
        
	html += "<tr>";
        html += "<td class = \"bold\">"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ " Period Month</td>";
	html += "<td>"+ this.pMonth +"</td>";
	html += "</tr>";

        html += "</table>";
        
        return html;
    }
    
    public String getInvoiceTab(){
        String html = "";
        
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        if(sys.recordExists("VIEWHMINVSHEADER", "REGNO = '"+ this.regNo +"'")){
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Invoice No</th>";
            html += "<th>Invoice Date</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            Double total = 0.00;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM VIEWHMINVSHEADER WHERE REGNO = '"+ this.regNo +"' ORDER BY INVNO DESC ";
                ResultSet rs = stmt.executeQuery(query);
                
                Integer count  = 1;
                
                while(rs.next()){
                    String invNo            = rs.getString("INVNO");
                    String invDate          = rs.getString("INVDATE");
                    
                    String invDateLbl       = invDate;
                    
                    Double amount = 0.00;
                    
//                    String amountInvDtls_    = sys.getOne("VIEWHMINVSDETAILS", "SUM(AMOUNT)", "INVNO = '"+ invNo +"'");
                    String amountInvDtls_    = sys.getOneAgt("VIEWHMINVSDETAILS", "SUM", "AMOUNT", "SM", "INVNO = '"+ invNo +"'");
                    
                    if(amountInvDtls_ != null){
                        amount = Double.parseDouble(amountInvDtls_);
                    }
                    
                    String editLink         = gui.formHref("onclick = \"invoice.editInvoice('"+ invNo +"');\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String printLink        = gui.formHref("onclick = \"invoice.printInvoice('"+ invNo +"');\"", request.getContextPath(), "", "print", "print", "", "");
                    
                    String opts = editLink +" || "+ printLink;
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ invNo +"</td>";
                    html += "<td>"+ invDateLbl +"</td>";
                    html += "<td style = \"text-align: right;\">"+ amount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    total = total + amount;
                    
                    count++;
                }
                
            }catch(Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"3\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ total +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
        }else{
           html += "No invoice records found.";
        }
                
        return html;
    }
    
    public String editInvoice(){
        String html = "";
        
        Gui gui = new Gui();
        
        MedInvHeader medInvHeader = new MedInvHeader(this.invNo);
        
        html += gui.formInput("hidden", "invType", 15, medInvHeader.invType, "", "");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"22%\" class = \"bold\" nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "") + " Invoice No.</td>";
	html += "<td >"+ this.invNo + gui.formInput("hidden", "invNo", 15, this.invNo, "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "") + " Date</td>";
        html += "<td >"+ medInvHeader.invDate + gui.formInput("hidden", "invDate", 15, medInvHeader.invDate, "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+ gui.formIcon(request.getContextPath(),"coins.png", "", "") + " Amount</td>";
	html += "<td id = \"tdAmount\">"+ medInvHeader.amount +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td class = \"bold\">Invoice Details</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td ><div id = \"divInvDtls\">"+this.getInvoiceDtls()+"</div></td>";
	html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public String getInvoiceDtls(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        MedInvHeader medInvHeader = new MedInvHeader(this.invNo);
        
        if(sys.recordExists("VIEWHMINVSDETAILS", "REGNO = '"+ this.regNo +"' AND INVNO = '"+ this.invNo +"'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Item</th>";
            html += "<th>Quantity</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "<th style = \"text-align: center;\">Options</th>";
            html += "</tr>";
            
            Double total   = 0.00;
            
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM VIEWHMINVSDETAILS WHERE REGNO = '"+ this.regNo +"' AND INVNO = '"+ this.invNo +"'";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String qty          = rs.getString("QTY");
                    String itemName     = rs.getString("ITEMNAME");
                    Double amount       = rs.getDouble("AMOUNT");
                    
                    String opts         = "";
                    
                    String editLink     = gui.formHref("onclick = \"invoice.editInvItem("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String delLink      = gui.formHref("onclick = \"invoice.delInvItem("+ id +", '"+ itemName +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    String lockLink     = gui.formIcon(request.getContextPath(), "lock.png", "", "");
                    
                    if(medInvHeader.paid){
                        opts = lockLink;
                    }else{
                        opts = editLink +" || "+ delLink;
                    }
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ itemName +"</td>";
                    html += "<td>"+ qty +"</td>";
                    html += "<td style = \"text-align: right;\">"+ amount +"</td>";
                    html += "<td style = \"text-align: center;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    total = total + amount;

                    count++;
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"3\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ total +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No invoice items record found.";
        }
        
        if(! medInvHeader.paid){
            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"invoice.addInvItem();\"", "");
        }
        
	html += gui.formButton(request.getContextPath(), "button", "btnCancelInv", "Back", "arrow-left.png", "onclick = \"invoice.getInvoices();\"", "");
        
        return html;
    }
    
    public String addInvItem(){
        String html = "";
        
        Gui gui = new Gui();
        
        String rid  = request.getParameter("rid");
        
        String itemCode = "";
        String qty      = "";
        
        if(rid != null){
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.table +" WHERE ID = "+ rid;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    itemCode    = rs.getString("ITEMCODE");		
                    qty         = rs.getString("QTY");		
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += gui.formInput("hidden", "rid", 15, rid, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
        html += "<td width = \"22%\" class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("item", "Item")+"</td>";
	html += "<td>"+ gui.formSelect("item", "HMITEMS", "ITEMCODE", "ITEMNAME", "", "", itemCode, "", false) +"</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+gui.formLabel("quantity", "Quantity")+"</td>";
	html += "<td>"+ gui.formInput("text", "quantity", 15, qty, "", "") +"</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"invoice.save('item quantity')\"", "");
        html += gui.formButton(request.getContextPath(), "button", "btnCancelInv", "Back", "arrow-left.png", "onclick = \"invoice.editInvoice('"+ invNo +"');\"", "");
	html += "</td>";
	html += "</tr>";
        
          
        html += "</table>";
        
        return html;
    }
    
    public JSONObject save() throws Exception{
        
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        
        Medical medical = new Medical(this.comCode);
        HttpSession session = request.getSession();
        
        String rid      = request.getParameter("rid");
        String itemCode = request.getParameter("item");
        String invType  = request.getParameter("invType");
        Double qty      = request.getParameter("quantity") != null? Double.parseDouble(request.getParameter("quantity")): 0.00;
        
        Integer saved = 0;
        
        try{
            if(rid == null){
                if(! sys.recordExists("HMINVSDTLS", "INVNO = '"+ this.invNo +"' AND ITEMCODE = '"+ itemCode +"'")){
                    saved = medical.createInvDtls(this.regNo, invType, itemCode, qty, session, request);
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "This entry already made.");
                }
            }else{
                sys.delete("HMINVSDTLS", "INVNO = '"+ this.invNo +"' AND ITEMCODE = '"+ itemCode +"'");
                saved = medical.createInvDtls(this.regNo, invType, itemCode, qty, session, request);
            }
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made."); 
            }
            
        }catch(Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public String getInvoices(){
        String html = "";
        
        html += this.getInvoiceTab();
        
        return html;
    }
    
    public JSONObject delInvItem() throws Exception{
        JSONObject obj = new JSONObject();
         
        String rid      = request.getParameter("rid");
         
        try{

           Connection conn = ConnectionProvider.getConnection();
           Statement stmt = conn.createStatement();

           if(rid != null){
               String query = "DELETE FROM "+this.table+" WHERE ID = "+ rid;

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
    
        
}

%>