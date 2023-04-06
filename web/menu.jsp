<%@page import="com.qset.sys.Sys"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.io.UnsupportedEncodingException"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="com.qset.security.EncryptionUtil"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%
    final class Menu{
        HttpSession session = request.getSession();
        String comCode      = session.getAttribute("comCode").toString();
                
//        String roleCode = this.getUserRole();
//        public String getUserRole(){
//            String roleCode = null;
//            HttpSession session     = request.getSession();
//            
//            try{
//                Connection conn = ConnectionProvider.getConnection();
//                Statement stmt = conn.createStatement();
//                String query = "SELECT ROLECODE FROM "+comCode+".SYSUSRS WHERE USERID = '"+ session.getAttribute("userId")+ "'";
//                ResultSet rs = stmt.executeQuery(query); 
//                while(rs.next()){
//                    roleCode = rs.getString("ROLECODE");			
//                }
//                
//            }catch (Exception e){
//                roleCode = e.getMessage();
//            }
//
//            return roleCode;
//        }
        
         public String getMenu(){
            String html = "";
            HttpSession session     = request.getSession();
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = ""
                        + " SELECT * FROM "+comCode+".SYSMENUS WHERE MENUPARENT = 0 AND USERVSB = 1 AND "
                        + " MENUCODE IN(SELECT DISTINCT(MENUPID) FROM "+comCode+".VIEWSYSPVGS"
                        + " WHERE ROLECODE IN (SELECT ROLECODE FROM "+comCode+".SYSUSRPVGS WHERE UPPER(USERID) = '"+ session.getAttribute("userId")+ "')) ORDER BY MENUPOS "
                        + "";
                
//                html += query;
                ResultSet rs = stmt.executeQuery(query);
                Integer count = 1;
                html += "<table width = \"100%\" cellpadding = \"5\" cellspacing = \"3\">";
                while(rs.next()){
                    Integer menuCode    = rs.getInt("MENUCODE");			
                    String menuName     = rs.getString("MENUNAME");	
                    String menuUrl      = rs.getString("URL");

                    try{
                        EncryptionUtil encryptionUtil = new EncryptionUtil();
                        menuUrl    = menuUrl+"?n="+encryptionUtil.encode(URLEncoder.encode(""+rs.getInt("MENUCODE"), "UTF-8"));
                    }catch(Exception e){
                        html += e.getMessage();
                    }

                    if(this.menuHasChildren(menuCode)){
                        String toggleMenu       = "onclick=\"container.toggleMenu('"+menuCode+"');\"";

                        html += "<tr>";
                        html += "<td width = \"2px\" style = \"text-align: center;\">";
                        html += "<img id = \"img"+menuCode+"\" src=\""+request.getContextPath()+"/assets/img/menu/plus.gif\" "+toggleMenu+" />";
                        html += "</td>";
                        html += "<td> ";
                        html += "<div class = \"menu-parent\" >";
                        html += "<a href = \"javascript:;\" "+ toggleMenu+ " >";	
                        html += menuName;
                        html += "</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";
                        html += "<tr id = \"row"+menuCode+"\" style=\"display:none;\">";
                        html += "<td width = \"1px\" >";
                        html += "</td>";
                        html += "<td>";
                        html += "<div id = \"menu"+menuCode+"\" style=\"display: none;\" >";
                        html += this.getChildrenMenu(menuCode);
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";
                    }else{

                        html += "<tr>";
                        html += "<td width = \"2px\" style = \"text-align: center;\">&nbsp;</td>";
                        html += "<td nowrap> ";
                        html += "<div class = \"menu-parent\">";
//                        html += "<a href = \"javascript:;\">";
//                        html += "<a href = \""+menuUrl+"\" target = \"content-iframe\">";
                        html += "<a onclick=\"container.loadModLk();\">";
                        html += menuName+ "-";
                        html += "</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";
                    }

                    count++;
                }
                html += "</table>";

                if(count == 1){
                    html += "No privileges awarded";
                }

                rs.close();

            }catch (Exception e){
                html += e.getMessage();
            }
            
            return html;
        }
        
        public Boolean menuHasChildren(Integer menuCode){
            Boolean hasChildren = false;
            
            Sys sys = new Sys();
            
            Integer count = 0;
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT COUNT(*)CT FROM "+comCode+".SYSMENUS WHERE MENUPARENT = "+menuCode+ " AND USERVSB = 1 ";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    count = rs.getInt("CT");			
                }
            }catch (Exception e){
//                out.println(e.getMessage());
                sys.logV2(e.getMessage());
            }

            if(count > 0){
                hasChildren = true;
            }

            return hasChildren;
        }
        
        public String getChildrenMenu(Integer menuCode){
            String html = "";
            
            HttpSession session     = request.getSession();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            Integer countRecord = 0;

            try{
                stmt = conn.createStatement();
                
                String query = "SELECT COUNT(*)CT FROM "+comCode+".SYSMENUS WHERE MENUPARENT = "+menuCode+" AND USERVSB = 1 AND "
                            + " MENUCODE IN(SELECT DISTINCT(MENUCID) FROM "+comCode+".VIEWSYSPVGS "
                            + " WHERE ROLECODE IN (SELECT ROLECODE FROM "+comCode+".SYSUSRPVGS WHERE UPPER(USERID) = '"+ session.getAttribute("userId")+ "')) ";
                
//                html += query;
//                System.out.println("query="+ query);
                
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    countRecord = rs.getInt("CT");			
                }
                rs.close();
            }catch (Exception e){
                html += e.getMessage();
            }

            try{
                stmt = null;
                stmt = conn.createStatement();
                String query    = "SELECT * FROM "+comCode+".SYSMENUS WHERE MENUPARENT = "+menuCode+" AND USERVSB = 1  AND "
                                + "MENUCODE IN(SELECT DISTINCT(MENUCID) FROM "+comCode+".VIEWSYSPVGS "
                                + "WHERE ROLECODE IN (SELECT ROLECODE FROM "+comCode+".SYSUSRPVGS WHERE UPPER(USERID) = '"+ session.getAttribute("userId")+ "')) ORDER BY MENUPOS";
                
//                System.out.println("query2="+ query);
                
                ResultSet rs = stmt.executeQuery(query);
                Integer count = 1;

                html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"2\">";

                while(rs.next()){
                    Integer menuCodeChild       = rs.getInt("MENUCODE");
                    String menuNameChild        = rs.getString("MENUNAME");
                    String menuUrlChild         = rs.getString("URL");
                    Double menuWidthChild       = rs.getDouble("WDT");
                    Double menuHeightChild      = rs.getDouble("HGT");

                    try{
                        EncryptionUtil encryptionUtil = new EncryptionUtil();
                        menuUrlChild    = menuUrlChild+"?n="+encryptionUtil.encode(URLEncoder.encode(""+rs.getInt("MENUCODE"), "UTF-8"));
                    }catch(UnsupportedEncodingException e){
                        html += e.getMessage();
                    }

                    String toggleMenu           = "onclick=\"container.toggleMenu('"+menuCodeChild+"');\"";
                    String iconChildBranch      = count < countRecord? "branch.gif": "branch-bottom.gif";
                    iconChildBranch             = "<img src=\""+request.getContextPath()+"/assets/img/menu/"+iconChildBranch+"\" />";	
                    String iconChild            = "<img src=\""+request.getContextPath()+"/assets/img/icons/"+rs.getString("ICON")+"\" border=\"0\" />";	
                    String treeLine             = "";

                    if(this.menuHasChildren(menuCodeChild)){
                        treeLine        = count < countRecord? "menu-tree-line": "";
                    }else{
                        treeLine        = "";
                    }
                    
//                    Integer menuHeightChild = 335;
//                    Integer menuWidthChild  = 500;

                    if(this.menuHasChildren(menuCodeChild)){
                        html += "<tr>";
                        html += "<td width = \"2px\" style = \"text-align: center;\">";
                        html += "<img id = \"img"+menuCodeChild+"\" src = \""+request.getContextPath()+"/assets/img/menu/plus.gif\" "+toggleMenu+"/>";
                        html += "</td>";
                        html += "<td colspan = \"2px\">";
                        html += "<div class = \"menu-child\" >";
                        html += "<a href = \"javascript:;\" "+toggleMenu+" > ";		
                        html += iconChild+ menuNameChild;
                        html += "</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";

                        html += "<tr id = \"row"+menuCodeChild+"\" style=\"display:none;\">";
                        html += "<td width = \"1px\" valign=\"top\" class=\""+treeLine+"\">&nbsp;";
                        html += "</td>";
                        html += "<td valign = \"top\" colspan = \"3\">";
                        html += "<div class = \"menu-child\" id = \"menu"+menuCodeChild+"\" style = \"display:none;\">";
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
                        html += "<div class = \"menu-child-link\" id = \"menu"+ menuCode+ "\">";
                        html += "<a href = \""+menuUrlChild+"\" target = \"content-iframe\" onclick = \"container.getMenuHeader('"+ menuNameChild +"'); container.loadModLk("+ menuCode+ ",'"+ menuUrlChild+ "');\" >";		
//                        html += "<a href = \"javascript:;\"  onclick = \"container.loadModLk("+ menuCode+ ",'"+ menuUrlChild+ "', "+ menuHeightChild+ ", "+ menuWidthChild+ ");\" >";		
//                        html += "<a href = \"javascript:;\"  onclick = \"container.loadModLk("+ menuCodeChild+ ",'"+ menuUrlChild+ "', "+ menuHeightChild+ ", "+ menuWidthChild+ ");\" >";		
                        html += menuNameChild;
                        html += "</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";
                    }

                    ++count;
                }
                html += "</table>";
                
            }catch (Exception e){
                html += e.getMessage();
            }

            return html;
        }
        
        public Object checkMenuSession() throws Exception{
            JSONObject obj  = new JSONObject();
            
            HttpSession session     = request.getSession();
            
            if(session.getAttribute("userId") != null){
                obj.put("success", new Integer(1));
                obj.put("message", "Session valid");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Session expired");
            }
            
            return obj;
        }
        
        
    }
%>