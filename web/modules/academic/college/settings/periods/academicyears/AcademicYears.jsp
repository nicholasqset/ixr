<%@page import="java.util.Calendar"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

    final class AcademicYears {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        String table = comCode + ".cl_acad_years";

        Integer id = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : null;
        String academicYear = request.getParameter("academicYear");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        public String getGrid() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            String dbType = ConnectionProvider.getDBType();

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

                            list.add("acad_year");
                            for (int i = 0; i < list.size(); i++) {
                                if (i == 0) {
                                    if (dbType.equals("postgres")) {
                                        filterSql += " WHERE ( UPPER(CAST (" + list.get(i) + " AS TEXT)) LIKE '%" + find.toUpperCase() + "%' ";
                                    } else {
                                        filterSql += " WHERE ( UPPER(" + list.get(i) + ") LIKE '%" + find.toUpperCase() + "%' ";
                                    }
                                } else {
                                    if (dbType.equals("postgres")) {
                                        filterSql += " OR (CAST(" + list.get(i) + " AS TEXT) LIKE '%" + find + "%' ";
                                    } else {
                                        filterSql += " OR ( UPPER(" + list.get(i) + ") LIKE '%" + find.toUpperCase() + "%' ";
                                    }
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

//            gridSql = "SELECT * FROM "+this.table+" "+filterSql+" ORDER BY acad_year DESC LIMIT "
//                    + session.getAttribute("startRecord")
//                    + " , "
//                    + session.getAttribute("maxRecord");
                String orderBy = "acad_year DESC ";
                String limitSql = "";

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

                    html += gui.formInput("hidden", "maxRecord", 10, session.getAttribute("maxRecord").toString(), "", "");
                    html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                    html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                    html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                    html += "<table class = \"grid\" width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" border = \"0\">";

                    html += "<tr>";
                    html += "<th>#</th>";
                    html += "<th>Academic Year</th>";
                    html += "<th>Start Date</th>";
                    html += "<th>End Date</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("ID");
                        String academicYear = rs.getString("acad_year");
                        String startDate = rs.getString("start_date");
                        String endDate = rs.getString("end_date");

                        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                        SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

                        java.util.Date startDateUf = originalFormat.parse(startDate);
                        java.util.Date endDateUf = originalFormat.parse(endDate);

                        startDate = targetFormat.format(startDateUf);
                        endDate = targetFormat.format(endDateUf);

                        String bgcolor = (count % 2 > 0) ? "#FFFFFF" : "#F7F7F7";

                        String edit = gui.formHref("onclick = \"module.editModule(" + id + ")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr bgcolor = \"" + bgcolor + "\">";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + academicYear + "</td>";
                        html += "<td>" + startDate + "</td>";
                        html += "<td>" + endDate + "</td>";
                        html += "<td>" + edit + "</td>";
                        html += "</tr>";

                        count++;
                    }
                    html += "</table>";
                } catch (SQLException e) {
                    html += e.getMessage();
                } catch (Exception e) {
                    html += e.getMessage();
                }
            } else {
                html += "No records found.";
            }

            return html;
        }

        public String getModule() {
            String html = "";

            Gui gui = new Gui();

            if (this.id != null) {

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.table + " WHERE ID = " + this.id;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.academicYear = rs.getString("acad_year");
                        this.startDate = rs.getString("start_date");
                        this.endDate = rs.getString("end_date");
                    }
                } catch (SQLException e) {
                    html += e.getMessage();
                } catch (Exception e) {
                    html += e.getMessage();
                }

                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

                try {
                    java.util.Date startDate = originalFormat.parse(this.startDate);
                    java.util.Date endDate = originalFormat.parse(this.endDate);

                    this.startDate = targetFormat.format(startDate);
                    this.endDate = targetFormat.format(endDate);
                } catch (ParseException e) {
                    html += e.getMessage();
                } catch (Exception e) {
                    html += e.getMessage();
                }
            }

            Integer calendarYear = Calendar.getInstance().get(Calendar.YEAR);

            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (this.id != null) {
                html += gui.formInput("hidden", "id", 30, "" + this.id, "", "");
            }

            html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";

            html += "<tr>";
            html += "<td width = \"15%\" nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("academicYear", " Academic Year") + "</td>";
//            html += "<td>" + gui.formYearSelect("academicYear", 1985, calendarYear + 5, this.id != null ? this.academicYear : calendarYear, "", true) + "</td>";
            html += "<td>" + gui.formInput("text", "academicYear", 25, this.id != null ? this.academicYear+"" : calendarYear+"/"+(calendarYear+1), "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("startDate", " Start Date") + "</td>";
            html += "<td>" + gui.formDateTime(request.getContextPath(), "startDate", 15, this.id != null ? this.startDate : "", false, "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("endDate", " End Date") + "</td>";
            html += "<td >" + gui.formDateTime(request.getContextPath(), "endDate", 15, this.id != null ? this.endDate : "", false, "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"academicYears.save('academicYear startDate endDate');\"", "");
            if (this.id != null) {
                html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"academicYears.purge(" + this.id + ",'" + this.academicYear + "');\"", "");
            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";
            html += gui.formEnd();

            return html;
        }

        public Object save() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                try {
                    java.util.Date startDate = originalFormat.parse(this.startDate);
                    java.util.Date endDate = originalFormat.parse(this.endDate);
                    this.startDate = targetFormat.format(startDate);
                    this.endDate = targetFormat.format(endDate);
                } catch (ParseException e) {
                    obj.put("success", new Integer(0));
                    obj.put("message", e.getMessage());
                }

                String query;
                Integer saved = 0;

                if (this.id == null) {

                    query = "INSERT INTO " + this.table + " "
                            + "(acad_year, start_date, end_date)"
                            + "VALUES"
                            + "("
                            + "'" + this.academicYear + "', "
                            + "'" + this.startDate + "', "
                            + "'" + this.endDate + "'"
                            + ")";
                } else {

                    query = "UPDATE " + this.table + " SET "
                            + "acad_year = '" + this.academicYear + "', "
                            + "start_date    = '" + this.startDate + "', "
                            + "end_date      = '" + this.endDate + "'"
                            + " WHERE ID    = " + this.id;
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
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
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
                    obj.put("message", "An unexpected error occured while deleting record.");
                }

            } catch (SQLException e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;

        }

    }

%>