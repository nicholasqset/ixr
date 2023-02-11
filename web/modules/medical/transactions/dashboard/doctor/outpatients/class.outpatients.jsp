<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.ic.ICItem"%>
<%@page import="org.json.JSONObject"%>
<%@page import="bean.medical.Medical"%>
<%@page import="bean.finance.FinConfig"%>
<%@page import="bean.medical.HMStaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.medical.PatientProfile"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

    final class OutPatients {
//    String table    = "HMREGISTRATION";

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        String table = comCode + ".HMREGISTRATION";
        String view = comCode + ".VIEWDOCTOROPDS";

        Integer id = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : null;
        String regNo = request.getParameter("regNo");
        String regType = request.getParameter("regType");
        String ptNo = "";
        String drNo = "";
        String nrNo = "";
        String drNotes = request.getParameter("dr_notes") != null ? request.getParameter("dr_notes") : "";
        String remarks = request.getParameter("remarks") != null ? request.getParameter("remarks") : "";

        public String getGrid() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            String dbType = ConnectionProvider.getDBType();

            Integer recordCount = sys.getRecordCount(this.view, "");

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

                            list.add("REGNO");
                            list.add("PTNO");
                            list.add("FULLNAME");
                            list.add("CELLPHONE");
                            for (int i = 0; i < list.size(); i++) {
                                if (i == 0) {
                                    if (dbType.equals("postgres")) {
                                        filterSql += " WHERE ( UPPER(CAST (" + list.get(i) + " AS TEXT)) LIKE '%" + find.toUpperCase() + "%' ";
                                    } else {
                                        filterSql += " WHERE ( UPPER(" + list.get(i) + ") LIKE '%" + find.toUpperCase() + "%' ";
                                    }
                                } else {
                                    if (dbType.equals("postgres")) {
                                        filterSql += " OR ( UPPER(CAST (" + list.get(i) + " AS TEXT)) LIKE '%" + find.toUpperCase() + "%' ";
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

                String orderBy = "REGNO DESC ";
                String limitSql = "";

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
                    html += "<th>Reg No</th>";
                    html += "<th>Reg Type</th>";
                    html += "<th>Patient No</th>";
                    html += "<th>Patient Name</th>";
                    html += "<th>Phone No</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("ID");
                        String regNo = rs.getString("REGNO");
                        String regType = rs.getString("REGTYPE");
                        String ptNo = rs.getString("PTNO");
                        String fullName = rs.getString("FULLNAME");
                        String cellphone = rs.getString("CELLPHONE");

                        String regTypeLbl = "Unknown";

                        if (regType.equals("N")) {
                            regTypeLbl = "New Patient";
                        } else if (regType.equals("R")) {
                            regTypeLbl = "Return Patient";
                        }

                        String bgcolor = (count % 2 > 0) ? "#FFFFFF" : "#F7F7F7";

                        String edit = gui.formHref("onclick = \"module.editModule(" + id + ")\"", request.getContextPath(), "pencil.png", "view", "view", "", "");

                        html += "<tr bgcolor = \"" + bgcolor + "\">";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + regNo + "</td>";
                        html += "<td>" + regTypeLbl + "</td>";
                        html += "<td>" + ptNo + "</td>";
                        html += "<td>" + fullName + "</td>";
                        html += "<td>" + cellphone + "</td>";
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

            return html;
        }

        public String getModule() {
            String html = "";

            Gui gui = new Gui();

            html += "<div id = \"dhtmlgoodies_tabView1\">";

            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getProfileTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getHistoryTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getVitalParamTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divComplaints\">" + this.getComplaintsTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divLab\">" + this.getLabTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divDiagnosis\">" + this.getDiagnosisTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divDrNotes\">" + this.getDrNotesTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divMedication\">" + this.getMedicationTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getDischargeTab() + "</div>";

            html += "</div>";

            html += "<div style = \"padding-left: 10px; padding-top: 40px; border: 0;\" >";

            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Discharge", "save.png", "onclick = \"dashboard.save('remarks');\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"module.getGrid();\"", "");
            html += "</div>";

            html += "<script type = \"text/javascript\">";
//            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Profile\', \'History\', \'Vital Parameter\', \'Complaints\', \'Laboratory\', \'Diagnosis\', \'Medication\', \'Doctor Notes\',\'Discharge\'), 0, 625, 365, Array(false));";
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Profile\', \'History\', \'Vital Parameter\', \'Complaints\', \'Laboratory\', \'Diagnosis\', \'Doctor Notes\', \'Prescription\',\'Discharge\'), 0, 625, 365, Array(false));";
            html += "</script>";

            return html;
        }

        public String getProfileTab() {
            String html = "";
            Gui gui = new Gui();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;

            String drName = "";
            String nrName = "";

            try {
                stmt = conn.createStatement();
                String query = "SELECT * FROM " + this.view + " WHERE ID = " + this.id;
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                    this.regNo = rs.getString("REGNO");
                    this.regType = rs.getString("REGTYPE");
                    this.ptNo = rs.getString("PTNO");
                    this.drNo = rs.getString("DRNO");
                    drName = rs.getString("DRNAME");
                    this.nrNo = rs.getString("NRNO");
                    nrName = rs.getString("NRNAME");
                }
            } catch (SQLException e) {
                html += e.getMessage();
            }

            PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);

            String regTypeLbl = "Unknown";

            if (this.regType.equals("N")) {
                regTypeLbl = "New Patient";
            } else if (this.regType.equals("R")) {
                regTypeLbl = "Return Patient";
            }

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " Registration No</td>";
            html += "<td >" + this.regNo + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " Registration Type</td>";
            html += "<td>" + regTypeLbl + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">" + gui.formIcon(request.getContextPath(), "patient-male.png", "", "") + " Patient</td>";
            html += "<td nowrap>" + this.ptNo + " - " + patientProfile.fullName + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">" + gui.formIcon(request.getContextPath(), "gender.png", "", "") + " Gender</td>";
            html += "<td>" + patientProfile.genderName + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + " Age</td>";
            html += "<td>" + patientProfile.age + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + " Date of Birth</td>";
            html += "<td>" + patientProfile.dob + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">" + gui.formIcon(request.getContextPath(), "mobile-phone.png", "", "") + " Cellphone</td>";
            html += "<td>" + patientProfile.cellphone + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">" + gui.formIcon(request.getContextPath(), "doctor-male.png", "", "") + " Doctor</td>";
            html += "<td nowrap>" + this.drNo + " - " + drName + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">" + gui.formIcon(request.getContextPath(), "doctor-female.png", "", "") + " Nurse</td>";
            html += "<td nowrap>" + this.nrNo + " - " + nrName + "</td>";
            html += "</tr>";

            html += "</table>";

            return html;
        }

        public String getHistoryTab() {
            String html = "";
            Gui gui = new Gui();

            PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\">" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " Allergies</td>";
            html += "<td >" + patientProfile.allergies + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " Warnings</td>";
            html += "<td >" + patientProfile.warns + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " Family History</td>";
            html += "<td >" + patientProfile.familyHist + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " Personal History</td>";
            html += "<td >" + patientProfile.selfHist + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " Past Medical History</td>";
            html += "<td >" + patientProfile.pastMedHist + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " Social History</td>";
            html += "<td>" + patientProfile.socialHist + "</td>";
            html += "</tr>";

            html += "</table>";

            return html;
        }

        public String getVitalParamTab() {
            String html = "";
            Gui gui = new Gui();

            String pulseRate = "";
            String bloodPressure = "";
            String temperature = "";
            String respiration = "";
            String height = "";
            String weight = "";

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM " + this.comCode + ".HMTRIAGE WHERE REGNO = '" + this.regNo + "'";
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                    pulseRate = rs.getString("PULSERATE");
                    bloodPressure = rs.getString("BLOODPRESSURE");
                    temperature = rs.getString("TEMPERATURE");
                    respiration = rs.getString("RESPIRATION");
                    height = rs.getString("HEIGHT");
                    weight = rs.getString("WEIGHT");
                }
            } catch (SQLException e) {
                html += e.getMessage();
            }

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + " Pulse Rate</td>";
            html += "<td >" + pulseRate + "<span class = \"fade\"> /min</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + " Blood Pressure</td>";
            html += "<td >" + bloodPressure + "<span class = \"fade\"> mm of Hg</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + " Temperature</td>";
            html += "<td >" + temperature + "<span class = \"fade\"> C</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + " Respiration</td>";
            html += "<td >" + respiration + "<span class = \"fade\"> /min</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + " Height</td>";
            html += "<td >" + height + "<span class = \"fade\"> cm</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + " Weight</td>";
            html += "<td >" + weight + "<span class = \"fade\"> Kg</span></td>";
            html += "</tr>";

            html += "</table>";

            return html;
        }

        public String getComplaintsTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            if (sys.recordExists("" + this.comCode + ".HMPTCOMPLAINTS", "REGNO = '" + this.regNo + "'")) {
                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Complaint</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
//                String query = "SELECT * FROM "+this.comCode+".VIEWPTCOMPLAINTS WHERE REGNO = '"+this.regNo+"' ";
                    String query = "SELECT * FROM " + this.comCode + ".HMPTCOMPLAINTS WHERE REGNO = '" + this.regNo + "' ";
                    ResultSet rs = stmt.executeQuery(query);
                    Integer count = 1;
                    while (rs.next()) {

                        String id = rs.getString("ID");
                        String complName = rs.getString("COMPLNAME");

                        String editLink = gui.formHref("onclick = \"dashboard.editComplaint(" + id + ");\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + complName + "</td>";
                        html += "<td>" + editLink + "</td>";
                        html += "</tr>";

                        count++;
                    }

                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "</table>";

            } else {
                html += gui.formWarningMsg("No complaints record found.");
            }
            html += "<br>";
            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"dashboard.addComplaint('" + this.regNo + "');\"", "");

            return html;
        }

        public String addComplaint() {
            String html = "";

            Gui gui = new Gui();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String complCode = "";
            String complName = "";
            String remarks = "";
//            String results = "";
            if (rid != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt;
                    stmt = conn.createStatement();
//                String query = "SELECT * FROM "+this.comCode+".VIEWPTCOMPLAINTS WHERE ID = "+rid;
                    String query = "SELECT * FROM " + this.comCode + ".HMPTCOMPLAINTS WHERE ID = " + rid;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.regNo = rs.getString("REGNO");
                        complCode = rs.getString("COMPLCODE");
                        complName = rs.getString("COMPLNAME");
                        remarks = rs.getString("REMARKS");
//                        results = rs.getString("results");
                    }
                } catch (SQLException e) {
                    html += e.getMessage();
                }

            }

            html += gui.formStart("frmComplaint", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (rid != null) {
                html += gui.formInput("hidden", "rid", 15, "" + rid, "", "");
            }

            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("complaint", " Complaint") + "</td>";
//        html += "<td >"+gui.formSelect("complaint", ""+this.comCode+".HMCOMPLAINTS", "COMPLCODE", "COMPLNAME", "", "", complCode, "", false)+"</td>";
            html += "<td >" + gui.formInput("textarea", "complaint", 40, complName, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("remarks", " Remarks") + "</td>";
            html += "<td >" + gui.formInput("textarea", "remarks", 40, remarks, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSaveComplaint", "Save", "save.png", "onclick = \"dashboard.saveComplaint('complaint');\"", "");
            if (rid != null) {
                html += gui.formButton(request.getContextPath(), "button", "btnDelComplaint", "Delete", "delete.png", "onclick = \"dashboard.delComplaint(" + rid + ", '" + complName + "', '" + this.regNo + "');\"", "");
            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"dashboard.getComplaints('" + this.regNo + "');\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();
            return html;
        }

        public Object saveComplaint() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String complCode = request.getParameter("complaint");
            String remarks = request.getParameter("remarks");

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query;

                if (rid == null) {
                    Integer id = sys.generateId("" + this.comCode + ".HMPTCOMPLAINTS", "ID");
                    query = "INSERT INTO " + this.comCode + ".HMPTCOMPLAINTS "
                            + "(ID, REGNO, COMPLCODE, COMPLNAME, REMARKS, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                            + "VALUES"
                            + "("
                            + id + ", "
                            + "'" + this.regNo + "', "
                            //                    + "'"+ complCode +"', "
                            + "'" + id + "', "
                            + "'" + complCode + "', "
                            + "'" + remarks + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getLogTime() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                } else {
                    query = "UPDATE " + this.comCode + ".HMPTCOMPLAINTS SET "
                            //                    + "COMPLCODE    = '"+ complCode +"', "
                            + "COMPLNAME    = '" + complCode + "', "
                            + "REMARKS      = '" + remarks + "' "
                            + "WHERE ID     = " + rid + "";
                }

                Integer saved = stmt.executeUpdate(query);

                if (saved == 1) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Complaint entry successfully made.");
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record." + query);
                }
            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

        public String getComplaints() {
            String html = "";
            html += this.getComplaintsTab();
            return html;
        }

        public Object delComplaint() throws Exception {

            JSONObject obj = new JSONObject();
            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if (rid != null) {
                    String query = "DELETE FROM " + this.comCode + ".HMPTCOMPLAINTS WHERE ID = " + rid;

                    Integer purged = stmt.executeUpdate(query);
                    if (purged == 1) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "Complaint entry successfully deleted.");
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

        //lab start
        public String getLabTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            if (sys.recordExists("" + this.comCode + ".HMPTLAB", "REGNO = '" + this.regNo + "'")) {
                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Lab Item</th>";
                html += "<th>Results</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
//                String query = "SELECT * FROM "+this.comCode+".VIEWPTCOMPLAINTS WHERE REGNO = '"+this.regNo+"' ";
                    String query = "SELECT * FROM " + this.comCode + ".HMPTLAB WHERE REGNO = '" + this.regNo + "' ";
                    ResultSet rs = stmt.executeQuery(query);
                    Integer count = 1;
                    while (rs.next()) {

                        String id = rs.getString("ID");
                        String labItemName = rs.getString("LABITEMNAME");
                        String results = rs.getString("RESULTS");

                        String editLink = gui.formHref("onclick = \"dashboard.editLab(" + id + ");\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + labItemName + "</td>";
                        html += "<td>" + results + "</td>";
                        html += "<td>" + editLink + "</td>";
                        html += "</tr>";

                        count++;
                    }

                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "</table>";

            } else {
                html += gui.formWarningMsg("No lab record found.");
            }
            html += "<br>";
            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"dashboard.addLab('" + this.regNo + "');\"", "");

            return html;
        }

        public String addLab() {
            String html = "";

            Sys sys = new Sys();
            Gui gui = new Gui();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String labItemCode = "";
            String labItemName = "";
            String remarks = "";
            String results = "";
            if (rid != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt;
                    stmt = conn.createStatement();
//                String query = "SELECT * FROM "+this.comCode+".VIEWPTCOMPLAINTS WHERE ID = "+rid;
                    String query = "SELECT * FROM " + this.comCode + ".HMPTLAB WHERE ID = " + rid;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.regNo = rs.getString("REGNO");
                        labItemCode = rs.getString("LABITEMCODE");
                        labItemName = rs.getString("LABITEMNAME");
                        remarks = rs.getString("REMARKS");
                        results = rs.getString("RESULTS");
                    }
                } catch (SQLException e) {
                    html += e.getMessage();
                }

            }

            html += gui.formStart("frmLab", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (rid != null) {
                html += gui.formInput("hidden", "rid", 15, "" + rid, "", "");
            }

            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("labItem", " Lab Item") + "</td>";
//        html += "<td >"+gui.formSelect("labItem", ""+this.comCode+".HMCOMPLAINTS", "LABITEMCODE", "LABITEMNAME", "", "", labItemCode, "", false)+"</td>";
            html += "<td >" + gui.formInput("textarea", "labItem", 40, labItemName, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("remarks", " Remarks") + "</td>";
            html += "<td >" + gui.formInput("textarea", "remarks", 40, remarks, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "pencil.png", "", "") + gui.formLabel("results", " Lab Results") + "</td>";
            html += "<td >" + "<textarea id = \"results\" name = \"results\" cols = \"40\"  rows = \"12\" readonly>" + results + "</textarea>" + "</td>";
            html += "</tr>";
            
            String filePath = sys.getOne(this.comCode + ".HMPTLABDOCS", "filepath", "rid=" + rid);
            String refNo = sys.getOne(this.comCode + ".HMPTLABDOCS", "refno", "rid=" + rid);

            
            if (filePath != null) {
                String docLink = "<a href=\"" + request.getContextPath() + filePath + "\" target=\"blank\">download - " + refNo + "</a>";

               // html += "<tr>";
                //html += "<td colspan=\"2\" >&nbsp;</td>";
//                html += "</tr>";

                html += "<tr>";
                html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "attach.png", "", "") + gui.formLabel("attachment", " Attachment") + "</td>";
                html += "<td >" + docLink + "</td>";
                html += "</tr>";
            }


            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSaveLab", "Save", "save.png", "onclick = \"dashboard.saveLab('labItem');\"", "");
            if (rid != null) {
                html += gui.formButton(request.getContextPath(), "button", "btnDelLab", "Delete", "delete.png", "onclick = \"dashboard.delLab(" + rid + ", '" + labItemName + "', '" + this.regNo + "');\"", "");
            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"dashboard.getLab('" + this.regNo + "');\"", "");
            html += "</td>";
            html += "</tr>";

            
            html += "</table>";

            html += gui.formEnd();
            return html;
        }

        public Object saveLab() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String labItemCode = request.getParameter("labItem");
            String remarks = request.getParameter("remarks");

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query;

                if (rid == null) {
                    Integer id = sys.generateId("" + this.comCode + ".HMPTLAB", "ID");
                    query = "INSERT INTO " + this.comCode + ".HMPTLAB "
                            + "(ID, REGNO, LABITEMCODE, LABITEMNAME, REMARKS, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                            + "VALUES"
                            + "("
                            + id + ", "
                            + "'" + this.regNo + "', "
                            //                    + "'"+ labItemCode +"', "
                            + "'" + id + "', "
                            + "'" + labItemCode + "', "
                            + "'" + remarks + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getLogTime() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                } else {
                    query = "UPDATE " + this.comCode + ".HMPTLAB SET "
                            //                    + "LABITEMCODE    = '"+ labItemCode +"', "
                            + "LABITEMNAME    = '" + labItemCode + "', "
                            + "REMARKS      = '" + remarks + "' "
                            + "WHERE ID     = " + rid + "";
                }

                Integer saved = stmt.executeUpdate(query);

                if (saved == 1) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Lab entry successfully made.");
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record." + query);
                }
            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

        public String getLab() {
            String html = "";
            html += this.getLabTab();
            return html;
        }

        public Object delLab() throws Exception {

            JSONObject obj = new JSONObject();
            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if (rid != null) {
                    String query = "DELETE FROM " + this.comCode + ".HMPTLAB WHERE ID = " + rid;

                    Integer purged = stmt.executeUpdate(query);
                    if (purged == 1) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "Lab entry successfully deleted.");
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
        //lab end

        public String getDiagnosisTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            if (sys.recordExists("" + this.comCode + ".HMPTDIAGNOSIS", "REGNO = '" + this.regNo + "'")) {
                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Diagnosis</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
//                String query = "SELECT * FROM "+this.comCode+".VIEWPTDIAGNOSIS WHERE REGNO = '"+this.regNo+"' ";
                    String query = "SELECT * FROM " + this.comCode + ".HMPTDIAGNOSIS WHERE REGNO = '" + this.regNo + "' ";
                    ResultSet rs = stmt.executeQuery(query);
                    Integer count = 1;
                    while (rs.next()) {

                        String id = rs.getString("ID");
                        String diagName = rs.getString("DIAGNAME");

                        String editLink = gui.formHref("onclick = \"dashboard.editDiagnosis(" + id + ");\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + diagName + "</td>";
                        html += "<td>" + editLink + "</td>";
                        html += "</tr>";

                        count++;
                    }

                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "</table>";

            } else {
                html += gui.formWarningMsg("No diagnosis record found.");
            }
            html += "<br>";
            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"dashboard.addDiagnosis('" + this.regNo + "');\"", "");

            return html;
        }

        public String addDiagnosis() {
            String html = "";

            Gui gui = new Gui();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String diagCode = "";
            String diagName = "";
            String remarks = "";
            if (rid != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
//                String query = "SELECT * FROM "+this.comCode+".VIEWPTDIAGNOSIS WHERE ID = "+rid;
                    String query = "SELECT * FROM " + this.comCode + ".HMPTDIAGNOSIS WHERE ID = " + rid;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.regNo = rs.getString("REGNO");
                        diagCode = rs.getString("DIAGCODE");
                        diagName = rs.getString("DIAGNAME");
                        remarks = rs.getString("REMARKS");
                    }
                } catch (SQLException e) {
                    html += e.getMessage();
                }

            }

            html += gui.formStart("frmDiagnosis", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (rid != null) {
                html += gui.formInput("hidden", "rid", 15, "" + rid, "", "");
            }

            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("diagnosis", " Diagnosis") + "</td>";
//        html += "<td >"+gui.formSelect("diagnosis", ""+this.comCode+".HMDIAGNOSIS", "DIAGCODE", "DIAGNAME", "", "", diagCode, "", false)+"</td>";
            html += "<td >" + gui.formInput("textarea", "diagnosis", 40, diagName, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("remarks", " Remarks") + "</td>";
            html += "<td >" + gui.formInput("textarea", "remarks", 40, remarks, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSaveDiagnosis", "Save", "save.png", "onclick = \"dashboard.saveDiagnosis('diagnosis');\"", "");
            if (rid != null) {
                html += gui.formButton(request.getContextPath(), "button", "btnDelDiagnosis", "Delete", "delete.png", "onclick = \"dashboard.delDiagnosis(" + rid + ", '" + diagName + "', '" + this.regNo + "');\"", "");
            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"dashboard.getDiagnosis('" + this.regNo + "');\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();
            return html;
        }

        public Object saveDiagnosis() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String diagCode = request.getParameter("diagnosis");
            String remarks = request.getParameter("remarks");

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query;

                if (rid == null) {
                    Integer id = sys.generateId(this.comCode + ".HMPTDIAGNOSIS", "ID");

                    query = "INSERT INTO " + this.comCode + ".HMPTDIAGNOSIS "
                            + "(ID, REGNO, DIAGCODE, DIAGNAME, REMARKS, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                            + "VALUES"
                            + "("
                            + id + ", "
                            + "'" + this.regNo + "', "
                            //                    + "'"+ diagCode +"', "
                            + "'" + id + "', "
                            + "'" + diagCode + "', "
                            + "'" + remarks + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getLogTime() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                } else {
                    query = "UPDATE " + this.comCode + ".HMPTDIAGNOSIS SET "
                            //                    + "DIAGCODE     = '"+ diagCode +"', "
                            + "DIAGNAME     = '" + diagCode + "', "
                            + "REMARKS      = '" + remarks + "' "
                            + "WHERE ID     = " + rid + "";
                }

                Integer saved = stmt.executeUpdate(query);

                if (saved > 0) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Diagnosis entry successfully made.");
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record." + query + "=" + saved);
                }
            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

        public String getDiagnosis() {
            String html = "";
            html += this.getDiagnosisTab();
            return html;
        }

        public Object delDiagnosis() throws Exception {

            JSONObject obj = new JSONObject();
            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if (rid != null) {
                    String query = "DELETE FROM " + this.comCode + ".HMPTDIAGNOSIS WHERE ID = " + rid;

                    Integer purged = stmt.executeUpdate(query);
                    if (purged > 0) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "Diagnosis entry successfully deleted.");
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

        public String getMedicationTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            if (sys.recordExists("" + this.comCode + ".HMMEDICATION", "REGNO = '" + this.regNo + "'")) {
                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Medication</th>";
                html += "<th>Quantity</th>";
                html += "<th>Days</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
//                    String query = "SELECT * FROM " + this.comCode + ".VIEWPTMEDICATION WHERE REGNO = '" + this.regNo + "' ";
                    String query = "SELECT * FROM " + this.comCode + ".HMMEDICATION WHERE REGNO = '" + this.regNo + "' ";
                    ResultSet rs = stmt.executeQuery(query);
                    Integer count = 1;
                    while (rs.next()) {

                        String id = rs.getString("ID");
//                        String drugName = rs.getString("DRUGNAME");
                        String drugName = rs.getString("DRUGCODE");
                        String days = rs.getString("DAYS");
                        String qty = rs.getString("QTY");

                        String editLink = gui.formHref("onclick = \"dashboard.editMedication(" + id + ");\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + drugName + "</td>";
                        html += "<td>" + qty + "</td>";
                        html += "<td>" + days + "</td>";
                        html += "<td>" + editLink + "</td>";
                        html += "</tr>";

                        count++;
                    }

                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "</table>";

            } else {
                html += gui.formWarningMsg("No prescription record found.");
            }
            html += "<br>";
            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"dashboard.addMedication('" + this.regNo + "');\"", "");

            return html;
        }

        public String addMedication() {
            String html = "";

            Gui gui = new Gui();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String drugCode = "";
            String drugName = "";
            String days = "";
            String qty = "";
            String instruction = "";
            String advice = "";
            String pxdate = "";
            if (rid != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.comCode + ".VIEWPTMEDICATION WHERE ID = " + rid;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.regNo = rs.getString("REGNO");
                        drugCode = rs.getString("DRUGCODE");
                        drugName = rs.getString("DRUGNAME");
                        days = rs.getString("DAYS");
                        qty = rs.getString("QTY");
                        instruction = rs.getString("INSTRUCTION");
                        advice = rs.getString("ADVICE");
                        
                        pxdate = rs.getString("pxdate");
                        
                        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy HH:mm");

                        java.util.Date pxdate2 = originalFormat.parse(pxdate);
                        pxdate = targetFormat.format(pxdate2);
                            
                        
                        
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

            }

            html += gui.formStart("frmMedication", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (rid != null) {
                html += gui.formInput("hidden", "rid", 15, "" + rid, "", "");
            }

            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "pill.png", "", "") + gui.formLabel("drug", " Drug") + "</td>";
//        html += "<td >"+gui.formSelect("drug", "HMITEMS", "ITEMCODE", "ITEMNAME", "", "ISDRUG = 1", drugCode, "", false)+"</td>";
//        html += "<td >"+gui.formSelect("drug", ""+this.comCode+".ICITEMS", "ITEMCODE", "ITEMNAME", "", "", drugCode, "", false)+"</td>";
//            html += "<td nowrap>" + gui.formAutoComplete("drug", 17, drugCode, "dashboard.searchItem", "drugHd", "") + "</td>";
            html += "<td >" + gui.formInput("text", "drug", 30, drugCode, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("quantity", " Quantity") + "</td>";
            html += "<td >" + gui.formInput("text", "quantity", 15, qty, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("days", " Days") + "</td>";
            html += "<td >" + gui.formInput("text", "days", 15, days, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "package.png", "", "") + gui.formLabel("instruction", " Instruction") + "</td>";
            html += "<td >" + gui.formInput("textarea", "instruction", 40, instruction, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "package.png", "", "") + gui.formLabel("advice", " Advice") + "</td>";
            html += "<td >" + gui.formInput("textarea", "advice", 40, advice, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("pxdate", " Prescription Date") + "</td>";
            html += "<td >" + gui.formDateTime(request.getContextPath(), "pxdate", 20, pxdate, true, "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSaveMedication", "Save", "save.png", "onclick = \"dashboard.saveMedication('drug days quantity');\"", "");
            if (rid != null) {
                html += gui.formButton(request.getContextPath(), "button", "btnDelMedication", "Delete", "delete.png", "onclick = \"dashboard.delMedication(" + rid + ", '" + drugName + "', '" + this.regNo + "');\"", "");
            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"dashboard.getMedication('" + this.regNo + "');\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();
            return html;
        }

        public String searchItem() {
            String html = "";

            Gui gui = new Gui();

            String itemCode = request.getParameter("drugHd");

            html += gui.getAutoColsSearch("" + this.comCode + ".ICITEMS", "ITEMCODE, ITEMNAME", "", itemCode);

            return html;
        }

        public Object getItemProfile() throws Exception {
            JSONObject obj = new JSONObject();

            String itemCode = request.getParameter("itemNo");

            if (itemCode == null || itemCode.trim().equals("")) {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            } else {
                ICItem iCItem = new ICItem(itemCode, this.comCode);

                obj.put("itemName", iCItem.itemName);
                obj.put("quantity", 1.0);
                obj.put("price", iCItem.unitPrice);
                obj.put("amount", (1.0 * iCItem.unitPrice));

                obj.put("success", new Integer(1));
                obj.put("message", "Item No '" + iCItem.itemCode + "' successfully retrieved.");
            }

            return obj;
        }

        public Object saveMedication() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String drugCode = request.getParameter("drug");
            String days = request.getParameter("days"); //!= null ? Integer.parseInt(request.getParameter("days")) : 0;
            String qty = request.getParameter("quantity"); //!= null ? Double.parseDouble(request.getParameter("quantity")) : 0.00;
            String instruction = request.getParameter("instruction");
            String advice = request.getParameter("advice");
            String pxdate = request.getParameter("pxdate");

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query;
                
                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");

                java.util.Date pxdate2 = originalFormat.parse(pxdate);
                pxdate = targetFormat.format(pxdate2);
                    

                if (rid == null) {
                    Integer id = sys.generateId("" + this.comCode + ".HMMEDICATION", "ID");

                    query = "INSERT INTO " + this.comCode + ".HMMEDICATION "
                            + "(ID, REGNO, DRUGCODE, DAYS, QTY, INSTRUCTION, ADVICE, pxdate,"
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                            + "VALUES"
                            + "("
                            + id + ", "
                            + "'" + this.regNo + "', "
                            + "'" + drugCode + "', "
                            + "'" + days + "', "
                            + "'" + qty + "', "
                            + "'" + instruction + "', "
                            + "'" + advice + "', "
                            + "'" + pxdate + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getLogTime() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                } else {
                    query = "UPDATE " + this.comCode + ".HMMEDICATION SET "
                            + "DRUGCODE     = '" + drugCode + "', "
                            + "DAYS         = '" + days + "', "
                            + "QTY          = '" + qty + "', "
                            + "INSTRUCTION  = '" + instruction + "', "
                            + "ADVICE       = '" + advice + "', "
                            + "pxdate       = '" + pxdate + "', "
                            + "AUDITUSER    = '" + sys.getLogUser(session) + "', "
                            + "AUDITDATE    = '" + sys.getLogDate() + "', "
                            + "AUDITTIME    = '" + sys.getLogTime() + "', "
                            + "AUDITIPADR   = '" + sys.getClientIpAdr(request) + "' "
                            + "WHERE ID     = " + rid + "";
                }

                Integer saved = stmt.executeUpdate(query);

                if (saved == 1) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Medication entry successfully made.");
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

        public String getMedication() {
            String html = "";
            html += this.getMedicationTab();
            return html;
        }

        public Object delMedication() throws Exception {

            JSONObject obj = new JSONObject();
            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if (rid != null) {
                    String query = "DELETE FROM " + this.comCode + ".HMMEDICATION WHERE ID = " + rid;

                    Integer purged = stmt.executeUpdate(query);
                    if (purged == 1) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "Medication entry successfully deleted.");
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

        public String getDrNotesTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            if (sys.recordExists(this.table, "REGNO = '" + this.regNo + "'")) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.table + " WHERE REGNO = '" + this.regNo + "'";
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.drNotes = rs.getString("dr_notes");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

            }

            this.drNotes = this.drNotes != null ? this.drNotes : "";

            html += gui.formStart("frmDrNotes", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += gui.formInput("hidden", "id", 15, "" + this.id, "", "");
            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");
            html += gui.formInput("hidden", "regType", 15, this.regType, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\">" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("dr_notes", " Doctor Notes") + "</td>";
            html += "<td ><textarea id = \"dr_notes\" name = \"dr_notes\" cols = \"48\"  rows = \"20\"  >" + this.drNotes + "</textarea></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>"
                    + gui.formButton(request.getContextPath(), "button", "btnSaveDrNotes", "Save", "save.png", "onclick=\"dashboard.saveDrNotes('dr_notes');\"", "")
                    + " "
                    + gui.formButton(request.getContextPath(), "button", "btnPrintDrNotes", "Print", "printer.png", "onclick=\"dashboard.printDrNotes('dr_notes');\"", "")
                    + "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

        public Object saveDrNotes() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            String query;

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                query = "UPDATE " + this.table + " SET "
                        + "DR_NOTES     = '" + this.drNotes + "', "
                        + "AUDITUSER    = '" + sys.getLogUser(session) + "', "
                        + "AUDITDATE    = '" + sys.getLogDate() + "', "
                        + "AUDITTIME    = '" + sys.getLogTime() + "', "
                        + "AUDITIPADR   = '" + sys.getClientIpAdr(request) + "' "
                        + "WHERE ID     = " + id + "";

                Integer saved = stmt.executeUpdate(query);

                if (saved == 1) {
                    obj.put("success", 1);
                    obj.put("message", "Entry successfully made.");
//                    obj.put("message", "Entry successfully made."+ query);

                } else {
                    obj.put("success", 0);
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }

            } catch (Exception e) {
                obj.put("success", 0);
                obj.put("message", e.getMessage());
            }

            return obj;
        }

        public String getDischargeTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            if (sys.recordExists(this.table, "REGNO = '" + this.regNo + "'")) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.table + " WHERE REGNO = '" + this.regNo + "'";
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.remarks = rs.getString("REMARKS");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

            }

            this.remarks = this.remarks != null ? this.remarks : "";

            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += gui.formInput("hidden", "id", 15, "" + this.id, "", "");
            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");
            html += gui.formInput("hidden", "regType", 15, this.regType, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\">" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("remarks", " Remarks") + "</td>";
            html += "<td >" + gui.formInput("textarea", "remarks", 40, this.remarks, "", "") + "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

        public Object save() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query;

                query = "UPDATE " + this.table + " SET "
                        + "DISCHARGED   = " + new Integer(1) + ", "
                        + "REMARKS      = '" + this.remarks + "', "
                        + "AUDITUSER    = '" + sys.getLogUser(session) + "', "
                        + "AUDITDATE    = '" + sys.getLogDate() + "', "
                        + "AUDITTIME    = '" + sys.getLogTime() + "', "
                        + "AUDITIPADR   = '" + sys.getClientIpAdr(request) + "' "
                        + "WHERE ID     = " + id + "";

                Integer saved = stmt.executeUpdate(query);

                if (saved == 1) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");

                    this.invoicePatient(this.regNo);

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

        public void invoicePatient(String regNo) {
            Medical medical = new Medical(this.comCode);
            HttpSession session = request.getSession();
            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM " + this.comCode + ".VIEWPTMEDICATION WHERE REGNO = '" + regNo + "'";
                ResultSet rs = stmt.executeQuery(query);

                while (rs.next()) {
                    String itemCode = rs.getString("DRUGCODE");
                    Double qty = rs.getDouble("QTY");

                    medical.createInvDtls(regNo, "A", itemCode, qty, session, request);
                }
            } catch (Exception e) {

            }

        }

    }

%>