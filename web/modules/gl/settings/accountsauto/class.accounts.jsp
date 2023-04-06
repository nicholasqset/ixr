<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class Accounts{
    String table            = "qset.GLACCOUNTS";
    String view             = "";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String accountCode      = request.getParameter("code") ;
    Integer autoCode        = request.getParameter("autoCode") != null? 1: null;
    String accountName      = request.getParameter("name");
    String accountDesc      = request.getParameter("desc");
    String normalBal        = request.getParameter("normalBal");
    String accTypeCode      = request.getParameter("accountType");
    String accGrpCode       = request.getParameter("accountGroup");
    Integer active          = request.getParameter("active") != null? 1: null;
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        Integer recordCount = system.getRecordCount(this.table, "");
        
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
                }else{
                    session.setAttribute("startRecord", 0);
                }
            }else{
                session.setAttribute("startRecord", 0);
            }

            gridSql = "SELECT * FROM "+ this.table +" "+ filterSql +" ORDER BY ACCOUNTCODE LIMIT "
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
                html += "<th>Account Code</th>";
                html += "<th>Account Name</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){
                    Integer id              = rs.getInt("ID");
                    String accountCode      = rs.getString("ACCOUNTCODE");
                    String accountName      = rs.getString("ACCOUNTNAME");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor +"\">";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ accountCode +"</td>";
                    html += "<td>"+ accountName +"</td>";
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
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getAccountTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"account.save('name normalBal accountType accountGroup'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Account\'), 0, 625, 350, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getAccountTab(){
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
                    this.accountDesc        = rs.getString("ACCOUNTDESC");
                    
                    this.normalBal          = rs.getString("NORMALBAL");		
                    this.accTypeCode        = rs.getString("ACCTYPECODE");		
                    this.accGrpCode         = rs.getString("ACCGRPCODE");
                    this.active             = rs.getInt("ACTIVE");		
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        HashMap<String, String> normalBal = new HashMap();
        normalBal.put("DR", "Debit");
        normalBal.put("CR", "Credit");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        String autoCodeUi = "";
        
        if(this.id == null){
            autoCodeUi  = gui.formCheckBox("autoCode", "checked", "", "onchange = \"account.toggleCodeUi();\"", "", "")+ "<span class = \"fade\"><label for = \"autoCode\"> No Auto</label></span>";
        }
        
        html += "<tr>";
	html += "<td width = \"22%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page.png", "", "") + gui.formLabel("code", " Account Code") +"</td>";
        html += "<td>"+ gui.formInput("text", "code", 15, this.id != null? this.accountCode: "" , "", "disabled") +" "+ autoCodeUi +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("name", " Account Name")+"</td>";
	html += "<td>"+ gui.formInput("text", "name", 30, this.id != null? this.accountName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "package.png", "", "") + gui.formLabel("desc", " Account Description")+"</td>";
	html += "<td>"+ gui.formInput("textarea", "desc", 40, this.id != null? this.accountDesc: "", "", "")+"</td>";
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
        
        html += "</table>";
        
        return html;
    }
    
    public Object save(){
        
        JSONObject obj      = new JSONObject();
        System system       = new System();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
	    String query = "";  
            
            if(this.id == null){
                Integer id = system.generateId(this.table, "ID");
                
                if(this.autoCode != null && this.autoCode == 1){
                    this.accountCode = system.getNextNo(this.table, "ID", "", "", 4);
                }
                
                query = "INSERT INTO "+ this.table +" "
                        + "(ID, ACCOUNTCODE, ACCOUNTNAME, ACCOUNTDESC, NORMALBAL, ACCTYPECODE, ACCGRPCODE, ACTIVE)"
                        + "VALUES"
                        + "("
                        + id +","
                        + "'"+ this.accountCode +"', "
                        + "'"+ this.accountName +"', "
                        + "'"+ this.accountDesc +"', "
                        + "'"+ this.normalBal +"', "
                        + "'"+ this.accTypeCode +"', "
                        + "'"+ this.accGrpCode +"', "
                        + this.active+" "
                        + ")";
                
                obj.put("code", this.accountCode);
                
            }else{
                
                query = "UPDATE "+ this.table +" SET "
                        + "ACCOUNTNAME      = '"+ this.accountName +"', "
                        + "ACCOUNTDESC      = '"+ this.accountDesc +"', "
                        + "NORMALBAL        = '"+ this.normalBal +"', "
                        + "ACCTYPECODE      = '"+ this.accTypeCode +"', "
                        + "ACCGRPCODE       = '"+ this.accGrpCode +"', "
                        + "ACTIVE           = "+ this.active +" "

                        + "WHERE ID         = "+ this.id +"";
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
    
}

%>