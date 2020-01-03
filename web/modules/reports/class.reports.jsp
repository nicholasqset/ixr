<%@page import="java.io.File"%>
<%@page import="java.io.UnsupportedEncodingException"%>
<%@page import="bean.security.EncryptionUtil"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="bean.user.User"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class Reports{
    HttpSession session = request.getSession();
    String schema = session.getAttribute("comCode").toString();
        
    String table    = schema+ ".MDRPTS";
        
    Integer id      = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        Integer menuCode = null;
        
        try{
            EncryptionUtil encryptionUtil = new EncryptionUtil();
            menuCode = Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(session.getAttribute("n").toString(), "UTF-8")));
        }catch(Exception e){
            html += e.getMessage();
        }
        
        Integer recordCount = sys.getRecordCount(this.table, "MENUCODE = "+menuCode+"");
        
        if(recordCount > 0){
            String gridSql;
            String filterSql = "";
            Integer startRecord     = 0;
            Integer maxRecord       = 10;

            Integer maxRecordHidden = request.getParameter("maxRecord") != null? Integer.parseInt(request.getParameter("maxRecord")): null;
            Integer pageSize        = maxRecordHidden != null? maxRecordHidden: maxRecord;
            maxRecord               = maxRecordHidden != null? maxRecordHidden: maxRecord;

            session.setAttribute("maxRecord", maxRecord);

            String act              = request.getParameter("act");

            if(act != null){
                if(act.equals("find")){
                    String find = request.getParameter("find");
                    if(find != null){
                        session.setAttribute("startRecord", startRecord);

                        ArrayList<String> list = new ArrayList();

                        list.add("RPTNAME");
                        list.add("RPTDESC");
                        list.add("DATASRC");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                filterSql += " WHERE MENUCODE = "+ menuCode+ " AND (( UPPER("+ list.get(i)+ ") LIKE '%"+ find.toUpperCase()+ "%' ";
                            }else{
                                filterSql += " OR ( UPPER("+ list.get(i)+ ") LIKE '%"+ find.toUpperCase()+ "%' ";
                            }
                            filterSql += ")";
                        }
                        filterSql += ")";
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

            String addFilterSql = "";

            if(act == null){
                addFilterSql += " WHERE MENUCODE = "+menuCode+" ";
            }

            String orderBy = "RPTDESC ";
            String limitSql = "";

            String dbType = ConnectionProvider.getDBType();

            switch(dbType){
                case "mysql":
                    limitSql = "LIMIT "+ session.getAttribute("startRecord")+ " , "+ session.getAttribute("maxRecord");
                    break;
                case "postgres":
                    limitSql = "OFFSET "+ session.getAttribute("startRecord")+ " LIMIT "+ session.getAttribute("maxRecord");
                    break;
            }

            gridSql = "SELECT * FROM "+this.table+" "+filterSql+" "+addFilterSql+" ORDER BY "+ orderBy+ limitSql;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(gridSql);

                Integer startRecordHidden = Integer.parseInt(session.getAttribute("startRecord").toString()) + Integer.parseInt(session.getAttribute("maxRecord").toString());

                html += gui.formInput("hidden", "maxRecord", 10, session.getAttribute("maxRecord").toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                html += "<table class = \"grid\" width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" border=\"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Report Name</th>";
                html += "<th>Data Source</th>";
                html += "<th>Open</th>";
                html += "<th>Filter</th>";
                html += "<th>Sub Reports</th>";
                html += "<th>Delete</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String rptDesc      = rs.getString("RPTDESC");
                    String dataSrc      = rs.getString("DATASRC");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String subReportLink    = gui.formHref("onclick = \"reports.getSubReports("+id+")\"", request.getContextPath(), "reports-stack.png", "sub reports", "sub reports", "", "");
                    String selectExpertLink = gui.formHref("onclick = \"reports.getReportFilter("+id+")\"", request.getContextPath(), "funnel-pencil.png", "filter", "filter", "", "");
                    String openLink         = gui.formHref("onclick = \"reports.openReport("+id+")\"", request.getContextPath(), "blue-folder-open-document-text.png", "open", "open", "", "");
                    String deleteLink       = gui.formHref("onclick = \"reports.purge("+id+", '"+rptDesc+"')\"", request.getContextPath(), "delete.png", "delete", "delete", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+count+"</td>";
                    html += "<td>"+rptDesc+"</td>";
                    html += "<td>"+dataSrc+"</td>";
                    html += "<td>"+openLink+"</td>";
                    html += "<td>"+selectExpertLink+"</td>";
                    html += "<td>"+subReportLink+"</td>";
                    html += "<td>"+deleteLink+"</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";

            }catch(SQLException e){
                html += e.getMessage();
            }
            catch(Exception e){
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
        
        HttpSession session     = request.getSession();
        
        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
        
        try{
            EncryptionUtil encryptionUtil = new EncryptionUtil();
            html += gui.formInput("hidden", "menu", 30, ""+Integer.parseInt(encryptionUtil.decode(URLDecoder.decode(session.getAttribute("n").toString(), "UTF-8"))) , "", ""); 
        }catch(Exception e){
            html += e.getMessage();
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(), "report-edit.png", "", "")+" "+gui.formLabel("rptDesc", "Report Name")+"</td>";
	html += "<td>"+gui.formInput("text", "rptDesc", 30, this.id != null? "": "" , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "database-pencil.png", "", "")+" "+gui.formLabel("dataSrc", "Data Source")+"</td>";
	html += "<td>"+gui.formDbDataSrcSelect("dataSrc", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "attach.png", "", "")+" "+gui.formLabel("report", "Report")+"</td>";
	html += "<td><input type = \"file\" name = \"report\" id = \"report\" onchange = \"reports.upload('rptDesc', 'm');\" ></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
         
        html += gui.formEnd();
        
        html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
        
        return html;
    }
    
    public String getSubReports(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists("MDSUBRPTS", "IDRPT = "+ this.id)){
            html += "<table style = \"width: 50%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Sub Report Name</th>";
            html += "<th>Data Source</th>";
            html += "<th style = \"text-align: center;\">Options</th>";
            html += "</tr>";
            
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+schema+".MDSUBRPTS WHERE IDRPT = "+ this.id;
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id               = rs.getString("ID");
                    String subRptDesc       = rs.getString("SUBRPTDESC");
                    String subRptDataSrc    = rs.getString("SUBRPTDATASRC");
                    
                    String opts         = "";
                    
                    String delLink      = gui.formHref("onclick = \"reports.delSubReport("+ id+", '"+ subRptDesc+ "');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    
                    opts = delLink;
                    
                    html += "<tr>";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ subRptDesc+ "</td>";
                    html += "<td>"+ subRptDataSrc+ "</td>";
                    html += "<td style = \"text-align: center;\">"+ opts +"</td>";
                    html += "</tr>";
                    

                    count++;
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "</table>";
            
        }else{
            html += "No sub reports record found.";
        }
        
        html += "<br><br>";
        html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"reports.addSubReport("+ this.id+ ");\"", "");
        
        return html;
    }
    
    public String addSubReport(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
        
        html += gui.formInput("hidden", "id", 30, ""+ this.id, "", ""); 
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(), "report-pencil.png", "", "")+" "+gui.formLabel("subRptDesc", "Sub Report Name")+"</td>";
	html += "<td>"+gui.formInput("text", "subRptDesc", 30, this.id != null? "": "" , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "database-pencil.png", "", "")+" "+gui.formLabel("subRptDataSrc", "Data Source")+"</td>";
	html += "<td>"+gui.formDbDataSrcSelect("subRptDataSrc", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "reports-stack.png", "", "")+" "+gui.formLabel("subRpt", "Sub Report")+"</td>";
	html += "<td><input type = \"file\" name = \"subRpt\" id = \"subRpt\" onchange = \"reports.upload('subRptDesc', 's');\" ></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnCancelSubRpt", "back", "arrow-left.png", "onclick = \"reports.getSubReports("+ this.id+ "); return false;\"", "");
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
        
        html += gui.formEnd();
        
        html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
        return html;
    }
    
    public Object delSubReport(){
        
         JSONObject obj = new JSONObject();
         Sys sys  = new Sys();
         
         try{
            
            if(this.id != null){
                String webRootPath  = application.getRealPath("/").replace('\\', '/');
                String idRpt        = sys.getOne("MDSUBRPTS", "IDRPT", "ID = "+ this.id);
                String subRptName   = sys.getOne("MDSUBRPTS", "SUBRPTNAME", "ID = "+ this.id);
                
                String menuCode     = sys.getOne(this.table, "MENUCODE", "ID = "+ idRpt);
                
                String rptPath      = webRootPath+ "/reports/jasper/"+ menuCode+ "/"+ subRptName;
                
                Integer countOccr   = sys.getRecordCount("MDSUBRPTS", "SUBRPTNAME = '"+ subRptName+ "'");

                if(rptPath != null && ! rptPath.equals("") && countOccr == 1){
                    
                    File f = new File(rptPath);
                    if(f.delete()){
                        // file deleted
                    }else{
                        obj.put("success", new Integer(1));
                        obj.put("message", "Directory file deletion failed");
                    }
                }else{
                    obj.put("success", new Integer(1));
                    obj.put("message", "Directory file could not be traced");
                }
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "DELETE FROM "+schema+".MDSUBRPTS WHERE ID = "+this.id;
                Integer purged = stmt.executeUpdate(query);
                
                if(purged == 1){
                    
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully deleted.");
                    
                    obj.put("mId", idRpt);
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured while deleting record.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "An error occured while deleting record.");
            }
            
        }catch(SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }catch(Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
         return obj;
        
    }
    
    public String getReportFilter(){
        String html = "";
        
        Gui gui = new Gui();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        if(this.id != null){
            
            String rptDesc = "";
            String dataSrc = "";
            
            try{
                stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    rptDesc      = rs.getString("RPTDESC");		
                    dataSrc      = rs.getString("DATASRC");		
                }
                
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
            
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
            
            html += "<tr>";
            html += "<td class = \"bold\" width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(),"report-edit.png", "", "")+" Report Name</td>";
            html += "<td>"+rptDesc+"</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"database-pencil.png", "", "")+" Data Source</td>";
            html += "<td>"+dataSrc+"</td>";
            html += "</tr>";
            
            if(dataSrc != null && ! dataSrc.trim().equals("")){
                html += "<tr>";
                html += "<td class = \"bold\" style = \"vertical-align: top;\" nowrap>"+gui.formIcon(request.getContextPath(),"funnel-pencil.png", "", "")+" Filters</td>";
                html += "<td>";
                html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

                html += "<tr>";
                html += "<td class = \"bold\">#</td>";
                html += "<td class = \"bold\">Use</td>";
                html += "<td class = \"bold\">Column</td>";
                html += "<td class = \"bold\">Column Alias</td>";
                html += "<td class = \"bold\">Has Text Column</td>";
                html += "<td class = \"bold\">Text Column</td>";
                html += "</tr>";

                try{

                    ResultSet rs = stmt.executeQuery("SELECT * FROM "+dataSrc+"");
                    ResultSetMetaData md = rs.getMetaData();
                    for (int i = 1; i <= md.getColumnCount(); i++){

                        String colName      = md.getColumnLabel(i);

                        String colFltr      = null;
                        String colAlias     = null;
                        String colText      = null;

                        try{
                            String query = "SELECT * FROM "+schema+".MDRPTFLTRS WHERE IDRPT = "+this.id+" AND COLFLTR = '"+colName+"'";
                            ResultSet rset = stmt.executeQuery(query);
                            while(rset.next()){
                                colFltr     = rset.getString("COLFLTR");		
                                colAlias    = rset.getString("COLALIAS");		
                                colText     = rset.getString("COLTEXT");		
                            }
                        }catch (SQLException e){
                            html += e.getMessage();
                        }catch (Exception e){
                            html += e.getMessage();
                        }

                        String useStatus        = (colFltr != null)? "checked": "";
                        String colFltrStatus    = (colFltr != null)? "": "disabled";
                        String hasTextStatus    = (colText != null)? "checked": "";
                        String colTextStatus    = (colText != null)? "": "disabled";

                        String colUseUI         = gui.formCheckBox("colUse["+colName+"]", useStatus, "", "onchange = \"reports.toggleColAlias(this.id, '"+colName+"')\"", "", "");
                        String colAliasUI       = gui.formInput("text", "colAlias["+colName+"]", 20, colFltr != null? colAlias: "" , "", colFltrStatus);
                        String colHasTextUI     = gui.formCheckBox("colHasText["+colName+"]", hasTextStatus, "", "onchange = \"reports.toggleColText(this.id, '"+colName+"')\"", "", "");
                        String colTextUI        = gui.formDataSrcColSelect("colText["+colName+"]", dataSrc, colText != null? colText: "", colTextStatus);

                        html += "<tr>";
                        html += "<td>"+i+"</td>";
                        html += "<td>"+colUseUI+"</td>";
                        html += "<td>"+colName+"</td>";
                        html += "<td>"+colAliasUI+"</td>";
                        html += "<td>"+colHasTextUI+"</td>";
                        html += "<td>"+colTextUI+"</td>";
                        html += "</tr>";
                    }

                }catch (SQLException e){
                    html += e.getMessage();
                }catch (Exception e){
                    html += e.getMessage();
                }


                html += "</table>";
                html += "</td>";
                html += "</tr>";

                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>";
                html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"reports.save('_null');\"", "");
                html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"reports.getReportFilter("+this.id+");\"", "");
                html += "</td>";
                html += "</tr>";
            }else{
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>No report data source found</td>";
                html += "</tr>";
            }

            html += "</table>";

            html += gui.formEnd();


        }else{
            html += "Oops! An un-expected error occurred.";
        }

        return html;
    }
    
    public String openReport(){
        String html = "";
        Gui gui = new Gui();
        if(this.id != null){
            
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;
            
            String rptDesc = "";
            String dataSrc = "";
            
            try{
                stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    rptDesc      = rs.getString("RPTDESC");		
                    dataSrc      = rs.getString("DATASRC");		
                }
                
            }catch (SQLException e){

            }
            
            HashMap<String, String> outputForm = new HashMap();

            outputForm.put("pdf", "pfd");
            outputForm.put("excel", "excel");
            outputForm.put("text", "text");
            outputForm.put("html", "html");
         
//            html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./view/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
            html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./view/\" enctype = \"multipart/form-data\" target = \"_blank\">";
            
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
            
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
            html += "<tr>";
            html += "<td width = \"15%\">"+gui.formIcon(request.getContextPath(), "report-edit.png", "", "")+" Report Name</td>";
            html += "<td>"+rptDesc+"</td>";
            html += "</tr>";
            
            if(dataSrc != null && ! dataSrc.trim().equals("")){
                try{
                    String query = "SELECT * FROM "+schema+".MDRPTFLTRS WHERE IDRPT = "+this.id+"";
                    ResultSet rset = stmt.executeQuery(query);
                    while(rset.next()){
                        String colFltr      = rset.getString("COLFLTR");		
                        String colAlias     = rset.getString("COLALIAS");
                        String colText      = rset.getString("COLTEXT");

                        html += "<tr>";
                        html += "<td>"+gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+" "+colAlias+"</td>";
                        html += "<td>"+gui.formSelect("col["+colFltr+"]", dataSrc, colFltr, colText, colFltr, "", "", "", false)+"</td>";
                        html += "</tr>";

                    }
                }catch (SQLException e){
                    html += e.getMessage();
                }catch (Exception e){
                    html += e.getMessage();
                }
            }
        
            html += "<tr>";
            html += "<td>"+gui.formIcon(request.getContextPath(), "page.png", "", "")+" "+gui.formLabel("outputForm", "Output Form")+"</td>";
//            html += "<td>"+gui.formArraySelect("outputForm", 100,  new  HashMap(outputForm), "pdf", false, "", false)+"</td>";
            html += "<td>"+gui.formArraySelect("outputForm", 100,  new  HashMap(outputForm), "excel", false, "", false)+"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td >&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnViewRpt", "View Report", "blue-folder-open-document-text.png", "onclick = \"reports.viewReport('_null');\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"reports.openReport("+this.id+"); return false;\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "</form>";
            
            html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
        }else{
            html += "Oops! An un-expected error occurred.";
        }
        
        return html;
    }
    
    public Object save(){
        
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        String query = "";
        Integer count = 0;
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;
            
            Integer saved = 0;
            
            stmt = conn.createStatement();
            query = "DELETE FROM "+schema+".MDRPTFLTRS WHERE IDRPT = "+this.id;
            Integer purged = stmt.executeUpdate(query);
            
            String dataSrc = null;
            
            query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    dataSrc      = rs.getString("DATASRC");		
                }
            if(dataSrc != null && ! dataSrc.trim().equals("")){
                
                rs = stmt.executeQuery("SELECT * FROM "+dataSrc+"");
                ResultSetMetaData md = rs.getMetaData();
                
                for (int i = 1; i <= md.getColumnCount(); i++){
                    String colName      = md.getColumnLabel(i);
                    
                    Integer id = sys.generateId("MDRPTFLTRS", "ID");
                    
                    String colFltr = request.getParameter("colAlias["+colName+"]");
                    String colText = request.getParameter("colText["+colName+"]");
                    
                    if(colFltr != null && ! colFltr.trim().equals("")){
                        if(colText != null && ! colText.trim().equals("")){
                            colText = "'"+colText+"'";
                        }else{
                            colText = null;
                        }
                        query = "INSERT INTO "+schema+".MDRPTFLTRS "
                                + "(ID, IDRPT, COLFLTR, COLALIAS, COLTEXT)"
                                + "VALUES"
                                + "("
                                + id+", "
                                + this.id+", "
                                + "'"+colName+"', "
                                + "'"+colFltr+"', "
                                + colText
                                + ")";
                        
                        saved = stmt.executeUpdate(query);
                        if(saved == 1){
                            count++;
                        }
                    }
                }
            }
            
            
        }catch(SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }catch(Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        if(count > 0){
            obj.put("success", new Integer(1));
            obj.put("message", "Entry successfully made.");
        }else{
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while saving record.");
        }
        
        return obj;
    }
    
    public Object purge(){
        
         JSONObject obj = new JSONObject();
         Sys sys  = new Sys();
         
         try{
            
            if(this.id != null){
                String webRootPath  = application.getRealPath("/").replace('\\', '/');
                String rptName      = sys.getOne(this.table, "RPTNAME", "ID = "+this.id);
                String menuCode     = sys.getOne(this.table, "MENUCODE", "ID = "+this.id);
                
                String rptPath      = webRootPath+ "/reports/jasper/"+ menuCode+ "/"+ rptName;

                if(rptPath != null && ! rptPath.equals("")){
                    
                    File f = new File(rptPath);
                    if(f.delete()){
                        // file deleted
                    }else{
                        obj.put("success", new Integer(1));
                        obj.put("message", "Directory file deletion failed");
                    }
                }else{
                    obj.put("success", new Integer(1));
                    obj.put("message", "Directory file could not be traced");
                }
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "DELETE FROM "+this.table+" WHERE ID = "+this.id;
                Integer purged = stmt.executeUpdate(query);
                
                if(purged == 1){
                    
                    query = "DELETE FROM "+schema+".MDRPTFLTRS WHERE IDRPT = "+this.id;
                    purged = stmt.executeUpdate(query);
                    
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
            
        }catch(SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }catch(Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
         return obj;
        
    }
    
}

%>