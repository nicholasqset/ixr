<%@page import="org.json.JSONObject"%>
<%@page import="bean.primary.PrimarySchool"%>
<%@page import="bean.primary.PrimaryCalendar"%>
<%@page import="bean.primary.PRStudentProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

    final class CrDrNote {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        String table = comCode + ".PRQDHDR";
        String view = comCode + ".VIEWPRQDHEADER";

        Integer id = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : null;
        Integer sid = request.getParameter("sid") != null ? Integer.parseInt(request.getParameter("sid")) : null;
        String studentNo = request.getParameter("studentNo");
        Integer academicYear = (request.getParameter("academicYear") != null && !request.getParameter("academicYear").toString().trim().equals("")) ? Integer.parseInt(request.getParameter("academicYear")) : null;
        String termCode = request.getParameter("term");
        String docType = request.getParameter("documentType");
        String docDate = request.getParameter("documentDate");
        String docDesc = request.getParameter("docDescription");
        String itemCode = request.getParameter("item");
        Double amount = (request.getParameter("amount") != null && !request.getParameter("amount").toString().trim().equals("")) ? Double.parseDouble(request.getParameter("amount")) : 0.0;

        String docNo = request.getParameter("documentNo");
        Integer posted;

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

                            list.add("DOCNO");
                            list.add("DOCDESC");
                            list.add("STUDENTNO");
                            list.add("FULLNAME");
                            list.add("DOCDATE");
                            for (int i = 0; i < list.size(); i++) {
                                if (i == 0) {
                                    filterSql += " WHERE ( UPPER(" + list.get(i) + ") LIKE '%" + find + "%' ";
                                } else {
                                    filterSql += " OR ( UPPER(" + list.get(i) + ") LIKE '%" + find + "%' ";
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

                String orderBy = "DOCNO DESC ";
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
                    html += "<th>Document No</th>";
                    html += "<th>Desc</th>";
                    html += "<th>Student No</th>";
                    html += "<th>Name</th>";
                    html += "<th>Academic Year</th>";
                    html += "<th>Term</th>";
                    html += "<th>Amount</th>";
                    html += "<th>Posted</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("ID");
                        String docNo = rs.getString("DOCNO");
                        String docDesc = rs.getString("DOCDESC");
                        String studentNo = rs.getString("STUDENTNO");
                        String fullName = rs.getString("FULLNAME");
                        Integer academicYear = rs.getInt("ACADEMICYEAR");
                        String termName = rs.getString("TERMNAME");
                        Integer posted = rs.getInt("POSTED");

//                    String amountLbl = sys.getOne("PRQDDTLS", "SUM(AMOUNT)", "DOCNO = '"+ docNo+ "'");
                        String amountLbl = sys.getOneAgt("" + this.comCode + ".PRQDDTLS", "SUM", "AMOUNT", "SM", "DOCNO = '" + docNo + "'");
                        amountLbl = sys.numberFormat(amountLbl);

                        String postedLbl = posted == 1 ? gui.formIcon(request.getContextPath(), "tick.png", "", "") : gui.formIcon(request.getContextPath(), "cross.png", "", "");

                        String edit = gui.formHref("onclick = \"module.editModule(" + id + ")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        String bgcolor = (count % 2 > 0) ? "#FFFFFF" : "#F7F7F7";

                        html += "<tr bgcolor = \"" + bgcolor + "\">";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + docNo + "</td>";
                        html += "<td>" + docDesc + "</td>";
                        html += "<td>" + studentNo + "</td>";
                        html += "<td>" + fullName + "</td>";
                        html += "<td>" + academicYear + "</td>";
                        html += "<td>" + termName + "</td>";
                        html += "<td>" + amountLbl + "</td>";
                        html += "<td>" + postedLbl + "</td>";
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
            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

            if (this.id != null) {

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.view + " WHERE ID = " + this.id;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.docNo = rs.getString("DOCNO");
                        this.studentNo = rs.getString("STUDENTNO");
                        this.academicYear = rs.getInt("ACADEMICYEAR");
                        this.termCode = rs.getString("TERMCODE");
                        this.docType = rs.getString("DOCTYPE");

                        this.docDate = rs.getString("DOCDATE");

                        java.util.Date docDate = originalFormat.parse(this.docDate);
                        this.docDate = targetFormat.format(docDate);

                        this.docDesc = rs.getString("DOCDESC");
                        this.posted = rs.getInt("POSTED");

                    }
                } catch (SQLException e) {
                    html += e.getMessage();
                } catch (Exception e) {
                    html += e.getMessage();
                }
            }

            html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

            html += "<div id = \"dhtmlgoodies_tabView1\">";

            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getQDTab() + "</div>";

            html += "</div>";

            html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";

            String btnSave = gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"crDrNote.save('studentNo academicYear term documentType documentDate docDescription item amount'); return false;\"", "");
            String btnPost = gui.formButton(request.getContextPath(), "button", "btnPost", "Post", "tick.png", "onclick = \"crDrNote.post('" + this.docNo + "', '" + this.docType + "'); return false;\"", "");
            String btnCancel = gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getGrid(); return false;\"", "");

            if (this.id == null) {
                html += btnSave;
            } else {
                if ((this.posted == null || this.posted == 0)) {
                    html += btnSave;
                    html += btnPost;
                }
            }

            html += btnCancel;
            html += "</div>";

            html += gui.formEnd();

            html += "<script type = \"text/javascript\">";
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Quick Documents\'), 0, 625, 420, Array(false));";
            html += "</script>";

            return html;
        }

        public String getQDTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

            String fullName = "";
            String studPrdName = "";
            String studTypeName = "";

            if (this.id != null) {
                PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo, this.comCode);

                fullName = pRStudentProfile.fullName;
                studPrdName = pRStudentProfile.studPrdName;
                studTypeName = pRStudentProfile.studTypeName;
            }

            PrimaryCalendar primaryCalendar = new PrimaryCalendar(this.comCode);

            HashMap<String, String> quickDocs = new HashMap();
            quickDocs.put("CN", "Credit Note");
            quickDocs.put("DN", "Debit Note");

            String defaultDate = sys.getLogDate();

            try {
                java.util.Date today = originalFormat.parse(defaultDate);
                defaultDate = targetFormat.format(today);
            } catch (ParseException e) {
                html += e.getMessage();
            } catch (Exception e) {
                html += e.getMessage();
            }

            if (this.id != null) {
                html += gui.formInput("hidden", "id", 30, "" + this.id, "", "");
                html += gui.formInput("hidden", "documentNo", 30, "" + this.docNo, "", "");
            }

            html += "<div id = \"divFSDtlsSid\">";
            if (this.sid != null) {
                html += gui.formInput("hidden", "sid", 30, "" + this.sid, "", "");
            }
            html += "</div>";

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"15%\">" + gui.formIcon(request.getContextPath(), "user-properties.png", "", "") + gui.formLabel("studentNo", " Student No") + "</td>";
            html += "<td width = \"35%\">" + gui.formAutoComplete("studentNo", 15, this.id != null ? this.studentNo : "", "crDrNote.searchStudent", "studentNoHd", this.id != null ? this.studentNo : "") + "</td>";

            html += "<td width = \"15%\">" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " Name</td>";
            html += "<td id = \"tdFullName\">" + fullName + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + " Student Period</td>";
            html += "<td id = \"tdStudentPeriod\">" + studPrdName + "</td>";

            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " Student Type</td>";
            html += "<td id = \"tdStudentType\">" + studTypeName + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("academicYear", " Academic Year") + "</td>";
            html += "<td>" + gui.formSelect("academicYear", "" + this.comCode + ".PRACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", this.id != null ? "" + this.academicYear : "" + primaryCalendar.academicYear, "onchange = \"crDrNote.getQDItems();\"", false) + "</td>";

            html += "<td>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("term", " Term") + "</td>";
            html += "<td>" + gui.formSelect("term", "" + this.comCode + ".PRTERMS", "TERMCODE", "TERMNAME", "", "", this.id != null ? this.termCode : primaryCalendar.termCode, "onchange = \"crDrNote.getQDItems();\"", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("documentType", " Document Type") + "</td>";
            html += "<td>" + gui.formArraySelect("documentType", 100, quickDocs, this.id != null ? this.docType : "", false, "onchange = \"crDrNote.getQDItems();\"", true) + "</td>";

            html += "<td>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + " " + gui.formLabel("documentDate", " Date") + "</td>";
            html += "<td>" + gui.formDateTime(request.getContextPath(), "documentDate", 15, this.id != null ? this.docDate : defaultDate, false, "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + gui.formLabel("docDescription", " Description") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "docDescription", 25, this.id != null ? this.docDesc : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("item", " Fee Item") + "</td>";
            html += "<td colspan = \"3\">" + gui.formSelect("item", "" + this.comCode + ".PRITEMS", "ITEMCODE", "ITEMNAME", "", "", "", "onchange = \"crDrNote.getItemAmount();\"", false) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "money.png", "", "") + gui.formLabel("amount", " Amount") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "amount", 15, "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"4\">&nbsp;</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"4\"><div id = \"dvQDItems\">" + this.getQDItems() + "</div></td>";
            html += "</tr>";

            html += "</table>";

            return html;
        }

        public String searchStudent() {
            String html = "";

            Gui gui = new Gui();

            this.studentNo = request.getParameter("studentNoHd");

            html += gui.getAutoColsSearch("" + this.comCode + ".PRSTUDENTS", "STUDENTNO, FULLNAME", "", this.studentNo);

            return html;
        }

        public Object getStudentProfile() throws Exception {
            JSONObject obj = new JSONObject();

            if (this.studentNo == null || this.studentNo.equals("")) {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            } else {

                PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo, this.comCode);

                obj.put("fullName", pRStudentProfile.fullName);

                obj.put("studentPeriod", pRStudentProfile.studPrdName);
                obj.put("studentType", pRStudentProfile.studTypeName);

                obj.put("success", new Integer(1));
                obj.put("message", "Student No '" + pRStudentProfile.studentNo + "' successfully retrieved.");

            }

            return obj;
        }

        public String getQDItems() {
            String html = "";
            Gui gui = new Gui();
            Sys sys = new Sys();

            String filterSql;

            if (this.id != null) {
                filterSql = "DOCNO  = '" + this.docNo + "'";
            } else {
                filterSql = "STUDENTNO      = '" + this.studentNo + "' AND "
                        + "ACADEMICYEAR     = " + this.academicYear + " AND "
                        + "TERMCODE         = '" + this.termCode + "' AND "
                        + "DOCTYPE          = '" + this.docType + "' AND "
                        + "(POSTED IS NULL OR POSTED = 0)";
            }

            if (sys.recordExists("" + this.comCode + ".VIEWPRQDDETAILS", filterSql)) {

                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Document No</th>";
                html += "<th>Item</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";
                html += "<th style = \"text-align: right;\">Options</th>";
                html += "</tr>";

                Double total = 0.0;

                try {

                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    Integer count = 1;

                    String query = "SELECT * FROM " + this.comCode + ".VIEWPRQDDETAILS WHERE " + filterSql + "ORDER BY ITEMNAME";

                    ResultSet rs = stmt.executeQuery(query);

                    while (rs.next()) {
                        Integer id = rs.getInt("ID");
                        String docNo = rs.getString("DOCNO");
                        String itemName = rs.getString("ITEMNAME");
                        Double amount = rs.getDouble("AMOUNT");
                        Integer posted = rs.getInt("POSTED");

                        String editLink = gui.formHref("onclick = \"crDrNote.editQDDtls(" + id + ");\"", request.getContextPath(), "", "edit", "edit", "", "");
                        String removeLink = gui.formHref("onclick = \"crDrNote.purge(" + id + ", '" + itemName + "');\"", request.getContextPath(), "", "delete", "delete", "", "");

                        String opts = "";
                        if (posted == 1) {
                            opts = gui.formIcon(request.getContextPath(), "lock.png", "", "locked");
                        } else {
                            opts = editLink + " || " + removeLink;
                        }

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + docNo + "</td>";
                        html += "<td>" + itemName + "</td>";
                        html += "<td style = \"text-align: right;\">" + amount + "</td>";
                        html += "<td style = \"text-align: right;\">" + opts + "</td>";
                        html += "</tr>";

                        total = total + amount;

                        count++;
                    }
                } catch (SQLException e) {
                    html += e.getMessage();
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
                html += "No item record found.";
            }

            return html;
        }

        public Object getItemAmount() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();

            PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo, this.comCode);

            String amount = sys.getOne("" + this.comCode + ".VIEWPRFSDETAILS", "AMOUNT", "ACADEMICYEAR = " + this.academicYear + " AND "
                    + "TERMCODE     = '" + this.termCode + "' AND "
                    + "CLASSCODE    = '" + pRStudentProfile.classCode + "' AND "
                    + "STUDTYPECODE = '" + pRStudentProfile.studTypeCode + "' AND "
                    + "ITEMCODE     = '" + this.itemCode + "' "
            );

            amount = amount != null ? amount : "0";

            obj.put("amount", amount);

            return obj;
        }

        public Object editQDDtls() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            Gui gui = new Gui();
            if (sys.recordExists("" + this.comCode + ".PRQDDTLS", "ID = " + this.sid + "")) {
                try {

                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query = "SELECT * FROM " + this.comCode + ".VIEWPRQDDETAILS WHERE ID = " + this.sid + "";
                    ResultSet rs = stmt.executeQuery(query);

                    while (rs.next()) {
                        String id = rs.getString("ID");
                        String itemCode = rs.getString("ITEMCODE");
                        String amount = rs.getString("AMOUNT");

                        obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                        obj.put("item", itemCode);
                        obj.put("amount", amount);

                        obj.put("success", new Integer(1));
                        obj.put("message", "Record retrieved successfully.");

                    }
                } catch (SQLException e) {
                    obj.put("success", new Integer(0));
                    obj.put("message", e.getMessage());
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

        public Object save() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            String docNo = this.getQDHdr();

            if (docNo != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;
                    Integer saved = 0;

                    if (this.sid == null) {

                        Integer sid = sys.generateId("" + this.comCode + ".PRQDDTLS", "ID");

                        query = "INSERT INTO " + this.comCode + ".PRQDDTLS "
                                + "(ID, DOCNO, ITEMCODE, AMOUNT, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + sid + ", "
                                + "'" + docNo + "', "
                                + "'" + this.itemCode + "', "
                                + this.amount + ", "
                                + "'" + sys.getLogUser(session) + "', "
                                + "'" + sys.getLogDate() + "', "
                                + "'" + sys.getLogTime() + "', "
                                + "'" + sys.getClientIpAdr(request) + "'"
                                + ")";

                    } else {

                        query = "UPDATE " + this.comCode + ".PRQDDTLS SET "
                                + "ITEMCODE     = '" + this.itemCode + "', "
                                + "AMOUNT       = " + this.amount + " "
                                + "WHERE ID     = " + this.sid;
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
            } else {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record header." + docNo);
            }

            return obj;
        }

        public String getQDHdr() {

            Sys sys = new Sys();
            HttpSession session = request.getSession();

            String docNo = sys.getOne(this.table, "DOCNO", "STUDENTNO = '" + this.studentNo + "' AND "
                    + "ACADEMICYEAR = " + this.academicYear + " AND "
                    + "TERMCODE     = '" + this.termCode + "' AND "
                    + "DOCTYPE      = '" + this.docType + "' AND "
                    + "(POSTED IS NULL OR POSTED = 0)");

            if (docNo == null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    Integer id = sys.generateId(this.table, "ID");
//                docNo = sys.getNextNo(this.table, "ID", this.docType, 7);
                    docNo = this.getNextNo(this.table, "DOCNO", this.docType, this.docType, 7);

                    SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                    SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                    java.util.Date docDate = originalFormat.parse(this.docDate);
                    this.docDate = targetFormat.format(docDate);

                    String query = "INSERT INTO " + this.table + " "
                            + "(ID, ACADEMICYEAR, TERMCODE, STUDENTNO, DOCNO, DOCTYPE, DOCDESC, DOCDATE, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + id + ", "
                            + this.academicYear + ", "
                            + "'" + this.termCode + "', "
                            + "'" + this.studentNo + "', "
                            + "'" + docNo + "', "
                            + "'" + this.docType + "', "
                            + "'" + this.docDesc + "', "
                            + "'" + this.docDate + "', "
                            + "'" + sys.getLogUser(session) + "', "
                            + "'" + sys.getLogDate() + "', "
                            + "'" + sys.getLogTime() + "', "
                            + "'" + sys.getClientIpAdr(request) + "'"
                            + ")";
                            
                            sys.log(query);

                    Integer docHdrCreated = stmt.executeUpdate(query);

                    if (docHdrCreated > 0) {

                    } else {
                        docNo = null;
                    }

                } catch (SQLException e) {
                    e.getMessage();
                } catch (Exception e) {
                    e.getMessage();
                }

            }

            return docNo;
        }

        public String getNextNo(String table, String col, String docType, String mask, Integer padSize) {
            String nextNo = "";
            Sys sys = new Sys();
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;
            String query;
            Integer nextNoMax = 0;
            String docNoMax = "";
            try {
                stmt = conn.createStatement();
                query = "SELECT MAX(" + col + ")MX FROM " + this.table + " WHERE DOCTYPE = '" + docType + "'";
                sys.log(query);
                ResultSet rs = stmt.executeQuery(query);
                while (rs.next()) {
                sys.log("xxx");
//                nextNoMax = rs.getInt("MAX("+col+")");		
                    docNoMax += rs.getString("MX");
                    sys.log(docNoMax);
                    sys.log("yyy");
                }

            } catch (Exception e) {
                nextNo += e.getMessage();
            }

            docNoMax = docNoMax != null && !docNoMax.trim().equals("") ? docNoMax : "000";
            sys.log(docNoMax);
            docNoMax = docNoMax.substring(2);
            sys.log(docNoMax);
//        docNoMax = docNoMax.replace("^0+(?!$)", " ");
            nextNoMax = Integer.parseInt(docNoMax);
            nextNoMax = nextNoMax * 1;
            nextNoMax = nextNoMax + 1;

            if (mask != null && !mask.trim().equals("")) {
                nextNo = mask + String.format("%0" + padSize + "d", nextNoMax);
            } else {
                nextNo = String.format("%0" + padSize + "d", nextNoMax);
            }

            return nextNo;
        }

        public Object purge() throws Exception {

            JSONObject obj = new JSONObject();

            try {
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                if (this.id != null) {
                    String query = "DELETE FROM " + this.comCode + ".PRQDDTLS WHERE ID = " + this.id;

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

        public Object post() throws Exception {

            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            PrimarySchool primarySchool = new PrimarySchool();
            HttpSession session = request.getSession();

            String filterSql = "DOCNO  = '" + this.docNo + "'";

            if (this.docNo != null && !this.docNo.trim().equals("")) {
                if (sys.recordExists("" + this.comCode + ".VIEWPRQDDETAILS", filterSql)) {
                    try {
                        Connection conn = ConnectionProvider.getConnection();
                        Statement stmt = conn.createStatement();

                        String query = "SELECT * FROM " + this.comCode + ".VIEWPRQDDETAILS WHERE " + filterSql;

                        ResultSet rs = stmt.executeQuery(query);
                        Integer count = 0;
                        while (rs.next()) {
                            String studentNo = rs.getString("STUDENTNO");
                            Integer academicYear = rs.getInt("ACADEMICYEAR");
                            String termCode = rs.getString("TERMCODE");
                            String docNo = rs.getString("DOCNO");
                            String docDesc = rs.getString("DOCDESC");
                            String docDate = rs.getString("DOCDATE");
                            String itemCode = rs.getString("ITEMCODE");
                            Double amount = rs.getDouble("AMOUNT");

                            Integer obsCreated = primarySchool.createPrObs(studentNo, academicYear, termCode, docNo, docDesc, this.docType, docDate, itemCode, amount, session, request, this.comCode);

                            if (obsCreated == 1) {
                                Statement st = conn.createStatement();
                                st.executeUpdate("UPDATE " + this.table + " SET POSTED = 1 WHERE DOCNO = '" + docNo + "' ");
                                count++;
                            }

                        }
                        if (count > 0) {
                            obj.put("success", new Integer(1));
                            obj.put("message", "Entry successfully posted.");
                        }
                    } catch (SQLException e) {
                        obj.put("success", new Integer(0));
                        obj.put("message", e.getMessage());
                    } catch (Exception e) {
                        obj.put("success", new Integer(0));
                        obj.put("message", e.getMessage());
                    }
                } else {
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! Could not retrieve Document Details");
                }
            } else {
                obj.put("success", new Integer(0));
                obj.put("message", "Error! Could not retrieve Document");
            }

            return obj;

        }

    }

%>