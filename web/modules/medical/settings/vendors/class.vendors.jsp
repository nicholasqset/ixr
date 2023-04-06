<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class Vendors{
    String table            = "HMVEN";
    String view             = "";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String vendId           = request.getParameter("vendId") ;
    Integer autoVendId      = request.getParameter("autoVendId") != null? 1: null;
    String vendName         = request.getParameter("vendName");
    String postalAdr        = request.getParameter("postalAdr");
    String postalCode       = request.getParameter("postalCode");
    String physicalAdr      = request.getParameter("physicalAdr");
    String telephone        = request.getParameter("telephone");
    String cellphone        = request.getParameter("cellphone");
    String email            = request.getParameter("email");
    
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

                        ArrayList<String> list = new ArrayList<String>();

                        list.add("VENDID");
                        list.add("VENDNAME");
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

            gridSql = "SELECT * FROM "+this.table+" "+filterSql+" ORDER BY VENDID LIMIT "
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

                html += "<table class = \"grid\" width=\"100%\" cellpadding=\"2\" cellspacing=\"0\" border=\"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Supplier No</th>";
                html += "<th>Name</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String vendId       = rs.getString("VENDID");
                    String vendName     = rs.getString("VENDNAME");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+count+"</td>";
                    html += "<td>"+vendId+"</td>";
                    html += "<td>"+vendName+"</td>";
                    html += "<td>"+edit+"</td>";
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
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"vendors.save('vendName'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Profile\'), 0, 625, 350, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getProfileTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        if(this.id != null){
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+ this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.vendId         = rs.getString("VENDID");		
                    this.vendName       = rs.getString("VENDNAME");		
                    this.postalAdr      = rs.getString("POSTALADR");		
                    this.postalCode     = rs.getString("POSTALCODE");		
                    this.physicalAdr    = rs.getString("PHYSICALADR");		
                    this.telephone      = rs.getString("TELEPHONE");		
                    this.cellphone      = rs.getString("CELLPHONE");		
                    this.email          = rs.getString("EMAIL");		
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        String autoVendIdUi = "";
        
        if(this.id == null){
            autoVendIdUi  = gui.formCheckBox("autoVendId", "checked", "", "onchange = \"vendors.toggleVendId();\"", "", "")+ "<span class = \"fade\"><label for = \"autoVendId\"> No Auto</label></span>";
        }
        
        html += "<tr>";
	html += "<td width = \"22%\" nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("vendId", "Supplier No") +"</td>";
        html += "<td>"+ gui.formInput("text", "vendId", 15, this.id != null? this.vendId: "" , "", "disabled") +" "+ autoVendIdUi +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+gui.formLabel("vendName", "Supplier Name")+"</td>";
	html += "<td>"+gui.formInput("text", "vendName", 25, this.id != null? this.vendName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td >"+gui.formIcon(request.getContextPath(),"email-open.png", "", "")+" "+gui.formLabel("postalAdr", "Postal Address")+"</td>";
	html += "<td >"+gui.formInput("text", "postalAdr", 25, this.id != null? this.postalAdr: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td >"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("postalCode", "Postal Code")+"</td>";
	html += "<td>"+gui.formInput("text", "postalCode", 15, this.id != null? this.postalCode: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("physicalAdr", "Physical Address")+"</td>";
	html += "<td >"+gui.formInput("textarea", "physicalAdr", 30, this.id != null? this.physicalAdr: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"telephone.png", "", "")+" "+gui.formLabel("telephone", "Telephone")+"</td>";
	html += "<td>"+gui.formInput("text", "telephone", 15, this.id != null? this.telephone: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"mobile-phone.png", "", "")+" "+gui.formLabel("cellphone", "Cell Phone")+"</td>";
	html += "<td>"+gui.formInput("text", "cellphone", 15, this.id != null? this.cellphone: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"email.png", "", "")+" "+gui.formLabel("email", "Email")+"</td>";
	html += "<td >"+gui.formInput("text", "email", 25, this.id != null? this.email: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public Object save(){
        
        JSONObject obj      = new JSONObject();
        System system       = new System();
        HttpSession session = request.getSession();
        String query = ""; 
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
	        
            if(this.id == null){
                Integer id = system.generateId(this.table, "ID");
                
                if(this.autoVendId != null && this.autoVendId == 1){
                    this.vendId = system.getNextNo(this.table, "ID", "", "", 4);
                }
                
                query = "INSERT INTO "+this.table+" "
                        + "(ID, VENDID, VENDNAME, "
                        + "POSTALADR, POSTALCODE, PHYSICALADR, TELEPHONE, CELLPHONE, EMAIL, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                        + "VALUES"
                        + "("
                        + id +","
                        + "'"+ this.vendId +"', "
                        + "'"+ this.vendName +"', "
                        + "'"+ this.postalAdr +"', "
                        + "'"+ this.postalCode +"', "
                        + "'"+ this.physicalAdr +"', "
                        + "'"+ this.telephone +"', "
                        + "'"+ this.cellphone +"', "
                        + "'"+ this.email +"', "
                        + "'"+ system.getLogUser(session) +"', "
                        + "'"+ system.getLogDate() +"', "
                        + "'"+ system.getLogTime() +"', "
                        + "'"+ system.getClientIpAdr(request) +"'"
                        + ")";
                
                obj.put("vendId", this.vendId);
                
            }else{
                
                query = "UPDATE "+this.table+" SET "
                        + "VENDNAME         = '"+ this.vendName +"', "
                        + "POSTALADR        = '"+ this.postalAdr +"', "
                        + "POSTALCODE       = '"+ this.postalCode +"', "
                        + "PHYSICALADR      = '"+ this.physicalAdr +"', "
                        + "TELEPHONE        = '"+ this.telephone +"', "
                        + "CELLPHONE        = '"+ this.cellphone +"', "
                        + "EMAIL            = '"+ this.email +"', "
                        + "AUDITUSER        = '"+ system.getLogUser(session) +"', "
                        + "AUDITDATE        = '"+ system.getLogDate() +"', "
                        + "AUDITTIME        = '"+ system.getLogTime() +"', "
                        + "AUDITIPADR       = '"+ system.getClientIpAdr(request) +"' "

                        + "WHERE ID         = '"+ this.id +"'";
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