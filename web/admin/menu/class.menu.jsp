<%@page import="java.util.HashMap"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class Menu{
    String table    = "qset.SYSMENU";
        
    Integer menuCode    = request.getParameter("menuCode") != null? Integer.parseInt(request.getParameter("menuCode")): null;
    String menuName     = request.getParameter("menuName");
    String menuDesc     = request.getParameter("menuDesc");
    String menuUrl      = request.getParameter("menuUrl");
    String menuIcon     = request.getParameter("menuIcon");
    Integer menuParent  = (request.getParameter("menuParent") != null && ! request.getParameter("menuParent").trim().equals(""))? Integer.parseInt(request.getParameter("menuParent")): 0;
    Integer menuPos     = request.getParameter("menuPos") != null? Integer.parseInt(request.getParameter("menuPos")): null;
    Integer userVsb     = request.getParameter("visible") != null? 1: null;
    
    public String getModule(){
        String html;
	
	html = "<div>";
	html += "<table width = \"100%\" cellpadding = \"4\" cellspacing = \"1\" >";
	
	html += "<tr>";
	html += "<td width = \"50%\" style = \"border: 1px dotted #4185F3; vertical-align: top;\">"+this.getMenu()+"</td>";
	html += "<td style = \"border: 1px dotted #4185F3; vertical-align: top;\"><div id=\"divMenuEditor\">"+this.getMenuEditor()+"</div></td>";
	html += "</tr>";
	
	html += "</table>";
	html += "</div>";
	
	return html;
    }
    
    public String getMenu(){
        String html = "";
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;

        try{
            stmt = conn.createStatement();
            String query = "SELECT * FROM "+this.table+" WHERE MENUPARENT = 0 ORDER BY MENUPOS ";
            ResultSet rs = stmt.executeQuery(query);
            html += "<table width = \"100%\" cellpadding = \"0\" cellspacing = \"0\" >";
            while(rs.next()){
                Integer menuCode    = rs.getInt("MENUCODE");			
                String menuName     = rs.getString("MENUNAME");	

                if(this.menuHasChildren(menuCode)){
                    String toggleMenu       = "onclick=\"menu.toggleMenu('"+menuCode+"');\"";

                    html += "<tr>";
                    html += "<td width = \"2px\" style = \"text-align: center;\">";
                    html += "<img id = \"img"+menuCode+"\" src = \""+request.getContextPath()+"/assets/img/menu/plus.gif\" "+toggleMenu+" />";
                    html += "</td>";
                    html += "<td nowrap> ";
                    html += "<div class = \"menu-parent\" >";
                    html += "<a href = \"javascript:;\" "+toggleMenu+">";		
                    html += menuName;
                    html += "</a>";
                    html += "</div>";
                    html += "</td>";
                    html += "<td style = \"text-align: right;\">";
                    html += "<div class = \"menu-action-link\">";
                    html += "<a href = \"javascript:;\" onclick = \"menu.addMenu("+menuCode+");return false;\">add</a>";
                    html += " | ";
                    html += "<a href = \"javascript:;\" onclick = \"menu.editMenu("+menuCode+");return false;\">edit</a>";
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
                    html += "<a href = \"javascript:;\"f>";		
                    html += menuName;
                    html += "</a>";
                    html += "</div>";
                    html += "</td>";
                    html += "<td style = \"text-align: right;\">";
                    html += "<div class = \"menu-action-link\">";
                    html += "<a href = \"javascript:;\" onclick = \"menu.addMenu("+menuCode+");return false;\">add</a>";
                    html += " | ";
                    html += "<a href = \"javascript:;\" onclick = \"menu.editMenu("+menuCode+");return false;\">edit</a>";
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
            String query = "SELECT COUNT(*)CT FROM "+this.table+" WHERE MENUPARENT = "+menuCode;
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
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        Integer countRecord = 0;
        
        try{
            stmt = conn.createStatement();
            String query = "SELECT COUNT(*)CT FROM "+this.table+" WHERE MENUPARENT = "+menuCode;
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                countRecord = rs.getInt("CT");			
            }
            rs.close();
            
        }catch (SQLException  e){
            e.getMessage();
        }
        
        try{
            stmt = null;
            stmt = conn.createStatement();
            String query = "SELECT * FROM "+this.table+" WHERE MENUPARENT = "+menuCode+" ORDER BY MENUPOS";
            ResultSet rs = stmt.executeQuery(query);
            Integer count = 1;

            html += "<table width = \"100%\" cellpadding = \"0\" cellspacing = \"0\">";

            while(rs.next()){
                Integer menuCodeChild       = rs.getInt("MENUCODE");
                String menuNameChild        = rs.getString("MENUNAME");

                String toggleMenu           = "onclick=\"menu.toggleMenu('"+ menuCodeChild+ "');\"";
                String iconChildBranch      = count < countRecord? "branch.gif": "branch-bottom.gif";
                iconChildBranch             = "<img src=\""+request.getContextPath()+"/assets/img/menu/"+ iconChildBranch+ "\" />";	
                String iconChild            = "<img src=\""+request.getContextPath()+"/assets/img/icons/"+ rs.getString("ICON")+"\" border=\"0\" />";	
                String treeLine             = "";

                if(this.menuHasChildren(menuCodeChild)){
                    treeLine        = count < countRecord? "menu-tree-line": "";
                }else{
                    treeLine        = "";
                }

                if(this.menuHasChildren(menuCodeChild)){
                    html += "<tr>";
                    html += "<td width = \"2px\" style = \"text-align: center;\" >";
                    html += "<img id = \"img"+menuCodeChild+"\" src=\""+request.getContextPath()+"/assets/img/menu/plus.gif\" "+toggleMenu+"/>";;
                    html += "</td>";
                    html += "<td colspan = \"2\" nowrap>";
                    html += "<div class = \"menu-child\" >";
                    html += "<a href = \"javascript:;\" "+toggleMenu+"> ";		
                    html += iconChild+menuNameChild;
                    html += "</a>";
                    html += "</div>";
                    html += "</td>";
                    html += "<td style = \"text-align: right;\">";
                    html += "<div class = \"menu-action-link\">";
                    html += "<a href = \"javascript:;\" onclick=\"menu.addMenu("+menuCodeChild+");return false;\">add</a>";
                    html += " | ";
                    html += "<a href = \"javascript:;\" onclick=\"menu.editMenu("+menuCodeChild+");return false;\">edit</a>";
                    html += "</div>";
                    html += "</td>";
                    html += "</tr>";

                    html += "<tr id=\"row"+menuCodeChild+"\" style=\"display:none;\">";
                    html += "<td width = \"1px\"  valign=\"top\" class=\""+treeLine+"\">&nbsp;";
                    html += "</td>";
                    html += "<td valign = \"top\" colspan = \"3\">";
                    html += "<div class = \"menu-child\" id=\"menu"+menuCodeChild+"\" style=\"display:none;\">";
                    html += this.getChildrenMenu(menuCodeChild);
                    html += "</div>";
                    html += "</td>";
                    html += "</tr>";
                }else{
                    html += "<tr>";	
                    html += "<td width = \"5px\" valign = \"top\" nowrap>";
                    html += iconChildBranch;
                    html += "</td>";
                    html += "<td width = \"5px\" valign = \"top\" nowrap>";
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
                    html += "<div class = \"menu-action-link\">";
                    html += "<a href = \"javascript:;\" onclick=\"menu.addMenu("+menuCodeChild+");return false;\">add</a>";
                    html += " | ";
                    html += "<a href = \"javascript:;\" onclick=\"menu.editMenu("+menuCodeChild+");return false;\">edit</a>";
                    html += "</div>";
                    html += "</td>";
                    html += "</tr>";

                }

                ++count;
            }
            html += "</table>";
        }catch(SQLException e){
            
        }
        
        return html;
    }
    
    public String getMenuEditor(){
        String html = "";
        Gui gui = new Gui();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        if(this.menuParent != null){
            
            try{
                stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE MENUCODE = "+this.menuParent;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    menuParent  = rs.getInt("MENUPARENT");		
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
        }
        
        Integer menuParentEdit = null; //menu parent from edit
        
        if(this.menuCode != null){
            
            try{
                stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE MENUCODE = "+this.menuCode;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.menuName   = rs.getString("MENUNAME");		
                    this.menuDesc   = rs.getString("MENUDESC");		
                    this.menuUrl    = rs.getString("URL");		
                    this.menuIcon   = rs.getString("ICON");		
                    this.menuPos    = rs.getInt("MENUPOS");		
                    menuParentEdit  = rs.getInt("MENUPARENT");	
                    this.userVsb    = rs.getInt("USERVSB");
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        if(this.menuCode != null){
            html += gui.formInput("hidden", "menuCode", 30, ""+this.menuCode, "", "");
        }
        
        html += "<table class = \"module\" width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"20%\">"+gui.formIcon(request.getContextPath(),"page.png", "", "")+" "+gui.formLabel("menuName", "Menu Name")+"</td>";
	html += "<td>"+gui.formInput("text", "menuName", 30, this.menuCode != null? this.menuName: "" , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("menuDesc", "Menu Description")+"</td>";
	html += "<td>"+gui.formInput("text", "menuDesc", 30, this.menuCode != null? this.menuDesc: "" , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-white-go.png", "", "")+" "+gui.formLabel("menuParent", "Menu Parent")+"</td>";
	html += "<td>";
        
        String defaultMenuCode = "";
        
        if(this.menuCode != null){
            defaultMenuCode = menuParentEdit+ "";
        }else{
            String menuParent = request.getParameter("menuParent");
            if(menuParent != null && ! menuParent.trim().equals("")){
                this.menuParent = Integer.parseInt(menuParent);
            }
            defaultMenuCode = this.menuParent+ "";
//            html += this.menuParent;
        }
        
        html += gui.formSelect("menuParent", this.table, "MENUCODE", "MENUDESC", "MENUCODE", "", defaultMenuCode, "", false);
	html += "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(), "page-white-link.png", "", "")+" "+gui.formLabel("menuUrl", "Url")+"</td>";
	html += "<td>"+gui.formInput("text", "menuUrl", 30, this.menuCode != null? this.menuUrl: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(), "page-white-picture.png", "", "")+" "+gui.formLabel("menuIcon", "Icon")+"</td>";
	html += "<td>"+gui.formInput("text", "menuIcon", 30, this.menuCode != null? this.menuIcon: "", "", "")+"</td>";
	html += "</tr>";
        
        if(this.menuCode != null){
            Integer countMenuParent = 0;
            try{
                stmt = conn.createStatement();
                String query = "SELECT COUNT(*)CT FROM "+this.table+" WHERE MENUPARENT = "+menuParentEdit;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    countMenuParent  = rs.getInt("CT");		
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            HashMap<String, String> menuPos = new HashMap();
            
            if(countMenuParent > 0){
                for(int i = 1; i <= countMenuParent; i++){
                    menuPos.put(""+i, ""+i);
                }
            }
            
            html += "<tr>";
            html += "<td>"+gui.formIcon(request.getContextPath(), "actions-view-sort-ascending.png", "", "")+" "+gui.formLabel("menuPos", "Sort")+"</td>";
            html += "<td>"+gui.formArraySelect("menuPos", 100,  new  HashMap(menuPos), ""+this.menuPos, false, "", true)+"</td>";
            html += "</tr>";
        }
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+ gui.formLabel("visible", " User Visible")+"</td>";
	html += "<td>"+gui.formCheckBox("visible", (this.menuCode != null && this.userVsb == 1)? "checked": "", null, "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"menu.save('menuName menuDesc menuIcon menuPos');\"", "");
        if(this.menuCode != null){
            if(! this.menuHasChildren(this.menuCode)){
                html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"menu.purge("+this.menuCode+",'"+this.menuName+"');\"", "");
            }
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
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        Integer menuPos = 1;
        
        try{
            stmt = conn.createStatement();
            String query = "SELECT MAX(MENUPOS)MX FROM "+this.table+" WHERE MENUPARENT = "+this.menuParent;
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                menuPos = rs.getInt("MX");
                menuPos = menuPos + 1;
            }
        }catch (SQLException  e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        try{
            stmt = conn.createStatement();
            
            String query;
            Integer saved = 0;
            
            if(this.menuCode == null){
                Integer id = system.generateId(this.table, "ID");
                query = "INSERT INTO "+this.table+" "
                    + "(ID, MENUCODE, MENUNAME, MENUDESC, MENUPARENT, MENUPOS, ICON, URL, USERVSB)"
                    + "VALUES"
                    + "("
                    + id+ ", "
                    + id+ ", "
                    + "'"+ this.menuName+ "', "
                    + "'"+ this.menuDesc+ "', "
                    + this.menuParent+ ", "
                    + menuPos+ ", "
                    + "'"+ this.menuIcon+ "', "
                    + "'"+ this.menuUrl+ "', "
                    + this.userVsb
                    + ")";
            }else{
                
                query = "UPDATE "+this.table+" SET "
                    + "MENUNAME         = '"+ this.menuName+"', "
                    + "MENUDESC         = '"+ this.menuDesc+"', "
                    + "MENUPARENT       = "+ this.menuParent+", "
                    + "ICON             = '"+ this.menuIcon+"', "
                    + "URL              = '"+ this.menuUrl+"', "
                    + "MENUPOS          = "+ this.menuPos+", "
                    + "USERVSB          = "+ this.userVsb+" "
                        
                    + "WHERE MENUCODE   = "+ this.menuCode;
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
        catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public Object purge(){
        JSONObject obj = new JSONObject();

        try{
           Connection conn = ConnectionProvider.getConnection();
           Statement stmt = null;
           stmt = conn.createStatement();

            if(this.menuCode != null){
               String query = "DELETE FROM "+this.table+" WHERE MENUCODE = "+this.menuCode;

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
        }
        catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
        
    }
    
}

%>