<%@page import="com.qset.communication.Subscriber"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

    final class Subscribers {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        String table = comCode + ".cm_subscribers";
        String view = comCode + ".cm_subscribers";

        Integer id = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : null;
        String salutationCode = request.getParameter("salutation");
        String firstName = request.getParameter("firstName");
        String middleName = request.getParameter("middleName");
        String lastName = request.getParameter("lastName");
        String genderCode = request.getParameter("gender");
        String dob = request.getParameter("dob");
        String countryCode = request.getParameter("country");
        String nationalId = request.getParameter("nationalId");
        String passportNo = request.getParameter("passportNo");
        String postalAdr = request.getParameter("postalAdr");
        String postalCode = request.getParameter("postalCode");
        String physicalAdr = request.getParameter("physicalAdr");
        String phoneNo = request.getParameter("phoneNo");
        String email = request.getParameter("email");

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

                            list.add("first_name");
                            list.add("last_name");
                            list.add("phone_no");
                            list.add("email");
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

                String orderBy = "first_name ";
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
                    html += "<th>First Name</th>";
                    html += "<th>Last Name</th>";
                    html += "<th>Phone No</th>";
                    html += "<th>Email</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("ID");
                        String firstName = rs.getString("first_name");
                        String lastName = rs.getString("last_name");
                        String phoneNo = rs.getString("phone_no");
                        String email = rs.getString("email");

                        String bgcolor = (count % 2 > 0) ? "#FFFFFF" : "#F7F7F7";

                        String edit = gui.formHref("onclick = \"module.editModule(" + id + ")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr bgcolor = \"" + bgcolor + "\">";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + firstName + "</td>";
                        html += "<td>" + lastName + "</td>";
                        html += "<td>" + phoneNo + "</td>";
                        html += "<td>" + email + "</td>";
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

            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getBioDataTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getContactTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id=\"divSubGroup\">" + this.getSubGroupsTab() + "</div></div>";

            html += "</div>";

            html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"subscriber.save('firstName lastName dob phoneNo  email'); return false;\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
            html += "</div>";

            html += "<script type = \"text/javascript\">";
            if (this.id != null) {
                html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\', \'Groups\'), 0, 625, 350, Array(false, false, false));";
            } else {
                html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\'), 0, 625, 350, Array(false, false));";
            }

            html += "</script>";

            html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";

            return html;
        }

        public String getBioDataTab() {
            Gui gui = new Gui();
            Sys sys = new Sys();

//            Connection conn = ConnectionProvider.getConnection();
//            Statement stmt = null;

            String html = "";

//        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
//        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" enctype = \"multipart/form-data\" target = \"_blank\">";

            if (this.id != null) {

                Subscriber subscriber = new Subscriber(this.id + "", this.comCode);

                this.salutationCode = subscriber.salutationCode;
                this.firstName = subscriber.firstName;
                this.middleName = subscriber.middleName;
                this.lastName = subscriber.lastName;
                this.genderCode = subscriber.genderCode;
                this.dob = subscriber.dob;
                this.countryCode = subscriber.countryCode;
                this.nationalId = subscriber.nationalId;
                this.passportNo = subscriber.passportNo;
                
                this.postalAdr = subscriber.postalAdr;
                this.postalCode = subscriber.postalCode;
                this.physicalAdr = subscriber.physicalAdr;
                this.phoneNo = subscriber.phoneNo;
                this.email = subscriber.email;

                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

                try {
                    java.util.Date dob = originalFormat.parse(this.dob);
                    this.dob = targetFormat.format(dob);
                } catch (ParseException e) {
                    html += e.getMessage();
                }

                html += gui.formInput("hidden", "id", 30, "" + this.id, "", "");
            }

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "personal-information.png", "", "") + " " + gui.formLabel("salutation", "Salutation") + "</td>";
            html += "<td colspan = \"3\">" + gui.formSelect("salutation", comCode + ".CSSALUTATION", "SALUTATIONCODE", "SALUTATIONNAME", null, null, this.id != null ? this.salutationCode : "", null, false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("firstName", "First Name") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "firstName", 25, this.id != null ? this.firstName : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("middleName", "Middle Name") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "middleName", 25, this.id != null ? this.middleName : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("lastName", "Last Name") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "lastName", 25, this.id != null ? this.lastName : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "gender.png", "", "") + " " + gui.formLabel("gender", "Gender") + "</td>";
            html += "<td colspan = \"3\">" + gui.formSelect("gender", comCode + ".CSGENDER", "GENDERCODE", "GENDERNAME", null, null, this.id != null ? this.genderCode : "", null, false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + " " + gui.formLabel("dob", "Date of Birth") + "</td>";
            html += "<td colspan = \"3\">" + gui.formDateTime(request.getContextPath(), "dob", 15, this.id != null ? this.dob : sys.getLogDateV2(), false, "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "globe-medium-green.png", "", "") + " " + gui.formLabel("country", "Country") + "</td>";
            html += "<td colspan = \"3\">" + gui.formSelect("country", comCode + ".CSCOUNTRIES", "COUNTRYCODE", "COUNTRYNAME", null, null, this.id != null ? this.countryCode : "KE", null, false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td width = \"20%\" nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("nationalId", "National ID") + "</td>";
            html += "<td width = \"30%\">" + gui.formInput("text", "nationalId", 15, this.id != null ? this.nationalId : "", "", "") + "</td>";

            html += "<td width = \"20%\" nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("passportNo", "Passport No") + "</td>";
            html += "<td>" + gui.formInput("text", "passportNo", 15, this.id != null ? this.passportNo : "", "", "") + "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

//        public String searchStaff() {
//            String html = "";
//
//            Gui gui = new Gui();
//
//            this.staffNo = request.getParameter("staffNoHd");
//
//            html += gui.getAutoColsSearch(comCode + ".HMSTAFFPROFILE", "STAFFNO, FULLNAME", "", this.staffNo);
//
//            return html;
//        }
//        public Boolean hasPhoto(String staffNo) {
//            Boolean hasPhoto = false;
//
//            Sys sys = new Sys();
//
//            if (this.id != null) {
//                Connection conn = ConnectionProvider.getConnection();
//                Statement stmt = null;
//
//                Integer count = 0;
//
//                try {
//                    stmt = conn.createStatement();
//                    String query = "SELECT COUNT(*) FROM " + this.comCode + ".HMSTAFFPHOTOS WHERE STAFFNO = '" + staffNo + "'";
//                    ResultSet rs = stmt.executeQuery(query);
//                    while (rs.next()) {
//                        count = rs.getInt("COUNT(*)");
//                    }
//
//                    if (count > 0) {
//                        hasPhoto = true;
//                    }
//
//                } catch (Exception e) {
//                    sys.logV2(e.getMessage());
//                }
//            }
//
//            return hasPhoto;
//        }

        public String getContactTab() {
            String html = "";
            Gui gui = new Gui();

            html += gui.formStart("frmContact", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"20%\">" + gui.formIcon(request.getContextPath(), "email-open.png", "", "") + " " + gui.formLabel("postalAdr", "Postal Address") + "</td>";
            html += "<td width = \"30%\">" + gui.formInput("text", "postalAdr", 20, this.id != null ? this.postalAdr : "", "", "") + "</td>";

            html += "<td width = \"20%\">" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("postalCode", "Postal Code") + "</td>";
            html += "<td>" + gui.formInput("text", "postalCode", 15, this.id != null ? this.postalCode : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("physicalAdr", "Physical Address") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("textarea", "physicalAdr", 30, this.id != null ? this.physicalAdr : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
//            html += "<td>" + gui.formIcon(request.getContextPath(), "telephone.png", "", "") + " " + gui.formLabel("telephone", "Telephone") + "</td>";
//            html += "<td>" + gui.formInput("text", "telephone", 15, this.id != null ? this.telephone : "", "", "") + "</td>";

            html += "<td>" + gui.formIcon(request.getContextPath(), "mobile-phone.png", "", "") + " " + gui.formLabel("phoneNo", "Cell Phone") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "phoneNo", 15, this.id != null ? this.phoneNo : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "email.png", "", "") + " " + gui.formLabel("email", "Email") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "email", 25, this.id != null ? this.email : "", "", "") + "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

//        public Object getStaffProfile() throws Exception {
//            JSONObject obj = new JSONObject();
//
//            if (this.id == null || this.id.equals("")) {
//                obj.put("success", new Integer(0));
//                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
//            } else {
//
//                Subscriber subscriber = new Subscriber(this.id + "", this.comCode);
//
//                obj.put("salutation", subscriber.salutationCode);
//                obj.put("firstName", subscriber.firstName);
//                obj.put("middleName", subscriber.middleName);
//                obj.put("lastName", subscriber.lastName);
//                obj.put("gender", subscriber.genderCode);
//
//                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
//                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");
//
//                try {
//                    java.util.Date dob = originalFormat.parse(subscriber.dob);
//                    subscriber.dob = targetFormat.format(dob);
//                } catch (ParseException e) {
//
//                }
//
//                obj.put("dob", subscriber.dob);
//                obj.put("country", subscriber.countryCode);
//                obj.put("postalAddr", subscriber.postalAdr);
//                obj.put("postalCode", subscriber.postalCode);
//                obj.put("physicalAddr", subscriber.physicalAdr);
////                obj.put("telephone", subscriber.telephone);
//                obj.put("cellphone", subscriber.phoneNo);
//                obj.put("email", subscriber.email);
//
//                obj.put("success", new Integer(1));
//                obj.put("message", "Subscriber Id '" + this.id + "' successfully retrieved.");
//
//            }
//
//            return obj;
//        }

        public JSONObject save() throws Exception{

            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;
            String query = "";

            Integer saved = 0;

            try {
                stmt = conn.createStatement();

                SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                try {
                    java.util.Date dob = originalFormat.parse(this.dob);
                    this.dob = targetFormat.format(dob);
                } catch (ParseException e) {

                }

                if (this.id == null) {
                    query += "INSERT INTO " + this.table + " "
                            + "(SALUTATION_CODE, FIRST_NAME, MIDDLE_NAME, LAST_NAME, "
                            + "GENDER_CODE, DOB, COUNTRY_CODE, NATIONAL_ID, PASSPORT_NO, "
                            + "POSTAL_ADR, POSTAL_CODE, PHYSICAL_ADR, phone_no, EMAIL) "
                            + "VALUES"
                            + "("
                            + "'" + this.salutationCode + "',"
                            + "'" + this.firstName + "',"
                            + "'" + this.middleName + "',"
                            + "'" + this.lastName + "',"
                            + "'" + this.genderCode + "',"
                            + "'" + this.dob + "',"
                            + "'" + this.countryCode + "',"
                            + "'" + this.nationalId + "',"
                            + "'" + this.passportNo + "',"
                            + "'" + this.postalAdr + "',"
                            + "'" + this.postalCode + "',"
                            + "'" + this.physicalAdr + "',"
                            //                            + "'" + this.telephone + "',"
                            + "'" + this.phoneNo + "',"
                            + "'" + this.email + "'"
                            + ")";
                            
                    String id_ = sys.getOneByQuery("SELECT currval(pg_get_serial_sequence('"+this.table+"','id')) as col");

                    obj.put("id", id_);

                } else {
                    query = "UPDATE " + this.table + " SET "
                            + "SALUTATION_CODE   = '" + this.salutationCode + "', "
                            + "FIRST_NAME        = '" + this.firstName + "', "
                            + "MIDDLE_NAME       = '" + this.middleName + "', "
                            + "LAST_NAME         = '" + this.lastName + "',"
                            + "GENDER_CODE       = '" + this.genderCode + "', "
                            + "DOB              = '" + this.dob + "', "
                            + "COUNTRY_CODE      = '" + this.countryCode + "', "
                            + "NATIONAL_ID       = '" + this.nationalId + "', "
                            + "PASSPORT_NO       = '" + this.passportNo + "', "
                            + "POSTAL_ADR       = '" + this.postalAdr + "', "
                            + "POSTAL_CODE       = '" + this.postalCode + "', "
                            + "PHYSICAL_ADR     = '" + this.physicalAdr + "', "
                            //                                + "TELEPHONE        = '" + this.telephone + "', "
                            + "phone_no        = '" + this.phoneNo + "', "
                            + "EMAIL            = '" + this.email + "' "
                            //                                + "STAFFTYPECODE    = '" + this.staffTypeCode + "', "
                            //                                + "DEPTCODE         = '" + this.deptCode + "', "
                            //                                + "CMNT             = '" + this.cmnt + "', "
                            //                                + "AUDITUSER        = '" + system.getLogUser(session) + "', "
                            //                                + "AUDITDATE        = '" + system.getLogDate() + "', "
                            //                                + "AUDITTIME        = '" + system.getLogTime() + "', "
                            //                                + "AUDITIP          = '" + system.getClientIpAdr(request) + "' "
                            + "WHERE ID    = '" + this.id + "'";
                }

                saved = stmt.executeUpdate(query);

                sys.logV2(query);

                if (saved > 0) {

                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");

//                    system.createUser(this.staffNo, this.firstName + " " + this.middleName + " " + this.lastName, this.email, this.cellphone, this.comCode);
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An unexpected error occured while saving record.");
                }

            } catch (Exception e) {
                obj.put("success", 0);
                obj.put("message", e.getMessage());
                
            }

            return obj;
        }

//        public String getNextStaffNo() {
//            String nextNo = "";
//            Connection conn = ConnectionProvider.getConnection();
//            Statement stmt;
//            String query;
//            Integer drNoMax = 0;
//            try {
//                stmt = conn.createStatement();
//                query = "SELECT MAX(ID) FROM " + this.table;
//                ResultSet rs = stmt.executeQuery(query);
//                while (rs.next()) {
//                    drNoMax = rs.getInt("MAX(ID)");
//                }
//
//            } catch (Exception e) {
//                nextNo += e.getMessage();
//            }
//            drNoMax = drNoMax + 1;
//
//            nextNo = String.format("%05d", drNoMax);
//
//            return nextNo;
//        }

//        public Object purgePhoto() {
//
//            Connection conn = ConnectionProvider.getConnection();
//            Statement stmt = null;
//
//            JSONObject obj = new JSONObject();
//
//            try {
//                stmt = conn.createStatement();
//
//                if (this.staffNo != null && !this.staffNo.trim().equals("")) {
//                    String query = "DELETE FROM HMSTAFFPHOTOS WHERE STAFFNO = '" + this.staffNo + "'";
//
//                    Integer purged = stmt.executeUpdate(query);
//                    if (purged == 1) {
//                        obj.put("success", new Integer(1));
//                        obj.put("message", "Entry successfully deleted.");
//                    } else {
//                        obj.put("success", new Integer(0));
//                        obj.put("message", "An error occured while deleting record.");
//                    }
//                } else {
//                    obj.put("success", new Integer(0));
//                    obj.put("message", "An error occured while deleting record.");
//                }
//
//            } catch (Exception e) {
//
//            }
//
//            return obj;
//
//        }

        public String getSubGroupsTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            if (sys.recordExists("" + this.comCode + ".cm_subscriber_grps", "subscriber_id = '" + this.id + "'")) {
                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Subscriber Group</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT s.*, g.grp_desc FROM " + this.comCode + ".cm_subscriber_grps s "
                    + "LEFT JOIN " + this.comCode + ".cm_groups g on g.grp_code = s.grp_code "
                    + "WHERE s.subscriber_id = '" + this.id + "' ";
                    ResultSet rs = stmt.executeQuery(query);
                    Integer count = 1;
                    while (rs.next()) {

                        String id = rs.getString("ID");
                        String grp_desc = rs.getString("grp_desc");

                        String editLink = gui.formHref("onclick = \"subscriber.editSubGroup(" + id + ");\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + grp_desc + "</td>";
                        html += "<td>" + editLink + "</td>";
                        html += "</tr>";

                        count++;
                    }

                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "</table>";

            } else {
                html += gui.formWarningMsg("No subscriber group record found.");
            }
            html += "<br>";
            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"subscriber.addSubGroup('" + this.id + "');\"", "");

            return html;
        }

        public String addSubGroup() {
            String html = "";

            Gui gui = new Gui();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String grpCode = "";
            String grpDesc = "";
            if (rid != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT s.*, g.grp_desc FROM " + this.comCode + ".cm_subscriber_grps s "
                    + "LEFT JOIN " + this.comCode + ".cm_groups g ON g.grp_code = s.grp_code "
                    + "WHERE s.ID = " + rid;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.id = rs.getInt("subscriber_id");
                        grpCode = rs.getString("grp_code");
                        grpDesc = rs.getString("grp_desc");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

            }

            html += gui.formStart("frmSubGroup", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (rid != null) {
                html += gui.formInput("hidden", "rid", 15, "" + rid, "", "");
            }

            html += gui.formInput("hidden", "id", 15, this.id+"", "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("grpCode", " Subscriber Group") + "</td>";
            html += "<td >" + gui.formSelect("grpCode", "" + this.comCode + ".cm_groups", "grp_code", "grp_desc", "", "", grpCode, "", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSaveSubGroup", "Save", "save.png", "onclick = \"subscriber.saveSubGroup('grpCode');\"", "");
            if (rid != null) {
                html += gui.formButton(request.getContextPath(), "button", "btnDelSubGroup", "Delete", "delete.png", "onclick = \"subscriber.delSubGroup(" + rid + ", '" + grpDesc + "', '" + this.id + "');\"", "");
            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"subscriber.getSubGroup('" + this.id + "');\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();
            return html;
        }

        public Object saveSubGroup() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String grpCode = request.getParameter("grpCode");

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query;

                if (rid == null) {
                    query = "INSERT INTO " + this.comCode + ".cm_subscriber_grps "
                            + "(subscriber_id, grp_code)"
                            + "VALUES"
                            + "("
                            + "'" + this.id + "', "
                            + "'" + grpCode + "' "
                            + ")";

                } else {
                    query = "UPDATE " + this.comCode + ".cm_subscriber_grps SET "
                            + "grp_code     = '" + grpCode + "' "
                            + "WHERE ID     = " + rid + "";
                }

                Integer saved = stmt.executeUpdate(query);

                if (saved > 0) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Subcriber Group entry successfully made.");
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An unexpected error occured while saving record." + query + "=" + saved);
                }
            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }

        public String getSubGroup() {
            String html = "";
            html += this.getSubGroupsTab();
            return html;
        }

        public Object delSubGroup() throws Exception {

            JSONObject obj = new JSONObject();
            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if (rid != null) {
                    String query = "DELETE FROM " + this.comCode + ".cm_subscriber_grps WHERE ID = " + rid;

                    Integer purged = stmt.executeUpdate(query);
                    if (purged > 0) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "SubGroup entry successfully deleted.");
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