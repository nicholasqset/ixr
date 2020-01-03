<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.user.User"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%

final class Privilege{
    HttpSession session =request.getSession();
    String table    = ""+session.getAttribute("comCode")+".SYSPVGS";

    Integer id;
    String rightStatus  = request.getParameter("rightStatus");
    String roleCode     = request.getParameter("userRole");
    String parentId     = request.getParameter("parentId");
    String childId      = request.getParameter("childId");
    
    public String getModule(){

        Gui gui = new Gui();

        String html = "";

        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

        html += "<table width = \"50%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

        html += "<tr>";
	html += "<td width = \"20%\" nowrap>"+gui.formIcon(request.getContextPath(), "group.png", "", "")+" "+gui.formLabel("userRole", "User Role")+"</td>";
	html += "<td>"+gui.formSelect("userRole", ""+session.getAttribute("comCode")+".SYSROLES", "ROLECODE", "ROLENAME", "", "", this.id != null? this.roleCode: "", "onchange = \"rights.getUserGrpRights();\"", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td id = \"tdRightsUI\">&nbsp;</td>";
	html += "</tr>";

        html += "</table>";
        html += gui.formEnd();

        return html;
    }
    
    public Object getUserGrpRights(){
        JSONObject obj = new JSONObject();
        
        if(this.roleCode != ""){
            obj.put("success", new Integer(1));
            obj.put("message", "ok");
        }else{
            obj.put("success", new Integer(0));
            obj.put("message", "Select User Group Please.");
        }
        
        return obj;
    }
    
    public String getMenu(){
        String html = "";
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;

        try{
            stmt = conn.createStatement();
            String query = "SELECT * FROM "+session.getAttribute("comCode")+".SYSMENUS WHERE MENUPARENT = 0 AND USERVSB = 1 ORDER BY MENUPOS ";
            ResultSet rs = stmt.executeQuery(query);
            html += "<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">";
            while(rs.next()){
                Integer menuCode    = rs.getInt("MENUCODE");			
                String menuName     = rs.getString("MENUNAME");	

                if(this.menuHasChildren(menuCode)){
                    String toggleMenu       = "onclick=\"rights.toggleMenu('"+menuCode+"');\"";

                    html += "<tr>";
                    html += "<td width = \"2px\" style = \"text-align: center;\">";
                    html += "<img id = \"img"+menuCode+"\" src = \""+request.getContextPath()+"/images/menu/plus.gif\" "+toggleMenu+" />";
                    html += "</td>";
                    html += "<td nowrap> ";
                    html += "<div class = \"menu-parent\" >";
                    html += "<a href = \"javascript:;\" "+toggleMenu+">";		
                    html += menuName;
                    html += "</a>";
                    html += "</div>";
                    html += "</td>";
                    html += "</tr>";

                    html += "<tr id = \"row"+menuCode+"\" style = \"display:none;\">";
                    html += "<td width = \"1px\"></td>";
                    html += "<td >";
                    html += "<div id = \"menu"+menuCode+"\" style = \"display:none;\" >";
                    html += this.getChildrenMenu(menuCode);
                    html += "</div>";
                    html += "</td>";
                    html += "</tr>";

                }else{

                    html += "<tr>";
                    html += "<td width = \"2px\" style = \"text-align: center;\">&nbsp;</td>";
                    html += "<td nowrap> ";
                    html += "<div class = \"menu-parent\">";
                    html += "<a href = \"javascript:;\">";		
                    html += menuName;
                    html += "</a>";
                    html += "</div>";
                    html += "</td>";
                    html += "</tr>";

                }
            }
            html += "</table>";
            rs.close();
        }catch (SQLException e){

        }
        
        return html;
    }
    
    public Boolean menuHasChildren(Integer menuCode){
        Boolean hasChildren = false;
        Integer count = 0;
        
         Statement stmt = null;

        Connection conn = ConnectionProvider.getConnection();
        try{
            stmt = conn.createStatement();
            String query = "SELECT COUNT(*)CT FROM "+session.getAttribute("comCode")+".SYSMENUS WHERE MENUPARENT = "+ menuCode+ " AND USERVSB = 1 ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                count = rs.getInt("CT");			
            }
        }catch (SQLException e){
            e.getMessage();
        }

        if(count > 0){
            hasChildren = true;
        }
        
        return hasChildren;
    }
    
    public String getChildrenMenu(Integer menuCode){
        String html = "";
        String rightStatus = "";
        
        Gui gui = new Gui();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        Integer countRecord = 0;
        
        try{
            stmt = conn.createStatement();
            String query = "SELECT COUNT(*)CT FROM "+session.getAttribute("comCode")+".SYSMENUS WHERE MENUPARENT = "+ menuCode+ " AND USERVSB = 1 ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                countRecord = rs.getInt("CT");			
            }
            rs.close();
            
        }catch (SQLException  e){
            html += e.getMessage();
        }
        catch (Exception  e){
            html += e.getMessage();
        }
        
        try{
            stmt = null;
            stmt = conn.createStatement();
            String query = "SELECT * FROM "+session.getAttribute("comCode")+".SYSMENUS WHERE MENUPARENT = "+menuCode+" AND USERVSB = 1  ORDER BY MENUPOS";
            ResultSet rs = stmt.executeQuery(query);
            Integer count = 1;

            html += "<table width = \"100%\" cellpadding = \"0\" cellspacing = \"0\">";

            while(rs.next()){
                Integer menuCodeChild       = rs.getInt("MENUCODE");
                String menuNameChild        = rs.getString("MENUNAME");

                String toggleMenu           = "onclick=\"rights.toggleMenu('"+menuCodeChild+"');\"";
                String iconChildBranch      = count < countRecord? "branch.gif": "branch-bottom.gif";
                iconChildBranch             = "<img src=\""+request.getContextPath()+"/images/menu/"+iconChildBranch+"\" />";	
                String iconChild            = "<img src=\""+request.getContextPath()+"/images/icons/"+rs.getString("ICON")+"\" border=\"0\" />";	
                String treeLine             = "";

                if(this.menuHasChildren(menuCodeChild)){
                    treeLine        = count < countRecord? "menu-tree-line": "";
                }else{
                    treeLine        = "";
                }

                if(this.menuHasChildren(menuCodeChild)){
                    rightStatus = this.hasRight(menuCode, menuCodeChild) == true ? "checked": "";

                    html += "<tr>";
                    html += "<td width = \"2px\" style = \"text-align: center;\">";
                    html += "<img id = \"img"+menuCodeChild+"\" src = \""+request.getContextPath()+"/images/menu/plus.gif\" "+toggleMenu+"/>";;
                    html += "</td>";
                    html += "<td colspan = \"2px\" nowrap>";
                    html += "<div class = \"menu-child\" >";
                    html += "<a href = \"javascript:;\" "+toggleMenu+"> ";		
                    html += iconChild+menuNameChild;
                    html += "</a>";
                    html += "</div>";
                    html += "</td>";
                    html += "<td style = \"text-align: right;\">";
                    html += gui.formCheckBox("allowDeny["+menuCodeChild+"]", rightStatus, "", "onchange = \"rights.save("+menuCode+", "+menuCodeChild+");\"", "", "");
                    html += "</td>";
                    html += "</tr>";

                    html += "<tr id = \"row"+menuCodeChild+"\" style = \"display:none;\">";
                    html += "<td width = \"1px\"  valign = \"top\" class = \""+treeLine+"\">&nbsp;";
                    html += "</td>";
                    html += "<td valign = \"top\" colspan = \"3\">";
                    html += "<div class = \"menu-child\" id = \"menu"+menuCodeChild+"\" style = \"display:none;\">";
                    html += this.getChildrenMenu(menuCodeChild);
                    html += "</div>";
                    html += "</td>";
                    html += "</tr>";
                }else{

                    rightStatus = this.hasRight(menuCode, menuCodeChild) == true ? "checked": "";

                    html += "<tr>";	
                    html += "<td width = \"5px\" valign = \"top\" nowrap>";
                    html += iconChildBranch;
                    html += "</td>";
                    html += "<td width = \"5px\" valign=\"top\" nowrap>";
                    html += iconChild;
                    html += "</td>";
                    html += "<td nowrap>";
                    html += "<div class = \"menu-child-link\" id = \"menu"+menuCodeChild+"\">";
                    html += "<a href = \"javascript:;\">";				
                    html += menuNameChild;
                    html += "</a>";
                    html += "</div>";
                    html += "</td>";
                    html += "<td style = \"text-align: right;\">";
                    html += gui.formCheckBox("allowDeny["+menuCodeChild+"]", rightStatus, "", "onchange = \"rights.save("+menuCode+", "+menuCodeChild+");\"", "", "");
                    html += "</td>";
                    html += "</tr>";

                }

                ++count;
            }
            html += "</table>";
        }catch(SQLException e){
            html += e.getMessage();
        }catch(Exception e){
            html += e.getMessage();
        }
        
        return html;
    }

    public Boolean hasRight(Integer parentId, Integer childId){
        Boolean hasRight = false;
        
        Integer count = 0;
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT COUNT(*)CT FROM "+this.table+" WHERE "
                            + "ROLECODE = '"+this.roleCode+"' AND "
                            + "menupid = "+parentId+" AND "
                            + "menucid = "+childId+" ";
            
//            out.print(query);
            
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                count = rs.getInt("CT");			
            }
        }catch (SQLException e){
            e.printStackTrace();
            System.out.println(e.getMessage());
        }

        if(count > 0){
            hasRight = true;
        }
        
        return hasRight;
    }

//    public Object save(){
//        JSONObject obj  = new JSONObject();
//
//        System system   = new System();
//        HttpSession session     = request.getSession();
//        User user = new User(system.getLogUser(session));
//
//        try{
//            Connection conn  = ConnectionProvider.getConnection();
//            Statement stmt = conn.createStatement();
//
//            String query;
//            Integer saved   = 0;
//            String allowDeny;
//
//            if(this.rightStatus.equals("on")){
//                String purgeQuery = "DELETE FROM "+this.table+" WHERE "
//                                    + "ROLECODE    = '"+this.roleCode+"' AND "
//                                    + "menupid     = "+this.parentId+" AND "
//                                    + "menucid      = "+this.childId+"";
//                
//                Integer purged = stmt.executeUpdate(purgeQuery);
//                
//                Integer id = system.generateId(this.table, "ID");
//                
//                query = "INSERT INTO "+this.table+" "
//                        + "(ID, ROLECODE, menupid, menucid)"
//                        + "VALUES"
//                        + "("
//                        + id+","
//                        + "'"+this.roleCode+"',"
//                        + "'"+this.parentId+"',"
//                        + "'"+this.childId+"'"
//                        + ")";
//                
//                allowDeny = "allow";
//                
//            }else{
//                query = "DELETE FROM "+this.table+" WHERE "
//                        + "ROLECODE    = '"+this.roleCode+"' AND "
//                        + "menupid     = "+this.parentId+" AND "
//                        + "menucid      = "+this.childId+"";
//                        
//                allowDeny = "deny";
//            }
//            
//            saved = stmt.executeUpdate(query);
//            
//            if(saved == 1){
//                if(user.roleCode.equals(this.roleCode)){
//                    obj.put("reloadMenu", new Integer(1));
//                }else{
//                    obj.put("reloadMenu", new Integer(0));
//                }
//                obj.put("allowDeny", allowDeny);
//                obj.put("success", new Integer(1));
//                obj.put("message", "Right allowed.");
//            }else{
//                obj.put("success", new Integer(0));
//                obj.put("message", "Oops! An Un-expected error occured while saving record.");
//            }
//
//        }catch (SQLException e){
//            obj.put("success", new Integer(0));
//            obj.put("message", e.getMessage());
//        }catch (Exception e){
//            obj.put("success", new Integer(0));
//            obj.put("message", e.getMessage());
//        }
//
//        return obj;
//    }
    
    public Object save(){
        JSONObject obj  = new JSONObject();

//        Sys sys   = new Sys();
//        HttpSession session     = request.getSession();
//        QSetUser qSetUser       = new QSetUser(sys.getLogUserId(session));

        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query;
            Integer saved   = 0;
            String allowDeny;
            
            String purgeQuery = null;

            if(this.rightStatus.equals("on")){
                purgeQuery = "DELETE FROM "+this.table+" WHERE "
                                    + "ROLECODE    = '"+this.roleCode+"' AND "
                                    + "MENUPID     = "+this.parentId+" AND "
                                    + "MENUCID      = "+this.childId+"";
                
                Integer purged = stmt.executeUpdate(purgeQuery);
                
//                Integer id = sys.generateId(this.table, "ID");
                
                query = "INSERT INTO "+ this.table+ " "
//                        + "(ID, ROLECODE, MENUPID, MENUCID)"
                        + "(ROLECODE, MENUPID, MENUCID)"
                        + "VALUES"
                        + "("
//                        + id+","
                        + "'"+this.roleCode+"',"
                        + "'"+this.parentId+"',"
                        + "'"+this.childId+"'"
                        + ")";
                
                allowDeny = "allow";
                
            }else{
                query = "DELETE FROM "+this.table+" WHERE "
                        + "ROLECODE    = '"+this.roleCode+"' AND "
                        + "MENUPID     = "+this.parentId+" AND "
                        + "MENUCID      = "+this.childId+"";
                        
                allowDeny = "deny";
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("allowDeny", allowDeny);
                obj.put("success", new Integer(1));
                obj.put("message", "Privilege allowed.");
            }else{
                obj.put("purgeQuery", purgeQuery);
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