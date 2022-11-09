<%@page import="org.json.JSONObject"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Users{
    HttpSession session = request.getSession();
    
    String comCode      = session.getAttribute("comCode").toString();
    
    String table        = comCode+".SYSUSRS";
    String view         = comCode+".viewsysusrs";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    
    String roleCode     = request.getParameter("userRole");
    String userId       = request.getParameter("userId");
    String userName     = request.getParameter("userName");
    String email        = request.getParameter("email");
    String cellphone    = request.getParameter("cellphone");
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        
        Sys sys = new Sys();
        
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

                        ArrayList<String> list = new ArrayList<>();

                        list.add("USERID");
                        list.add("USERNAME");
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

           String orderBy = "USERID ";
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

                gridSql = "SELECT * FROM "+this.view+" "+filterSql+" ORDER BY "+ orderBy+ limitSql;

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
                html += "<th>User ID</th>";
                html += "<th>User Name</th>";
//                html += "<th>User Group</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String userId       = rs.getString("USERID");
                    String userName     = rs.getString("USERNAME");
//                    String roleName     = rs.getString("ROLENAME");

                    String bgcolor = (count%2>0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ userId+ "</td>";
                    html += "<td>"+ userName+ "</td>";
//                    html += "<td>"+ roleName+ "</td>";
                    html += "<td>"+ edit+"</td>";
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
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        if(this.id != null){
            try{
                stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.userId         = rs.getString("USERID");		
                    this.userName       = rs.getString("USERNAME");		
                    this.email          = rs.getString("EMAIL");		
                    this.cellphone      = rs.getString("CELLPHONE");		
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
        
        html += "<tr>";
	html += "<td width = \"15%\">"+gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+" "+gui.formLabel("userId", "User ID")+"</td>";
	html += "<td>"+gui.formInput("text", "userId", 25, this.id != null? this.userId: "", "", "")+"<span style = \"color: grey;\"> ...can be email</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(), "user-properties.png", "", "")+" "+gui.formLabel("userName", "User Name")+"</td>";
	html += "<td>"+gui.formInput("text", "userName", 25, this.id != null? this.userName: "", "", "")+"</td>";
	html += "</tr>";
        
//        html += "<tr>";
//	html += "<td>"+gui.formIcon(request.getContextPath(), "email.png", "", "")+" "+gui.formLabel("email", "Email")+"</td>";
//	html += "<td>"+gui.formInput("text", "email", 25, this.id != null? this.email: "", "", "")+"</td>";
//	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(), "phone.png", "", "")+" "+gui.formLabel("cellphone", "Cellphone")+"</td>";
	html += "<td>"+gui.formInput("text", "cellphone", 25, this.id != null? this.cellphone: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"users.save('userId userName email cellphone');\"", "");
        if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"users.purge("+this.id+",'"+this.userId+"');\"", "");
        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
    
    public Object save() throws Exception{
        Integer saved = 0;
        
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        try{
            stmt = conn.createStatement();
            
            String query;
            
            if(this.id == null){
                Integer id = sys.generateId(this.table, "ID");
                
                query = "INSERT INTO "+this.table+" "
                    + "(ID, USERID, PASSWORD, USERNAME, EMAIL, CELLPHONE)"
                    + "VALUES"
                    + "("
                    + id+","
                    + "'"+this.userId+"',"
                    + "'******',"
                    + "'"+this.userName+"',"
//                    + "'"+this.email+"',"
                    + "'"+this.userId+"',"
                    + "'"+this.cellphone+"'"
                    + ")";             
                
                
            }else{
                query = "UPDATE "+this.table+" SET "
//                    + "USERID       = '"+this.userId+"',"
//                    + "USERNAME     = '"+this.userName+"',"
                    + "USERNAME     = '"+this.userName+"'"
//                    + "EMAIL        = '"+this.email+"',"
//                    + "CELLPHONE    = '"+this.cellphone+"'"
                    + "WHERE ID     = "+this.id;
            }
            
            if(! sys.emailValid(this.userId)){
//                obj.put("success", new Integer(0));
//                obj.put("message", "Invalid email");
                
//                return obj;
            }
            
            saved = stmt.executeUpdate(query);
            if(saved == 1){
                
                this.updateCoUsers();
                
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
    
    public Object purge() throws Exception{
         Connection conn = ConnectionProvider.getConnection();
         Statement stmt = null;
         
         JSONObject obj = new JSONObject();
         
         try{
            stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+this.table+" WHERE ID = "+this.id;
            
//                Integer purged = stmt.executeUpdate(query);
                Integer purged = 0;
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
    
    public void updateCoUsers(){
        Sys sys = new Sys();
        Boolean userExists = sys.recordExists("sys.com_users", "cu_usr_id = '"+userId+"'");
        if(! userExists){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = ""
                        + "INSERT INTO sys.com_users "
                        + "("
                        + "cu_com_code, cu_usr_id"
                        + ")"
                        + "VALUES"
                        + "("
                        + "'"+this.comCode+"',"
                        + "'"+this.userId+"'"
                        + ")";       
                Integer saved = stmt.executeUpdate(query);
                if(saved == 1){
//                    out.println("...user saved for co access..!");
                }else{
//                    out.println("...user couldnt be saved for co access..");
                }
            }catch(Exception e){
//                out.println(e.getMessage());
            }
        }else{
//            out.println("...user already exits..");
        }
    }
    
}

%>