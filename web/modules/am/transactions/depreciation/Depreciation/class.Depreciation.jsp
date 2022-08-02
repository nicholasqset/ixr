<%@page import="bean.am.AssetDep"%>
<%@page import="bean.am.AssetProfile"%>
<%@page import="bean.am.AmDpBatch"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.finance.VAT"%>
<%@page import="bean.finance.FinConfig"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Depreciation{
    String table            = "AMDPHDR";
    String view             = "VIEWAMDPHDR";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        
    String batchNo          = request.getParameter("batchNo");
    String entryNo          = request.getParameter("entryNoHd") != null && ! request.getParameter("entryNoHd").trim().equals("")? request.getParameter("entryNoHd"): null;
    String entryDesc        = request.getParameter("entryDesc");
    
    String entryDate        = request.getParameter("entryDate");
    Integer pYear           = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth          = request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    
    String assetNo          = this.id != null? request.getParameter("assetNoHd"): request.getParameter("assetNo");
    Double opc              = (request.getParameter("opc") != null && ! request.getParameter("opc").trim().equals(""))? Double.parseDouble(request.getParameter("opc")): 0.0;
    Double nbvS             = (request.getParameter("nbvS") != null && ! request.getParameter("nbvS").trim().equals(""))? Double.parseDouble(request.getParameter("nbvS")): 0.0;
    String depCode          = request.getParameter("depMethod");
    Double depRate          = (request.getParameter("depRate") != null && ! request.getParameter("depRate").trim().equals(""))? Double.parseDouble(request.getParameter("depRate")): 0.0;
    Double estLife          = request.getParameter("estLife") != null? Double.parseDouble(request.getParameter("estLife")): null;
    Double depV             = request.getParameter("depV") != null? Double.parseDouble(request.getParameter("depV")): null;
    Double acmDepV          = request.getParameter("acmDepV") != null? Double.parseDouble(request.getParameter("acmDepV")): null;
    Double nbvE             = request.getParameter("nbvE") != null? Double.parseDouble(request.getParameter("nbvE")): null;
    Double salV             = request.getParameter("salV") != null? Double.parseDouble(request.getParameter("salV")): null;
    
    Integer sid             = request.getParameter("sid") != null? Integer.parseInt(request.getParameter("sid")): null;
    
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
                    
                    String depV_ = system.getOneAgt("VIEWAMDPDTLS", "SUM", "DEPV", "SM", "BATCHNO = '"+ batchNo+ "' AND ENTRYNO = '"+ entryNo+ "'");
                    depV_ = (depV_ != null && ! depV_.trim().equals(""))? depV_: "0";
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ batchNo+ "</td>";
                    html += "<td>"+ batchDesc+ "</td>";
                    html += "<td>"+ entryNo+ "</td>";
                    html += "<td>"+ entryDesc+ "</td>";
                    html += "<td>"+ system.numberFormat(depV_)+ "</td>";
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
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getDepTab()+ "</div>";
        html += "</div>";
        
        html += "<div style = \"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"depreciation.save('batchNo entryDesc pYear pMonth opc nbvS depMethod depRate estLife depV acmDepV nbvE salV '); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Depreciation\'), 0, 625, 420, Array(true));";
        html += "</script>";
        
        return html;
    }
    
    public String getDepTab(){
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
        
        String defaultDate = system.getLogDate();
        
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
        
        html += "<div id = \"dvDpEntrySid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+this.sid, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"17%\">"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("batchNo", " Batch No.")+ "</td>";
        html += "<td width = \"33%\">"+ gui.formAutoComplete("batchNo", 13, this.id != null? this.batchNo: "", "depreciation.searchBatch", "batchNoHd", this.id != null? this.batchNo: "")+ "</td>";
	
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
        html += "<td>"+ gui.formSelect("pYear", "FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+system.getPeriodYear(), "", false)+"</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: system.getPeriodMonth(), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("assetNo", "Asset No")+"</td>";
        html += "<td>"+ gui.formAutoComplete("assetNo", 13, "", "depreciation.searchAsset", "assetNoHd", "")+ "</td>";
	
        html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Description</td>";
	html += "<td id = \"tdAstDesc\">&nbsp;</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"money.png", "", "")+ gui.formLabel("opc", " Original Purchase Cost")+"</td>";
	html += "<td >"+ gui.formInput("text", "opc", 15, "", "", "disabled")+ "</td>";
       
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"coins.png", "", "")+ gui.formLabel("nbvS", " Start NBV")+"</td>";
	html += "<td >"+ gui.formInput("text", "nbvS", 15, "", "", "disabled")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("depMethod", " Depreciation Method")+ "</td>";
        html += "<td colspan = \"3\">"+ gui.formSelect("depMethod", "AMDEPMETHODS", "DEPCODE", "DEPNAME", "", "", "", "onchange = \"\"; style = \"\"; disabled", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("depRate", " Depreciation Rate")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "depRate", 15, "", "", "disabled")+ "<span class = \"fade\"> </span></td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("estLife", " Estimated Life")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "estLife", 15, "", "", "disabled")+ "<span class = \"fade\"> </span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("depV", " Depreciation Value")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "depV", 15, "", "", "disabled")+ "</td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("acmDepV", " Accumulated Depreciation")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "acmDepV", 15, "", "", "disabled")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("nbvE", " Ending NBV")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "nbvE", 15, "", "", "disabled")+ "</td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("salV", " Salvage Value")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "salV", 15, "", "", "disabled")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvDpEntries\">"+ this.getDpEntries()+ "</div></td>";
        html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchBatch(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.batchNo = request.getParameter("batchNoHd");
        
        html += gui.getAutoColsSearch("AMDPBATCHES", "BATCHNO, BATCHDESC", "", this.batchNo);
        
        return html;
    }
    
    public Object getBatchProfile(){
        JSONObject obj = new JSONObject();
        
        if(this.batchNo == null || this.batchNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            AmDpBatch amDpBatch = new AmDpBatch(this.batchNo);
            
            obj.put("batchDesc", amDpBatch.batchDesc);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Batch No '"+ amDpBatch.batchNo+ "' successfully retrieved.");
        }
        
        return obj;
    }
    
    public String searchAsset(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.assetNo = request.getParameter("assetNoHd");
        
        html += gui.getAutoColsSearch("AMASSETS", "ASSETNO, ASSETDESC", "", this.assetNo);
        
        return html;
    }
    
    public Object getAssetProfile(){
        JSONObject obj = new JSONObject();
        
        if(this.assetNo == null || this.assetNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            AssetProfile assetProfile = new AssetProfile(this.assetNo);
            AssetDep assetDep = new AssetDep(this.assetNo);
            
            obj.put("assetDesc", assetProfile.assetDesc);
            obj.put("opc", assetProfile.opc);
            obj.put("nbvS", assetProfile.nbv);
            obj.put("depMethod", assetProfile.depCode);
            obj.put("depRate", assetProfile.depRate);
            obj.put("estLife", assetProfile.estLife);
            obj.put("depV", assetDep.depV);
            obj.put("acmDepV", assetDep.acmDepV);
            obj.put("nbvE", assetDep.nbvE);
            obj.put("salV", assetProfile.salv);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Asset No '"+assetProfile.assetNo+"' successfully retrieved.");
            
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
                
                if(this.sid == null){
                    Integer sid = system.generateId("AMDPDTLS", "ID");
                    
                    query = "INSERT INTO AMDPDTLS "
                            + "("
                            + "ID, BATCHNO, ENTRYNO, ASSETNO, "
                            + "OPC, NBVS, DEPCODE, DEPRATE, ESTLIFE, "
                            + "DEPV, ACMDEPV, NBVE, SALV, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + sid+ ", "
                            + this.batchNo+ ", "
                            + this.entryNo+ ", "
                            + "'"+ this.assetNo+ "', "
                            + this.opc+ ", "
                            + this.nbvS+ ", "
                            + "'"+ this.depCode+ "', "
                            + this.depRate+ ", "
                            + this.estLife+ ", "
                            + this.depV+ ", "
                            + this.acmDepV+ ", "
                            + this.nbvE+ ", "
                            + this.salV+ ", "
                            + "'"+ system.getLogUser(session)+"', "
                            + "'"+ system.getLogDate()+ "', "
                            + "'"+ system.getLogTime()+ "', "
                            + "'"+ system.getClientIpAdr(request)+ "'"
                            + ")";
                }else{
                    query = "UPDATE AMDPDTLS SET "
                            + "ASSETNO          = '"+ this.assetNo+ "', "
                            + "OPC              = "+ this.opc+ ", "
                            + "NBVS             = "+ this.nbvS+ ", "
                            + "DEPCODE          = '"+ this.depCode+ "', "
                            + "DEPRATE          = "+ this.depRate+ ", "
                            + "ESTLIFE          = "+ this.estLife+ ", "
                            + "DEPV             = "+ this.depV+ ", "
                            + "ACMDEPV          = "+ this.acmDepV+ ", "
                            + "NBVE             = "+ this.nbvE+ ", "
                            + "SALV             = "+ this.salV+ ", "
                            + "AUDITUSER        = '"+ system.getLogUser(session)+"', "
                            + "AUDITDATE        = '"+ system.getLogDate()+ "', "
                            + "AUDITTIME        = '"+ system.getLogTime()+ "', "
                            + "AUDITIPADR       = '"+ system.getClientIpAdr(request)+ "'"
                            + "WHERE ID         = "+ this.sid;
                }
                
                saved = stmt.executeUpdate(query);

                if(saved == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");
                    
                    obj.put("entryNo", this.entryNo);
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
                
                Integer id = system.generateId(this.table, "ID");
                this.entryNo = system.getNextNo(this.table, "ID", "", "", 1);
                
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
                        + "'"+ system.getLogUser(session)+"', "
                        + "'"+ system.getLogDate()+ "', "
                        + "'"+ system.getLogTime()+ "', "
                        + "'"+ system.getClientIpAdr(request)+ "'"
                        + ")";

                Integer aqHdrCreated = stmt.executeUpdate(query);
                
                if(aqHdrCreated == 1){
                    //has depreciation no already
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
    
    public String getDpEntries(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(system.recordExists("VIEWAMDPDTLS", "BATCHNO = '"+ this.batchNo+ "' AND ENTRYNO = '"+ this.entryNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Asset No </th>";
            html += "<th>Description</th>";
            html += "<th style = \"text-align: right;\">Depreciation Value</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            Double sumDepV    = 0.0;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM VIEWAMDPDTLS WHERE BATCHNO = '"+ this.batchNo+ "' AND ENTRYNO = '"+ this.entryNo+ "'";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    
                    String assetNo      = rs.getString("ASSETNO");
                    String assetDesc    = rs.getString("ASSETDESC");
                    
                    Double depV         = rs.getDouble("DEPV");
                    
                    String editLink     = gui.formHref("onclick = \"depreciation.editDpDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"depreciation.purge("+ id +", '"+ assetDesc +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    
                    String opts = "";
                    opts = editLink+ " || "+ removeLink;
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ assetNo+ "</td>";
                    html += "<td>"+ assetDesc+ "</td>";
                    html += "<td style = \"text-align: right;\">"+ system.numberFormat(depV.toString()) +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    sumDepV   = sumDepV + depV;

                    count++;
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"3\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\">"+ system.numberFormat(sumDepV.toString()) +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No depreciation items record found.";
        }
        
        return html;
    }
    
    public Object editDpDtls(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(system.recordExists("AMDPDTLS", "ID = "+ this.sid +"")){
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM VIEWAMDPDTLS WHERE ID = "+ this.sid +"";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String assetNo      = rs.getString("ASSETNO");
                    String assetDesc    = rs.getString("ASSETDESC");
                    String opc          = rs.getString("OPC");
                    String nbvS         = rs.getString("NBVS");
                    String depCode      = rs.getString("DEPCODE");
                    String depRate      = rs.getString("DEPRATE");
                    String estLife      = rs.getString("ESTLIFE");
                    String depV         = rs.getString("DEPV");
                    String acmDepV      = rs.getString("ACMDEPV");
                    String nbvE         = rs.getString("NBVE");
                    String salV         = rs.getString("SALV");
                    
                    obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                    obj.put("assetNo", assetNo);
                    obj.put("assetDescription", assetDesc);
                    obj.put("opc", opc);
                    obj.put("nbvS", nbvS);
                    obj.put("depMethod", depCode);
                    obj.put("depRate", depRate);
                    obj.put("estLife", estLife);
                    obj.put("depV", depV);
                    obj.put("acmDepV", acmDepV);
                    obj.put("nbvE", nbvE);
                    obj.put("salV", salV);
                    
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
                String query = "DELETE FROM AMDPDTLS WHERE ID = "+ this.id;
            
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