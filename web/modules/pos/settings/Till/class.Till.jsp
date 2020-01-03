<%@page import="bean.user.User"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Till{
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
    String table        = comCode+".PSTILLS";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String tillNo       = request.getParameter("code");
    String tillDesc     = request.getParameter("name");
    String userId       = request.getParameter("user");
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys system = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
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

                        list.add("TILLNO");
                        list.add("TILLDESC");
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
            
            String orderBy = "TILLNO ";
            String limitSql = "";

            switch(dbType){
                case "mysql":
                    limitSql = "LIMIT "+ session.getAttribute("startRecord")+ " , "+ session.getAttribute("maxRecord");
                    break;
                case "postgres":
                    limitSql = "OFFSET "+ session.getAttribute("startRecord")+ " LIMIT "+ session.getAttribute("maxRecord");
                    break;
            }

            gridSql = "SELECT * FROM "+ this.table+ " "+ filterSql+ " ORDER BY "+ orderBy+ limitSql;

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

                    Integer id      = rs.getInt("ID");
                    String tillNo   = rs.getString("TILLNO");
                    String tillDesc = rs.getString("TILLDESC");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+count+"</td>";
                    html += "<td>"+tillNo+"</td>";
                    html += "<td>"+tillDesc+"</td>";
                    html += "<td>"+edit+"</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
            }catch (SQLException e){
                html += e.getMessage();
            }
            catch (Exception e){
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
        
        String userName = "";
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.table+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.tillNo     = rs.getString("TILLNO");		
                    this.tillDesc   = rs.getString("TILLDESC");	
                    this.userId     = rs.getString("USERID");
                    
                    User user = new User(this.userId, comCode);
                    userName = user.userName;
                }
            }catch (SQLException e){
                html += e.getMessage();
            }
            catch (Exception e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 15, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(),"page.png", "", "")+" "+gui.formLabel("code", "Till No.")+"</td>";
	html += "<td>"+gui.formInput("text", "code", 10, this.id != null? this.tillNo: "" , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("name", "Till Description")+"</td>";
	html += "<td>"+gui.formInput("text", "name", 30, this.id != null? this.tillDesc: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "user-properties.png", "", "")+" "+gui.formLabel("user", "Default Attendant")+"</td>";
	html += "<td>"+ gui.formAutoComplete("user", 13, this.id != null? ""+ this.userId: "", "till.searchUser", "userId", this.id != null? ""+ this.userId: "")+ " <span id = \"spUserName\">"+ userName+ "</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"till.save('code name');\"", "");
//        if(this.id != null){
//            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"till.purge("+this.id+",'"+this.tillDesc+"');\"", "");
//        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
    public String searchUser(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.userId = (request.getParameter("userId") != null && ! request.getParameter("userId").trim().equals(""))? request.getParameter("userId"): null;
        
        html += gui.getAutoColsSearch(comCode+ ".SYSUSRS", "USERID, USERNAME", "", this.userId);
        
        return html;
    }
    
    public Object getUserDtls(){
        JSONObject obj = new JSONObject();
        
        if(this.userId == null || this.userId.trim().equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            User user = new User(this.userId, comCode);
            
            obj.put("userName", user.userName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "User ID '"+ this.userId+ "' details successfully retrieved.");
            
        }
        
        return obj;
    }
    
    
    public Object save(){
        JSONObject obj = new JSONObject();
        Sys system = new Sys();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
             
            String query;
            Integer saved = 0;
            
            if(this.id == null){
                Integer id = system.generateId(this.table, "ID");
                
                query = "INSERT INTO "+ this.table+ " "
                    + "(ID, TILLNO, TILLDESC, USERID)"
                    + "VALUES"
                    + "("
                    + id+","
                    + "'"+this.tillNo+"', "
                    + "'"+this.tillDesc+"', "
                    + "'"+this.userId+"' "
                    + ")";
                
            }else{
                query = "UPDATE "+this.table+" SET "
                    + "USERID       = '"+this.userId+"', "
                    + "TILLDESC     = '"+this.tillDesc+"' "
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
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public Object purge(){
        JSONObject obj = new JSONObject();

        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

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