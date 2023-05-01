<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

    final class Houses {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        String table = "" + session.getAttribute("comCode") + ".re_houses";
        String view = "" + session.getAttribute("comCode") + ".re_houses";

        Integer id = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : null;
        String locCode = request.getParameter("loc");
        String buildingCode = request.getParameter("code");
        String buildingName = request.getParameter("name");

        public String getGrid() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            Integer recordCount = sys.getRecordCount(this.table, "");

            if (recordCount > 0) {
                String gridSql;
                String filterSql = "";
                Integer startRecord = 0;
                Integer maxRecord = 10;

                Integer maxRecordHidden = request.getParameter("maxRecord") != null ? Integer.parseInt(request.getParameter("maxRecord")) : null;
                Integer pageSize = maxRecordHidden != null ? maxRecordHidden : maxRecord;
                maxRecord = maxRecordHidden != null ? maxRecordHidden : maxRecord;

                HttpSession session = request.getSession();
                session.setAttribute("maxRecord", maxRecord);

                String act = request.getParameter("act");

                if (act != null) {
                    if (act.equals("find")) {
                        String find = request.getParameter("find");
                        if (find != null) {
                            session.setAttribute("startRecord", startRecord);

                            ArrayList<String> list = new ArrayList<String>();

                            list.add("loc_code");
                            list.add("building_code");
                            list.add("building_name");
                            for (int i = 0; i < list.size(); i++) {
                                if (i == 0) {
                                    filterSql += " WHERE ( UPPER(" + list.get(i) + ") LIKE '%" + find.toUpperCase() + "%' ";
                                } else {
                                    filterSql += " OR ( UPPER(" + list.get(i) + ") LIKE '%" + find.toUpperCase() + "%' ";
                                }
                                filterSql += ")";
                            }
                        }
                    }
                }

                Integer useGrid = request.getParameter("maxRecord") != null ? Integer.parseInt(request.getParameter("maxRecord")) : null;
                String gridAction = request.getParameter("gridAction");

                if (useGrid != null) {
                    if (gridAction.equals("gridNext")) {
                        if (session.getAttribute("startRecord") != null) {
                            if (Integer.parseInt(session.getAttribute("startRecord").toString()) >= startRecord) {
                                session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) + pageSize);
                            } else {
                                session.setAttribute("startRecord", startRecord);
                            }

                            if (Integer.parseInt(session.getAttribute("startRecord").toString()) == recordCount) {
                                session.setAttribute("startRecord", startRecord);
                            }

                            if (Integer.parseInt(session.getAttribute("startRecord").toString()) > recordCount) {
                                session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) - pageSize);
                            }
                        } else {
                            session.setAttribute("startRecord", startRecord);
                        }
                    } else if (gridAction.equals("gridPrevious")) {
                        if (session.getAttribute("startRecord") != null) {
                            if (Integer.parseInt(session.getAttribute("startRecord").toString()) > startRecord) {
                                session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) - pageSize);
                            } else {
                                session.setAttribute("startRecord", startRecord);
                            }
                        } else {
                            session.setAttribute("startRecord", startRecord);
                        }
                    } else if (gridAction.equals("gridFirst")) {
                        session.setAttribute("startRecord", startRecord);
                    } else if (gridAction.equals("gridLast")) {
                        session.setAttribute("startRecord", recordCount - pageSize);
                    } else {
                        session.setAttribute("startRecord", 0);
                    }
                } else {
                    session.setAttribute("startRecord", 0);
                }

                String orderBy = "loc_code, building_code ";
                String limitSql = "";

                String dbType = ConnectionProvider.getDBType();

                switch (dbType) {
                    case "mysql":
                        limitSql = "LIMIT " + session.getAttribute("startRecord") + " , " + session.getAttribute("maxRecord");
                        break;
                    case "postgres":
                        limitSql = "OFFSET " + session.getAttribute("startRecord") + " LIMIT " + session.getAttribute("maxRecord");
                        break;
                }

                gridSql = "SELECT * FROM " + this.view + " " + filterSql + " ORDER BY " + orderBy + limitSql;

                try {
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
                    html += "<th>Building</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("ID");
                        String regionName = rs.getString("loc_code");
                        String buildingCode = rs.getString("building_code");
                        String buildingName = rs.getString("building_name");

                        String bgcolor = (count % 2 > 0) ? "#FFFFFF" : "#F7F7F7";

                        String edit = gui.formHref("onclick = \"module.editModule(" + id + ")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr bgcolor = \"" + bgcolor + "\">";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + buildingCode + "</td>";
                        html += "<td>" + buildingName + "</td>";
                        html += "<td>" + regionName + "</td>";
                        html += "<td>" + edit + "</td>";
                        html += "</tr>";

                        count++;
                    }
                    html += "</table>";
                } catch (SQLException e) {
                    html += e.getMessage();
                }
            } else {
                html += "No records found.";
            }

            return html;
        }

        public String getModule() {

            Gui gui = new Gui();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            if (this.id != null) {

                try {
                    stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.table + " WHERE ID = " + this.id;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.locCode = rs.getString("loc_code");
                        this.buildingCode = rs.getString("building_code");
                        this.buildingName = rs.getString("building_name");
                    }
                } catch (SQLException e) {

                }
            }

            String html = "";

            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (this.id != null) {
                html += gui.formInput("hidden", "id", 30, "" + this.id, "", "");
            }

            html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";

            html += "<tr>";
            html += "<td width = \"15%\" nowrap>" + gui.formIcon(request.getContextPath(), "house.png", "", "") + " " + gui.formLabel("loc", "Region") + "</td>";
            html += "<td>" + gui.formSelect("loc", this.comCode + ".re_locs", "loc_code", "loc_name", null, null, this.id != null ? this.locCode : "", null, false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "page.png", "", "") + " " + gui.formLabel("code", "Building Code") + "</td>";
            html += "<td>" + gui.formInput("text", "code", 10, this.id != null ? this.buildingCode : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("name", "Building Name") + "</td>";
            html += "<td>" + gui.formInput("text", "name", 30, this.id != null ? this.buildingName : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"towns.save('loc code name');\"", "");
            if (this.id != null) {
                html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"towns.purge(" + this.id + ",'" + this.buildingName + "');\"", "");
            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";
            html += gui.formEnd();

            return html;
        }

        public JSONObject save() throws Exception {

            Integer saved = 0;

            JSONObject obj = new JSONObject();

            Sys sys = new Sys();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            try {
                stmt = conn.createStatement();

                String query;

                if (this.id == null) {
                    query = "INSERT INTO " + this.table + " "
                            + "(loc_code, building_code, building_name)"
                            + "VALUES"
                            + "("
                            + "'" + this.locCode + "',"
                            + "'" + this.buildingCode + "',"
                            + "'" + this.buildingName + "'"
                            + ")";
                } else {

                    query = "UPDATE " + this.table + " SET "
                            + "loc_code   = '" + this.locCode + "',"
                            + "building_code  = '" + this.buildingCode + "',"
                            + "building_name  = '" + this.buildingName + "'"
                            + "WHERE ID     = " + this.id;
                }

                saved = stmt.executeUpdate(query);

                if (saved == 1) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }

            } catch (SQLException e) {
                obj.put("success", new Integer(1));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

        public Object purge() throws Exception {

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            JSONObject obj = new JSONObject();

            try {
                stmt = conn.createStatement();

                if (this.id != null) {
                    String query = "DELETE FROM " + this.table + " WHERE ID = " + this.id;

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

            } catch (SQLException e) {

            }

            return obj;

        }

    }

%>