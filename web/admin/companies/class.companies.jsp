<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>

<%

    final class Sub {

        String table = "sys.coms";

        Integer id = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : null;
        String campname = request.getParameter("compname");
        String telephone = request.getParameter("telephone");
        String cellphone = request.getParameter("cellphone");
        String email = request.getParameter("email");
        String website = request.getParameter("website");
        String postalcode = request.getParameter("postalcode");
        String postaladr = request.getParameter("postaladr");
        String physicalcaladr = request.getParameter("physicalcaladr");

        String active = request.getParameter("active");

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

                            ArrayList<String> list = new ArrayList();
                            list.add("id");
                            list.add("compname");
                            list.add("telephone");
                            list.add("cellphone");
                            list.add("email");
                            list.add("website");
                            list.add("postalcode");
                            list.add("postaladr");
                            list.add("physicaladr");
                            for (int i = 0; i < list.size(); i++) {
                                if (i == 0) {
                                    filterSql += " WHERE ( UPPER(CAST(" + list.get(i) + " AS character varying)) LIKE '%" + find.toUpperCase() + "%' ";
                                } else {
                                    filterSql += " OR ( UPPER(CAST(" + list.get(i) + " AS character varying)) LIKE '%" + find.toUpperCase() + "%' ";
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

                String orderBy = "compname ";
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

                gridSql = "SELECT * FROM " + this.table + " " + filterSql + " ORDER BY " + orderBy + limitSql;

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(gridSql);

                    Integer startRecordHidden = Integer.parseInt(session.getAttribute("startRecord").toString()) + Integer.parseInt(session.getAttribute("maxRecord").toString());
                    html += "<div class=\"col-md-12\">";
                    html += gui.formInput("hidden", "maxRecord", 10, session.getAttribute("maxRecord").toString(), "", "");
                    html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                    html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                    html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                    html += "<h4>Companies</h4>";

                    html += "<table class = \"grid table table-responsive\" width=\"100%\" cellpadding=\"2\" cellspacing=\"0\" border=\"0\">";

                    html += "<tr>";
                    html += "<th>#</th>";
                    html += "<th>Company Code</th>";
                    html += "<th>Name</th>";
                    html += "<th>Email</th>";
                    html += "<th>Website</th>";
                    html += "<th>Telephone</th>";
                    html += "<th>Cell phone</th>";
                    html += "<th>Postal address</th>";
                    html += "<th>Postal code</th>";
                    html += "<th>Physical address</th>";
                    html += "<th>Active</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("id");
                        String comCode = rs.getString("comCode");
                        String compname = rs.getString("compname");
                        String telephone = rs.getString("telephone");
                        String cellphone = rs.getString("cellphone");
                        String email = rs.getString("email");
                        String website = rs.getString("website");
                        String postaladr = rs.getString("postaladr");
                        String postalcode = rs.getString("postalcode");
                        String physicaladr = rs.getString("physicaladr");
                        String active = rs.getString("active");

                        String bgcolor = (count % 2 > 0) ? "#FFFFFF" : "#F7F7F7";

                        String edit = gui.formHref("onclick = \"module.editModule(" + id + ")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr bgcolor = \"" + bgcolor + "\">";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + comCode + "</td>";
                        html += "<td>" + compname + "</td>";
                        html += "<td>" + email + "</td>";
                        html += "<td>" + website + "</td>";
                        html += "<td>" + telephone + "</td>";
                        html += "<td>" + cellphone + "</td>";
                        html += "<td>" + postaladr + "</td>";
                        html += "<td>" + postalcode + "</td>";
                        html += "<td>" + physicaladr + "</td>";
                        html += "<td>" + active + "</td>";
                        html += "<td>" + edit + "</td>";

                        html += "</tr>";

                        count++;
                    }
                    html += "</table>";
                } catch (Exception e) {
                    html += e.getMessage();
                }
            } else {
                html += "No records found.";
            }
            html += "</div>";

            return html;
        }

        public String getModule() {
            String html = "";
            Gui gui = new Gui();
//        
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            if (this.id != null) {

                try {
                    stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.table + " WHERE ID = " + this.id;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.id = rs.getInt("id");
                        this.active = rs.getString("active");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }
            }

            String checked = this.active.equals("1") ? "checked" : "";
//        
//        
            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (this.id != null) {
                html += gui.formInput("hidden", "id", 30, "" + this.id, "", "");
            }

            html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
//              
            html += "<tr>";
            html += "<td style=\"width: 15%;\">" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("active", "Is Active") + "</td>";
            html += "<td>" + gui.formCheckBox("active", checked, "", "", "", "") + "</td>";
            html += "</tr>";
////        
////        html += "<tr>";
////	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("amount", "Amount")+"</td>";
////	
////        html += "<td>"+gui.formInput("text", "amount", 30, this.amount != null? this.amount: "", "", "")+"</td>";
////	html += "</tr>";
////        
            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"coms.save('country code name');\"", "");
//        if(this.id != null){
//            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"coms.purge("+this.id+",'"+this.id+"');\"", "");
//        }
            html += " ";

            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
            html += "</td>";
            html += "</tr>";
//         
            html += "</table>";
            html += gui.formEnd();

            return html;
        }

        public Object save() throws Exception {
            Integer saved = 0;

            JSONObject obj = new JSONObject();

            Sys sys = new Sys();

            if (this.active != null) {
                this.active = this.active.equals("on") ? "1" : "0";
            } else {
                this.active = "0";
            }

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query = "";

                if (this.id == null) {
                    Integer id = sys.generateId(this.table, "ID");
//                    query = "INSERT INTO sys.syssubscriptions(amount,pyear)VALUES('209','2018')";
                } else {

                    query = "UPDATE " + this.table + " SET "
                            + "active  = '" + this.active + "' "
                            + "WHERE ID     = " + this.id;
                }

                saved = stmt.executeUpdate(query);
                if (saved > 0) {
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

            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;

        }

    }

%>