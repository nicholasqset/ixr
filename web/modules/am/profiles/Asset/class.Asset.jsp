<%@page import="org.json.JSONObject"%>
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

final class Asset{
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        String table            = comCode+".AMASSETS";
    String view             = comCode+".VIEWAMASSETS";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String assetNo          = this.id != null? request.getParameter("assetNoHd"): request.getParameter("assetNo");
    String assetDesc        = request.getParameter("assetDesc");
    String aqNo             = request.getParameter("acquisitionNo");
    String aqDate           = request.getParameter("aqDate");
    String catCode          = request.getParameter("category");
    String serialNo         = request.getParameter("serialNo");
    
    String statusCode       = request.getParameter("assetStatus");
    String depCode          = request.getParameter("depMethod");
    String depStartDate     = request.getParameter("depStartDate");
    Double estLife          = request.getParameter("estLife") != null? Double.parseDouble(request.getParameter("estLife")): null;
    String estExpDate       = request.getParameter("estExpDate");
    Double depRate          = request.getParameter("depRate") != null? Double.parseDouble(request.getParameter("depRate")): null;
    Double opc              = request.getParameter("opc") != null? Double.parseDouble(request.getParameter("opc")): null;
    Double acmDep           = request.getParameter("acmDep") != null? Double.parseDouble(request.getParameter("acmDep")): null;
    Double nbv              = request.getParameter("nbv") != null? Double.parseDouble(request.getParameter("nbv")): null;
    Double salv             = request.getParameter("salv") != null? Double.parseDouble(request.getParameter("salv")): null;
    String insCo            = request.getParameter("insCo");
    String insPlcNo         = request.getParameter("insPlcNo");
    String insDate          = request.getParameter("insDate");
    Double insV             = request.getParameter("insV") != null? Double.parseDouble(request.getParameter("insV")): null;
    
    String comments         = request.getParameter("comments");
    
    Integer docId           = request.getParameter("docId") != null? Integer.parseInt(request.getParameter("docId")): null;
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
        Integer recordCount = sys.getRecordCount(this.table, "");
        
        if(recordCount > 0){
            String gridSql;
            String filterSql = "";
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

                        list.add("ASSETNO");
                        list.add("ASSETDESC");
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
            
            String orderBy  = "ASSETNO ";
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

                html += "<table class = \"grid\" width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" border = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Asset No</th>";
                html += "<th>Name</th>";
                html += "<th>Acquisition No</th>";
                html += "<th>Category</th>";
                html += "<th>Original Purchase Cost</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String assetNo      = rs.getString("ASSETNO");
                    String fullName     = rs.getString("ASSETDESC");
                    String aqNo         = rs.getString("AQNO");
                    String catName      = rs.getString("CATNAME");
                    Double opc          = rs.getDouble("OPC");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ assetNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ aqNo+ "</td>";
                    html += "<td>"+ catName+ "</td>";
                    html += "<td>"+ sys.numberFormat(opc.toString())+ "</td>";
                    html += "<td>"+ edit+ "</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
            }catch(SQLException e){
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
        
//        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
//        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" enctype = \"multipart/form-data\" target = \"_blank\">";
        
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getMasterTab()+ "</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getBookTab()+ "</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getMiscTab()+ "</div>";
        
        html += gui.formEnd();
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getAttachmentTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"asset.save('assetNo assetNoHd aqNo serialNo aqDate'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getGrid(); return false;\"", "");
	html += "</div>";
        
        
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Master\', \'Book\', \'Misc.\', \'Attachments\'), 0, 625, 420, Array(false, false, false));";
        html += "</script>";
        
        html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
        
        return html;
    }
    
    public String getMasterTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.table+ " WHERE ID = "+ this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.assetNo           = rs.getString("ASSETNO");		
                }
            }catch (SQLException e){
                html += e.getMessage();
            }
            
            AssetProfile assetProfile = new AssetProfile(this.assetNo);
            
            this.assetDesc      = assetProfile.assetDesc;
            this.aqNo           = assetProfile.aqNo;
            this.aqDate         = assetProfile.aqDate;
            this.catCode        = assetProfile.catCode;
            this.serialNo       = assetProfile.serialNo;
            
            this.statusCode     = assetProfile.statusCode;
            this.depCode        = assetProfile.depCode;
            this.depStartDate   = assetProfile.depStartDate;
            this.estLife        = assetProfile.estLife;
            this.estExpDate     = assetProfile.estExpDate;
            this.depRate        = assetProfile.depRate;
            this.opc            = assetProfile.opc;
            this.acmDep         = assetProfile.acmDep;
            this.nbv            = assetProfile.nbv;
            this.salv           = assetProfile.salv;
            this.insCo          = assetProfile.insCo;
            this.insPlcNo       = assetProfile.insPlcNo;
            this.insDate        = assetProfile.insDate;
            this.insV           = assetProfile.insV;
            
            this.comments       = assetProfile.comments;

            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
                java.util.Date aqDate = originalFormat.parse(this.aqDate);
                this.aqDate = targetFormat.format(aqDate);
                
                java.util.Date depStartDate = originalFormat.parse(this.depStartDate);
                this.depStartDate = targetFormat.format(depStartDate);
                
                java.util.Date estExpDate = originalFormat.parse(this.estExpDate);
                this.estExpDate = targetFormat.format(estExpDate);
                
                this.insDate = this.insDate != null? this.insDate: assetProfile.aqDate;
                
                java.util.Date insDate = originalFormat.parse(this.insDate);
                this.insDate = targetFormat.format(insDate);
            }catch(Exception e){
                html += e.getMessage();
            }
            
            html += gui.formInput("hidden", "id", 30, ""+ this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("assetNo", "Asset No")+"</td>";
        html += "<td colspan = \"3\">"+ gui.formAutoComplete("assetNo", 15, this.id != null? this.assetNo: "", "asset.searchAsset", "assetNoHd", this.id != null? this.assetNo: "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+gui.formLabel("assetDesc", "Description")+"</td>";
	html += "<td colspan = \"2\">"+ gui.formInput("text", "assetDesc", 25, this.id != null? this.assetDesc: "", "", "")+ "</td>";
        if(this.id != null){
            String imgPhotoSrc;
            if(hasPhoto(this.assetNo)){
                imgPhotoSrc = "photo.jsp?assetNo="+ this.assetNo;
            }else{
                imgPhotoSrc = request.getContextPath()+"/images/emblems/folders-OS-pictures-metro.png";
            }
            
            html += "<td rowspan = \"5\">";
            html += "<div class = \"divPhoto\"><img id = \"imgPhoto\" src=\""+ imgPhotoSrc+ "\"></div>";
            html += "</td>";
        }
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("acquisitionNo", " Acquisition No.")+ "</td>";
	html += "<td colspan = \"2\">"+ gui.formInput("text", "acquisitionNo", 25, this.id != null? this.aqNo: "", "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("aqDate", " Acquisition Date")+"</td>";
	html += "<td colspan = \"2\">"+ gui.formDateTime(request.getContextPath(), "aqDate", 10, this.id != null? this.aqDate: "", false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("serialNo", " Category")+ "</td>";
	html += "<td colspan = \"2\">"+ gui.formSelect("category", "AMCATS", "CATCODE", "CATNAME", "", "", this.id != null? this.catCode: "", "onchange = \"\"", false)+ "</td>";
	html += "</tr>";        
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("serialNo", " Serial No.")+ "</td>";
	html += "<td colspan = \"2\">"+ gui.formInput("text", "serialNo", 25, this.id != null? this.serialNo: "", "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"17%\">&nbsp;</td>";
	html += "<td width = \"33%\">&nbsp;</td>";
	html += "<td width = \"17%\">&nbsp;</td>";
	html += "<td>&nbsp;</td>";
	html += "</tr>";
        
        html += "</table>";
        
        if(this.id != null){
            html += " <script type=\"text/javascript\">"
                    +   "Event.observe(\'imgPhoto\', \'mouseover\' , function(){"
                    +       "if($(\'divPhotoOptions\')){"
                    +           "$(\'divPhotoOptions\')"
                    +           ".absolutize()"
                    +           ".setStyle({display:\'table-cell\'})"
                    +           ".clonePosition($(\'imgPhoto\'));"
                    +       "}"
                    +   "});"
                    + "</script>";
                        
            html += "<div id = \"divPhotoOptions\" onmouseout = \"asset.hidePhotoOptions();\" style = \"display: none; background-color: #000000; opacity: 0.4; text-align: center;\">";
            html += "<input name = \"photo\" id = \"photo\" type = \"file\" onchange = \"asset.uploadPhoto();\" style = \"display: none;\">";
            html += "<div style = \"padding-top: 50px;\">";
            html += "<a href = \"javascript:;\" onclick = \"$('photo').click();\">upload</a>";
            html += "</div>";
            if(this.hasPhoto(this.assetNo)){
                html += "<div >";
                html += gui.formHref("onclick = \"asset.purgePhoto('"+this.assetNo+"', '"+ this.assetDesc+"')\"", request.getContextPath(), "", "remove", "remove", "", "");
                html += "</div>";
            }
            html += "</div>";
        }
        
        return html;
    }
    
    public String searchAsset(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.assetNo = request.getParameter("assetNoHd");
        
        html += gui.getAutoColsSearch("AMASSETS", "ASSETNO, ASSETDESC", "", this.assetNo);
        
        return html;
    }
    
    public JSONObject getAssetProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.assetNo == null || this.assetNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            AssetProfile assetProfile = new AssetProfile(this.assetNo);
            
            obj.put("assetDesc", assetProfile.assetDesc);
            obj.put("aqNo", assetProfile.aqNo);
            obj.put("catCode", assetProfile.catCode);
            obj.put("serialNo", assetProfile.serialNo);
            obj.put("comments", assetProfile.comments);
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            try{
                java.util.Date aqDate = originalFormat.parse(assetProfile.aqDate);
                assetProfile.aqDate = targetFormat.format(aqDate);
            }catch(ParseException e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }
            
            obj.put("aqDate", assetProfile.aqDate);
            obj.put("depMethod", assetProfile.depCode);
            obj.put("insDate", assetProfile.insDate);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Asset No '"+assetProfile.assetNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Boolean hasPhoto(String assetNo){
        Boolean hasPhoto = false;
        
        if(this.id != null){
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;
            
            Integer count = 0;
            
            try{
                stmt = conn.createStatement();
                String query = "SELECT COUNT(*)CT FROM AMASSETPHOTOS WHERE ASSETNO = '"+ assetNo+ "'";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    count      = rs.getInt("CT");		
                }
                
                if(count > 0){
                    hasPhoto = true;
                }
                
            }catch (SQLException e){
                e.getMessage();
            } 
        }
        
        return hasPhoto;
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
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("assetStatus", " Status")+ "</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("assetStatus", "AMASTSTATUS", "STATUSCODE", "STATUSNAME", "", "", this.id != null? this.statusCode: "", "onchange = \"\"", false)+ "</td>";
	html += "</tr>";  
        
        html += "<tr>";
	html += "<td width = \"17%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("depMethod", " Depreciation Method")+ "</td>";
        html += "<td width = \"33%\">"+ gui.formSelect("depMethod", "AMDEPMETHODS", "DEPCODE", "DEPNAME", "", "", this.id != null? this.depCode: "", "onchange = \"\" style = \"width: 150px;\"", false)+ "</td>";
	
	html += "<td width = \"17%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("depRate", " Depreciation Rate")+ "</td>";
	html += "<td>"+ gui.formInput("text", "depRate", 15, ""+ this.depRate, "", "")+ "<span class = \"fade\"> %</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("depStartDate", " Start Date")+ "</td>";
        html += "<td >"+ gui.formDateTime(request.getContextPath(), "depStartDate", 10, this.id != null? this.depStartDate: defaultDate, false, "")+ "</td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("estLife", " Estimated Life")+ "</td>";
	html += "<td nowrap>"+ gui.formInput("text", "estLife", 15, ""+ this.estLife, "", "")+ "<span class = \"fade\"> years</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("estExpDate", " End Date")+ "</td>";
        html += "<td colspan = \"3\">"+ gui.formDateTime(request.getContextPath(), "estExpDate", 10, this.id != null? this.estExpDate: defaultDate, false, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("opc", " Original Purchase Cost")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "opc", 15, ""+ this.opc, "", "")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "pencil.png", "", "")+ gui.formLabel("acmDep", " Accumulated Depreciation")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "acmDep", 15, ""+ this.acmDep, "", "")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("nbv", " Net book value")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "nbv", 15, ""+ this.nbv, "", "")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("salv", " Salvage value")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "salv", 15, ""+ this.salv, "", "")+ "</td>";
        html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String getMiscTab(){
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
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("insCo", " Insurance Company")+ "</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "insCo", 30, this.id != null? this.insCo: "", "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"17%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("insPlcNo", " Policy No.")+ "</td>";
	html += "<td width = \"33%\">"+ gui.formInput("text", "insPlcNo", 15, ""+ this.insPlcNo, "", "")+ "</td>";
	
        html += "<td width = \"17%\" nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("depStartDate", " Insurance Date")+ "</td>";
        html += "<td >"+ gui.formDateTime(request.getContextPath(), "insDate", 10, this.id != null? this.insDate: defaultDate, false, "")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "money.png", "", "")+ gui.formLabel("opc", " Insurance Value")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "insV", 15, ""+ this.insV, "", "")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "pencil.png", "", "")+ gui.formLabel("comments", " Additional Information")+ "</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("textarea", "comments", 25, this.id != null? this.comments: "", "", "")+ "</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String getAttachmentTab(){
        String html = "";
        Gui gui = new Gui();
        
        html += "<form name = \"frmDocs\" id = \"frmDocs\" method = \"post\"  action = \"./uploadDoc/\" enctype = \"multipart/form-data\" target = \"upload_doc_iframe\">";
        
        html += gui.formInput("hidden", "assetNoD", 30, this.assetNo, "", "");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";
        
        html += "<tr>";
	html += "<td colspan = \"2\"><div id = \"dvDocs\">"+ this.getAttachments()+ "</div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"10%\">&nbsp;</td>";
//	html += "<td>"+ gui.formButton(request.getContextPath(), "button", "btnUpload", "Upload", "page-up.png", "onclick = \"asset.uploadDoc();\"", "")+"</td>";
	html += "<td><input name = \"doc\" id = \"doc\" type = \"file\" onchange = \"asset.uploadDoc();\"></td>";
	html += "</tr>";
        
        html += "</table>";
        
        html += gui.formEnd();
        
        html += "<iframe name = \"upload_doc_iframe\" id = \"upload_doc_iframe\"></iframe>";
                
        return html;
    }
    
    public String getAttachments(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists("AMASSETDOCS", "ASSETNO = '"+ this.assetNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Document Name</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM AMASSETDOCS WHERE ASSETNO = '"+ this.assetNo+ "' ORDER BY FILENAME";
                
                ResultSet rs = stmt.executeQuery(query);
                
                Integer count  = 1;

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String fileName     = rs.getString("FILENAME");
                    
                    String editLink     = gui.formHref("onclick = \"asset.viewDoc("+ id +");\"", request.getContextPath(), "", "view", "view", "", "");
                    String removeLink   = gui.formHref("onclick = \"asset.purgeDoc("+ id +", '"+ fileName +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    
                    String opts = "";
                    opts = editLink+ " || "+ removeLink;
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ fileName +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                }
                
            }catch(Exception e){
                html += e.getMessage();
            }
            
        }else{
            html += "No attachments record found.";
        }
        
        return html;
    }
    
    public JSONObject save() throws Exception{
        JSONObject obj      = new JSONObject();
        Sys sys       = new Sys();
        HttpSession session = request.getSession();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "";
        
            Integer saved = 0;
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
            SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

            java.util.Date aqDate = originalFormat.parse(this.aqDate);
            this.aqDate = targetFormat.format(aqDate);
            
            java.util.Date insDate = originalFormat.parse(this.insDate);
            this.insDate = targetFormat.format(insDate);
	            
            if(this.assetNo == null || this.assetNo.equals("")){
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record. Could not retrieve Asset No.");
            }else{
                query = "UPDATE "+this.table+" SET "
                        + "ASSETDESC        = '"+ this.assetDesc+ "', "
                        + "AQDATE           = '"+ this.aqDate+ "', "
                        + "SERIALNO         = '"+ this.serialNo+ "', "
                        + "SALV             = "+ this.salv+ ", "
                        + "INSCO            = '"+ this.insCo+ "', "
                        + "INSPLCNO         = '"+ this.insPlcNo+ "', "
                        + "INSDATE          = '"+ this.insDate+ "', "
                        + "INSV             = "+ this.insV+ ", "
                        + "COMMENTS         = '"+ this.comments+ "', "
                        + "AUDITUSER        = '"+ sys.getLogUser(session)+ "', "
                        + "AUDITDATE        = '"+ sys.getLogDate()+ "', "
                        + "AUDITTIME        = '"+ sys.getLogTime()+ "', "
                        + "AUDITIPADR       = '"+ sys.getClientIpAdr(request)+ "' "
                        + "WHERE ASSETNO    = '"+ this.assetNo+ "'";
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
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
    
    public JSONObject purgePhoto() throws Exception{
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            
            if(this.assetNo != null && ! this.assetNo.trim().equals("")){
                String query = "DELETE FROM AMASSETPHOTOS WHERE ASSETNO = '"+this.assetNo+"'";
            
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
            
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
        return obj;
    } 
    
    public JSONObject purgeDoc() throws Exception{
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            
            if(this.docId != null){
                String query = "DELETE FROM AMASSETDOCS WHERE ID = "+ this.docId;
            
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
            
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
        return obj;
    }
    
}

%>