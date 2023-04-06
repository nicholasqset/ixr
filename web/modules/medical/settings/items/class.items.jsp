<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class Items{
    String table        = "HMITEMS";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    Integer autoCode    = request.getParameter("autoCode") != null? 1: null;
    String itemCode     = request.getParameter("code");
    String itemName     = request.getParameter("name");
    String itemDesc     = request.getParameter("desc");
    Integer vatable     = request.getParameter("vatable") != null? 1: null;
    Integer isDrug      = request.getParameter("isDrug") != null? 1: null;
    Integer stocked     = request.getParameter("stocked") != null? 1: null;
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        Integer recordCount = 0;
        
        try{
            stmt = conn.createStatement();
            String query = "SELECT COUNT(*) FROM "+this.table;
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                recordCount = rs.getInt("COUNT(*)");			
            }
        }catch (SQLException e){
            html += e.getMessage();
        }
        
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

                    list.add("ITEMCODE");
                    list.add("ITEMNAME");
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
        
        gridSql = "SELECT * FROM "+this.table+" "+filterSql+" ORDER BY ITEMCODE LIMIT "
                + session.getAttribute("startRecord")
                + " , "
                + session.getAttribute("maxRecord");
        
        try{
            stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(gridSql);
                
            Integer startRecordHidden = Integer.parseInt(session.getAttribute("startRecord").toString()) + Integer.parseInt(session.getAttribute("maxRecord").toString());

            html += gui.formInput("hidden", "maxRecord", 10, session.getAttribute("maxRecord").toString(), "", "");
            html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
            html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
            html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

            html += "<table class = \"grid\" width=\"100%\" cellpadding=\"2\" cellspacing=\"0\" border=\"0\">";

            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Code</th>";
            html += "<th>Name</th>";
            html += "<th>Options</th>";
            html += "</tr>";

            Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

            while(rs.next()){

                Integer id          = rs.getInt("ID");
                String itemCode     = rs.getString("ITEMCODE");
                String itemName     = rs.getString("ITEMNAME");

                String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                html += "<tr bgcolor = \""+bgcolor+"\">";
                html += "<td>"+count+"</td>";
                html += "<td>"+itemCode+"</td>";
                html += "<td>"+itemName+"</td>";
                html += "<td>"+edit+"</td>";
                html += "</tr>";

                count++;
            }
            html += "</table>";
        }catch(SQLException e){
            html += e.getMessage();
        }
        
        if(recordCount == 0){
            html += "No records found.";
        }
        
        return html;
    }
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        if(this.id != null){
            
            try{
                stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.itemCode       = rs.getString("ITEMCODE");		
                    this.itemName       = rs.getString("ITEMNAME");		
                    this.itemDesc       = rs.getString("ITEMDESC");		
                    this.vatable        = rs.getInt("VATABLE");		
                    this.isDrug         = rs.getInt("ISDRUG");		
                    this.stocked        = rs.getInt("STOCKED");		
                }
            }catch (SQLException e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
        
        String autoCodeUi = "";
        
        if(this.id == null){
            autoCodeUi  = gui.formCheckBox("autoCode", "checked", "", "onchange = \"items.toggleCodeUi();\"", "", "")+ "<span class = \"fade\"><label for = \"autoCode\"> No Auto</label></span>";
        }
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("code", "Item Code") +"</td>";
        html += "<td>"+ gui.formInput("text", "code", 15, this.id != null? this.itemCode: "" , "", "disabled") +" "+ autoCodeUi +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("name", "Item Name")+"</td>";
	html += "<td>"+gui.formInput("text", "name", 30, this.id != null? this.itemName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td style = \"vertical-align: top;\">"+gui.formIcon(request.getContextPath(),"package-green.png", "", "")+" "+gui.formLabel("desc", "Item Desc")+"</td>";
	html += "<td>"+gui.formInput("textarea", "desc", 40, this.id != null? this.itemDesc: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+gui.formLabel("vatable", "Vatable")+"</td>";
	html += "<td>"+gui.formCheckBox("vatable", (this.id != null && this.vatable == 1)? "checked": "", null, "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+gui.formLabel("isDrug", "Is Drug")+"</td>";
	html += "<td>"+gui.formCheckBox("isDrug", (this.id != null && this.isDrug == 1)? "checked": "", null, "", "", "")+"</td>";
	html += "</tr>";
        
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+" "+gui.formLabel("stocked", "Stocked")+"</td>";
	html += "<td>"+gui.formCheckBox("stocked", (this.id != null && this.stocked == 1)? "checked": "", null, "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"items.save('name');\"", "");
        if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"items.purge("+this.id+",'"+this.itemName+"');\"", "");
        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
    
    public Object save(){
        
        Integer saved = 0;
        
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;
        
        try{
            stmt = conn.createStatement();
            
            Integer id;
                    
            String query;
            
            if(this.id == null){
                
                id = system.generateId(this.table, "ID");
                
                if(this.autoCode != null && this.autoCode == 1){
                    this.itemCode = system.getNextNo(this.table, "ID", "", "M", 6);
                }
                
                query = "INSERT INTO "+this.table+" "
                        + "(ID, ITEMCODE, ITEMNAME, ITEMDESC, VATABLE, ISDRUG, STOCKED)"
                        + "VALUES"
                        + "("
                        + id+","
                        + "'"+this.itemCode+"',"
                        + "'"+this.itemName+"',"
                        + "'"+this.itemDesc+"',"
                        + this.vatable+","
                        + this.isDrug+","
                        + this.stocked+""
                        + ")";
                
                
                obj.put("code", this.itemCode);
                
            }else{
                
                query = "UPDATE "+this.table+" SET "
                        
                    + "ITEMNAME   = '"+this.itemName+"', "
                    + "ITEMDESC   = '"+this.itemDesc+"', "
                    + "VATABLE    = "+this.vatable+", "
                    + "ISDRUG     = "+this.isDrug+", "
                    + "STOCKED    = "+this.stocked+" "
                        
                    + "WHERE ID   = "+this.id;
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
            }
            
        }catch (SQLException e){

        }
        
        return obj;
    }
    
    public Object purge(){
        
         Connection conn = ConnectionProvider.getConnection();
         Statement stmt = null;
         
         JSONObject obj = new JSONObject();
         
         try{
            stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+this.table+" WHERE ID = "+this.id;
            
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