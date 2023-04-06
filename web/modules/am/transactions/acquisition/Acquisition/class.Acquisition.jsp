<%@page import="org.json.JSONObject"%>
<%@page import="com.qset.ap.APSupplierProfile"%>
<%@page import="com.qset.am.AmAqBatch"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.finance.VAT"%>
<%@page import="com.qset.finance.FinConfig"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class Acquisition{
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        String table            = comCode+".AMAQHDR";
    String view             = comCode+".VIEWAMAQHDR";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        
    String batchNo          = request.getParameter("batchNo");
    String entryNo          = request.getParameter("entryNoHd") != null && ! request.getParameter("entryNoHd").trim().equals("")? request.getParameter("entryNoHd"): null;
    String entryDesc        = request.getParameter("entryDesc");
    
    String entryDate        = request.getParameter("entryDate");
    Integer pYear           = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth          = request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    
    String aqNo             = request.getParameter("aqNoHd") != null && ! request.getParameter("aqNoHd").trim().equals("")? request.getParameter("aqNoHd"): null;
    
    String aqDesc           = request.getParameter("aqDescription");
    String catCode          = request.getParameter("category");
    String aqCode           = request.getParameter("aqCode");
    String supplierNo       = request.getParameter("supplierNo");
    String poNo             = request.getParameter("poNo");
    String serialNo         = request.getParameter("serialNo");
    
    String depCode          = request.getParameter("depMethod");
    String depStartDate     = request.getParameter("depStartDate");
    Double estLife         = request.getParameter("estLife") != null? Double.parseDouble(request.getParameter("estLife")): null;
    String estExpDate       = request.getParameter("estExpDate");
    
    Double depRate          = (request.getParameter("depRate") != null && ! request.getParameter("depRate").trim().equals(""))? Double.parseDouble(request.getParameter("depRate")): 0.0;
    Double opc              = (request.getParameter("opc") != null && ! request.getParameter("opc").trim().equals(""))? Double.parseDouble(request.getParameter("opc")): 0.0;
    
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

                        list.add("BATCHNO");
                        list.add("BATCHDESC");
                        list.add("ENTRYNO");
                        list.add("ENTRYDESC");
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
                html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                html += "<table class = \"grid\" width=\"100%\" cellpadding=\"1\" cellspacing=\"0\" border=\"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Batch No</th>";
                html += "<th>Description</th>";
                html += "<th>Entry No</th>";
                html += "<th>Description</th>";
                html += "<th>Batch Total</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id              = rs.getInt("ID");
                    Integer batchNo         = rs.getInt("BATCHNO");
                    String batchDesc        = rs.getString("BATCHDESC");
                    String entryNo          = rs.getString("ENTRYNO");
                    String entryDesc        = rs.getString("ENTRYDESC");
                    
                    String opc_ = sys.getOneAgt(""+this.comCode+".VIEWAMAQDTLS", "SUM", "OPC", "SM", "BATCHNO = '"+ batchNo+ "' AND ENTRYNO = '"+ entryNo+ "'");
                    opc_ = (opc_ != null && ! opc_.trim().equals(""))? opc_: "0";
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ batchNo+ "</td>";
                    html += "<td>"+ batchDesc+ "</td>";
                    html += "<td>"+ entryNo+ "</td>";
                    html += "<td>"+ entryDesc+ "</td>";
                    html += "<td>"+ sys.numberFormat(opc_)+ "</td>";
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
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getAcqTab()+ "</div>";
        html += "</div>";
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Acquisition\'), 0, 625, 145, Array(true));";
        html += "</script>";
        
        html += "<div style = \"padding-top: 20px; border: 0;\">&nbsp;</div>";
        
        html += "<div id = \"dhtmlgoodies_tabView2\">";
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getMasterTab()+ "</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getBookTab()+ "</div>";
        html += "</div>";
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView2\', Array(\'Master\', \'Book\'), 0, 625, 135, Array(false, true));";
        html += "</script>";
        
        html += "<div style = \"padding-top: 22px; border: 0;\">&nbsp;</div>";
        
        html += "<div id = \"dvAqEntries\">"+ this.getAqEntries()+ "</div>";
        
        html += "<div style = \"padding-left: 10px; padding-top: 5px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"acquisition.save('batchNo entryDesc pYear pMonth aqDescription category aqCode supplierNo depMethod depRate depStartDate estLife estExpDate opc'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        return html;
    }
    
    public String getAcqTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        String batchDesc    = "";
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.view+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.batchNo    = rs.getString("BATCHNO");		
                    batchDesc       = rs.getString("BATCHDESC");		
                    this.entryNo    = rs.getString("ENTRYNO");
                    this.entryDesc  = rs.getString("ENTRYDESC");
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
        
        html += "<div id = \"dvAqEntrySid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+this.sid, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"17%\">"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("batchNo", " Batch No.")+ "</td>";
        html += "<td width = \"33%\">"+ gui.formAutoComplete("batchNo", 13, this.id != null? this.batchNo: "", "acquisition.searchBatch", "batchNoHd", this.id != null? this.batchNo: "")+ "</td>";
	
	html += "<td width = \"17%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Description</td>";
	html += "<td id = \"tdBatchDesc\">"+ batchDesc+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("entryNo", " Entry No.")+"</td>";
	html += "<td>"+ gui.formInput("text", "entryNo", 15, this.id != null? this.entryNo: "", "", "disabled")+ gui.formInput("hidden", "entryNoHd", 15, this.id != null? this.entryNo: "", "", "")+ "</td>";
        
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("entryDate", " Date")+"</td>";
        html += "<td>"+ gui.formDateTime(request.getContextPath(), "entryDate", 10, this.id != null? this.entryDate: defaultDate, false, "")+"</td>";
	html += "</tr>";
              
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"package.png", "", "")+ gui.formLabel("entryDesc", " Description")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "entryDesc", 25, this.id != null? this.entryDesc: "", "", "")+"</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
        html += "<td>"+ gui.formSelect("pYear", this.comCode+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+sys.getPeriodYear(this.comCode), "", false)+"</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: sys.getPeriodMonth(this.comCode), "", true)+ "</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchBatch(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.batchNo = request.getParameter("batchNoHd");
        
        html += gui.getAutoColsSearch(this.comCode+".AMAQBATCHES", "BATCHNO, BATCHDESC", "", this.batchNo);
        
        return html;
    }
    
    public JSONObject getBatchProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.batchNo == null || this.batchNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            AmAqBatch amAqBatch = new AmAqBatch(this.batchNo);
            
            obj.put("batchDesc", amAqBatch.batchDesc);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Batch No '"+ amAqBatch.batchNo+ "' successfully retrieved.");
        }
        
        return obj;
    }
    
    public String searchSupplier(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.supplierNo = request.getParameter("supplierNoHd");
        
        html += gui.getAutoColsSearch(this.comCode+".APSUPPLIERS", "SUPPLIERNO, FULLNAME", "", this.supplierNo);
        
        return html;
    }
    
    public JSONObject getSupplierProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.supplierNo == null || this.supplierNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            APSupplierProfile aPSupplierProfile = new APSupplierProfile(this.supplierNo, this.comCode);
            
            obj.put("fullName", aPSupplierProfile.fullName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Supplier No '"+aPSupplierProfile.supplierNo+"' successfully retrieved.");
        }
        
        return obj;
    }
    
    public String getMasterTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("aqNo", " Acquisition No.")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "aqNo", 15, "", "", "disabled")+ gui.formInput("hidden", "aqNoHd", 15, "", "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"package.png", "", "")+ gui.formLabel("aqDescription", " Description")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "aqDescription", 25, "", "", "")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"17%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("category", " Category")+ "</td>";
        html += "<td width = \"33%\">"+ gui.formSelect("category", this.comCode+".AMCATS", "CATCODE", "CATNAME", "", "", "", "onchange = \"\"", false)+ "</td>";
	
	html += "<td width = \"17%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("aqCode", " Acquisition Code")+ "</td>";
	html += "<td>"+ gui.formSelect("aqCode", this.comCode+".AMAQCODES", "AQCODE", "AQNAME", "", "", "", "onchange = \"\" style = \"width: 160px;\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("supplierNo", " Supplier No.")+ "</td>";
        html += "<td >"+ gui.formAutoComplete("supplierNo", 13, "", "acquisition.searchSupplier", "supplierNoHd", "")+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdFullName\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+ gui.formLabel("poNo", " PO No.")+"</td>";
	html += "<td >"+ gui.formInput("text", "poNo", 15, "", "", "")+ "</td>";
        
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"pencil.png", "", "")+ gui.formLabel("serialNo", " Serial No.")+"</td>";
	html += "<td >"+ gui.formInput("text", "serialNo", 15, "", "", "")+ "</td>";
        html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public String getBookTab(){
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
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"17%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("depMethod", " Depreciation Method")+ "</td>";
        html += "<td width = \"33%\">"+ gui.formSelect("depMethod", this.comCode+".AMDEPMETHODS", "DEPCODE", "DEPNAME", "", "", "", "onchange = \"\" style = \"width: 160px;\"", false)+ "</td>";
	
	html += "<td width = \"17%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("depRate", " Depreciation Rate")+ "</td>";
	html += "<td>"+ gui.formInput("text", "depRate", 15, "", "", "")+ "<span class = \"fade\"> %</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("depStartDate", " Start Date")+ "</td>";
        html += "<td >"+ gui.formDateTime(request.getContextPath(), "depStartDate", 10, defaultDate, false, "")+ "</td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("estLife", " Estimated Life")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "estLife", 15, "", "", "")+ "<span class = \"fade\"> i.e years</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("estExpDate", " End Date")+ "</td>";
        html += "<td colspan = \"3\">"+ gui.formDateTime(request.getContextPath(), "estExpDate", 10, "", false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"money.png", "", "")+ gui.formLabel("opc", " Original Purchase Cost")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "opc", 15, "", "", "")+ "</td>";
        html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public JSONObject save() throws Exception{
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
                
                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                java.util.Date depStartDate = originalFormat.parse(this.depStartDate);
                this.depStartDate = targetFormat.format(depStartDate);
                
                java.util.Date estExpDate = originalFormat.parse(this.estExpDate);
                this.estExpDate = targetFormat.format(estExpDate);
                
                if(this.sid == null){

                    Integer sid = sys.generateId(""+this.comCode+".AMAQDTLS", "ID");
                    
                    this.aqNo = sys.getNextNo("AMAQDTLS", "ID", "", "AQ", 7);
                    
                    query = "INSERT INTO "+this.comCode+".AMAQDTLS "
                            + "("
                            + "ID, BATCHNO, ENTRYNO, AQNO, AQDESC, "
                            + "CATCODE, AQCODE, SUPPLIERNO, PONO, SERIALNO, "
                            + "DEPCODE, DEPSTARTDATE, ESTLIFE, ESTEXPDATE, "
                            + "DEPRATE, OPC, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + sid+ ", "
                            + this.batchNo+ ", "
                            + this.entryNo+ ", "
                            + "'"+ this.aqNo+ "', "
                            + "'"+ this.aqDesc+ "', "
                            + "'"+ this.catCode+ "', "
                            + "'"+ this.aqCode+ "', "
                            + "'"+ this.supplierNo+ "', "
                            + "'"+ this.poNo+ "', "
                            + "'"+ this.serialNo+ "', "
                            + "'"+ this.depCode+ "', "
                            + "'"+ this.depStartDate+ "', "
                            + this.estLife+ ", "
                            + "'"+ this.estExpDate+ "', "
                            + this.depRate+ ", "
                            + this.opc+ ", "
                            + "'"+ sys.getLogUser(session)+"', "
                            + "'"+ sys.getLogDate()+ "', "
                            + "'"+ sys.getLogTime()+ "', "
                            + "'"+ sys.getClientIpAdr(request)+ "'"
                            + ")";
                }else{
                    query = "UPDATE "+this.comCode+".AMAQDTLS SET "
                            + "AQDESC           = '"+ this.aqDesc+ "', "
                            + "CATCODE          = '"+ this.catCode+ "', "
                            + "AQCODE           = '"+ this.aqCode+ "', "
                            + "SUPPLIERNO       = '"+ this.supplierNo+ "', "
                            + "PONO             = '"+ this.poNo+ "', "
                            + "SERIALNO         = '"+ this.serialNo+ "', "
                            + "DEPCODE          = '"+ this.depCode+ "', "
                            + "DEPSTARTDATE     = '"+ this.depStartDate+ "', "
                            + "ESTLIFE          = "+ this.estLife+ ", "
                            + "ESTEXPDATE       = '"+ this.estExpDate+ "', "
                            + "DEPRATE          = "+ this.depRate+ ", "
                            + "OPC              = "+ this.opc+ ", "
                            + "AUDITUSER        = '"+ sys.getLogUser(session)+"', "
                            + "AUDITDATE        = '"+ sys.getLogDate()+ "', "
                            + "AUDITTIME        = '"+ sys.getLogTime()+ "', "
                            + "AUDITIPADR       = '"+ sys.getClientIpAdr(request)+ "'"
                            + "WHERE ID         = "+this.sid;
                }
                
                saved = stmt.executeUpdate(query);

                if(saved == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");
                    
                    obj.put("entryNo", this.entryNo);
                    obj.put("aqNo", this.aqNo);
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
    
    public String getEntryNo(){
        Sys sys = new Sys();
        
        HttpSession session = request.getSession();
        
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
                        + "ENTRYDATE, PYEAR, PMONTH,"
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ", "
                        + this.batchNo+ ", "
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

                Integer aqHdrCreated = stmt.executeUpdate(query);
                
                if(aqHdrCreated == 1){
                    //has acquisition no already
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
    
    public String getAqEntries(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(""+this.comCode+".VIEWAMAQDTLS", "BATCHNO = '"+ this.batchNo+ "' AND ENTRYNO = '"+ this.entryNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Document</th>";
            html += "<th>Supplier</th>";
            html += "<th style = \"text-align: right;\">Original Purchase Cost</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            Double sumOpc    = 0.0;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+this.comCode+".VIEWAMAQDTLS WHERE BATCHNO = '"+ this.batchNo+ "' AND ENTRYNO = '"+ this.entryNo+ "'";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    
                    String aqNo         = rs.getString("AQNO");
                    String aqDesc       = rs.getString("AQDESC");
                    
                    String supplierNo   = rs.getString("SUPPLIERNO");
                    String fullName     = rs.getString("FULLNAME");
                    
                    Double opc          = rs.getDouble("OPC");
                    
                    String editLink     = gui.formHref("onclick = \"acquisition.editAqDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"acquisition.purge("+ id +", '"+ aqDesc +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    
                    String opts = "";
                    opts = editLink+ " || "+ removeLink;
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ aqNo+ " - "+ aqDesc+ "</td>";
                    html += "<td>"+ supplierNo+ " - "+ fullName+ "</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(opc.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    sumOpc   = sumOpc + opc;

                    count++;
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"3\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumOpc.toString()) +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No acquisition items record found.";
        }
        
        return html;
    }
    
    public JSONObject editAqDtls() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists(""+this.comCode+".AMAQDTLS", "ID = "+ this.sid +"")){
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+this.comCode+".VIEWAMAQDTLS WHERE ID = "+ this.sid +"";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String aqNo         = rs.getString("AQNO");
                    String aqDesc       = rs.getString("AQDESC");
                    String catCode      = rs.getString("CATCODE");
                    String aqCode       = rs.getString("AQCODE");
                    String supplierNo   = rs.getString("SUPPLIERNO");
                    String fullName     = rs.getString("FULLNAME");
                    String poNo         = rs.getString("PONO");
                    String serialNo     = rs.getString("SERIALNO");
                    String depCode      = rs.getString("DEPCODE");
                    String depStartDate = rs.getString("DEPSTARTDATE");
                    String estLife      = rs.getString("ESTLIFE");
                    String estExpDate   = rs.getString("ESTEXPDATE");
                    String depRate      = rs.getString("DEPRATE");
                    String opc          = rs.getString("OPC");
                    
                    java.util.Date depStartDate_ = originalFormat.parse(depStartDate);
                    depStartDate = targetFormat.format(depStartDate_);
                    
                    java.util.Date estExpDate_ = originalFormat.parse(estExpDate);
                    estExpDate = targetFormat.format(estExpDate_);
                    
                    obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                    obj.put("aqNo", aqNo);
                    obj.put("aqDescription", aqDesc);
                    obj.put("category", catCode);
                    obj.put("aqCode", aqCode);
                    obj.put("supplierNo", supplierNo);
                    obj.put("fullName", fullName);
                    obj.put("poNo", poNo);
                    obj.put("serialNo", serialNo);
                    obj.put("depMethod", depCode);
                    obj.put("depStartDate", depStartDate);
                    obj.put("estLife", estLife);
                    obj.put("estExpDate", estExpDate);
                    obj.put("depRate", depRate);
                    obj.put("opc", opc);
                    
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
    
    public JSONObject purge() throws Exception{
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+this.comCode+".AMAQDTLS WHERE ID = "+ this.id;
            
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