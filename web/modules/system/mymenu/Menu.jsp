<%-- 
    Document   : class.Menu
    Created on : Jan 14, 2018, 3:44:08 PM
    Author     : nicholas
--%>

<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.SQLException"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%
    final class Menu {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        String table = comCode + ".SYSMENUS";

        Integer menuCode = request.getParameter("menuCode") != null ? Integer.parseInt(request.getParameter("menuCode")) : null;
        String menuName = request.getParameter("menuName");
        String menuDesc = request.getParameter("menuDesc");
        String menuUrl = request.getParameter("menuUrl");
        String menuIcon = request.getParameter("menuIcon");
        Integer menuParent = (request.getParameter("menuParent") != null && !request.getParameter("menuParent").trim().equals("")) ? Integer.parseInt(request.getParameter("menuParent")) : 0;
        Integer menuPos = request.getParameter("menuPos") != null ? Integer.parseInt(request.getParameter("menuPos")) : null;
        Integer userVsb = request.getParameter("visible") != null ? 1 : null;
        Double hgt = request.getParameter("menuHeight") != null ? Double.parseDouble(request.getParameter("menuHeight")) : 0.0;
        Double wdt = request.getParameter("menuWidth") != null ? Double.parseDouble(request.getParameter("menuWidth")) : 0.0;

        public String getModule() {
            String html;

            html = "<div>";
            html += "<table width = \"100%\" cellpadding = \"4\" cellspacing = \"1\" >";

            html += "<tr>";
            html += "<td width = \"50%\" style = \"border: 1px dotted #4185F3; vertical-align: top;\">" + this.getMenu() + "</td>";
            html += "<td style = \"border: 1px dotted #4185F3; vertical-align: top;\"><div id=\"divMenuEditor\">" + this.getMenuEditor() + "</div></td>";
            html += "</tr>";

            html += "</table>";
            html += "</div>";

            return html;
        }

        public String getMenu() {
            String html = "";

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM " + this.table + " WHERE MENUPARENT = 0 ORDER BY MENUPOS ";
                ResultSet rs = stmt.executeQuery(query);
                html += "<table width = \"100%\" cellpadding = \"4\" cellspacing = \"2\" >";
                while (rs.next()) {
                    Integer menuCode = rs.getInt("MENUCODE");
                    String menuName = rs.getString("MENUNAME");

                    if (this.menuHasChildren(menuCode)) {
                        String toggleMenu = "onclick=\"menu.toggleMenu('" + menuCode + "');\"";

                        html += "<tr>";
                        html += "<td width = \"2px\" style = \"text-align: center;\">";
                        html += "<img id = \"img" + menuCode + "\" src = \"" + request.getContextPath() + "/assets/img/menu/plus.gif\" " + toggleMenu + " />";
                        html += "</td>";
                        html += "<td nowrap> ";
                        html += "<div class = \"menu-parent\" >";
                        html += "<a href = \"javascript:;\" " + toggleMenu + ">";
                        html += menuName;
                        html += "</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "<td style = \"text-align: right;\">";
                        html += "<div class = \"menu-action-link\">";
                        html += "<a href = \"javascript:;\" onclick = \"menu.addMenu(" + menuCode + ");return false;\">add</a>";
                        html += " | ";
                        html += "<a href = \"javascript:;\" onclick = \"menu.editMenu(" + menuCode + ");return false;\">edit</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";

                        html += "<tr id = \"row" + menuCode + "\" style = \"display:none;\">";
                        html += "<td width = \"1px\"></td>";
                        html += "<td >";
                        html += "<div id = \"menu" + menuCode + "\" style = \"display:none;\" >";
                        html += this.getChildrenMenu(menuCode);
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";

                    } else {

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
                        html += "<a href = \"javascript:;\" onclick = \"menu.addMenu(" + menuCode + ");return false;\">add</a>";
                        html += " | ";
                        html += "<a href = \"javascript:;\" onclick = \"menu.editMenu(" + menuCode + ");return false;\">edit</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";
                    }
                }
                html += "</table>";
                rs.close();
            } catch (Exception e) {
                html += e.getMessage();
            }

            return html;
        }

        public Boolean menuHasChildren(Integer menuCode) {
            Boolean hasChildren = false;
            Integer count = 0;

            Statement stmt = null;

            Connection conn = ConnectionProvider.getConnection();
            try {
                stmt = conn.createStatement();
                String query = "SELECT COUNT(*)CT FROM " + this.table + " WHERE MENUPARENT = " + menuCode;
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                    count = rs.getInt("CT");
                }
            } catch (Exception e) {
                e.getMessage();
            }

            if (count > 0) {
                hasChildren = true;
            }

            return hasChildren;
        }

        public String getChildrenMenu(Integer menuCode) {
            String html = "";

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            Integer countRecord = 0;

            try {
                stmt = conn.createStatement();
                String query = "SELECT COUNT(*)CT FROM " + this.table + " WHERE MENUPARENT = " + menuCode;
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                    countRecord = rs.getInt("CT");
                }
                rs.close();

            } catch (Exception e) {
                html = e.getMessage();
            }

            try {
                stmt = null;
                stmt = conn.createStatement();
                String query = "SELECT * FROM " + this.table + " WHERE MENUPARENT = " + menuCode + " ORDER BY MENUPOS";
                ResultSet rs = stmt.executeQuery(query);
                Integer count = 1;

                html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"1\">";

                while (rs.next()) {
                    Integer menuCodeChild = rs.getInt("MENUCODE");
                    String menuNameChild = rs.getString("MENUNAME");

                    String toggleMenu = "onclick=\"menu.toggleMenu('" + menuCodeChild + "');\"";
                    String iconChildBranch = count < countRecord ? "branch.gif" : "branch-bottom.gif";
                    iconChildBranch = "<img src=\"" + request.getContextPath() + "/assets/img/menu/" + iconChildBranch + "\" />";
                    String iconChild = "<img src=\"" + request.getContextPath() + "/assets/img/icons/" + rs.getString("ICON") + "\" border=\"0\" />";
                    String treeLine = "";

                    if (this.menuHasChildren(menuCodeChild)) {
                        treeLine = count < countRecord ? "menu-tree-line" : "";
                    } else {
                        treeLine = "";
                    }

                    if (this.menuHasChildren(menuCodeChild)) {
                        html += "<tr>";
                        html += "<td width = \"2px\" style = \"text-align: center;\" >";
                        html += "<img id = \"img" + menuCodeChild + "\" src=\"" + request.getContextPath() + "/assets/img/menu/plus.gif\" " + toggleMenu + "/>";;
                        html += "</td>";
                        html += "<td colspan = \"2\" nowrap>";
                        html += "<div class = \"menu-child\" >";
                        html += "<a href = \"javascript:;\" " + toggleMenu + "> ";
                        html += iconChild + menuNameChild;
                        html += "</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "<td style = \"text-align: right;\">";
                        html += "<div class = \"menu-action-link\">";
                        html += "<a href = \"javascript:;\" onclick=\"menu.addMenu(" + menuCodeChild + ");return false;\">add</a>";
                        html += " | ";
                        html += "<a href = \"javascript:;\" onclick=\"menu.editMenu(" + menuCodeChild + ");return false;\">edit</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";

                        html += "<tr id=\"row" + menuCodeChild + "\" style=\"display:none;\">";
                        html += "<td width = \"1px\"  valign=\"top\" class=\"" + treeLine + "\">&nbsp;";
                        html += "</td>";
                        html += "<td valign = \"top\" colspan = \"3\">";
                        html += "<div class = \"menu-child\" id=\"menu" + menuCodeChild + "\" style=\"display:none;\">";
                        html += this.getChildrenMenu(menuCodeChild);
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";
                    } else {
                        html += "<tr>";
                        html += "<td width = \"5px\" valign = \"top\" nowrap>";
                        html += iconChildBranch;
                        html += "</td>";
                        html += "<td width = \"5px\" valign = \"top\" nowrap>";
                        html += iconChild;
                        html += "</td>";
                        html += "<td nowrap>";
                        html += "<div class = \"menu-child-link\" id = \"menu" + menuCodeChild + "\">";
                        html += "<a href = \"javascript:;\">";
                        html += menuNameChild;
                        html += "</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "<td style = \"text-align: right;\">";
                        html += "<div class = \"menu-action-link\">";
                        html += "<a href = \"javascript:;\" onclick=\"menu.addMenu(" + menuCodeChild + ");return false;\">add</a>";
                        html += " | ";
                        html += "<a href = \"javascript:;\" onclick=\"menu.editMenu(" + menuCodeChild + ");return false;\">edit</a>";
                        html += "</div>";
                        html += "</td>";
                        html += "</tr>";

                    }

                    ++count;
                }
                html += "</table>";
            } catch (Exception e) {
                html += e.getMessage();
            }

            return html;
        }

        public String getMenuEditor() {
            String html = "";
            Gui gui = new Gui();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            if (this.menuParent != null) {

                try {
                    stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.table + " WHERE MENUCODE = " + this.menuParent;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        menuParent = rs.getInt("MENUPARENT");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }
            }

            Integer menuParentEdit = null; //menu parent from edit

            if (this.menuCode != null) {

                try {
                    stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.table + " WHERE MENUCODE = " + this.menuCode;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.menuName = rs.getString("MENUNAME");
                        this.menuDesc = rs.getString("MENUDESC");
                        this.menuUrl = rs.getString("URL");
                        this.menuIcon = rs.getString("ICON");
                        this.menuPos = rs.getInt("MENUPOS");
                        menuParentEdit = rs.getInt("MENUPARENT");
                        this.userVsb = rs.getInt("USERVSB");
                        this.wdt = rs.getDouble("WDT");
                        this.hgt = rs.getDouble("HGT");
                    }
                } catch (Exception e) {
                    html += e.getMessage();

                }
            }

            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (this.menuCode != null) {
                html += gui.formInput("hidden", "menuCode", 30, "" + this.menuCode, "", "");
            }

            html += "<table class = \"module\" width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"20%\"><i class=\"fa fa-file\"></i>" + gui.formLabel("menuName", "Menu Name") + "</td>";
            html += "<td>" + gui.formInput("text", "menuName", 30, this.menuCode != null ? this.menuName : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap><i class=\"fa fa-edit\"></i>" + gui.formLabel("menuDesc", "Menu Description") + "</td>";
            html += "<td>" + gui.formInput("text", "menuDesc", 30, this.menuCode != null ? this.menuDesc : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap><i class=\"fa fa-pagelines\"></i>" + gui.formLabel("menuParent", "Menu Parent") + "</td>";
            html += "<td>";

            String defaultMenuCode = "";

            if (this.menuCode != null) {
                defaultMenuCode = menuParentEdit + "";
            } else {
                String menuParent = request.getParameter("menuParent");
                if (menuParent != null && !menuParent.trim().equals("")) {
                    this.menuParent = Integer.parseInt(menuParent);
                }
                defaultMenuCode = this.menuParent + "";
                //            html += this.menuParent;
            }

            html += gui.formSelect("menuParent", this.table, "MENUCODE", "MENUDESC", "MENUCODE", "", defaultMenuCode, "", false);
            html += "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td><i class=\"fa fa-link\"></i>" + gui.formLabel("menuUrl", "Url") + "</td>";
            html += "<td>" + gui.formInput("text", "menuUrl", 30, this.menuCode != null ? this.menuUrl : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td><i class=\"fa fa-image\"></i>" + gui.formLabel("menuIcon", "Icon") + "</td>";
            html += "<td>" + gui.formInput("text", "menuIcon", 30, this.menuCode != null ? this.menuIcon : "", "", "") + "</td>";
            html += "</tr>";

            if (this.menuCode != null) {
                Integer countMenuParent = 0;
                try {
                    stmt = conn.createStatement();
                    String query = "SELECT COUNT(*)CT FROM " + this.table + " WHERE MENUPARENT = " + menuParentEdit;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        countMenuParent = rs.getInt("CT");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

                HashMap<String, String> menuPos = new HashMap();

                if (countMenuParent > 0) {
                    for (int i = 1; i <= countMenuParent; i++) {
                        menuPos.put("" + i, "" + i);
                    }
                }

                html += "<tr>";
                html += "<td><i class=\"fa fa-sort-alpha-asc\"></i>" + gui.formLabel("menuPos", "Sort") + "</td>";
                html += "<td>" + gui.formArraySelect("menuPos", 100, new HashMap(menuPos), "" + this.menuPos, false, "", true) + "</td>";
                html += "</tr>";
            }

            html += "<tr>";
            html += "<td><i class=\"fa fa-check\"></i>" + gui.formLabel("visible", " User Visible") + "</td>";
            html += "<td>" + gui.formCheckBox("visible", (this.menuCode != null && this.userVsb == 1) ? "checked" : "", null, "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td><i class=\"fa fa-pencil\"></i>" + gui.formLabel("menuWidth", "Width") + "</td>";
            html += "<td>" + gui.formInput("text", "menuWidth", 10, this.menuCode != null ? "" + this.wdt : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td><i class=\"fa fa-pencil\"></i>" + gui.formLabel("menuHeight", "Height") + "</td>";
            html += "<td>" + gui.formInput("text", "menuHeight", 10, this.menuCode != null ? "" + this.hgt : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
//            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"menu.save('menuName menuDesc menuIcon menuPos');\"", "");
            html += "<button type=\"button\" id = \"btnSave\" class=\"btn btn-info\" onclick = \"menu.save('menuName menuDesc menuIcon');\">Save</button>";
            html += "&nbsp;";
            if (this.menuCode != null) {
                if (!this.menuHasChildren(this.menuCode)) {
//                    html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"menu.purge("+this.menuCode+",'"+this.menuName+"');\"", "");
                    html += "<button type=\"button\" id = \"btnDelete\" class=\"btn btn-danger\" onclick = \"menu.purge(" + this.menuCode + ",'" + this.menuName + "');\">Delete</button>";
                    html += "&nbsp;";
                }
            }

//            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
            html += "<button type=\"button\" id = \"btnCancel\" class=\"btn\" onclick = \"module.getModule();\">Cancel</button>";
            html += "</td>";
            html += "</tr>";

            html += "</table>";
            html += gui.formEnd();

            return html;
        }

        public Object save() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            Integer menuPos = 1;

            try {
                stmt = conn.createStatement();
                String query = "SELECT MAX(MENUPOS)MX FROM " + this.table + " WHERE MENUPARENT = " + this.menuParent;
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                    menuPos = rs.getInt("MX");
                    menuPos = menuPos + 1;
                }
            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            try {
                stmt = conn.createStatement();

                String query;
                Integer saved = 0;

                if (this.menuCode == null) {
//                    Integer id = sys.generateId(this.table, "ID");
//                    this.menuCode = sys.generateId(this.table, "MENUCODE");
//                    this.menuCode = sys.generateNextNo(this.table, "MENUCODE");
                    query = "INSERT INTO " + this.table + " "
                            + "("
                            + "MENUNAME, MENUDESC, MENUPARENT, MENUPOS, ICON, URL, USERVSB, WDT, HGT"
                            + ")"
                            //                        + "(MENUCODE, MENUNAME, MENUDESC, MENUPARENT, MENUPOS, ICON, URL, USERVSB)"
                            + "VALUES"
                            + "("
                            //                        + this.menuCode+ ", "
                            //                        + this.menuCode+ ", "
                            + "'" + this.menuName + "', "
                            + "'" + this.menuDesc + "', "
                            + this.menuParent + ", "
                            + menuPos + ", "
                            + "'" + this.menuIcon + "', "
                            + "'" + this.menuUrl + "', "
                            + this.userVsb + ", "
                            + this.wdt + ", "
                            + this.hgt
                            + ")";
                } else {

                    query = "UPDATE " + this.table + " SET "
                            + ""
                            + "MENUNAME         = '" + this.menuName + "', "
                            + "MENUDESC         = '" + this.menuDesc + "', "
                            + "MENUPARENT       = " + this.menuParent + ", "
                            + "ICON             = '" + this.menuIcon + "', "
                            + "URL              = '" + this.menuUrl + "', "
                            + "MENUPOS          = " + this.menuPos + ", "
                            + "USERVSB          = " + this.userVsb + ", "
                            + "WDT              = " + this.wdt + ", "
                            + "HGT              = " + this.hgt + " "
                            + "WHERE MENUCODE   = " + this.menuCode;
                }

                saved = stmt.executeUpdate(query);
                if (saved == 1) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }
            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

        public Object purge() throws Exception {
            JSONObject obj = new JSONObject();

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if (this.menuCode != null) {
                    String query = "DELETE FROM " + this.table + " WHERE MENUCODE = " + this.menuCode;

                    Integer purged = stmt.executeUpdate(query);
                    if (purged == 1) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "Entry successfully deleted.");
                    } else {
                        obj.put("success", new Integer(0));
                        obj.put("message", "An error occured while deleting record.");
                    }
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured while deleting record.");
                }
            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

    }
%>
