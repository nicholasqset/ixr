<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.medical.HMStaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

    final class Staffs {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        String table = comCode + ".HMSTAFFPROFILE";

        String view = comCode + ".VIEWHMSTAFFPROFILE";

        Integer id = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : null;
        String staffNo = this.id != null ? request.getParameter("staffNoHd") : request.getParameter("staffNo");
        Integer autoStaffNo = request.getParameter("autoStaffNo") != null ? 1 : null;
        String salutationCode = request.getParameter("salutation");
        String firstName = request.getParameter("firstName");
        String middleName = request.getParameter("middleName");
        String lastName = request.getParameter("lastName");
        String genderCode = request.getParameter("gender");
        String dob = request.getParameter("dob");
        String countryCode = request.getParameter("country");
        String nationalId = request.getParameter("nationalId");
        String passportNo = request.getParameter("passportNo");
        Integer physChald = request.getParameter("physChald") != null ? 1 : null;
        String disabCode = request.getParameter("disability");
        String postalAddr = request.getParameter("postalAddr");
        String postalCode = request.getParameter("postalCode");
        String physicalAddr = request.getParameter("physicalAddr");
        String telephone = request.getParameter("telephone");
        String cellphone = request.getParameter("cellphone");
        String email = request.getParameter("email");

        String staffTypeCode = request.getParameter("staffType");
        String deptCode = request.getParameter("department");
        String cmnt = request.getParameter("comment");

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

                            list.add("STAFFNO");
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

                String orderBy = "STAFFNO ";
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
                    html += "<th>Personnel No</th>";
                    html += "<th>Name</th>";
                    html += "<th>Gender</th>";
                    html += "<th>Type</th>";
                    html += "<th>Department</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("ID");
                        String staffNo = rs.getString("STAFFNO");
                        String fullName = rs.getString("FULLNAME");
                        String genderName = rs.getString("GENDERNAME");
                        String staffTypeName = rs.getString("STAFFTYPENAME");
                        String deptName = rs.getString("DEPTNAME");

                        String bgcolor = (count % 2 > 0) ? "#FFFFFF" : "#F7F7F7";

                        String edit = gui.formHref("onclick = \"module.editModule(" + id + ")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr bgcolor = \"" + bgcolor + "\">";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + staffNo + "</td>";
                        html += "<td>" + fullName + "</td>";
                        html += "<td>" + genderName + "</td>";
                        html += "<td>" + staffTypeName + "</td>";
                        html += "<td>" + deptName + "</td>";
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
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getEmploymentTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id=\"divSpecialisation\">" + this.getSpecialisationsTab() + "</div></div>";

            html += "</div>";

            html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"staffs.save('firstName lastName gender dob country staffType department'); return false;\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
            html += "</div>";

            html += "<script type = \"text/javascript\">";
            if (this.id != null) {
                html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\', \'Employment\', \'Specialisations\'), 0, 625, 350, Array(false, false, false, false));";
            } else {
                html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\', \'Employment\'), 0, 625, 350, Array(false, false, false));";
            }

            html += "</script>";

            html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";

            return html;
        }

        public String getBioDataTab() {

            Gui gui = new Gui();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            String html = "";

//        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
//        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" enctype = \"multipart/form-data\" target = \"_blank\">";

            if (this.id != null) {

                try {
                    stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.table + " WHERE ID = " + this.id;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.staffNo = rs.getString("STAFFNO");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

                HMStaffProfile hMStaffProfile = new HMStaffProfile(this.staffNo, this.comCode);

                this.salutationCode = hMStaffProfile.salutationCode;
                this.firstName = hMStaffProfile.firstName;
                this.middleName = hMStaffProfile.middleName;
                this.lastName = hMStaffProfile.lastName;
                this.genderCode = hMStaffProfile.genderCode;
                this.dob = hMStaffProfile.dob;
                this.countryCode = hMStaffProfile.countryCode;
                this.nationalId = hMStaffProfile.nationalId;
                this.passportNo = hMStaffProfile.passportNo;
                this.physChald = hMStaffProfile.physChald;
                this.disabCode = hMStaffProfile.disabCode;
                this.postalAddr = hMStaffProfile.postalAddr;
                this.postalCode = hMStaffProfile.postalCode;
                this.physicalAddr = hMStaffProfile.physicalAddr;
                this.telephone = hMStaffProfile.telephone;
                this.cellphone = hMStaffProfile.cellphone;
                this.email = hMStaffProfile.email;

                this.staffTypeCode = hMStaffProfile.staffTypeCode;
                this.deptCode = hMStaffProfile.deptCode;
                this.cmnt = hMStaffProfile.cmnt;

                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

                try {
                    java.util.Date dob = originalFormat.parse(this.dob);
                    this.dob = targetFormat.format(dob);
                } catch (ParseException e) {

                }

                html += gui.formInput("hidden", "id", 30, "" + this.id, "", "");
            }

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "doctor-male.png", "", "") + " " + gui.formLabel("staffNo", "Staff No") + "</td>";
            String staffNoUi;
            String autoStaffNoUi;
            if (this.id != null) {
                staffNoUi = gui.formAutoComplete("staffNo", 15, this.id != null ? this.staffNo : "", "staffs.searchStaff", "staffNoHd", this.id != null ? this.staffNo : "");
                autoStaffNoUi = "";
            } else {
                staffNoUi = gui.formInput("text", "staffNo", 15, "", "", "disabled");
                autoStaffNoUi = gui.formCheckBox("autoStaffNo", "checked", "", "onchange = \"staffs.toggleStaffNo();\"", "", "") + "<span class = \"fade\"><label for = \"autoStaffNo\"> No Auto</label></span>";
            }

            html += "<td colspan = \"3\">" + staffNoUi + " " + autoStaffNoUi + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "personal-information.png", "", "") + " " + gui.formLabel("salutation", "Salutation") + "</td>";
            html += "<td colspan = \"2\">" + gui.formSelect("salutation", comCode + ".CSSALUTATION", "SALUTATIONCODE", "SALUTATIONNAME", null, null, this.id != null ? this.salutationCode : "", null, false) + "</td>";
            if (this.id != null) {
                String imgPhotoSrc;
                if (hasPhoto(this.staffNo)) {
                    imgPhotoSrc = "photo.jsp?staffNo=" + this.staffNo;
                } else {
                    imgPhotoSrc = request.getContextPath() + "/assets/img/emblems/places-user-identity.png";
                }

                html += "<td rowspan = \"5\">";
                html += "<div class = \"divPhoto\"><img id = \"imgPhoto\" src=\"" + imgPhotoSrc + "\"></div>";
                html += "</td>";
            }
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
            html += "<td colspan = \"3\">" + gui.formDateTime(request.getContextPath(), "dob", 15, this.id != null ? this.dob : "", false, "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "globe-medium-green.png", "", "") + " " + gui.formLabel("country", "Country") + "</td>";
            html += "<td colspan = \"3\">" + gui.formSelect("country", comCode + ".CSCOUNTRIES", "COUNTRYCODE", "COUNTRYNAME", null, null, this.id != null ? this.countryCode : "", null, false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td width = \"20%\" nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("nationalId", "National ID") + "</td>";
            html += "<td width = \"30%\">" + gui.formInput("text", "nationalId", 15, this.id != null ? this.nationalId : "", "", "") + "</td>";

            html += "<td width = \"20%\" nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("passportNo", "Passport No") + "</td>";
            html += "<td>" + gui.formInput("text", "passportNo", 15, this.id != null ? this.passportNo : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("physChald", "Physically Challenged") + "</td>";
            html += "<td>" + gui.formCheckBox("physChald", (this.id != null && this.physChald == 1) ? "checked" : "", null, "onchange = \"staffs.toggleDisab();\"", "", "") + "</td>";

            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "apps-accessibility.png", "", "") + " " + gui.formLabel("disability", "Physical Disability") + "</td>";
            html += "<td>" + gui.formSelect("disability", comCode + ".CSDISAB", "DISABCODE", "DISABNAME", null, null, this.id != null ? this.disabCode : "", (this.id != null && this.physChald == 1) ? "" : "disabled", false) + "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            if (this.id != null) {
                html += " <script type=\"text/javascript\">"
                        + "Event.observe(\'imgPhoto\', \'mouseover\' , function(){"
                        + "if($(\'divPhotoOptions\')){"
                        + "$(\'divPhotoOptions\')"
                        + ".absolutize()"
                        + ".setStyle({display:\'table-cell\'})"
                        + ".clonePosition($(\'imgPhoto\'));"
                        + "}"
                        + "});"
                        + "</script>";

                html += "<div id = \"divPhotoOptions\" onmouseout = \"staffs.hidePhotoOptions();\" style = \"display: none; background-color: #000000; opacity: 0.4; text-align: center;\">";
                html += "<input name = \"photo\" id = \"photo\" type = \"file\" onchange = \"staffs.uploadPhoto();\" style = \"display: none;\">";
                html += "<div style = \"padding-top: 50px;\">";
                html += "<a href = \"javascript:;\" onclick = \"$('photo').click();\">upload</a>";
                html += "</div>";
                if (this.hasPhoto(this.staffNo)) {
                    html += "<div >";
                    html += gui.formHref("onclick = \"staffs.purgePhoto('" + this.staffNo + "', '" + this.lastName + "')\"", request.getContextPath(), "", "remove", "remove", "", "");
                    html += "</div>";
                }
                html += "</div>";
            }

            return html;
        }

        public String searchStaff() {
            String html = "";

            Gui gui = new Gui();

            this.staffNo = request.getParameter("staffNoHd");

            html += gui.getAutoColsSearch(comCode + ".HMSTAFFPROFILE", "STAFFNO, FULLNAME", "", this.staffNo);

            return html;
        }

        public Boolean hasPhoto(String staffNo) {
            Boolean hasPhoto = false;

            Sys sys = new Sys();

            if (this.id != null) {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = null;

                Integer count = 0;

                try {
                    stmt = conn.createStatement();
                    String query = "SELECT COUNT(*) FROM " + this.comCode + ".HMSTAFFPHOTOS WHERE STAFFNO = '" + staffNo + "'";
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        count = rs.getInt("COUNT(*)");
                    }

                    if (count > 0) {
                        hasPhoto = true;
                    }

                } catch (Exception e) {
                    sys.logV2(e.getMessage());
                }
            }

            return hasPhoto;
        }

        public String getContactTab() {
            String html = "";
            Gui gui = new Gui();

            html += gui.formStart("frmContact", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"20%\">" + gui.formIcon(request.getContextPath(), "email-open.png", "", "") + " " + gui.formLabel("postalAddr", "Postal Address") + "</td>";
            html += "<td width = \"30%\">" + gui.formInput("text", "postalAddr", 20, this.id != null ? this.postalAddr : "", "", "") + "</td>";

            html += "<td width = \"20%\">" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("postalCode", "Postal Code") + "</td>";
            html += "<td>" + gui.formInput("text", "postalCode", 15, this.id != null ? this.postalCode : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("physicalAddr", "Physical Address") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("textarea", "physicalAddr", 30, this.id != null ? this.physicalAddr : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "telephone.png", "", "") + " " + gui.formLabel("telephone", "Telephone") + "</td>";
            html += "<td>" + gui.formInput("text", "telephone", 15, this.id != null ? this.telephone : "", "", "") + "</td>";

            html += "<td>" + gui.formIcon(request.getContextPath(), "mobile-phone.png", "", "") + " " + gui.formLabel("cellphone", "Cell Phone") + "</td>";
            html += "<td>" + gui.formInput("text", "cellphone", 15, this.id != null ? this.cellphone : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "email.png", "", "") + " " + gui.formLabel("email", "Email") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "email", 25, this.id != null ? this.email : "", "", "") + "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

        public String getEmploymentTab() {
            String html = "";
            Gui gui = new Gui();

            html += gui.formStart("frmEmployment", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"20%\">" + gui.formIcon(request.getContextPath(), "user-properties.png", "", "") + " " + gui.formLabel("staffType", "Staff Type") + "</td>";
            html += "<td width = \"30%\">" + gui.formSelect("staffType", this.comCode + ".HMSTAFFTYPES", "STAFFTYPECODE", "STAFFTYPENAME", "", "", this.id != null ? this.staffTypeCode : "", "", false) + "</td>";

            html += "<td width = \"20%\">" + gui.formIcon(request.getContextPath(), "house.png", "", "") + " " + gui.formLabel("department", "Department") + "</td>";
            html += "<td>" + gui.formSelect("department", this.comCode + ".HMDEPTS", "DEPTCODE", "DEPTNAME", "", "", this.id != null ? this.deptCode : "", "", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + " " + gui.formLabel("comment", "General Comment") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("textarea", "comment", 30, this.id != null ? this.cmnt : "", "", "") + "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

        public Object getStaffProfile() throws Exception {
            JSONObject obj = new JSONObject();

            if (this.staffNo == null || this.staffNo.equals("")) {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            } else {

                HMStaffProfile hMStaffProfile = new HMStaffProfile(this.staffNo, this.comCode);

                obj.put("salutation", hMStaffProfile.salutationCode);
                obj.put("firstName", hMStaffProfile.firstName);
                obj.put("middleName", hMStaffProfile.middleName);
                obj.put("lastName", hMStaffProfile.lastName);
                obj.put("gender", hMStaffProfile.genderCode);

                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

                try {
                    java.util.Date dob = originalFormat.parse(hMStaffProfile.dob);
                    hMStaffProfile.dob = targetFormat.format(dob);
                } catch (ParseException e) {

                }

                obj.put("dob", hMStaffProfile.dob);
                obj.put("country", hMStaffProfile.countryCode);
                obj.put("physChald", hMStaffProfile.physChald);
                obj.put("disability", hMStaffProfile.disabCode);
                obj.put("postalAddr", hMStaffProfile.postalAddr);
                obj.put("postalCode", hMStaffProfile.postalCode);
                obj.put("physicalAddr", hMStaffProfile.physicalAddr);
                obj.put("telephone", hMStaffProfile.telephone);
                obj.put("cellphone", hMStaffProfile.cellphone);
                obj.put("email", hMStaffProfile.email);

                obj.put("success", new Integer(1));
                obj.put("message", "Staff No '" + hMStaffProfile.staffNo + "' successfully retrieved.");

            }

            return obj;
        }

        public Object save() {

            JSONObject obj = new JSONObject();
            Sys system = new Sys();
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
                    Integer id = system.generateId(this.table, "ID");

                    if (this.autoStaffNo == 1) {
//                    this.staffNo = this.getNextStaffNo();
                        this.staffNo = system.getNextNo(this.table, "ID", "", "", 5);
                    }

                    query += "INSERT INTO " + this.table + " "
                            + "(ID, STAFFNO, SALUTATIONCODE, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, "
                            + "GENDERCODE, DOB, COUNTRYCODE, NATIONALID, PASSPORTNO, PHYSCHALD, DISABCODE, "
                            + "POSTALADDR, POSTALCODE, PHYSICALADDR, TELEPHONE, CELLPHONE, EMAIL, STAFFTYPECODE, DEPTCODE, CMNT) "
                            + "VALUES"
                            + "("
                            + id + ","
                            + "'" + this.staffNo + "',"
                            + "'" + this.salutationCode + "',"
                            + "'" + this.firstName + "',"
                            + "'" + this.middleName + "',"
                            + "'" + this.lastName + "',"
                            + "'" + this.firstName + " " + this.middleName + " " + this.lastName + "',"
                            + "'" + this.genderCode + "',"
                            + "'" + this.dob + "',"
                            + "'" + this.countryCode + "',"
                            + "'" + this.nationalId + "',"
                            + "'" + this.passportNo + "',"
                            + this.physChald + ","
                            + "'" + this.disabCode + "',"
                            + "'" + this.postalAddr + "',"
                            + "'" + this.postalCode + "',"
                            + "'" + this.physicalAddr + "',"
                            + "'" + this.telephone + "',"
                            + "'" + this.cellphone + "',"
                            + "'" + this.email + "',"
                            + "'" + this.staffTypeCode + "',"
                            + "'" + this.deptCode + "',"
                            + "'" + this.cmnt + "'"
                            + ")";

                    obj.put("staffNo", this.staffNo);

                } else {

                    if (this.staffNo == null || this.staffNo.equals("")) {

                        obj.put("success", new Integer(0));
                        obj.put("message", "Oops! An Un-expected error occured while saving record. Could not retrieve Staff No.");

                    } else {
                        query = "UPDATE " + this.table + " SET "
                                + "SALUTATIONCODE   = '" + this.salutationCode + "', "
                                + "FIRSTNAME        = '" + this.firstName + "', "
                                + "MIDDLENAME       = '" + this.middleName + "', "
                                + "LASTNAME         = '" + this.lastName + "',"
                                + "FULLNAME         = '" + this.firstName + " " + this.middleName + " " + this.lastName + "', "
                                + "GENDERCODE       = '" + this.genderCode + "', "
                                + "DOB              = '" + this.dob + "', "
                                + "COUNTRYCODE      = '" + this.countryCode + "', "
                                + "NATIONALID       = '" + this.nationalId + "', "
                                + "PASSPORTNO       = '" + this.passportNo + "', "
                                + "PHYSCHALD        = " + this.physChald + ", "
                                + "DISABCODE        = '" + this.disabCode + "', "
                                + "POSTALADDR       = '" + this.postalAddr + "', "
                                + "POSTALCODE       = '" + this.postalCode + "', "
                                + "PHYSICALADDR     = '" + this.physicalAddr + "', "
                                + "TELEPHONE        = '" + this.telephone + "', "
                                + "CELLPHONE        = '" + this.cellphone + "', "
                                + "EMAIL            = '" + this.email + "', "
                                + "STAFFTYPECODE    = '" + this.staffTypeCode + "', "
                                + "DEPTCODE         = '" + this.deptCode + "', "
                                + "CMNT             = '" + this.cmnt + "', "
                                + "AUDITUSER        = '" + system.getLogUser(session) + "', "
                                + "AUDITDATE        = '" + system.getLogDate() + "', "
                                + "AUDITTIME        = '" + system.getLogTime() + "', "
                                + "AUDITIP          = '" + system.getClientIpAdr(request) + "' "
                                + "WHERE STAFFNO    = '" + this.staffNo + "'";
                    }
                }

                saved = stmt.executeUpdate(query);

                system.logV2(query);

                if (saved == 1) {

                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");

                    system.createUser(this.staffNo, this.firstName + " " + this.middleName + " " + this.lastName, this.email, this.cellphone, this.comCode);

                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }

            } catch (Exception e) {

            }

            return obj;
        }

        public String getNextStaffNo() {
            String nextNo = "";
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;
            String query;
            Integer drNoMax = 0;
            try {
                stmt = conn.createStatement();
                query = "SELECT MAX(ID) FROM " + this.table;
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                    drNoMax = rs.getInt("MAX(ID)");
                }

            } catch (Exception e) {
                nextNo += e.getMessage();
            }
            drNoMax = drNoMax + 1;

            nextNo = String.format("%05d", drNoMax);

            return nextNo;
        }

        public Object purgePhoto() {

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            JSONObject obj = new JSONObject();

            try {
                stmt = conn.createStatement();

                if (this.staffNo != null && !this.staffNo.trim().equals("")) {
                    String query = "DELETE FROM HMSTAFFPHOTOS WHERE STAFFNO = '" + this.staffNo + "'";

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

            }

            return obj;

        }

        public String getSpecialisationsTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            if (sys.recordExists("" + this.comCode + ".hmstaffspexs", "STAFFNO = '" + this.staffNo + "'")) {
                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Specialisation</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.comCode + ".vwhmstaffspexs WHERE STAFFNO = '" + this.staffNo + "' ";
                    ResultSet rs = stmt.executeQuery(query);
                    Integer count = 1;
                    while (rs.next()) {

                        String id = rs.getString("ID");
                        String sp_name = rs.getString("SP_NAME");

                        String editLink = gui.formHref("onclick = \"staffs.editSpecialisation(" + id + ");\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + sp_name + "</td>";
                        html += "<td>" + editLink + "</td>";
                        html += "</tr>";

                        count++;
                    }

                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "</table>";

            } else {
                html += gui.formWarningMsg("No specialisations record found.");
            }
            html += "<br>";
            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"staffs.addSpecialisation('" + this.staffNo + "');\"", "");

            return html;
        }

        public String addSpecialisation() {
            String html = "";

            Gui gui = new Gui();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String spCode = "";
            String spName = "";
            if (rid != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.comCode + ".vwHMSTAFFSPEXS WHERE ID = " + rid;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.staffNo = rs.getString("STAFFNO");
                        spCode = rs.getString("sp_code");
                        spName = rs.getString("sp_name");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

            }

            html += gui.formStart("frmSpecialisation", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (rid != null) {
                html += gui.formInput("hidden", "rid", 15, "" + rid, "", "");
            }

            html += gui.formInput("hidden", "staffNo", 15, this.staffNo, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("spCode", " Specialisation") + "</td>";
            html += "<td >" + gui.formSelect("spCode", "" + this.comCode + ".hmspecialists", "sp_code", "sp_name", "", "", spCode, "", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSaveSpecialisation", "Save", "save.png", "onclick = \"staffs.saveSpecialisation('spCode');\"", "");
            if (rid != null) {
                html += gui.formButton(request.getContextPath(), "button", "btnDelSpecialisation", "Delete", "delete.png", "onclick = \"staffs.delSpecialisation(" + rid + ", '" + spName + "', '" + this.staffNo + "');\"", "");
            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"staffs.getSpecialisation('" + this.staffNo + "');\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();
            return html;
        }

        public Object saveSpecialisation() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String spCode = request.getParameter("spCode");

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query;

                if (rid == null) {
//                    Integer id = sys.generateId(this.comCode + ".HMSTAFFSPEXS", "ID");

                    query = "INSERT INTO " + this.comCode + ".HMSTAFFSPEXS "
                            + "(staffno, sp_code, "
                            + "AUDIT_USER, AUDIT_DATE, audit_ip)"
                            + "VALUES"
                            + "("
                            + "'" + this.staffNo + "', "
                            + "'" + spCode + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                } else {
                    query = "UPDATE " + this.comCode + ".HMSTAFFSPEXS SET "
                            //                    + "DIAGCODE     = '"+ spCode +"', "
                            + "sp_code     = '" + spCode + "' "
                            + "WHERE ID     = " + rid + "";
                }

                Integer saved = stmt.executeUpdate(query);

                if (saved > 0) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Specialisation entry successfully made.");
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

        public String getSpecialisation() {
            String html = "";
            html += this.getSpecialisationsTab();
            return html;
        }

        public Object delSpecialisation() throws Exception {

            JSONObject obj = new JSONObject();
            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if (rid != null) {
                    String query = "DELETE FROM " + this.comCode + ".HMSTAFFSPEXS WHERE ID = " + rid;

                    Integer purged = stmt.executeUpdate(query);
                    if (purged > 0) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "Specialisation entry successfully deleted.");
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