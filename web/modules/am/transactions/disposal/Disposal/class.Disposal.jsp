<%@page import="org.json.JSONObject"%>
<%@page import="bean.am.AMDiBatch"%>
<%@page import="bean.am.AssetProfile"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Disposal{
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        String table            = comCode+".AMDIHDR";
    String view             = comCode+".VIEWAMDIHDR";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        
    String batchNo          = request.getParameter("batchNo");
    String entryNo          = request.getParameter("entryNoHd") != null && ! request.getParameter("entryNoHd").trim().equals("")? request.getParameter("entryNoHd"): null;
    String entryDesc        = request.getParameter("entryDesc");
    
    String entryDate        = request.getParameter("entryDate");
    Integer pYear           = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth          = request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    
    String assetNo          = this.id != null? request.getParameter("assetNoHd"): request.getParameter("assetNo");
    Double opc              = (request.getParameter("opc") != null && ! request.getParameter("opc").trim().equals(""))? Double.parseDouble(request.getParameter("opc")): 0.0;
    Double acmDepV          = request.getParameter("acmDepV") != null? Double.parseDouble(request.getParameter("acmDepV")): null;
    Double nbv              = request.getParameter("nbv") != null? Double.parseDouble(request.getParameter("nbv")): null;
    Double salv             = request.getParameter("salv") != null? Double.parseDouble(request.getParameter("salv")): null;
    String diClrAcc         = request.getParameter("diClrAcc");
    Double div              = request.getParameter("div") != null? Double.parseDouble(request.getParameter("div")): null;
    Double adic             = request.getParameter("adic") != null? Double.parseDouble(request.getParameter("adic")): null;
    
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
                    
                    String opc_ = sys.getOneAgt(""+this.comCode+".VIEWAMDIDTLS", "SUM", "OPC", "SM", "BATCHNO = '"+ batchNo+ "' AND ENTRYNO = '"+ entryNo+ "'");
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
        
        html += "<div style = \"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"disposal.save('batchNo entryDesc pYear pMonth assetNo opc acmDepV nbv salv diClrAcc div adic'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Disposal\'), 0, 625, 420, Array(true));";
        html += "</script>";
        
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
        
        html += "<div id = \"dvDiEntrySid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+this.sid, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"17%\">"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("batchNo", " Batch No.")+ "</td>";
        html += "<td width = \"33%\">"+ gui.formAutoComplete("batchNo", 13, this.id != null? this.batchNo: "", "disposal.searchBatch", "batchNoHd", this.id != null? this.batchNo: "")+ "</td>";
	
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
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("assetNo", " Asset No")+"</td>";
        html += "<td>"+ gui.formAutoComplete("assetNo", 13, "", "disposal.searchAsset", "assetNoHd", "")+ "</td>";
	
        html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Description</td>";
	html += "<td id = \"tdAstDesc\">&nbsp;</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"money.png", "", "")+ gui.formLabel("opc", " Original Purchase Cost")+"</td>";
	html += "<td >"+ gui.formInput("text", "opc", 15, "", "", "disabled")+ "</td>";
       
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("acmDepV", " Accm. Depreciation")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "acmDepV", 15, "", "", "disabled")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"coins.png", "", "")+ gui.formLabel("nbv", " NBV")+"</td>";
	html += "<td >"+ gui.formInput("text", "nbv", 15, "", "", "disabled")+ "</td>";
       
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("salv", " Salvage Value")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "salv", 15, "", "", "disabled")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("diClrAcc", " Clearing Account")+ "</td>";
        html += "<td colspan = \"3\">"+ gui.formSelect("diClrAcc", "GLACCOUNTS", "ACCOUNTCODE", "ACCOUNTNAME", "", "", "", "onchange = \"\"; style = \"width: 184px;\"; ", true)+ "<span class = \"fade\"> i.e Disposal</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("div", " Disposal Value")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "div", 15, "", "", "")+ "<span class = \"fade\"> </span></td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("adic", " Additional Cost")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "adic", 15, "", "", "")+ "<span class = \"fade\"> </span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvDiEntries\">"+ this.getDiEntries()+ "</div></td>";
        html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchBatch(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.batchNo = request.getParameter("batchNoHd");
        
        html += gui.getAutoColsSearch(this.comCode+".AMDIBATCHES", "BATCHNO, BATCHDESC", "", this.batchNo);
        
        return html;
    }
    
    public JSONObject getBatchProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.batchNo == null || this.batchNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            AMDiBatch aMDiBatch = new AMDiBatch(this.batchNo);
            
            obj.put("batchDesc", aMDiBatch.batchDesc);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Batch No '"+ aMDiBatch.batchNo+ "' successfully retrieved.");
        }
        
        return obj;
    }
    
    public String searchAsset(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.assetNo = request.getParameter("assetNoHd");
        
        html += gui.getAutoColsSearch(""+this.comCode+".AMASSETS", "ASSETNO, ASSETDESC", "", this.assetNo);
        
        return html;
    }
    
    public JSONObject getAssetProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.assetNo == null || this.assetNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            AssetProfile assetProfile = new AssetProfile(this.assetNo, this.comCode);
            
            obj.put("assetDesc", assetProfile.assetDesc);
            obj.put("opc", assetProfile.opc);
            obj.put("acmDepV", assetProfile.acmDep);
            obj.put("nbv", assetProfile.nbv);
            obj.put("salv", assetProfile.salv);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Asset No '"+assetProfile.assetNo+"' successfully retrieved.");
            
        }
        
        return obj;
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
                
                if(this.sid == null){

                    Integer sid = sys.generateId(""+this.comCode+".AMDIDTLS", "ID");
                    
                    query = "INSERT INTO "+this.comCode+".AMDIDTLS "
                            + "("
                            + "ID, BATCHNO, ENTRYNO, ASSETNO, "
                            + "OPC, ACMDEPV, NBV, SALV, DICLRACC, "
                            + "DIV, ADIC, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + sid+ ", "
                            + this.batchNo+ ", "
                            + this.entryNo+ ", "
                            + "'"+ this.assetNo+ "', "
                            + this.opc+ ", "
                            + this.acmDepV+ ", "
                            + this.nbv+ ", "
                            + this.salv+ ", "
                            + "'"+ this.diClrAcc+ "', "
                            + this.div+ ", "
                            + this.adic+ ", "
                            + "'"+ sys.getLogUser(session)+"', "
                            + "'"+ sys.getLogDate()+ "', "
                            + "'"+ sys.getLogTime()+ "', "
                            + "'"+ sys.getClientIpAdr(request)+ "'"
                            + ")";
                }else{
                    query = "UPDATE "+this.comCode+".AMDIDTLS SET "
                            + "ASSETNO          = '"+ this.assetNo+ "', "
                            + "OPC              = "+ this.opc+ ", "
                            + "ACMDEPV          = "+ this.acmDepV+ ", "
                            + "NBV              = "+ this.nbv+ ", "
                            + "SALV             = "+ this.salv+ ", "
                            + "DICLRACC         = '"+ this.diClrAcc+ "', "
                            + "DIV              = "+ this.div+ ", "
                            + "ADIC             = "+ this.adic+ ", "
                            + "AUDITUSER        = '"+ sys.getLogUser(session)+"', "
                            + "AUDITDATE        = '"+ sys.getLogDate()+ "', "
                            + "AUDITTIME        = '"+ sys.getLogTime()+ "', "
                            + "AUDITIPADR       = '"+ sys.getClientIpAdr(request)+ "'"
                            + "WHERE ID         = "+ this.sid;
                }
                
                saved = stmt.executeUpdate(query);

                if(saved == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");
                    
                    obj.put("entryNo", this.entryNo);
                    obj.put("assetNo", this.assetNo);
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
                    //has disposal no already
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
    
    public String getDiEntries(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(""+this.comCode+".VIEWAMDIDTLS", "BATCHNO = '"+ this.batchNo+ "' AND ENTRYNO = '"+ this.entryNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Asset No.</th>";
            html += "<th>Description</th>";
            html += "<th style = \"text-align: right;\">Disposal Value</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            Double sumDiv    = 0.0;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+this.comCode+".VIEWAMDIDTLS WHERE BATCHNO = '"+ this.batchNo+ "' AND ENTRYNO = '"+ this.entryNo+ "'";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    
                    String assetNo      = rs.getString("ASSETNO");
                    String assetDesc    = rs.getString("ASSETDESC");
                    
                    Double div          = rs.getDouble("DIV");
                    
                    String editLink     = gui.formHref("onclick = \"disposal.editDiDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"disposal.purge("+ id +", '"+ assetDesc +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    
                    String opts = "";
                    opts = editLink+ " || "+ removeLink;
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ assetNo+ "</td>";
                    html += "<td>"+ assetDesc+ "</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(div.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    sumDiv   = sumDiv + div;

                    count++;
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"3\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumDiv.toString()) +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No disposal items record found.";
        }
        
        return html;
    }
    
    public JSONObject editDiDtls() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists(""+this.comCode+".AMDIDTLS", "ID = "+ this.sid +"")){
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+this.comCode+".VIEWAMDIDTLS WHERE ID = "+ this.sid +"";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String assetNo      = rs.getString("ASSETNO");
                    String assetDesc    = rs.getString("ASSETDESC");
                    String opc          = rs.getString("OPC");
                    String acmDepV      = rs.getString("ACMDEPV");
                    String nbv          = rs.getString("NBV");
                    String salv         = rs.getString("SALV");
                    String diClrAcc     = rs.getString("DICLRACC");
                    String div          = rs.getString("DIV");
                    String adic         = rs.getString("ADIC");
                    
                    
                    obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                    obj.put("assetNo", assetNo);
                    obj.put("assetDesc", assetDesc);
                    obj.put("opc", opc);
                    obj.put("acmDepV", acmDepV);
                    obj.put("nbv", nbv);
                    obj.put("salv", salv);
                    obj.put("diClrAcc", diClrAcc);
                    obj.put("div", div);
                    obj.put("adic", adic);
                    
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
                String query = "DELETE FROM "+this.comCode+".AMDIDTLS WHERE ID = "+ this.id;
            
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