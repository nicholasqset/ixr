<%@page import="bean.finance.VAT"%>
<%@page import="bean.ic.ICItem"%>
<%@page import="org.json.JSONObject"%>
<%@page import="bean.medical.Medical"%>
<%@page import="bean.finance.FinConfig"%>
<%@page import="bean.medical.HMStaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.medical.PatientProfile"%>
<%@page import="java.util.*"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
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
        String remarks = request.getParameter("remarks") != null ? request.getParameter("remarks") : "";

        String pyNo = request.getParameter("billNoHd") != null && !request.getParameter("billNoHd").trim().equals("") ? request.getParameter("billNoHd") : null;
        Integer bid = request.getParameter("bid") != null ? Integer.parseInt(request.getParameter("bid")) : null;

        String entryDate = request.getParameter("entryDate");
        String pyDesc = request.getParameter("pyDesc");
        Integer pYear = request.getParameter("pYear") != null && !request.getParameter("pYear").trim().equals("") ? Integer.parseInt(request.getParameter("pYear")) : null;
        Integer pMonth = request.getParameter("pMonth") != null && !request.getParameter("pMonth").trim().equals("") ? Integer.parseInt(request.getParameter("pMonth")) : null;
        Integer sid = request.getParameter("sid") != null ? Integer.parseInt(request.getParameter("sid")) : null;

        String itemCode = request.getParameter("itemNo");
        Double qty = (request.getParameter("quantity") != null && !request.getParameter("quantity").trim().equals("")) ? Double.parseDouble(request.getParameter("quantity")) : 0.0;
        Double unitPrice = (request.getParameter("price") != null && !request.getParameter("price").trim().equals("")) ? Double.parseDouble(request.getParameter("price")) : 0.0;
        Double amount = (request.getParameter("amount") != null && !request.getParameter("amount").trim().equals("")) ? Double.parseDouble(request.getParameter("amount")) : 0.0;
//
        Integer taxIncl = 1;

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
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("ID");
                        String regNo = rs.getString("REGNO");
                        String regType = rs.getString("REGTYPE");
                        String ptNo = rs.getString("PTNO");
                        String fullName = rs.getString("FULLNAME");

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
            
            html += gui.formInput("hidden", "id", 15, "" + this.id, "", "");

            html += "<div id = \"dhtmlgoodies_tabView1\">";

            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getProfileTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getHistoryTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getVitalParamTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divComplaints\">" + this.getComplaintsTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divLab\">" + this.getLabTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"dvBills\">" + this.getBillingTab() + "</div></div>";
//            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divDiagnosis\">" + this.getDiagnosisTab() + "</div></div>";
//            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divMedication\">" + this.getMedicationTab() + "</div></div>";
//            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getDischargeTab() + "</div>";

            html += "</div>";

            html += "<div style = \"padding-left: 10px; padding-top: 40px; border: 0;\" >";

//            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Discharge", "save.png", "onclick = \"dashboard.save('remarks');\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"module.getGrid();\"", "");
            html += "</div>";

            html += "<script type = \"text/javascript\">";
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Profile\', \'History\', \'Vital Parameter\', \'Complaints\', \'Laboratory\', \'Billing\'), 0, 625, 365, Array(false));";
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
//            html += "<br>";
//            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"dashboard.addLab('" + this.regNo + "');\"", "");

            return html;
        }

        public String addLab() {
            String html = "";

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
            html += "<td >" + gui.formInput("textarea", "labItem", 40, labItemName, "", "readonly") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("remarks", " Doctor Remarks") + "</td>";
            html += "<td >" + gui.formInput("textarea", "remarks", 40, remarks, "", "readonly") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "pencil.png", "", "") + gui.formLabel("results", " Lab Results") + "</td>";
            html += "<td >" + gui.formInput("textarea", "results", 40, results, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSaveLab", "Save", "save.png", "onclick = \"dashboard.saveLab('results');\"", "");
//            if (rid != null) {
//                html += gui.formButton(request.getContextPath(), "button", "btnDelLab", "Delete", "delete.png", "onclick = \"dashboard.delLab(" + rid + ", '" + labItemName + "', '" + this.regNo + "');\"", "");
//            }
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
            String results = request.getParameter("results");

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
                            //                            + "LABITEMNAME    = '" + labItemCode + "', "
                            //                            + "REMARKS      = '" + remarks + "' "
                            + "RESULTS      = '" + results + "' "
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
                html += "<th>Days</th>";
                html += "<th>Quantity</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.comCode + ".VIEWPTMEDICATION WHERE REGNO = '" + this.regNo + "' ";
                    ResultSet rs = stmt.executeQuery(query);
                    Integer count = 1;
                    while (rs.next()) {

                        String id = rs.getString("ID");
                        String drugName = rs.getString("DRUGNAME");
                        String days = rs.getString("DAYS");
                        String qty = rs.getString("QTY");

                        String editLink = gui.formHref("onclick = \"dashboard.editMedication(" + id + ");\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + drugName + "</td>";
                        html += "<td>" + days + "</td>";
                        html += "<td>" + qty + "</td>";
                        html += "<td>" + editLink + "</td>";
                        html += "</tr>";

                        count++;
                    }

                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "</table>";

            } else {
                html += gui.formWarningMsg("No medication record found.");
            }
            html += "<br>";
            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"dashboard.addMedication('" + this.regNo + "');\"", "");

            return html;
        }

        public Object saveMedication() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String drugCode = request.getParameter("drug");
            Integer days = request.getParameter("days") != null ? Integer.parseInt(request.getParameter("days")) : 0;
            Double qty = request.getParameter("quantity") != null ? Double.parseDouble(request.getParameter("quantity")) : 0.00;
            String instruction = request.getParameter("instruction");
            String advice = request.getParameter("advice");

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query;

                if (rid == null) {
                    Integer id = sys.generateId("" + this.comCode + ".HMMEDICATION", "ID");

                    query = "INSERT INTO " + this.comCode + ".HMMEDICATION "
                            + "(ID, REGNO, DRUGCODE, DAYS, QTY, INSTRUCTION, ADVICE, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                            + "VALUES"
                            + "("
                            + id + ", "
                            + "'" + this.regNo + "', "
                            + "'" + drugCode + "', "
                            + days + ", "
                            + qty + ", "
                            + "'" + instruction + "', "
                            + "'" + advice + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getLogTime() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                } else {
                    query = "UPDATE " + this.comCode + ".HMMEDICATION SET "
                            + "DRUGCODE     = '" + drugCode + "', "
                            + "DAYS         = " + days + ", "
                            + "QTY          = " + qty + ", "
                            + "INSTRUCTION  = '" + instruction + "', "
                            + "ADVICE       = '" + advice + "', "
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

//            html += gui.formInput("hidden", "id", 15, "" + this.id, "", "");
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

        public String getBillingTab() {
            String html = "";

            html += this.listBills();

            return html;
        }

        public String listBills() {
            String html = "";

            Sys sys = new Sys();
            Gui gui = new Gui();

            String regNo = sys.getOne(this.table, "REGNO", "ID = " + this.id);
            this.ptNo = sys.getOne(this.table, "PTNO", "ID = " + this.id);

            if (sys.recordExists(this.comCode + ".VIEWHMPYHDR", "REGNO = '" + regNo + "'")) {
                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Invoice No</th>";
                html += "<th>Invoice Date</th>";
                html += "<th>Paid</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";
                html += "<th style = \"text-align: right;\">Options</th>";
                html += "</tr>";

                Double total = 0.00;

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query = "SELECT * FROM " + this.comCode + ".VIEWHMPYHDR WHERE REGNO = '" + regNo + "' ORDER BY PYNO DESC ";
                    ResultSet rs = stmt.executeQuery(query);

                    Integer count = 1;

                    while (rs.next()) {
                        Integer bid = rs.getInt("ID");
                        String pyNo = rs.getString("PYNO");
                        String entryDate = rs.getString("ENTRYDATE");
                        Integer cleared = rs.getInt("CLEARED");

                        String invDateLbl = entryDate;

                        Double amount = 0.00;

                        String amountInvDtls_ = sys.getOneAgt(this.comCode + ".VIEWHMPYDTLS", "SUM", "AMOUNT", "SM", "PYNO = '" + pyNo + "'");

                        if (amountInvDtls_ != null) {
                            amount = Double.parseDouble(amountInvDtls_);
                        }

                        String clearedLbl = cleared == 1 ? gui.formIcon(request.getContextPath(), "tick.png", "", "") : gui.formIcon(request.getContextPath(), "cross.png", "", "");

                        String editLink = gui.formHref("onclick = \"registration.editBill(" + this.id + ", " + bid + ", '" + pyNo + "');\"", request.getContextPath(), "", "edit", "edit", "", "");
                        String printLink = gui.formHref("onclick = \"registration.print('" + pyNo + "');\"", request.getContextPath(), "", "print", "print", "", "");

                        String opts = "";

                        if (cleared == 1) {
                            opts = printLink;
                        } else {
                            opts = editLink + " || " + printLink;
                        }

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + pyNo + "</td>";
                        html += "<td>" + invDateLbl + "</td>";
                        html += "<td>" + clearedLbl + "</td>";
                        html += "<td style = \"text-align: right;\">" + amount + "</td>";
                        html += "<td style = \"text-align: right;\">" + opts + "</td>";
                        html += "</tr>";

                        total = total + amount;

                        count++;
                    }

                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "<tr>";
                html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"3\">Total</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\" >" + total + "</td>";
                html += "<td>&nbsp;</td>";
                html += "</tr>";

                html += "</table>";
            } else {
                html += "No records found.";
            }

            html += "<div style = \"padding: 7px 0;\">" + gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "math-add.png", "onclick = \"registration.manageBill('" + regNo + "', '" + this.ptNo + "'); return false;\"", "") + "</div>";

            return html;
        }

        public String manageBill() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            this.ptNo = request.getParameter("ptNo");

            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

            String defaultDate = sys.getLogDate();

            try {
                java.util.Date today = originalFormat.parse(defaultDate);
                defaultDate = targetFormat.format(today);
            } catch (ParseException e) {
                html += e.getMessage();
            } catch (Exception e) {
                html += e.getMessage();
            }

            if (this.bid != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.comCode + ".VIEWHMPYHDR WHERE ID = " + this.bid;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.pyNo = rs.getString("PYNO");
                        this.entryDate = rs.getString("ENTRYDATE");

                        java.util.Date entryDate = originalFormat.parse(this.entryDate);
                        this.entryDate = targetFormat.format(entryDate);

                        this.pyDesc = rs.getString("PYDESC");
                        this.pMonth = rs.getInt("PMONTH");
                        this.pYear = rs.getInt("PYEAR");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }
            }

            html += gui.formStart("frmBill", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += gui.formInput("hidden", "regNo", 30, "" + this.regNo, "", "");

            html += "<div id = \"dvPyEntrySid\">";
            if (this.sid != null) {
                html += gui.formInput("hidden", "sid", 30, "" + this.sid, "", "");

            }
            html += "</div>";

            PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("billNo", " Bill No.") + "</td>";
            html += "<td>" + gui.formInput("text", "billNo", 15, this.bid != null ? this.pyNo : "", "", "disabled") + gui.formInput("hidden", "billNoHd", 15, this.bid != null ? this.pyNo : "", "", "") + "</td>";

            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("entryDate", " Date") + "</td>";
            html += "<td>" + gui.formDateTime(request.getContextPath(), "entryDate", 13, this.bid != null ? this.entryDate : defaultDate, false, "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + gui.formLabel("pyDesc", " Description") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "pyDesc", 30, this.bid != null ? this.pyDesc : this.ptNo + "-" + patientProfile.fullName, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td width = \"15%\">" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("pYear", " Fiscal Year") + "</td>";
            html += "<td width = \"35%\">" + gui.formSelect("pYear", this.comCode + ".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.bid != null ? "" + this.pYear : "" + sys.getPeriodYear(this.comCode), "", false) + "</td>";

            html += "<td width = \"15%\">" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("pMonth", " Period") + "</td>";
            html += "<td>" + gui.formMonthSelect("pMonth", this.bid != null ? this.pMonth : sys.getPeriodMonth(this.comCode), "", true) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("itemNo", " Item No") + "</td>";
            html += "<td nowrap>" + gui.formAutoComplete("itemNo", 13, "", "registration.searchItem", "itemNoHd", "") + "</td>";

            html += "<td>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + " Item Name</td>";
            html += "<td id = \"tdItemName\">&nbsp;</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("quantity", " Quantity") + "</td>";
            html += "<td id = \"tdQuantity\" colspan = \"3\">" + gui.formInput("text", "quantity", 15, "", "onkeyup = \"registration.getItemTotalAmount();\"", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "coins.png", "", "") + gui.formLabel("price", " Price") + "</td>";
            html += "<td id = \"tdCost\" colspan = \"3\" nowrap>" + gui.formInput("text", "price", 15, "", "onkeyup = \"registration.getItemTotalAmount();\"", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "money.png", "", "") + gui.formLabel("amount", " Amount") + "</td>";
            html += "<td id = \"tdAmount\" colspan = \"3\" nowrap>" + gui.formInput("text", "amount", 15, "", "", "disabled") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"4\"><div id = \"dvPyEntries\">" + this.getPyEntries() + "</div></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td colspan = \"3\">";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"registration.saveBill('entryDate pyDesc pYear pMonth till quantity itemNo price amount'); return false;\"", "");
            html += "&nbsp;";
            html += gui.formButton(request.getContextPath(), "button", "btnBack", "Back", "arrow-left-2.png", "onclick = \"registration.listBills(); return false;\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

        public String searchItem() {
            String html = "";

            Gui gui = new Gui();

            this.itemCode = request.getParameter("itemNoHd");

//        html += gui.getAutoColsSearch("VIEWHMITEMS", "ITEMCODE, ITEMNAME", "", this.itemCode);
            html += gui.getAutoColsSearch(this.comCode + ".ICITEMS", "ITEMCODE, ITEMNAME", "", this.itemCode);

            return html;
        }

        public Object getItemProfile() throws Exception {
            JSONObject obj = new JSONObject();

            if (this.itemCode == null || this.itemCode.trim().equals("")) {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            } else {
                ICItem iCItem = new ICItem(this.itemCode, this.comCode);

                obj.put("itemName", iCItem.itemName);
                obj.put("quantity", 1.0);
                obj.put("price", iCItem.unitPrice);
                obj.put("amount", (1.0 * iCItem.unitPrice));

                obj.put("success", new Integer(1));
                obj.put("message", "Item No '" + iCItem.itemCode + "' successfully retrieved.");
            }

            return obj;
        }

        public String getPyEntries() {
            String html = "";
            Gui gui = new Gui();
            Sys sys = new Sys();

//        html += this.pyNo;
            if (sys.recordExists(this.comCode + ".VIEWHMPYDTLS", "PYNO = '" + this.pyNo + "'")) {
                html += "<div id = \"dvPyEntries-a\">";

                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Item</th>";
                html += "<th style = \"text-align: right;\">Quantity</th>";
                html += "<th style = \"text-align: right;\">Price</th>";
                html += "<th style = \"text-align: center;\">Tax Incl.</th>";
                html += "<th style = \"text-align: right;\">Tax</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";

                html += "<th style = \"text-align: center;\">Options</th>";
                html += "</tr>";

                Double sumAmount = 0.0;
                Double sumTax = 0.0;
                Double sumTotal = 0.0;

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    Integer count = 1;

                    String query = "SELECT * FROM " + this.comCode + ".VIEWHMPYDTLS WHERE PYNO = '" + this.pyNo + "'";

                    ResultSet rs = stmt.executeQuery(query);

                    while (rs.next()) {
                        Integer id = rs.getInt("ID");
                        String itemName = rs.getString("ITEMNAME");
                        Double qty = rs.getDouble("QTY");
                        Double unitPrice = rs.getDouble("UNITPRICE");
                        Double taxAmount = rs.getDouble("TAXAMOUNT");
                        Double amount = rs.getDouble("AMOUNT");
                        Double total = rs.getDouble("TOTAL");
                        Integer taxIncl = rs.getInt("TAXINCL");
                        Integer cleared = rs.getInt("CLEARED");

                        Double taxAmountAlt = taxIncl == 1 ? taxAmount : 0;

                        String taxInclLbl = taxIncl == 1 ? "Yes" : "No";

                        String editLink = gui.formHref("onclick = \"registration.editPyDtls(" + id + ");\"", request.getContextPath(), "", "edit", "edit", "", "");
                        String removeLink = gui.formHref("onclick = \"registration.purge(" + id + ", '" + itemName + "');\"", request.getContextPath(), "", "delete", "delete", "", "");

                        String opts = "";
                        if (cleared == 1) {
                            opts = gui.formIcon(request.getContextPath(), "lock.png", "", "");
                        } else {
                            opts = editLink + " || " + removeLink;
                        }

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + itemName + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(qty.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(unitPrice.toString()) + "</td>";
                        html += "<td style = \"text-align: center;\">" + taxInclLbl + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(taxAmountAlt.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(amount.toString()) + "</td>";

                        html += "<td style = \"text-align: center;\">" + opts + "</td>";
                        html += "</tr>";

                        sumAmount = sumAmount + amount;
                        sumTax = sumTax + taxAmountAlt;
                        sumTotal = sumTotal + total;

                        count++;
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "<tr>";
                html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"5\">Total</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\">" + sys.numberFormat(sumTax.toString()) + "</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\">" + sys.numberFormat(sumAmount.toString()) + "</td>";
                html += "<td>&nbsp;</td>";
                html += "</tr>";

                html += "</table>";

                html += "</div>";
            } else {
                html += "No bill items record found.";
            }

            return html;
        }

        public Object getItemTotalAmount() throws Exception {
            JSONObject obj = new JSONObject();

            Double itemTotalPrice = this.qty * this.unitPrice;

            obj.put("amount", itemTotalPrice);

            return obj;
        }

        public Object saveBill() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            this.pyNo = this.getPyNo();

            if (this.pyNo != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;
                    Integer saved = 0;

                    ICItem iCItem = new ICItem(this.itemCode, this.comCode);

                    Boolean taxInclusive = (this.taxIncl != null && this.taxIncl == 1) ? true : false;

                    VAT vAT = new VAT(this.amount, taxInclusive, this.comCode);

                    if (this.sid == null) {
                        Integer sid = sys.generateId("HMPYDTLS", "ID");

                        query = "INSERT INTO " + this.comCode + ".HMPYDTLS "
                                + "(ID, PYNO, ITEMCODE, "
                                + "QTY, UNITCOST, UNITPRICE, TAXINCL, "
                                + "TAXRATE, TAXAMOUNT, NETAMOUNT, AMOUNT, TOTAL, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + sid + ", "
                                + "'" + this.pyNo + "', "
                                + "'" + this.itemCode + "', "
                                + this.qty + ", "
                                + iCItem.unitCost + ", "
                                + this.unitPrice + ", "
                                + this.taxIncl + ", "
                                + vAT.vatRate + ", "
                                + vAT.vatAmount + ", "
                                + vAT.netAmount + ", "
                                + this.amount + ", "
                                + vAT.total + ", "
                                + "'" + sys.getLogUser(session) + "', "
                                + "'" + sys.getLogDate() + "', "
                                + "'" + sys.getLogTime() + "', "
                                + "'" + sys.getClientIpAdr(request) + "'"
                                + ")";
                    } else {
                        query = "UPDATE " + this.comCode + ".HMPYDTLS SET "
                                + "ITEMCODE     = '" + this.itemCode + "', "
                                + "QTY          = " + this.qty + ", "
                                + "UNITPRICE     = " + this.unitPrice + ", "
                                + "TAXINCL      = " + this.taxIncl + ", "
                                + "TAXRATE      = " + vAT.vatRate + ", "
                                + "TAXAMOUNT    = " + vAT.vatAmount + ", "
                                + "NETAMOUNT    = " + vAT.netAmount + ", "
                                + "AMOUNT       = " + this.amount + ", "
                                + "TOTAL        = " + vAT.total + " "
                                + "WHERE ID     = " + this.sid;
                    }

                    saved = stmt.executeUpdate(query);

                    if (saved == 1) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "Entry successfully made.");

                        obj.put("billNo", this.pyNo);
                    } else {
                        obj.put("success", new Integer(0));
                        obj.put("message", "Oops! An Un-expected error occured while saving record.");
                    }
                } catch (Exception e) {
                    obj.put("success", new Integer(0));
                    obj.put("message", e.getMessage());
                }
            } else {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record header.");
            }

            return obj;
        }

        public String getPyNo() {
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            if (this.pyNo == null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    Integer id = sys.generateId(this.comCode + ".HMPYHDR", "ID");
                    this.pyNo = sys.getNextNo(this.comCode + ".HMPYHDR", "ID", "", "", 7);

                    SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                    SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                    java.util.Date entryDate = originalFormat.parse(this.entryDate);
                    this.entryDate = targetFormat.format(entryDate);

                    String query = "INSERT INTO " + this.comCode + ".HMPYHDR "
                            + "("
                            + "ID, REGNO, PYNO, PYDESC, "
                            + "ENTRYDATE, PYEAR, PMONTH, TILLNO, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + id + ", "
                            + "'" + this.regNo + "', "
                            + "'" + this.pyNo + "', "
                            + "'" + this.pyDesc + "', "
                            + "'" + this.entryDate + "', "
                            + this.pYear + ", "
                            + this.pMonth + ", "
                            + "'0', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + sys.getLogTime() + ", "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                    Integer pyHdrCreated = stmt.executeUpdate(query);

                    if (pyHdrCreated == 1) {
                        //
                    } else {
                        this.pyNo = null;
                    }
                } catch (Exception e) {
                    e.getMessage();
                }
            }

            return this.pyNo;
        }

        public Object editPyDtls() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            Gui gui = new Gui();
            if (sys.recordExists(this.comCode + ".HMPYDTLS", "ID = " + this.sid + "")) {
                try {

                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query = "SELECT * FROM " + this.comCode + ".VIEWHMPYDTLS WHERE ID = " + this.sid + "";
                    ResultSet rs = stmt.executeQuery(query);

                    while (rs.next()) {
                        String id = rs.getString("ID");
                        String itemCode = rs.getString("ITEMCODE");
                        Double qty = rs.getDouble("QTY");
                        Double unitPrice = rs.getDouble("UNITPRICE");
                        String amount = rs.getString("AMOUNT");

                        obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                        obj.put("itemNo", itemCode);
                        obj.put("quantity", qty);
                        obj.put("price", unitPrice);
                        obj.put("amount", amount);

                        obj.put("success", new Integer(1));
                        obj.put("message", "Record retrieved successfully.");
                    }
                } catch (Exception e) {
                    obj.put("success", new Integer(0));
                    obj.put("message", e.getMessage());
                }
            } else {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            }

            return obj;
        }

        public Object purge() throws Exception {
            JSONObject obj = new JSONObject();

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if (this.id != null) {
                    String query = "DELETE FROM " + this.comCode + ".HMPYDTLS WHERE ID = " + this.id;

                    Integer purged = stmt.executeUpdate(query);
                    if (purged > 0) {
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
            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

    }

%>