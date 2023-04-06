<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.SQLException"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="java.io.File"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class Banks{
    HttpSession session=request.getSession();
    String table        = ""+session.getAttribute("comCode")+".FNBANKS";
    String view         = "";
    
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String bankCode     = request.getParameter("code") ;
    Integer autoCode    = request.getParameter("autoCode") != null? 1: null;
    String bankName     = request.getParameter("name");
    String swiftCode    = request.getParameter("swiftCode");
    
    Integer sid          = request.getParameter("sid") != null? Integer.parseInt(request.getParameter("sid")): null;
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        Integer recordCount = sys.getRecordCount(this.table, "");
        
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

                        list.add("BANKCODE");
                        list.add("BANKNAME");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
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

            String orderBy = "BANKCODE ";
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

            gridSql = "SELECT * FROM "+this.table+" "+filterSql+" ORDER BY "+ orderBy+ limitSql;

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
                html += "<th>Bank Code</th>";
                html += "<th>Bank Name</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String bankCode     = rs.getString("BANKCODE");
                    String bankName     = rs.getString("BANKNAME");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor +"\">";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ bankCode +"</td>";
                    html += "<td>"+ bankName +"</td>";
                    html += "<td>"+ edit +"</td>";
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
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+ this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.bankCode       = rs.getString("BANKCODE");		
                    this.bankName       = rs.getString("BANKNAME");		
                    this.swiftCode      = rs.getString("SWIFTCODE");		
                }
            }catch (Exception e){
                html += e.getMessage();
            }
        }
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getAccountTab()+ "</div>";
        if(this.id != null){
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"dvChqTps\">"+ this.getChequeTab()+ "</div></div>";
        }
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"bank.save('name'); return false;\"", "");
	if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"bank.purge("+this.id+",'"+ this.bankName+ "');\"", "");
        }
        html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getGrid(); return false;\"", "");
	html += "</div>";
        
        html += "<script type = \"text/javascript\">";
        if(this.id != null){
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bank\', \'Cheque Template\'), 0, 625, 350, Array(false, false));";
        }else{
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bank\'), 0, 625, 350, Array(false));";
        }
        
        html += "</script>";
        
        return html;
    }
    
    public String getAccountTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
        
        String autoCodeUi = "";
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
            autoCodeUi  = gui.formCheckBox("autoCode", "checked", "", "onchange = \"bank.toggleCodeUi();\"", "", "")+ "<span class = \"fade\"><label for = \"autoCode\"> No Auto</label></span>";
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"22%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page.png", "", "") + gui.formLabel("code", "Bank Code") +"</td>";
        html += "<td>"+ gui.formInput("text", "code", 15, this.id != null? this.bankCode: "" , "", "") +" "+ autoCodeUi +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("name", " Bank Name")+"</td>";
	html += "<td>"+gui.formInput("text", "name", 30, this.id != null? this.bankName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(), "package.png", "", "") + gui.formLabel("swiftCode", " Swift Code")+"</td>";
	html += "<td>"+gui.formInput("text", "swiftCode", 15, this.id != null? this.swiftCode: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "</table>";
        
        html += gui.formEnd();
        
        return html;
    }
    
    public String getChequeTab(){
        String html = "";
        
        html += this.getChqList();
        
        return html;
    }
    
    public String getChqList(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(this.id != null){
            this.bankCode = sys.getOne(this.table, "BANKCODE", "ID = "+ this.id);
        }
        
        if(sys.recordExists("VIEWFNBKCHQTPLS", "BANKCODE = '"+ this.bankCode+ "'")){
            html += "<table class = \"module\" width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" border = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Template No</th>";
            html += "<th>Name</th>";
            html += "<th>Default</th>";
            html += "<th>Options</th>";
            html += "</tr>";
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM qset.VIEWFNBKCHQTPLS WHERE BANKCODE = '"+ this.bankCode+ "' ORDER BY TPLCODE ";
                
                ResultSet rs = stmt.executeQuery(query);
                Integer count = 1;
                while(rs.next()){
                    Integer mid     = rs.getInt("MID");
                    Integer id      = rs.getInt("ID");
                    String tplCode  = rs.getString("TPLCODE");
                    String tplName  = rs.getString("TPLNAME");
                    Integer isDft   = rs.getInt("ISDFT");
                    
                    String tplDesc = "";
                    
                    switch(tplCode){
                        case "tpl1":
                            tplDesc = "Template 1";
                            break;

                        case "tpl2":
                            tplDesc = "Template 2";
                            break;

                        case "tpl3":
                            tplDesc = "Template 3";
                            break;

                    }
                    
//                    String isDft_   = isDft == 1? gui.formIcon(request.getContextPath(), "tick.png", "", ""): "";
                    
                    String isDftUi = "";
                    if(isDft == 1){
                        isDftUi = gui.formCheckBox("isDft_"+ id, "checked", "", "", "", "");
                    }else{
                        isDftUi = gui.formCheckBox("isDft_"+ id, "", "", "onchange = \"bank.doDefault("+ id+ ", "+ mid+ ", '"+ tplName+ "');\"", "", "");
                    }
                    
                    String del_link     = gui.formHref("onclick = \"bank.removeTemplate("+ id+ ", "+ mid+ ", '"+ tplName+ "')\"", request.getContextPath(), "cross.png", "remove", "remove", "", "");
                   
                    String options = del_link;
                    
                    html += "<tr>";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ tplDesc+ "</td>";
                    html += "<td>"+ tplName+ "</td>";
                    html += "<td>"+ isDftUi+ "</td>";
                    html += "<td>"+ options+ "</td>";
                    html += "</tr>";
                    
                    count++;
                }
                
            }catch(Exception e){
                html += e.getMessage();
            }
            
           html += "</table>"; 
        }else{
            html += "No template upload found.";
        }
        
        html += "<div style = \"padding-top: 10px;\">";
        
        html += gui.formButton(request.getContextPath(), "button", "btnUpload", "Upload", "arrow-step-out.png", "onclick = \"bank.getUploadUI("+ this.id+ ");\"", "");
        
        html += "</div>";
        return html;
    }
    
    public String getUploadUI(){
        String html = "";
        Gui gui = new Gui();
        
        HashMap<String, String> hmTemplates = new HashMap();
        
        hmTemplates.put("tpl1", "Template 1");
        hmTemplates.put("tpl2", "Template 2");
        hmTemplates.put("tpl3", "Template 3");
        
        html += "<form name = \"frmCheque\" id = \"frmCheque\" method = \"post\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
//        html += "<form name = \"frmCheque\" id = \"frmCheque\" method = \"post\" enctype = \"multipart/form-data\" target = \"_blank\">";
        
        html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"22%\" nowrap>"+ gui.formIcon(request.getContextPath(), "report-edit.png", "", "") + gui.formLabel("template", "Template") +"</td>";
        html += "<td>"+ gui.formArraySelect("template", 150, hmTemplates, "", false, "onchange = \"\"", true) + "</td>";
	html += "</tr>";        
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "attach.png", "", "") + gui.formLabel("file", "Attach") +"</td>";
        html += "<td><input type = \"file\" name = \"template\" id = \"template\" onchange = \"bank.upload('template');\"></td>";
	html += "</tr>";        
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
        html += "<td>"+ gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "reload.png", "onclick = \"bank.getChqList("+ this.id+ "); return false;\"", "") + "</td>";
	html += "</tr>";
        
        html += "</table>";
         
        html += gui.formEnd();

        html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
        
        return html;
    }
    
    public Object save() throws Exception{
        JSONObject obj      = new JSONObject();
        Sys sys       = new Sys();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
	    String query = "";  
            
            if(this.id == null){
                Integer id = sys.generateId(this.table, "ID");
                
                if(this.autoCode != null && this.autoCode == 1){
                    this.bankCode = sys.getNextNo(this.table, "ID", "", "", 2);
                }
                
                query = "INSERT INTO "+ this.table +" "
                        + "(ID, BANKCODE, BANKNAME, SWIFTCODE)"
                        + "VALUES"
                        + "("
                        + id +","
                        + "'"+ this.bankCode +"', "
                        + "'"+ this.bankName +"', "
                        + "'"+ this.swiftCode +"' "
                        + ")";
                
                obj.put("code", this.bankCode);
            }else{
                query = "UPDATE "+ this.table +" SET "
                        + "BANKNAME      = '"+ this.bankName +"', "
                        + "SWIFTCODE     = '"+ this.swiftCode +"'"

                        + "WHERE ID      = '"+ this.id +"'";
            }
            
            Integer saved  = stmt.executeUpdate(query);
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
    
    public Object removeTemplate() throws Exception{
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.sid != null){
                String query = "DELETE FROM qset.FNBKCHQTPLS WHERE ID = "+this.sid;
            
                Integer purged = stmt.executeUpdate(query);
                if(purged == 1){
                    
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully deleted.");
                    
                    String webRootPath      = application.getRealPath("/").replace('\\', '/');
                    String relReportPath    = "/reports/jasper/ap/cheques/";

                    String reportDirPath    = webRootPath+ relReportPath;
                    
                    String template = request.getParameter("template");

                    String reportPath       = reportDirPath+ "/"+ this.bankCode+ "/"+ template;
                    
                    File f = new File(reportPath);
                    if(f.delete()){
                        
                    }else{
//                        obj.put("success", new Integer(1));
//                        obj.put("message", "Directory file deletion failed");
                    }
                    
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
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
        return obj;
    }
    
    public Object doDefault() throws Exception{
        JSONObject obj = new JSONObject();
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            Integer rts = 1;
            String msg = "";
            
            if(this.sid == null){
                rts = 0;
                msg = "An unexpected error occured";
            }
                
            String query1 = "UPDATE qset.FNBKCHQTPLS SET ISDFT = NULL WHERE BANKCODE = '"+ this.bankCode+ "'";
            stmt.executeUpdate(query1);
            
            String query2 = "UPDATE qset.FNBKCHQTPLS SET ISDFT = 1 WHERE ID = "+ this.sid;

            if(rts == 1){
                Integer saved = stmt.executeUpdate(query2);
                if(saved == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made default.");
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured.");
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
    
    public Object purge() throws Exception{
        JSONObject obj = new JSONObject();

        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

           if(this.id != null){
               String query = "DELETE FROM "+this.table+" WHERE ID = "+ this.id;

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

        }

        return obj;
        
    }
    
}

%>