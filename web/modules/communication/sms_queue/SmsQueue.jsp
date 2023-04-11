<%@page import="okhttp3.Response"%>
<%@page import="okhttp3.Request"%>
<%@page import="okhttp3.RequestBody"%>
<%@page import="okhttp3.MediaType"%>
<%@page import="okhttp3.OkHttpClient"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

    final class SmsQueue {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        String table = comCode + ".cm_queue";

        Integer id = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : null;
        String campaignId = request.getParameter("campaign");
        String grpCode = request.getParameter("group");

        public String getGrid() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            Integer recordCount = sys.getRecordCount(this.table, "msg_type = 'SMS'");

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

                            list.add("subject");
                            list.add("message");
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

                filterSql = filterSql.contentEquals("") ? " WHERE msg_type = 'SMS' " : " AND msg_type = 'SMS' ";

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

                String orderBy = "queue_date desc ";
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

                    html += gui.formInput("hidden", "maxRecord", 10, session.getAttribute("maxRecord").toString(), "", "");
                    html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                    html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                    html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                    html += "<table class = \"grid\" width=\"100%\" cellpadding=\"2\" cellspacing=\"0\" border=\"0\">";

                    html += "<tr>";
                    html += "<th>#</th>";
                    html += "<th>To</th>";
                    html += "<th>Name</th>";
                    html += "<th>Subject</th>";
                    html += "<th>Message</th>";
                    html += "<th>From</th>";
                    html += "<th>Name</th>";
                    html += "<th>Reply To</th>";
                    html += "<th>Date</th>";
                    html += "<th>Sent</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("ID");
                        String to = rs.getString("to_email");
                        String to_name = rs.getString("to_name");
                        String subject = rs.getString("subject");
                        String message = rs.getString("message");
                        String from = rs.getString("from_email");
                        String from_name = rs.getString("from_name");
                        String reply_to = rs.getString("reply_to");
                        String queue_date = rs.getString("queue_date");
                        Integer sent = rs.getInt("sent");

                        String sent_ = sent == 1 ? "<i class=\"fa fa-check\"></i>" : "<i class=\"fa fa-x\"></i>";

                        String sendMsg = gui.formCheckBox("send_" + id, "", "", "onclick = \"queue.sendMsg(" + id + ")\"", "", "");
                        String edit = gui.formHref("onclick = \"queue.viewMsg(" + id + ")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        String opts = "";

                        if (sent == 1) {
                            opts = edit;
                        } else {
                            opts = sendMsg + " || " + edit;
                        }

                        String bgcolor = (count % 2 > 0) ? "#FFFFFF" : "#F7F7F7";

                        html += "<tr bgcolor = \"" + bgcolor + "\">";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + to + "</td>";
                        html += "<td>" + to_name + "</td>";
                        html += "<td>" + subject + "</td>";
                        html += "<td>" + message + "</td>";
                        html += "<td>" + from + "</td>";
                        html += "<td>" + from_name + "</td>";
                        html += "<td>" + reply_to + "</td>";
                        html += "<td>" + queue_date + "</td>";
                        html += "<td>" + sent_ + "</td>";
                        html += "<td>" + opts + "</td>";
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
            String html = "";
            Gui gui = new Gui();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            if (this.id != null) {
                try {
                    stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.table + " WHERE ID = " + this.id;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
//                        this.type = rs.getString("type");
//                        this.subject = rs.getString("subject");
//                        this.message = rs.getString("message");
                    }
                } catch (SQLException e) {
                    html += e.getMessage();
                }
            }

            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (this.id != null) {
                html += gui.formInput("hidden", "id", 30, "" + this.id, "", "");
            }

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing=  \"0\" >";

            html += "<tr>";
            html += "<td width = \"15%\" nowrap>" + gui.formIcon(request.getContextPath(), "email.png", "", "") + gui.formLabel("campaign", " Campaign") + "</td>";
            html += "<td >" + gui.formSelect("campaign", "" + this.comCode + ".cm_campaigns", "id", "subject", "", "type='SMS'", "", "", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td width = \"15%\" nowrap>" + gui.formIcon(request.getContextPath(), "group.png", "", "") + gui.formLabel("group", " Group") + "</td>";
            html += "<td >" + gui.formSelect("group", "" + this.comCode + ".cm_groups", "grp_code", "grp_desc", "", "", "", "", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"queue.gen('campaign group');\"", "");
//            if (this.id != null) {
//                html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"queue.purge(" + this.id + ",'" + this.subject + "');\"", "");
//            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";
            html += gui.formEnd();

            return html;
        }

        public JSONObject save() throws Exception {
            JSONObject obj = new JSONObject();
            Integer saved = 0;

            Sys sys = new Sys();

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query;

                Boolean defaultGroup = sys.recordExists(this.comCode + ".cm_groups", "grp_code = '" + this.grpCode + "' and is_default = 1");
                if (defaultGroup) {
                    query = "select id, first_name, last_name, email from " + this.comCode + ".cm_subscribers ";
                } else {
                    query = "select id, first_name, last_name, email from " + this.comCode + ".cm_subscribers where id in (select subscriber_id from " + this.comCode + ".cm_subscriber_grps where grp_code = '" + this.grpCode + "')";
                }

                Integer hrdInserted = sys.executeSql("INSERT INTO " + this.comCode + ".cm_queue_hdr("
                        + "campaign_id, grp_code, queue_date)"
                        + "VALUES (" + this.campaignId + ", '" + this.grpCode + "', now()"
                        + ")");

                String id_ = sys.getOneByQuery("SELECT currval(pg_get_serial_sequence('" + this.comCode + ".cm_queue_hdr','id')) as col");

                Long count = new Long(0);

                if (hrdInserted > 0 && id_ != null) {
                    String subject = sys.getOne(this.comCode + ".cm_campaigns", "subject", "id=" + this.campaignId);
                    String message = sys.getOne(this.comCode + ".cm_campaigns", "message", "id=" + this.campaignId);

                    String fromEmail = "noreply@qset.co.ke";
                    String fromName = "iXr Info Desk";
                    String replyTo = "info@qset.co.ke";

                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        count++;

                        String id = rs.getString("id");
                        String firstName = rs.getString("first_name");
                        String lastName = rs.getString("last_name");
                        String email = rs.getString("email");

                        Integer msgInserted = sys.executeSql("INSERT INTO " + this.comCode + ".cm_queue("
                                + "grp_code, subscriber_id, campaign_id, to_email, to_name, subject, message, from_email, from_name, reply_to, queue_date, msg_type, hdr_id)"
                                + "VALUES ("
                                + "'" + this.grpCode + "', "
                                + "" + id + ", "
                                + "" + this.campaignId + ", "
                                + "'" + email + "', "
                                + "'" + firstName + " " + lastName + "', "
                                + "'" + subject + "', "
                                + "'" + message + "', "
                                + "'" + fromEmail + "', "
                                + "'" + fromName + "', "
                                + "'" + replyTo + "', "
                                + "now(),"
                                + "'SMS', "
                                + "" + id_ + " "
                                + ")");
                    }
                }

//
//                if (this.id == null) {
//                    query = "INSERT INTO " + this.table + " "
//                            + "(type, subject, message)"
//                            + "VALUES"
//                            + "("
//                            + "'" + this.type + "',"
//                            + "'" + this.subject + "',"
//                            + "'" + this.message + "'"
//                            + ")";
//                } else {
//                    query = "UPDATE " + this.table + " SET "
//                            + "type   = '" + this.type + "',"
//                            + "subject   = '" + this.subject + "',"
//                            + "message   = '" + this.message + "'"
//                            + "WHERE ID     = " + this.id;
//                }
//
//                saved = stmt.executeUpdate(query);
                if (count > 0) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An unexpected error occured while saving record.");
                }

            } catch (SQLException e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

        public JSONObject sendMsg() throws Exception {
            JSONObject obj = new JSONObject();

            Sys sys = new Sys();

            try {
                if (this.id != null) {

                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query = "SELECT * FROM " + this.table + " WHERE id = " + this.id;

                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        
                        String to_email = rs.getString("to_email");
                        String subject = rs.getString("subject");
                        String message = rs.getString("message");
                    
                        OkHttpClient client = new OkHttpClient().newBuilder()
                                .build();
                        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
                        RequestBody body = RequestBody.create(mediaType, "function=sendEmail&"
                                + "email="+to_email+"&"
                                + "subject=" + subject + "&"
                                + "message="+ message
                        );
                        Request request = new Request.Builder()
                                .url("https://api.goqset.com/")
                                .method("POST", body)
                                .addHeader("Content-Type", "application/x-www-form-urlencoded")
                                .build();
                        Response response = client.newCall(request).execute();

                        sys.logV2("response=" + response);
                    }

                    Integer sent = sys.executeSql("UPDATE "+this.table+" SET sent = 1 WHERE id = "+ this.id);
                    
                    if (sent == 1) {
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
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;

        }

    }

%>