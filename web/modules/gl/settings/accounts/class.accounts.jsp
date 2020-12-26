<%@page import="org.json.JSONObject"%>
<%@page import="java.util.HashMap"%>
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

final class Accounts{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    String table            = comCode+".GLACCOUNTS";
    String view             = comCode+".VIEWGLACCOUNTS";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String accountCode      = request.getParameter("code") ;
    Integer autoCode        = request.getParameter("autoCode") != null? 1: null;
    String accountName      = request.getParameter("name");
    String normalBal        = request.getParameter("normalBal");
    String accTypeCode      = request.getParameter("accountType");
    String accGrpCode       = request.getParameter("accountGroup");
    Integer active          = request.getParameter("active") != null? 1: null;
    
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

                        list.add("ACCOUNTCODE");
                        list.add("ACCOUNTNAME");
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

            String orderBy = "ACCOUNTCODE ";
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
                html += "<th>Account Code</th>";
                html += "<th>Account Name</th>";
                html += "<th>Type</th>";
                html += "<th>Group</th>";
                html += "<th>Normal Balance</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){
                    Integer id              = rs.getInt("ID");
                    String accountCode      = rs.getString("ACCOUNTCODE");
                    String accountName      = rs.getString("ACCOUNTNAME");
                    String accTypeName      = rs.getString("ACCTYPENAME");
                    String accGrpName       = rs.getString("ACCGRPNAME");
                    String normalBal        = rs.getString("NORMALBAL");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor +"\">";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ accountCode +"</td>";
                    html += "<td>"+ accountName +"</td>";
                    html += "<td>"+ accTypeName +"</td>";
                    html += "<td>"+ accGrpName +"</td>";
                    html += "<td>"+ normalBal +"</td>";
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
    
    public String getModulex(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
//        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getAccountTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"account.save('code name normalBal accountType accountGroup'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Account\'), 0, 625, 350, Array(false));";
        html += "</script>";
        
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
                    this.accountCode        = rs.getString("ACCOUNTCODE");		
                    this.accountName        = rs.getString("ACCOUNTNAME");		
                    
                    this.normalBal          = rs.getString("NORMALBAL");		
                    this.accTypeCode        = rs.getString("ACCTYPECODE");		
                    this.accGrpCode         = rs.getString("ACCGRPCODE");
                    this.active             = rs.getInt("ACTIVE");		
                }
            }catch (Exception e){
                html += e.getMessage();
            }
        }
        
        HashMap<String, String> normalBal = new HashMap();
        normalBal.put("DR", "Debit");
        normalBal.put("CR", "Credit");
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript:return false;\"");
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page.png", "", "") + gui.formLabel("code", " Account Code") +"</td>";
        html += "<td>"+ gui.formInput("text", "code", 15, this.id != null? this.accountCode: "" , "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("name", " Account Name")+"</td>";
	html += "<td>"+ gui.formInput("text", "name", 30, this.id != null? this.accountName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("normalBal", " Normal Balance")+"</td>";
	html += "<td>"+ gui.formArraySelect("normalBal", 100, normalBal, this.id != null? this.normalBal: "", false, "", true)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("accountType", " Account Type")+"</td>";
        html += "<td>"+ gui.formSelect("accountType", "qset.GLACCTYPES", "ACCTYPECODE", "ACCTYPENAME", "", "", this.id != null? this.accTypeCode: "", "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("accountGroup", " Account Group")+"</td>";
        html += "<td>"+ gui.formSelect("accountGroup", "qset.GLACCGRPS", "ACCGRPCODE", "ACCGRPNAME", "", "", this.id != null? this.accGrpCode: "", "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+ gui.formLabel("active", " Active")+"</td>";
	html += "<td>"+ gui.formCheckBox("active", (this.id != null && this.active == 1)? "checked": "", null, "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>"; 
        html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"account.save('code name normalBal accountType accountGroup'); return false;\"", "");
	if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"account.purge("+this.id+",'"+ this.accountName+"');\"", "");
        }
        html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
        html += "</td>";
	html += "</tr>";
        
        html += "</table>";
        
        html += gui.formEnd();
        
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
                    this.accountCode = sys.getNextNo(this.table, "ID", "", "", 4);
                }
                
                query = "INSERT INTO "+ this.table +" "
                        + "(ID, ACCOUNTCODE, ACCOUNTNAME, NORMALBAL, ACCTYPECODE, ACCGRPCODE, ACTIVE)"
                        + "VALUES"
                        + "("
                        + id +","
                        + "'"+ this.accountCode+ "', "
                        + "'"+ this.accountName+ "', "
                        + "'"+ this.normalBal+ "', "
                        + "'"+ this.accTypeCode+ "', "
                        + "'"+ this.accGrpCode+ "', "
                        + this.active+" "
                        + ")";
                
            }else{
                
                query = "UPDATE "+ this.table +" SET "
                        + "ACCOUNTNAME      = '"+ this.accountName+ "', "
                        + "NORMALBAL        = '"+ this.normalBal+ "', "
                        + "ACCTYPECODE      = '"+ this.accTypeCode+ "', "
                        + "ACCGRPCODE       = '"+ this.accGrpCode+ "', "
                        + "ACTIVE           = "+ this.active+ " "
                        + "WHERE ID         = "+ this.id+ "";
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
    
    public Object purge()throws Exception{
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+ this.table+" WHERE ID = "+ this.id;
            
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