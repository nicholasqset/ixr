<%@page import="bean.medical.HmDiagnosis"%>
<%@page import="java.util.HashMap"%>
<%@page import="bean.finance.VAT"%>
<%@page import="bean.ic.ICItem"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.medical.PatientProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%
    final class Patients {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        String table = comCode + ".HMPTPROFILE";
        String view = comCode + ".VIEWPATIENTPROFILE";

        Integer id = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : null;
        Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
        String ptNo = this.id != null ? request.getParameter("ptNoHd") : request.getParameter("ptNo");
        Integer autoPtNo = request.getParameter("autoPtNo") != null ? 1 : null;
        String salutationCode = request.getParameter("salutation");
        String firstName = request.getParameter("firstName");
        String middleName = request.getParameter("middleName");
        String lastName = request.getParameter("lastName");
        String genderCode = request.getParameter("gender");
        String age = request.getParameter("age");
        String dob = request.getParameter("dob");
        String countryCode = request.getParameter("country");
        String nationalId = request.getParameter("nationalId");
        String passportNo = request.getParameter("passportNo");
        String bloodGrpCode = request.getParameter("bloodGroup");
        Integer physChald = request.getParameter("physChald") != null ? 1 : null;
        String disabCode = request.getParameter("disability");
        String postalAddr = request.getParameter("postalAddr");
        String postalCode = request.getParameter("postalCode");
        String physicalAddr = request.getParameter("physicalAddr");
        String telephone = request.getParameter("telephone");
        String cellphone = request.getParameter("cellphone");
        String email = request.getParameter("email");
        String allergies = request.getParameter("allergies");
        String warns = request.getParameter("warns");
        String familyHist = request.getParameter("familyHist");
        String selfHist = request.getParameter("selfHist");
        String pastMedHist = request.getParameter("pastMedHist");
        String socialHist = request.getParameter("socialHist");

        String nhifNo = request.getParameter("nhifNo");

        String spCode = request.getParameter("spCode");

        String regNo = request.getParameter("regNo");

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

        Integer taxIncl = 1;

        String pulseRate = request.getParameter("pulseRate");
        String bloodPressure = request.getParameter("bloodPressure");
        Double temperature = request.getParameter("temperature") != null ? Double.parseDouble(request.getParameter("temperature")) : 0.00;
        String respiration = request.getParameter("respiration");
        Double height = request.getParameter("height") != null ? Double.parseDouble(request.getParameter("height")) : 0.00;
        Double weight = request.getParameter("weight") != null ? Double.parseDouble(request.getParameter("weight")) : 0.00;
        
        String drNotes = request.getParameter("dr_notes") != null ? request.getParameter("dr_notes") : "";
        String remarks = request.getParameter("remarks") != null ? request.getParameter("remarks") : "";
        
        String regType = request.getParameter("regType");

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

                String orderBy = "PTNO DESC ";
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

                    html += "<table class = \"grid\" width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" border = \"0\">";

                    html += "<tr>";
                    html += "<th>#</th>";
                    html += "<th>Student No</th>";
                    html += "<th>Name</th>";
                    html += "<th>Gender</th>";
                    html += "<th>Age</th>";
//                html += "<th>DOB</th>";
                    html += "<th>Blood Group</th>";
                    html += "<th>Phone No.</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("ID");
                        String ptNo = rs.getString("PTNO");
                        String fullName = rs.getString("FULLNAME");
                        String genderName = rs.getString("GENDERNAME");
                        String age = rs.getString("AGE");
                        String dob = rs.getString("DOB");
                        String bloodGrpName = rs.getString("BLOODGRPNAME");
                        String cellphone = rs.getString("CELLPHONE");

                        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                        SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

                        try {
                            java.util.Date dob_ = originalFormat.parse(dob);
                            dob = targetFormat.format(dob_);
                        } catch (ParseException e) {
                            html += e.getMessage();
                        }

                        String bgcolor = (count % 2 > 0) ? "#FFFFFF" : "#F7F7F7";

                        String edit = gui.formHref("onclick = \"module.editModule(" + id + ")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr bgcolor = \"" + bgcolor + "\">";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + ptNo + "</td>";
                        html += "<td>" + fullName + "</td>";
                        html += "<td>" + genderName + "</td>";
                        html += "<td>" + age + "</td>";
//                    html += "<td>"+ dob+ "</td>";
                        html += "<td>" + bloodGrpName + "</td>";
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

            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getBioDataTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getContactTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getNokTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getMedHistoryTab() + "</div>";

            if (this.id != null) {
                html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divRegistrations\">" + this.getRegistrations() + "</div></div>";
            }

            html += "</div>";

            html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"patients.save('firstName lastName gender dob country'); return false;\"", "");
            html += "&nbsp;";
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
            html += "</div>";

            html += "<script type = \"text/javascript\">";
            if (this.id != null) {
                html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\', \'Next of Kin\', \'Medical History\', \'Visitations/Encounters\'), 0, 692, 365, Array(false, false, false, false));";
            } else {
                html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bio Data\', \'Contacts\', \'Next of Kin\', \'Medical History\'), 0, 692, 365, Array(false, false, false));";
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
                        this.ptNo = rs.getString("PTNO");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

                PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);

                this.salutationCode = patientProfile.salutationCode;
                this.firstName = patientProfile.firstName;
                this.middleName = patientProfile.middleName;
                this.lastName = patientProfile.lastName;
                this.genderCode = patientProfile.genderCode;
                this.dob = patientProfile.dob;
                this.age = patientProfile.age;
                this.countryCode = patientProfile.countryCode;
                this.nationalId = patientProfile.nationalId;
                this.bloodGrpCode = patientProfile.bloodGrpCode;
                this.passportNo = patientProfile.passportNo;
                this.physChald = patientProfile.physChald;
                this.disabCode = patientProfile.disabCode;
                this.postalAddr = patientProfile.postalAddr;
                this.postalCode = patientProfile.postalCode;
                this.physicalAddr = patientProfile.physicalAddr;
                this.telephone = patientProfile.telephone;
                this.cellphone = patientProfile.cellphone;
                this.email = patientProfile.email;
                this.allergies = patientProfile.allergies;
                this.warns = patientProfile.warns;
                this.familyHist = patientProfile.familyHist;
                this.selfHist = patientProfile.selfHist;
                this.pastMedHist = patientProfile.pastMedHist;
                this.socialHist = patientProfile.socialHist;
                this.nhifNo = patientProfile.nhifNo;

                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

                try {
                    java.util.Date dob = originalFormat.parse(this.dob);
                    this.dob = targetFormat.format(dob);
                } catch (ParseException e) {

                }

                html += gui.formInput("hidden", "id", 30, "" + this.id, "", "");
            }

            html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "patient-male.png", "", "") + " " + gui.formLabel("ptNo", "Patient No") + "</td>";
            String ptNoUi;
            String autoPtNoUi;
            if (this.id != null) {
                ptNoUi = gui.formAutoComplete("ptNo", 15, this.id != null ? this.ptNo : "", "patients.searchPatient", "ptNoHd", this.id != null ? this.ptNo : "");
                autoPtNoUi = "";
            } else {
                ptNoUi = gui.formInput("text", "ptNo", 15, "", "", "disabled");
                autoPtNoUi = gui.formCheckBox("autoPtNo", "checked", "", "onchange = \"patients.togglePtNo();\"", "", "") + "<span class = \"fade\"><label for = \"autoPtNo\"> No Auto</label></span>";
            }

            html += "<td colspan = \"3\">" + ptNoUi + " " + autoPtNoUi + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "personal-information.png", "", "") + " " + gui.formLabel("salutation", "Salutation") + "</td>";
            html += "<td colspan = \"2\">" + gui.formSelect("salutation", comCode + ".CSSALUTATION", "SALUTATIONCODE", "SALUTATIONNAME", null, null, this.id != null ? this.salutationCode : "", null, false) + "</td>";
            if (this.id != null) {
                String imgPhotoSrc;
                if (hasPhoto(this.ptNo)) {
                    imgPhotoSrc = "photo.jsp?ptNo=" + this.ptNo;
                } else {
                    imgPhotoSrc = request.getContextPath() + "/images/emblems/places-user-identity.png";
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
            html += "<td>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + " " + gui.formLabel("age", "Age") + "</td>";
            html += "<td>" + gui.formInput("text", "age", 25, this.id != null ? this.age : "", "", "") + "</td>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + " " + gui.formLabel("dob", "Date of Birth") + "</td>";
            html += "<td>" + gui.formDateTime(request.getContextPath(), "dob", 15, this.id != null ? this.dob : "", false, "") + "</td>";
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

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("nhifNo", "NHIF No") + "</td>";
            html += "<td>" + gui.formInput("text", "nhifNo", 15, this.id != null ? this.nhifNo : "", "", "") + "</td>";

            html += "<td>" + gui.formIcon(request.getContextPath(), "blood-drop.png", "", "") + " " + gui.formLabel("bloodGroup", "Blood Group") + "</td>";
            html += "<td>" + gui.formSelect("bloodGroup", comCode + ".HMBLOODGRPS", "BLOODGRPCODE", "BLOODGRPNAME", "", "", this.id != null ? this.bloodGrpCode : "", null, false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("physChald", "Physically Challenged") + "</td>";
            html += "<td>" + gui.formCheckBox("physChald", (this.id != null && this.physChald == 1) ? "checked" : "", null, "onchange = \"patients.toggleDisab();\"", "", "") + "</td>";

            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "apps-accessibility.png", "", "") + " " + gui.formLabel("disability", "Physical Disability") + "</td>";
            html += "<td>" + gui.formSelect("disability", comCode + ".CSDISAB", "DISABCODE", "DISABNAME", null, null, this.id != null ? this.disabCode : "", (this.id != null && this.physChald == 1) ? "" : "disabled", false) + "</td>";
            html += "</tr>";

            html += "</table>";
            html += "</form>";

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

                html += "<div id = \"divPhotoOptions\" onmouseout = \"patients.hidePhotoOptions();\" style = \"display: none; background-color: #000000; opacity: 0.4; text-align: center;\">";
                html += "<input name = \"photo\" id = \"photo\" type = \"file\" onchange = \"patients.uploadPhoto();\" style = \"display: none;\">";
                html += "<div style = \"padding-top: 50px;\">";
                html += "<a href = \"javascript:;\" onclick = \"$('photo').click();\">upload</a>";
                html += "</div>";
                if (this.hasPhoto(this.ptNo)) {
                    html += "<div >";
                    html += gui.formHref("onclick = \"patients.purgePhoto('" + this.ptNo + "', '" + this.lastName + "')\"", request.getContextPath(), "", "remove", "remove", "", "");
                    html += "</div>";
                }
                html += "</div>";
            }

            return html;
        }

        public String searchPatient() {
            String html = "";

            Gui gui = new Gui();

            this.ptNo = request.getParameter("ptNoHd");

            html += gui.getAutoColsSearch("HMPTPROFILE", "PTNO, FULLNAME", "", this.ptNo);

            return html;
        }

        public Boolean hasPhoto(String ptNo) {
            Boolean hasPhoto = false;

            if (this.id != null) {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = null;

                Integer count = 0;

                try {
                    stmt = conn.createStatement();
                    String query = "SELECT COUNT(*) FROM HMPTPHOTOS WHERE PTNO = '" + ptNo + "'";
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        count = rs.getInt("COUNT(*)");
                    }

                    if (count > 0) {
                        hasPhoto = true;
                    }

                } catch (Exception e) {
                    e.getMessage();
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
            html += "</form>";

            return html;
        }
        
        public String getNokTab(){
            String html = "";
            
            return html;
        }

        public String getMedHistoryTab() {
            String html = "";
            Gui gui = new Gui();
            
            html += gui.formStart("frmMedHistory", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"20%\" style = \"vertical-align: top;\">" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " " + gui.formLabel("allergies", "Allergies") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("textarea", "allergies", 30, this.id != null ? this.allergies : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td style = \"vertical-align: top;\" nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " " + gui.formLabel("warns", "Warnings") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("textarea", "warns", 30, this.id != null ? this.warns : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td style = \"vertical-align: top;\" nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " " + gui.formLabel("familyHist", "Family History") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("textarea", "familyHist", 30, this.id != null ? this.familyHist : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td style = \"vertical-align: top;\" nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " " + gui.formLabel("selfHist", "Personal History") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("textarea", "selfHist", 30, this.id != null ? this.selfHist : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td style = \"vertical-align: top;\" nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " " + gui.formLabel("pastMedHist", "Past Medical History") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("textarea", "pastMedHist", 30, this.id != null ? this.pastMedHist : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td style = \"vertical-align: top;\" nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + " " + gui.formLabel("socialHist", "Social History") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("textarea", "socialHist", 30, this.id != null ? this.socialHist : "", "", "") + "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

        public Object getPatientProfile() throws Exception {
            JSONObject obj = new JSONObject();

            if (this.ptNo == null || this.ptNo.equals("")) {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            } else {

                PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);

                obj.put("salutation", patientProfile.salutationCode);
                obj.put("firstName", patientProfile.firstName);
                obj.put("middleName", patientProfile.middleName);
                obj.put("lastName", patientProfile.lastName);
                obj.put("gender", patientProfile.genderCode);

                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

                try {
                    java.util.Date dob = originalFormat.parse(patientProfile.dob);
                    patientProfile.dob = targetFormat.format(dob);
                } catch (ParseException e) {

                }

                obj.put("dob", patientProfile.dob);
                obj.put("country", patientProfile.countryCode);
                obj.put("physChald", patientProfile.physChald);
                obj.put("disability", patientProfile.disabCode);
                obj.put("postalAddr", patientProfile.postalAddr);
                obj.put("postalCode", patientProfile.postalCode);
                obj.put("physicalAddr", patientProfile.physicalAddr);
                obj.put("telephone", patientProfile.telephone);
                obj.put("cellphone", patientProfile.cellphone);
                obj.put("email", patientProfile.email);

                obj.put("success", new Integer(1));
                obj.put("message", "Pt No '" + patientProfile.ptNo + "' successfully retrieved.");

            }

            return obj;
        }

        public Object save() {

            JSONObject obj = new JSONObject();
            Sys system = new Sys();
            HttpSession session = request.getSession();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;
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
                    Integer id;
                    id = system.generateId(this.table, "ID");

                    if (this.autoPtNo == 1) {
//                    this.ptNo = this.getNextPtNo();
                        this.ptNo = system.getNextNo(this.table, "ID", "", "PT", 6);
                    }

                    query += "INSERT INTO " + this.table + " "
                            + "("
                            + "ID, PTNO, SALUTATIONCODE, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, "
                            + "GENDERCODE, DOB, AGE, COUNTRYCODE, NATIONALID, PASSPORTNO, BLOODGRPCODE, PHYSCHALD, DISABCODE, "
                            + "POSTALADDR, POSTALCODE, PHYSICALADDR, TELEPHONE, CELLPHONE, EMAIL, "
                            + "ALLERGIES, WARNS, FAMILYHIST, SELFHIST, PASTMEDHIST, SOCIALHIST,"
                            + "NHIFNO"
                            + ") "
                            + "VALUES"
                            + "("
                            + id + ","
                            + "'" + this.ptNo + "',"
                            + "'" + this.salutationCode + "',"
                            + "'" + this.firstName + "',"
                            + "'" + this.middleName + "',"
                            + "'" + this.lastName + "',"
                            + "'" + this.firstName + " " + this.middleName + " " + this.lastName + "',"
                            + "'" + this.genderCode + "',"
                            + "'" + this.dob + "',"
                            + "'" + this.age + "',"
                            + "'" + this.countryCode + "',"
                            + "'" + this.nationalId + "',"
                            + "'" + this.passportNo + "',"
                            + "'" + this.bloodGrpCode + "',"
                            + this.physChald + ","
                            + "'" + this.disabCode + "',"
                            + "'" + this.postalAddr + "',"
                            + "'" + this.postalCode + "',"
                            + "'" + this.physicalAddr + "',"
                            + "'" + this.telephone + "',"
                            + "'" + this.cellphone + "',"
                            + "'" + this.email + "',"
                            + "'" + this.allergies + "',"
                            + "'" + this.warns + "',"
                            + "'" + this.familyHist + "',"
                            + "'" + this.selfHist + "',"
                            + "'" + this.pastMedHist + "',"
                            + "'" + this.socialHist + "',"
                            + "'" + this.nhifNo + "'"
                            + ")";

                    obj.put("ptNo", this.ptNo);
                    obj.put("id", id);

                } else {

                    if (this.ptNo == null || this.ptNo.equals("")) {

                        obj.put("success", new Integer(0));
                        obj.put("message", "Oops! An Un-expected error occured while saving record. Could not retrieve Pf No.");

                    } else {
                        query = "UPDATE " + this.table + " SET "
                                + "SALUTATIONCODE   = '" + this.salutationCode + "', "
                                + "FIRSTNAME        = '" + this.firstName + "', "
                                + "MIDDLENAME       = '" + this.middleName + "', "
                                + "LASTNAME         = '" + this.lastName + "',"
                                + "FULLNAME         = '" + this.firstName + " " + this.middleName + " " + this.lastName + "', "
                                + "GENDERCODE       = '" + this.genderCode + "', "
                                + "DOB              = '" + this.dob + "', "
                                + "AGE              = '" + this.age + "', "
                                + "COUNTRYCODE      = '" + this.countryCode + "', "
                                + "NATIONALID       = '" + this.nationalId + "', "
                                + "PASSPORTNO       = '" + this.passportNo + "', "
                                + "BLOODGRPCODE     = '" + this.bloodGrpCode + "', "
                                + "PHYSCHALD        = " + this.physChald + ", "
                                + "DISABCODE        = '" + this.disabCode + "', "
                                + "POSTALADDR       = '" + this.postalAddr + "', "
                                + "POSTALCODE       = '" + this.postalCode + "', "
                                + "PHYSICALADDR     = '" + this.physicalAddr + "', "
                                + "TELEPHONE        = '" + this.telephone + "', "
                                + "CELLPHONE        = '" + this.cellphone + "', "
                                + "EMAIL            = '" + this.email + "', "
                                + "ALLERGIES        = '" + this.allergies + "', "
                                + "WARNS            = '" + this.warns + "', "
                                + "FAMILYHIST       = '" + this.familyHist + "', "
                                + "SELFHIST         = '" + this.selfHist + "', "
                                + "PASTMEDHIST      = '" + this.pastMedHist + "', "
                                + "SOCIALHIST       = '" + this.socialHist + "', "
                                + "NHIFNO           = '" + this.nhifNo + "', "
                                + "AUDITUSER        = '" + system.getLogUser(session) + "', "
                                + "AUDITDATE        = '" + system.getLogDate() + "', "
                                + "AUDITTIME        = '" + system.getLogTime() + "', "
                                + "AUDITIP          = '" + system.getClientIpAdr(request) + "' "
                                + "WHERE PTNO       = '" + this.ptNo + "'";

                        obj.put("id", this.id);
                    }
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

            }

            return obj;
        }

        public String getNextPtNo() {
            String nextNo = "";
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;
            String query;
            Integer ptNoMax = 0;
            try {
                stmt = conn.createStatement();
                query = "SELECT MAX(ID) FROM " + this.table;
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                    ptNoMax = rs.getInt("MAX(ID)");
                }

            } catch (Exception e) {
                nextNo += e.getMessage();
            }
            ptNoMax = ptNoMax + 1;

            nextNo = "PT" + String.format("%06d", ptNoMax);

            return nextNo;
        }

        public Object purgePhoto() {

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = null;

            JSONObject obj = new JSONObject();

            try {
                stmt = conn.createStatement();

                if (this.ptNo != null && !this.ptNo.trim().equals("")) {
                    String query = "DELETE FROM HMPTPHOTOS WHERE PTNO = '" + this.ptNo + "'";

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

        public String getRegistrations() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            this.ptNo = sys.getOne(this.table, "ptno", "id=" + this.id);

            if (sys.recordExists("" + this.comCode + ".HMREGISTRATION", "ptno = '" + this.ptNo + "'")) {
                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Reg. #</th>";
                html += "<th>Type</th>";
                html += "<th>Dept</th>";
                html += "<th>Date</th>";
                html += "<th>Seen By</th>";
                html += "<th>Triaged</th>";
                html += "<th>Discharged</th>";
                html += "<th style=\"text-align: center;\">Options</th>";
                html += "</tr>";

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.comCode + ".viewHMREGISTRATION  WHERE ptno = '" + this.ptNo + "' ORDER BY regdate DESC ";
//                    html += query;
                    ResultSet rs = stmt.executeQuery(query);
                    Integer count = 1;
                    while (rs.next()) {

                        String id = rs.getString("ID");
                        String regNo = rs.getString("regno");
                        String regType = rs.getString("regType");
                        String regDate = rs.getString("regdate");
                        String sp_name = rs.getString("sp_name");
                        String pttype = rs.getString("pttype");
                        Integer triaged = rs.getInt("triaged");
                        Integer discharged = rs.getInt("discharged");
                        
                        String triagedLbl = triaged == 1? gui.formIcon(request.getContextPath(), "tick.png", "", ""): gui.formIcon(request.getContextPath(), "cross.png", "", "");
                        String dischargedLbl = discharged == 1? gui.formIcon(request.getContextPath(), "tick.png", "", ""): gui.formIcon(request.getContextPath(), "cross.png", "", "");

                        String editLink = gui.formHref("onclick = \"patients.editRegistration(" + id + ", " + this.id + ",'" + this.ptNo + "');\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");
                        String manageLink = gui.formHref("onclick = \"patients.manageRegistration(" + id + ", " + this.id + ",'" + this.ptNo + "');\"", request.getContextPath(), "pencil.png", "manage", "manage", "", "");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + regNo + "</td>";
                        html += "<td>" + regType + "</td>";
                        html += "<td>" + pttype + "</td>";
                        html += "<td>" + regDate + "</td>";
                        html += "<td>" + sp_name + "</td>";
                        html += "<td>" + triagedLbl + "</td>";
                        html += "<td>" + dischargedLbl + "</td>";
                        html += "<td nowrap>" + editLink + "||" + manageLink + "</td>";
                        html += "</tr>";

                        count++;
                    }

                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "</table>";

            } else {
                html += gui.formWarningMsg("No registration record found.");
            }
            html += "<br>";
            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"patients.addRegistration(" + this.id + ",'" + this.ptNo + "');\"", "");

            return html;
        }

        public String addRegistration() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            if (this.ptNo == null) {
                this.ptNo = request.getParameter("ptNo");
            }

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String regNo = "";
            String spCode = "";
            String regType = "";
            String regTypeLbl = "";
            String pttype = "";
            String admdate = "";
            if (rid != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.comCode + ".HMREGISTRATION WHERE ID = " + rid;
//                    html += query;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        regNo = rs.getString("REGNO");
                        spCode = rs.getString("sp_code");
                        regType = rs.getString("regtype");
                        pttype = rs.getString("pttype");
                        admdate = rs.getString("admdate");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

            }

            if (rid != null) {
                regTypeLbl = regType.equals("R") ? "Return" : "New";
            } else {
                Boolean regTypeExists = sys.recordExists(this.comCode + ".HMREGISTRATION", "ptno='" + this.ptNo + "'");
                regTypeLbl = regTypeExists ? "Return" : "New";
            }

            HashMap<String, String> ptTypes = new HashMap();
            ptTypes.put("OPD", "Outpatient");
            ptTypes.put("IPD", "Inpatient");

            html += "";
            html += gui.formStart("frmRegistration", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (rid != null) {
                html += gui.formInput("hidden", "rid", 15, "" + rid, "", "");
            }

//            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";

            html += "<tr>";
            html += "<td width = \"25%\" class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + "Registration Type</td>";
            html += "<td >" + regTypeLbl + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "doctor-male.png", "", "") + gui.formLabel("spCode", " Be Seen by") + "</td>";
            html += "<td >" + gui.formSelect("spCode", this.comCode + ".hmspecialists", "sp_code", "sp_name", "", "", spCode, "", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("ptType", " Type") + "</td>";
            html += "<td >" + gui.formArraySelect("ptType", 136, ptTypes, rid != null ? pttype : "OPD", true, "", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("admdate", " Admission Date") + "</td>";
            html += "<td >" + gui.formDateTime(request.getContextPath(), "admdate", 25, rid != null ? admdate : sys.getFormatedDateTime(sys.getLogDate()), true, "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
            html += gui.formButton(request.getContextPath(), "button", "btnSaveRegistration", "Save", "save.png", "onclick = \"patients.saveRegistration('spCode');\"", "");
            if (rid != null) {
                html += "&nbsp;";
                html += gui.formButton(request.getContextPath(), "button", "btnDelRegistration", "Delete", "delete.png", "onclick = \"patients.delRegistration(" + rid + ", '" + this.id + "', '" + regNo + "');\"", "");
            }
            html += "&nbsp;";
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"patients.getRegistrations('" + this.id + "');\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

        public Object saveRegistration() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            String ptType = request.getParameter("ptType");
            String admdate = request.getParameter("admdate");

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query;

                if (rid == null) {

                    Integer id = sys.generateId(this.comCode + ".HMREGISTRATION", "ID");
                    String regNo = sys.getNextNo(this.comCode + ".HMREGISTRATION", "ID", "", "R", 7);

                    Boolean regTypeExists = sys.recordExists(this.comCode + ".HMREGISTRATION", "ptno='" + this.ptNo + "'");
                    String regType = regTypeExists ? "R" : "N";

                    String drNo = "1";
                    String nrNo = "1";

                    query = "INSERT INTO " + this.comCode + ".HMREGISTRATION" + " "
                            + ""
                            + "(ID, REGNO, REGTYPE, PTNO, PTTYPE, PYEAR, PMONTH, REGDATE, DRNO, "
                            + "NRNO, sp_code, admdate, AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                            + "VALUES"
                            + "("
                            + id + ", "
                            + "'" + regNo + "', "
                            + "'" + regType + "', "
                            + "'" + this.ptNo + "', "
                            + "'" + ptType + "', "
                            //                            + "'OPD', "
                            + sys.getPeriodYear(this.comCode) + ", "
                            + sys.getPeriodMonth(this.comCode) + ", "
                            + "now(), "
                            //                        + "'"+this.drNo+"', "
                            + "'" + drNo + "', "
                            //                        + "'"+this.nrNo+"', "
                            + "'" + nrNo + "', "
                            + "'" + this.spCode + "', "
                            + "'" + sys.getUnFormatedDateTimeV2(admdate) + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getLogTime() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                } else {
                    query = "UPDATE " + this.comCode + ".HMREGISTRATION SET "
                            + "sp_code     = '" + this.spCode + "', "
                            + "pttype     = '" + ptType + "', "
                            + "admdate     = '" + sys.getUnFormatedDateTimeV2(admdate) + "' "
                            + "WHERE ID     = " + rid + "";
                }

                Integer saved = stmt.executeUpdate(query);

                if (saved > 0) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Registration entry successfully made.");
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

        public Object delRegistration() throws Exception {
            JSONObject obj = new JSONObject();
            Integer rid = request.getParameter("rid") != null ? Integer.parseInt(request.getParameter("rid")) : null;
            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if (rid != null) {
                    String query = "DELETE FROM " + this.comCode + ".HMREGISTRATION WHERE ID = " + rid;

                    Integer purged = stmt.executeUpdate(query);
                    if (purged > 0) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "Registration entry successfully deleted.");
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

        public String manageRegistration() {
            String html = "";

            html += "<div id = \"dhtmlgoodies_tabView2\">";

            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"dvRegInfo\">" + this.getRegInfoTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"dvBills\">" + this.getBillingTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"dvBills\">" + this.getVitalParamTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divComplaints\">" + this.getComplaintsTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divLab\">" + this.getLabTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divDiagnosis\">" + this.getDiagnosisTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divDrNotes\">" + this.getDrNotesTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divMedication\">" + this.getMedicationTab() + "</div></div>";
            html += "<div class = \"dhtmlgoodies_aTab\"><div id = \"divDischarge\">" + this.getDischargeTab() + "</div></div>";

            html += "<script type = \"text/javascript\">";
            html += "initTabs(\'dhtmlgoodies_tabView2\', Array(\'Registration\', \'Billing\', \'Vitals\', \'Complaints\', \'Laboratory\', \'Diagnosis\', \'Doctor Notes\', \'Prescription\',\'Discharge\'), 0, 664, 320, Array(false));";
            html += "</script>";

            html += "</div>";

            return html;
        }      
        

        public String getRegInfoTab() {
            String html = "";
            
            Gui gui = new Gui();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;

            String ptType = "";

            try {
                stmt = conn.createStatement();
                String query = "SELECT * FROM " + this.comCode + ".viewHMREGISTRATION WHERE ID = " + this.rid;
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                    this.regNo = rs.getString("REGNO");
                    this.regType = rs.getString("REGTYPE");
                    this.ptNo = rs.getString("PTNO");
                    ptType = rs.getString("PTTYPE");
                }
            } catch (Exception e) {
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
            html += "<td class = \"bold\"  nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " Patient Type</td>";
            html += "<td>" + ptType + "</td>";
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
            html += "<td >&nbsp;</td>";
            html += "<td>" + gui.formButton(request.getContextPath(), "button", "btnCancel1", "Back", "arrow-left.png", "onclick = \"patients.getRegistrations(" + this.id + "); return false;\"", "") + "</td>";
            html += "</tr>";

            html += "</table>";

            return html;
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

            String regNo = sys.getOne(this.comCode + ".HMREGISTRATION", "REGNO", "ID = " + this.rid);
            this.ptNo = sys.getOne(this.comCode + ".HMREGISTRATION", "PTNO", "ID = " + this.id);

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

                        String editLink = gui.formHref("onclick = \"registration.editBill(" + this.id + "," + this.rid + ", " + bid + ", '" + pyNo + "', '" + regNo + "', '" + this.ptNo + "');\"", request.getContextPath(), "", "edit", "edit", "", "");
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

            html += "<div style = \"padding: 7px 0;\">"
                    + gui.formButton(request.getContextPath(), "button", "btnAdd", "Add Bill", "math-add.png", "onclick = \"registration.manageBill(" + this.rid + "," + this.id + ",'" + regNo + "', '" + this.ptNo + "'); return false;\"", "")
                    + "&nbsp;"
                    + gui.formButton(request.getContextPath(), "button", "btnCancel1", "Back", "arrow-left.png", "onclick = \"patients.getRegistrations(" + this.id + "); return false;\"", "")
                    + "</div>";

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

//            PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

//            html += "<tr>";
//            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("billNo", " Bill No.") + "</td>";
//            html += "<td>" + gui.formInput("text", "billNo", 15, this.bid != null ? this.pyNo : "", "", "disabled") + gui.formInput("hidden", "billNoHd", 15, this.bid != null ? this.pyNo : "", "", "") + "</td>";
//
//            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("entryDate", " Date") + "</td>";
//            html += "<td>" + gui.formDateTime(request.getContextPath(), "entryDate", 13, this.bid != null ? this.entryDate : defaultDate, false, "") + "</td>";
//            html += "</tr>";
            html += gui.formInput("hidden", "billNo", 30, this.bid != null ? this.pyNo : "", "", "");
            html += gui.formInput("hidden", "billNoHd", 30, this.bid != null ? this.pyNo : "", "", "");
            html += gui.formInput("hidden", "entryDate", 30, this.bid != null ? this.entryDate : defaultDate, "", "");

//            html += "<tr>";
//            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + gui.formLabel("pyDesc", " Description") + "</td>";
//            html += "<td colspan = \"3\">" + gui.formInput("text", "pyDesc", 30, this.bid != null ? this.pyDesc : this.ptNo + "-" + patientProfile.fullName, "", "") + "</td>";
//            html += "</tr>";
            html += gui.formInput("hidden", "pyDesc", 30, this.bid != null ? this.pyDesc : "** NEW SALE **", "", "");

//            html += "<tr>";
//            html += "<td width = \"15%\">" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("pYear", " Fiscal Year") + "</td>";
//            html += "<td width = \"35%\">" + gui.formSelect("pYear", this.comCode + ".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.bid != null ? "" + this.pYear : "" + sys.getPeriodYear(this.comCode), "", false) + "</td>";
//
//            html += "<td width = \"15%\">" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("pMonth", " Period") + "</td>";
//            html += "<td>" + gui.formMonthSelect("pMonth", this.bid != null ? this.pMonth : sys.getPeriodMonth(this.comCode), "", true) + "</td>";
//            html += "</tr>";
            html += gui.formInput("hidden", "pYear", 30, this.bid != null ? "" + this.pYear : "" + sys.getPeriodYear(this.comCode), "", "");
            html += gui.formInput("hidden", "pMonth", 30, this.bid != null ? "" + this.pMonth : "" + sys.getPeriodMonth(this.comCode), "", "");

//            html += "<tr>";
//            html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
//            html += "</tr>";
            html += "<tr>";
            html += "<td width = \"15%\" nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("itemNo", " Item No") + "</td>";
            html += "<td width = \"35%\" nowrap>" + gui.formAutoComplete("itemNo", 13, "", "registration.searchItem", "itemNoHd", "") + "</td>";

            html += "<td width = \"15%\" nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + " Item Name</td>";
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
//            html += gui.formButton(request.getContextPath(), "button", "btnBack", "Back", "arrow-left-2.png", "onclick = \"registration.listBills(); return false;\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnBack", "Back", "arrow-left-2.png", "onclick = \"patients.manageRegistration(" + this.rid + ", " + this.id + ",'" + this.ptNo + "'); return false;\"", "");
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

            html += gui.getAutoColsSearch(this.comCode + ".ICITEMS", "ITEMCODE, ITEMNAME", "catcode in (select catcode from " + this.comCode + ".hmcats)", this.itemCode);

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

//            html += this.pyNo;
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
//                    html += query;
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
                        Integer sid = sys.generateId("" + this.comCode + ".HMPYDTLS", "ID");

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
                            + "now(), "
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

        public String getVitalParamTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            this.regNo = sys.getOne(this.comCode + ".HMREGISTRATION", "REGNO", "ID = " + this.rid);

            if (sys.recordExists(comCode + ".HMTRIAGE", "REGNO = '" + this.regNo + "'")) {

                Connection conn = ConnectionProvider.getConnection();
                Statement stmt;

                try {
                    stmt = conn.createStatement();
                    String query = "SELECT * FROM " + comCode + ".HMTRIAGE" + " WHERE REGNO = '" + this.regNo + "'";
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.pulseRate = rs.getString("PULSERATE");
                        this.bloodPressure = rs.getString("BLOODPRESSURE");
                        this.temperature = rs.getDouble("TEMPERATURE");
                        this.respiration = rs.getString("RESPIRATION");
                        this.height = rs.getDouble("HEIGHT");
                        this.weight = rs.getDouble("WEIGHT");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

            } else {
                this.pulseRate = "";
                this.bloodPressure = "";
                this.respiration = "";
            }

            html += gui.formStart("frmVitals", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"15%\" nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("pulseRate", " Pulse Rate") + "</td>";
            html += "<td >" + gui.formInput("text", "pulseRate", 15, this.pulseRate, "", "") + "<span class = \"fade\"> /min</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("bloodPressure", " Blood Pressure") + "</td>";
            html += "<td >" + gui.formInput("text", "bloodPressure", 15, this.bloodPressure, "", "") + "<span class = \"fade\"> mm of Hg</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("temperature", " Temperature") + "</td>";
            html += "<td >" + gui.formInput("text", "temperature", 15, "" + this.temperature, "", "") + "<span class = \"fade\"> C</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("respiration", " Respiration") + "</td>";
            html += "<td >" + gui.formInput("text", "respiration", 15, this.respiration, "", "") + "<span class = \"fade\"> /min</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("height", " Height") + "</td>";
            html += "<td >" + gui.formInput("text", "height", 15, "" + this.height, "", "") + "<span class = \"fade\"> cm</span></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("weight", " Weight") + "</td>";
            html += "<td >" + gui.formInput("text", "weight", 15, "" + this.weight, "", "") + "<span class = \"fade\"> Kg</span></td>";
            html += "</tr>";

            html += "</table>";

            html += "<div style = \"padding: 7px 0;\">"
//                    + gui.formButton(request.getContextPath(), "button", "btnSaveVitals", "Save Vitals", "save.png", "onclick = \"registration.saveVitals('pulseRate bloodPressure temperature respiration height weight', " + this.rid + "," + this.id + ",'" + regNo + "', '" + this.ptNo + "'); return false;\"", "")
//                    + "&nbsp;"
                    + gui.formButton(request.getContextPath(), "button", "btnCancel1", "Back", "arrow-left.png", "onclick = \"patients.getRegistrations(" + this.id + "); return false;\"", "")
                    + "</div>";

            html += gui.formEnd();

            return html;
        }

        public JSONObject saveVitals() throws Exception {
            JSONObject obj = new JSONObject();
            HttpSession session = request.getSession();

            Sys sys = new Sys();

            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;

            try {
                if (!sys.recordExists(comCode+".HMTRIAGE", "REGNO = '" + this.regNo + "'")) {

                    stmt = conn.createStatement();

                    Integer id = sys.generateId(comCode+".HMTRIAGE", "ID");

                    String query;

                    query = "INSERT INTO " + comCode+".HMTRIAGE" + " "
                            + "(ID, REGNO, PULSERATE, BLOODPRESSURE, TEMPERATURE, RESPIRATION, HEIGHT, WEIGHT, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                            + "VALUES"
                            + "("
                            + id + ", "
                            + "'" + this.regNo + "', "
                            + "'" + this.pulseRate + "', "
                            + "'" + this.bloodPressure + "', "
                            + this.temperature + ", "
                            + "'" + this.respiration + "', "
                            + "'" + this.height + "', "
                            + "'" + this.weight + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getLogTime() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                    Integer saved = stmt.executeUpdate(query);

                    if (saved == 1) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "Entry successfully made.");

                        stmt.executeUpdate("UPDATE " + this.comCode + ".HMREGISTRATION SET TRIAGED = 1 WHERE REGNO = '" + this.regNo + "'");
                    } else {
                        obj.put("success", new Integer(0));
                        obj.put("message", "Oops! An Un-expected error occured while saving record.");
                    }

                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Entry already made");
                }

            } catch (Exception e) {
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }
        
//        complaints start
        public String getComplaintsTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();
            
            this.regNo = sys.getOne(this.comCode + ".HMREGISTRATION", "REGNO", "ID = " + this.rid);

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

                        String editLink = gui.formHref("onclick = \"dashboard.editComplaint(" + id + "," + this.rid + "," + this.id + ",'" + regNo + "', '" + this.ptNo + "');\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + sys.shorten(complName, 300) + "</td>";
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
//            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add Complaint", "add.png", "onclick = \"dashboard.addComplaint(" + this.rid + "," + this.id + ",'" + regNo + "', '" + this.ptNo + "');\"", "");
            html += " ";
            html += gui.formButton(request.getContextPath(), "button", "btnCancel1", "Back", "arrow-left.png", "onclick = \"patients.getRegistrations(" + this.id + "); return false;\"", "");

            return html;
        }

        public String addComplaint() {
            String html = "";

            Gui gui = new Gui();

            Integer rid = request.getParameter("cid") != null ? Integer.parseInt(request.getParameter("cid")) : null;
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
                } catch (Exception e) {
                    html += e.getMessage();
                }

            }

            html += gui.formStart("frmComplaint", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (rid != null) {
                html += gui.formInput("hidden", "cid", 15, "" + rid, "", "");
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
//            html += gui.formButton(request.getContextPath(), "button", "btnSaveComplaint", "Save", "save.png", "onclick = \"dashboard.saveComplaint('complaint');\"", "");
//            if (rid != null) {
//                html += " ";
//                html += gui.formButton(request.getContextPath(), "button", "btnDelComplaint", "Delete", "delete.png", "onclick = \"dashboard.delComplaint(" + rid + ", '" + complName + "', '" + this.regNo + "', " + this.rid + ", " + this.id + ",'" + this.ptNo + "');\"", "");
//            }
            html += " ";
            html += gui.formButton(request.getContextPath(), "button", "btnBack", "Back", "arrow-left-2.png", "onclick = \"patients.manageRegistration(" + this.rid + ", " + this.id + ",'" + this.ptNo + "'); return false;\"", "");
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

            Integer rid = request.getParameter("cid") != null ? Integer.parseInt(request.getParameter("cid")) : null;
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
            Integer rid = request.getParameter("cid") != null ? Integer.parseInt(request.getParameter("cid")) : null;
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
//        complaints end
        //lab start
        public String getLabTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();
            
            this.regNo = sys.getOne(this.comCode + ".HMREGISTRATION", "REGNO", "ID = " + this.rid);

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

                        String editLink = gui.formHref("onclick = \"dashboard.editLab(" + id + "," + this.rid + "," + this.id + ",'" + regNo + "', '" + this.ptNo + "');\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

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
//            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add Lab Request", "add.png", "onclick = \"dashboard.addLab(" + this.rid + "," + this.id + ",'" + regNo + "', '" + this.ptNo + "');\"", "");
//            html += " ";
            html += gui.formButton(request.getContextPath(), "button", "btnCancell", "Back", "arrow-left.png", "onclick = \"patients.getRegistrations(" + this.id + "); return false;\"", "");
            

            return html;
        }

        public String addLab() {
            String html = "";

            Sys sys = new Sys();
            Gui gui = new Gui();

            Integer rid = request.getParameter("lid") != null ? Integer.parseInt(request.getParameter("lid")) : null;
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
                } catch (Exception e) {
                    html += e.getMessage();
                }

            }

            html += gui.formStart("frmLab", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (rid != null) {
                html += gui.formInput("hidden", "lid", 15, "" + rid, "", "");
            }

            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("labItemCode", " Lab Item") + "</td>";
            html += "<td >"+gui.formSelect("labItemCode", ""+this.comCode+".ICITEMS", "ITEMCODE", "ITEMNAME", "", "catcode in (select catcode from "+this.comCode+".hmcats where islab = 1)", labItemCode, "", false)+"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("labItem", " Lab Item Description") + "</td>";
            html += "<td >" + gui.formInput("textarea", "labItem", 40, labItemName, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("remarks", " Remarks") + "</td>";
            html += "<td >" + gui.formInput("textarea", "remarks", 40, remarks, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "pencil.png", "", "") + gui.formLabel("results", " Lab Results") + "</td>";
            html += "<td >" + "<textarea id = \"results\" name = \"results\" cols = \"40\"  rows = \"6\" readonly>" + results + "</textarea>" + "</td>";
            html += "</tr>";
            
            String filePath = sys.getOne(this.comCode + ".HMPTLABDOCS", "filepath", "rid=" + rid);
            String refNo = sys.getOne(this.comCode + ".HMPTLABDOCS", "refno", "rid=" + rid);

            
            if (filePath != null) {
                String docLink = "<a href=\"" + request.getContextPath() + filePath + "\" target=\"blank\">download - " + refNo + "</a>";

                html += "<tr>";
                html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "attach.png", "", "") + gui.formLabel("attachment", " Attachment") + "</td>";
                html += "<td >" + docLink + "</td>";
                html += "</tr>";
            }


            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
//            html += gui.formButton(request.getContextPath(), "button", "btnSaveLab", "Save", "save.png", "onclick = \"dashboard.saveLab('labItemCode labItem');\"", "");
//            if (rid != null) {
//                html += gui.formButton(request.getContextPath(), "button", "btnDelLab", "Delete", "delete.png", "onclick = \"dashboard.delLab(" + rid + ", '" + labItemName + "', '" + this.regNo + "', " + this.rid + ", " + this.id + ",'" + this.ptNo + "');\"", "");
//            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancell2", "Back", "arrow-left-2.png", "onclick = \"patients.manageRegistration(" + this.rid + ", " + this.id + ",'" + this.ptNo + "'); return false;\"", "");
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

            Integer rid = request.getParameter("lid") != null ? Integer.parseInt(request.getParameter("lid")) : null;
            String labItemCode = request.getParameter("labItemCode");
            String labItemName = request.getParameter("labItem");
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
                            + "'" + labItemCode + "', "
                            + "'" + labItemName + "', "
                            + "'" + remarks + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getLogTime() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                } else {
                    query = "UPDATE " + this.comCode + ".HMPTLAB SET "
                            + "LABITEMCODE    = '" + labItemCode + "', "
                            + "LABITEMNAME    = '" + labItemName + "', "
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
            
            this.regNo = sys.getOne(this.comCode + ".HMREGISTRATION", "REGNO", "ID = " + this.rid);

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

                        String editLink = gui.formHref("onclick = \"dashboard.editDiagnosis(" + id + "," + this.rid + "," + this.id + ",'" + regNo + "', '" + this.ptNo + "');\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + sys.shorten(diagName, 300) + "</td>";
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
//            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"dashboard.addDiagnosis(" + this.rid + "," + this.id + ",'" + regNo + "', '" + this.ptNo + "');\"", "");
//            html += " ";
            html += gui.formButton(request.getContextPath(), "button", "btnCancell", "Back", "arrow-left.png", "onclick = \"patients.getRegistrations(" + this.id + "); return false;\"", "");

            return html;
        }

        public String addDiagnosis() {
            String html = "";

            Gui gui = new Gui();

            Integer rid = request.getParameter("did") != null ? Integer.parseInt(request.getParameter("did")) : null;
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
                } catch (Exception e) {
                    html += e.getMessage();
                }

            }

            html += gui.formStart("frmDiagnosis", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            if (rid != null) {
                html += gui.formInput("hidden", "did", 15, "" + rid, "", "");
            }

            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("diagnosis", " Diagnosis") + "</td>";
//            html += "<td >"+gui.formSelect("diagnosis", ""+this.comCode+".HMDIAGNOSIS", "DIAGCODE", "DIAGNAME", "", "", diagCode, "", false)+"</td>";
            html += "<td >"+gui.formAutoComplete("diagnosis", 25, diagCode, "dashboard.searchDiagnosis", "diagnosisHd", diagCode)+"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("diagName", " Description") + "</td>";
            html += "<td >" + gui.formInput("textarea", "diagName", 40, diagName, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("remarks", " Remarks") + "</td>";
            html += "<td >" + gui.formInput("textarea", "remarks", 40, remarks, "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>";
//            html += gui.formButton(request.getContextPath(), "button", "btnSaveDiagnosis", "Save", "save.png", "onclick = \"dashboard.saveDiagnosis('diagnosis diagName');\"", "");
//            if (rid != null) {
//                html += gui.formButton(request.getContextPath(), "button", "btnDelDiagnosis", "Delete", "delete.png", "onclick = \"dashboard.delDiagnosis(" + rid + ", '" + diagName + "', '" + this.regNo + "', " + this.rid + ", " + this.id + ",'" + this.ptNo + "');\"", "");
//            }
            html += gui.formButton(request.getContextPath(), "button", "btnCanceld", "Back", "arrow-left-2.png", "onclick = \"patients.manageRegistration(" + this.rid + ", " + this.id + ",'" + this.ptNo + "'); return false;\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();
            return html;
        }
        
        public String searchDiagnosis() {
            String html = "";

            Gui gui = new Gui();

            String diagnosis = request.getParameter("diagnosisHd");

//        html += gui.getAutoColsSearch("VIEWHMITEMS", "ITEMCODE, ITEMNAME", "", this.itemCode);
//            html += gui.getAutoColsSearch(this.comCode + ".ICITEMS", "ITEMCODE, ITEMNAME", "", this.itemCode);
            html += gui.getAutoColsSearch(this.comCode + ".HMDIAGNOSIS", "DIAGCODE, DIAGNAME", "", diagnosis);

            return html;
        }

        public Object getDiagnosisProfile() throws Exception {
            JSONObject obj = new JSONObject();
            
            String diagnosis = request.getParameter("diagnosis");

            if (diagnosis == null || diagnosis.trim().equals("")) {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            } else {
                HmDiagnosis hmDiagnosis = new HmDiagnosis(diagnosis, this.comCode);

                obj.put("diagnosis", hmDiagnosis.diagCode);
                obj.put("diagName", hmDiagnosis.diagName);

                obj.put("success", new Integer(1));
                obj.put("message", "Diagnosis '" + hmDiagnosis.diagCode + "' successfully retrieved.");
            }

            return obj;
        }

        public Object saveDiagnosis() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Integer rid = request.getParameter("did") != null ? Integer.parseInt(request.getParameter("did")) : null;
            String diagCode = request.getParameter("diagnosis");
            String diagName = request.getParameter("diagName");
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
                            + "'" + diagCode + "', "
                            + "'" + diagName + "', "
                            + "'" + remarks + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getLogTime() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";

                } else {
                    query = "UPDATE " + this.comCode + ".HMPTDIAGNOSIS SET "
                            + "DIAGCODE     = '"+ diagCode +"', "
                            + "DIAGNAME     = '" + diagName + "', "
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
            
            this.regNo = sys.getOne(this.comCode + ".HMREGISTRATION", "REGNO", "ID = " + this.rid);

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

                        String editLink = gui.formHref("onclick = \"dashboard.editMedication(" + id + "," + this.rid + "," + this.id + ",'" + regNo + "', '" + this.ptNo + "');\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

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
//            html += gui.formButton(request.getContextPath(), "button", "btnAdd", "Add", "add.png", "onclick = \"dashboard.addMedication(" + this.rid + "," + this.id + ",'" + regNo + "', '" + this.ptNo + "');\"", "");
//            html += " ";
            html += gui.formButton(request.getContextPath(), "button", "btnCancelp", "Back", "arrow-left.png", "onclick = \"patients.getRegistrations(" + this.id + "); return false;\"", "");

            return html;
        }

        public String addMedication() {
            String html = "";

            Gui gui = new Gui();

            Integer rid = request.getParameter("pid") != null ? Integer.parseInt(request.getParameter("pid")) : null;
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
                html += gui.formInput("hidden", "pid", 15, "" + rid, "", "");
            }

            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "pill.png", "", "") + gui.formLabel("drug", " Drug") + "</td>";
//        html += "<td >"+gui.formSelect("drug", ""+this.comCode+".ICITEMS", "ITEMCODE", "ITEMNAME", "", "", drugCode, "", false)+"</td>";
            html += "<td nowrap>" + gui.formAutoComplete("drug", 17, drugCode, "dashboard.searchDrug", "drugHd", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\" >" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("drugName", " Drug Description") + "</td>";
//        html += "<td >"+gui.formSelect("drug", "HMITEMS", "ITEMCODE", "ITEMNAME", "", "ISDRUG = 1", drugCode, "", false)+"</td>";
//        html += "<td >"+gui.formSelect("drug", ""+this.comCode+".ICITEMS", "ITEMCODE", "ITEMNAME", "", "", drugCode, "", false)+"</td>";
//            html += "<td nowrap>" + gui.formAutoComplete("drug", 17, drugCode, "dashboard.searchItem", "drugHd", "") + "</td>";
            html += "<td >" + gui.formInput("text", "drugName", 30, drugName, "", "") + "</td>";
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
//            html += gui.formButton(request.getContextPath(), "button", "btnSaveMedication", "Save", "save.png", "onclick = \"dashboard.saveMedication('drug days quantity');\"", "");
//            if (rid != null) {
//                html += gui.formButton(request.getContextPath(), "button", "btnDelMedication", "Delete", "delete.png", "onclick = \"dashboard.delMedication(" + rid + ", '" + drugName + "', '" + this.regNo + "', " + this.rid + ", " + this.id + ",'" + this.ptNo + "');\"", "");
//            }
            html += gui.formButton(request.getContextPath(), "button", "btnCancelp2", "Back", "arrow-left-2.png", "onclick = \"patients.manageRegistration(" + this.rid + ", " + this.id + ",'" + this.ptNo + "'); return false;\"", "");
            html += "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();
            return html;
        }
        

        public String searchDrug() {
            String html = "";

            Gui gui = new Gui();

            String itemCode = request.getParameter("drugHd");

            html += gui.getAutoColsSearch("" + this.comCode + ".ICITEMS", "ITEMCODE, ITEMNAME", "catcode in (select catcode from "+this.comCode+".hmcats )", itemCode);

            return html;
        }

        public Object getDrugItemProfile() throws Exception {
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

        public JSONObject saveMedication() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            Integer rid = request.getParameter("pid") != null ? Integer.parseInt(request.getParameter("pid")) : null;
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

        public JSONObject delMedication() throws Exception {
            JSONObject obj = new JSONObject();
            Integer rid = request.getParameter("pid") != null ? Integer.parseInt(request.getParameter("pid")) : null;
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
            
            this.regNo = sys.getOne(this.comCode + ".HMREGISTRATION", "REGNO", "ID = " + this.rid);

            if (sys.recordExists(this.comCode + ".HMREGISTRATION", "REGNO = '" + this.regNo + "'")) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.comCode + ".HMREGISTRATION" + " WHERE REGNO = '" + this.regNo + "'";
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

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\">" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("dr_notes", " Doctor Notes") + "</td>";
            html += "<td ><textarea id = \"dr_notes\" name = \"dr_notes\" cols = \"72\"  rows = \"14\"  >" + this.drNotes + "</textarea></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>"
//                    + gui.formButton(request.getContextPath(), "button", "btnSaveDrNotes", "Save", "save.png", "onclick=\"dashboard.saveDrNotes('dr_notes');\"", "")
//                    + " "
                    + gui.formButton(request.getContextPath(), "button", "btnPrintDrNotes", "Print", "printer.png", "onclick=\"dashboard.printDrNotes('dr_notes');\"", "")
                    + " "
                    + gui.formButton(request.getContextPath(), "button", "btnCanceld", "Back", "arrow-left.png", "onclick = \"patients.getRegistrations(" + this.id + "); return false;\"", "")
                    + "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

        public JSONObject saveDrNotes() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            String query;

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                query = "UPDATE " + this.comCode + ".HMREGISTRATION" + " SET "
                        + "DR_NOTES     = '" + this.drNotes + "', "
                        + "AUDITUSER    = '" + sys.getLogUser(session) + "', "
                        + "AUDITDATE    = '" + sys.getLogDate() + "', "
                        + "AUDITTIME    = '" + sys.getLogTime() + "', "
                        + "AUDITIPADR   = '" + sys.getClientIpAdr(request) + "' "
                        + "WHERE REGNO     = '" + this.regNo + "'";

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
            
            this.regNo = sys.getOne(this.comCode + ".HMREGISTRATION", "REGNO", "ID = " + this.rid);

            if (sys.recordExists(comCode + ".HMREGISTRATION", "REGNO = '" + this.regNo + "'")) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + comCode + ".HMREGISTRATION" + " WHERE REGNO = '" + this.regNo + "'";
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.remarks = rs.getString("REMARKS");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }
            }

            this.remarks = this.remarks != null ? this.remarks : "";

            html += gui.formStart("frmDischarge", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += gui.formInput("hidden", "id", 15, "" + this.id, "", "");
            html += gui.formInput("hidden", "regNo", 15, this.regNo, "", "");

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"22%\" class = \"bold\">" + gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "") + gui.formLabel("remarks", " Remarks") + "</td>";
            html += "<td >" + gui.formInput("textarea", "remarks", 40, this.remarks, "", "") + "</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td>&nbsp;</td>";
            html += "<td>" 
//                    + gui.formButton(request.getContextPath(), "button", "btnDischarge", "Discharge", "save.png", "onclick=dashboard.discharge('remarks');", "") 
//                    + " "
                    + gui.formButton(request.getContextPath(), "button", "btnCanceld", "Back", "arrow-left.png", "onclick = \"patients.getRegistrations(" + this.id + "); return false;\"", "")
                    + "</td>";
            html += "</tr>";

            html += "</table>";

            html += gui.formEnd();

            return html;
        }

        public JSONObject discharge() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query;

                query = "UPDATE " + comCode + ".HMREGISTRATION" + " SET "
                        + "DISCHARGED   =  1, "
                        + "REMARKS      = '" + this.remarks + "', "
                        + "AUDITUSER    = '" + sys.getLogUser(session) + "', "
                        + "AUDITDATE    = '" + sys.getLogDate() + "', "
                        + "AUDITTIME    = '" + sys.getLogTime() + "', "
                        + "AUDITIPADR   = '" + sys.getClientIpAdr(request) + "' "
                        + "WHERE REGNO     = '" + this.regNo + "'";

                Integer saved = stmt.executeUpdate(query);

                if (saved > 0) {
                    obj.put("success", new Integer(1));
                    obj.put("message", "Discharge for '"+this.regNo+"' successfully made.");

//                    this.invoicePatient(this.regNo);

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
    }

%>