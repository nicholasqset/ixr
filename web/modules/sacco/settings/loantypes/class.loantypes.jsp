<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class LoanTypes{
    String table            = "SCLOANTYPES";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String loanTypeCode     = request.getParameter("code");
    String loanTypeName     = request.getParameter("name");
    
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

                        list.add("LOANTYPECODE");
                        list.add("LOANTYPENAME");
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

            gridSql = "SELECT * FROM "+this.table+" "+filterSql+" ORDER BY LOANTYPECODE LIMIT "
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
                html += "<th>Code</th>";
                html += "<th>Name</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id              = rs.getInt("ID");
                    String loanTypeCode     = rs.getString("LOANTYPECODE");
                    String loanTypeName     = rs.getString("LOANTYPENAME");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+count+"</td>";
                    html += "<td>"+loanTypeCode+"</td>";
                    html += "<td>"+loanTypeName+"</td>";
                    html += "<td>"+edit+"</td>";
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
        
        if(this.id != null){
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.loanTypeCode      = rs.getString("LOANTYPECODE");		
                    this.loanTypeName      = rs.getString("LOANTYPENAME");		
                }
            }catch (SQLException e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(),"page.png", "", "")+" "+gui.formLabel("code", "Loan Type Code")+"</td>";
	html += "<td>"+gui.formInput("text", "code", 10, this.id != null? this.loanTypeCode: "" , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("name", "Loan Type Name")+"</td>";
	html += "<td>"+gui.formInput("text", "name", 30, this.id != null? this.loanTypeName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"loanTypes.save('code name');\"", "");
        if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"loanTypes.purge("+this.id+",'"+this.loanTypeName+"');\"", "");
        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
    
    public Object save(){
        
        
        
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            
            String query;
            
            Integer saved = 0;
            
            if(this.id == null){
                Integer id = system.generateId(this.table, "ID");
                
                query = "INSERT INTO "+this.table+" "
                    + "(ID, LOANTYPECODE, LOANTYPENAME)"
                    + "VALUES"
                    + "("
                    + id +","
                    + "'"+ this.loanTypeCode +"',"
                    + "'"+ this.loanTypeName +"'"
                    + ")";
            }else{
                
                query = "UPDATE "+this.table+" SET "
                    + "LOANTYPECODE = '"+ this.loanTypeCode +"',"
                    + "LOANTYPENAME = '"+ this.loanTypeName +"'"
                    + "WHERE ID     = "+ this.id;
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
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
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