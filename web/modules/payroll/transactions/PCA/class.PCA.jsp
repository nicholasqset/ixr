<%@page import="org.json.JSONObject"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

    final class PCA {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        String table = comCode + ".PYPCAHDR";
        String view = comCode + ".VIEWPYPCAHDR";

        Integer id = request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : null;

        String refNo = request.getParameter("reference") != null && !request.getParameter("reference").trim().equals("") ? request.getParameter("reference") : null;
        String pcaDesc = request.getParameter("pcaDesc");

        Integer pYear = request.getParameter("pYear") != null && !request.getParameter("pYear").trim().equals("") ? Integer.parseInt(request.getParameter("pYear")) : null;
        Integer pMonth = request.getParameter("pMonth") != null && !request.getParameter("pMonth").trim().equals("") ? Integer.parseInt(request.getParameter("pMonth")) : null;
        String efDate = request.getParameter("efDate");

        String pfNo = request.getParameter("staffNo");
        String itemCode = request.getParameter("item");
        Double oldAmount = (request.getParameter("oldAmount") != null && !request.getParameter("oldAmount").trim().equals("")) ? Double.parseDouble(request.getParameter("oldAmount")) : 0.0;
        Double newAmount = (request.getParameter("newAmount") != null && !request.getParameter("newAmount").trim().equals("")) ? Double.parseDouble(request.getParameter("newAmount")) : 0.0;
        String lineDesc = request.getParameter("lineDesc");

        Integer sid = request.getParameter("sid") != null ? Integer.parseInt(request.getParameter("sid")) : null;

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

                            list.add("REFNO");
                            list.add("PCANO");
                            list.add("PCADESC");
                            for (int i = 0; i < list.size(); i++) {
                                if (i == 0) {
                                    if (dbType.equals("postgres")) {
                                        filterSql += " WHERE ( UPPER(CAST (" + list.get(i) + " AS TEXT)) LIKE '%" + find.toUpperCase() + "%' ";
                                    } else {
                                        filterSql += " WHERE ( UPPER(" + list.get(i) + ") LIKE '%" + find.toUpperCase() + "%' ";
                                    }
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

                String orderBy = "PCANO DESC, PYEAR DESC, PMONTH DESC ";
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
                    html += "<th>Reference No</th>";
                    html += "<th>PCA No</th>";
                    html += "<th>Description</th>";
                    html += "<th>Year</th>";
                    html += "<th>Month</th>";
                    html += "<th>Amount</th>";
                    html += "<th>Options</th>";
                    html += "</tr>";

                    Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                    while (rs.next()) {

                        Integer id = rs.getInt("ID");
                        String refNo = rs.getString("REFNO");
                        String pcaNo = rs.getString("PCANO");
                        String pcaDesc = rs.getString("PCADESC");
                        Integer pYear = rs.getInt("PYEAR");
                        Integer pMonth = rs.getInt("PMONTH");

                        String amountStr = sys.getOneAgt("VIEWPYPCADTLS", "SUM", "NEWAMOUNT", "AMT", "REFNO = '" + refNo + "'");

                        amountStr = (amountStr != null && !amountStr.trim().equals("")) ? amountStr : "0";

                        String bgcolor = (count % 2 > 0) ? "#FFFFFF" : "#F7F7F7";

                        String edit = gui.formHref("onclick = \"module.editModule(" + id + ")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                        html += "<tr bgcolor = \"" + bgcolor + "\">";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + refNo + "</td>";
                        html += "<td>" + pcaNo + "</td>";
                        html += "<td>" + pcaDesc + "</td>";
                        html += "<td>" + pYear + "</td>";
                        html += "<td>" + pMonth + "</td>";
                        html += "<td>" + sys.numberFormat(amountStr) + "</td>";
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

//        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
//        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" enctype = \"multipart/form-data\" target = \"_blank\">";

            html += "<div id = \"dhtmlgoodies_tabView1\">";

            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getPcaTab() + "</div>";
            html += "<div class = \"dhtmlgoodies_aTab\">" + this.getImportTab() + "</div>";

            html += "</div>";

            html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
            html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"pca.save('reference pcaDesc pYear pMonth efDate staffNo item newAmount'); return false;\"", "");
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
            html += "</div>";

            html += gui.formEnd();

            html += "<script type = \"text/javascript\">";
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Pay Change Advice\', \'Import\'), 0, 625, 420, Array(false));";
            html += "</script>";

            html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";

            return html;
        }

        public String getPcaTab() {
            String html = "";

            Gui gui = new Gui();
            Sys sys = new Sys();

            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

            if (this.id != null) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.view + " WHERE ID = " + this.id;
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.refNo = rs.getString("REFNO");
                        this.pcaDesc = rs.getString("PCADESC");
                        this.pYear = rs.getInt("PYEAR");
                        this.pMonth = rs.getInt("PMONTH");
                        this.efDate = rs.getString("EFDATE");

                        java.util.Date efDate = originalFormat.parse(this.efDate);

                        this.efDate = targetFormat.format(efDate);
                    }
                } catch (SQLException e) {
                    html += e.getMessage();
                } catch (Exception e) {
                    html += e.getMessage();
                }
            }

//        String defaultDate = sys.getLogDate();
            String defaultDate = sys.getPeriodYear(this.comCode) + "-" + sys.getPeriodMonth(this.comCode) + "-01";

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
            }

            html += "<div id = \"dvPcaSid\">";
            if (this.sid != null) {
                html += gui.formInput("hidden", "sid", 30, "" + this.sid, "", "");
            }
            html += "</div>";

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + gui.formLabel("reference", " Reference No.") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "reference", 15, this.id != null ? this.refNo : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "package.png", "", "") + gui.formLabel("pcaDesc", " Description") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "pcaDesc", 25, this.id != null ? this.pcaDesc : "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td width = \"17%\" nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("pYear", " Fiscal Year") + "</td>";
            html += "<td width = \"33%\">" + gui.formSelect("pYear", this.comCode+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null ? "" + this.pYear : "" + sys.getPeriodYear(this.comCode), "", false) + "</td>";

            html += "<td width = \"17%\">" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("pMonth", " Period") + "</td>";
            html += "<td>" + gui.formMonthSelect("pMonth", this.id != null ? this.pMonth : sys.getPeriodMonth(this.comCode), "", true) + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "calendar.png", "", "") + gui.formLabel("efDate", " Effective Date") + "</td>";
            html += "<td colspan = \"3\">" + gui.formDateTime(request.getContextPath(), "efDate", 15, this.id != null ? this.efDate : defaultDate, false, "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "user-properties.png", "", "") + gui.formLabel("staffNo", " Staff") + "</td>";
            html += "<td>" + gui.formAutoComplete("staffNo", 13, "", "pca.searchStaff", "staffNoHd", "") + "</td>";

            html += "<td>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " Staff Name</td>";
            html += "<td id = \"tdFullName\">&nbsp;</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " " + gui.formLabel("item", " Item No.") + "</td>";
            html += "<td>" + gui.formAutoComplete("item", 13, "", "pca.searchItem", "itemCode", "") + "</td>";

            html += "<td>" + gui.formIcon(request.getContextPath(), "page-edit.png", "", "") + " Item Name</td>";
            html += "<td id = \"tdItemName\">&nbsp;</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>" + gui.formIcon(request.getContextPath(), "money.png", "", "") + gui.formLabel("newAmount", " New Amount") + "</td>";
            html += "<td nowrap>" + gui.formInput("text", "newAmount", 15, "", "", "") + "</td>";

            html += "<td>" + gui.formIcon(request.getContextPath(), "money.png", "", "") + gui.formLabel("oldAmount", " Old Amount") + "</td>";
            html += "<td nowrap>" + gui.formInput("text", "oldAmount", 15, "", "", "disabled") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td nowrap>" + gui.formIcon(request.getContextPath(), "package-green.png", "", "") + gui.formLabel("lineDesc", " Line Description") + "</td>";
            html += "<td colspan = \"3\">" + gui.formInput("text", "lineDesc", 25, "", "", "") + "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td colspan = \"4\"><div id = \"dvPCA\">" + this.getPcaEntries() + "</div></td>";
            html += "</tr>";

            html += "</table>";

            return html;
        }

        public String searchStaff() {
            String html = "";

            Gui gui = new Gui();

            this.pfNo = request.getParameter("staffNoHd");

            html += gui.getAutoColsSearch("HRSTAFFPROFILE", "PFNO, FULLNAME", "", this.pfNo);

            return html;
        }

        public Object getStaffProfile() throws Exception{
            JSONObject obj = new JSONObject();

            if (this.pfNo == null || this.pfNo.equals("")) {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            } else {
                StaffProfile staffProfile = new StaffProfile(this.pfNo, session.getAttribute("comCode").toString());

                obj.put("fullName", staffProfile.fullName);

                obj.put("success", new Integer(1));
                obj.put("message", "Staff No '" + this.pfNo + "' details successfully retrieved.");
            }

            return obj;
        }

        public String searchItem() {
            String html = "";

            Gui gui = new Gui();

            this.itemCode = (request.getParameter("itemCode") != null && !request.getParameter("itemCode").trim().equals("")) ? request.getParameter("itemCode") : null;

            html += gui.getAutoColsSearch("PYITEMS", "ITEMCODE, ITEMNAME", "", this.itemCode);

            return html;
        }

        public Object getItemDtls() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();

            if (this.itemCode == null || this.itemCode.trim().equals("")) {
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            } else {

                String itemName = sys.getOne("PYITEMS", "ITEMNAME", "ITEMCODE = '" + this.itemCode + "'");

                obj.put("itemName", itemName);

                obj.put("success", new Integer(1));
                obj.put("message", "Item Code '" + this.itemCode + "' details successfully retrieved.");

            }

            return obj;
        }

        public Object getOldAmount() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();

            Double oldAmount = 0.0;

            String sqlWhere = "PFNO = '" + this.pfNo + "' AND ITEMCODE = '" + this.itemCode + "' AND PYEAR = '" + sys.getPrevPeriodYear(this.comCode) + "' AND PMONTH = '" + sys.getPrevPeriodMonth(this.comCode) + "'";

            String oldAmount_ = sys.getOne("PYSLIP", "AMOUNT", sqlWhere);
            oldAmount_ = oldAmount_ != null ? oldAmount_ : "0";

            oldAmount = Double.parseDouble(oldAmount_);

            obj.put("oldAmount", oldAmount);

            return obj;
        }

        public String getImportTab() {
            String html = "";

            Gui gui = new Gui();

            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";

            html += "<tr>";
            html += "<td width = \"17%\" nowrap>" + gui.formIcon(request.getContextPath(), "attach.png", "", "") + " " + gui.formLabel("impfile", "Import File") + " <span class = \"fade\">(excel only)</span></td>";
            html += "<td><input type = \"file\" name = \"impfile\" id = \"impfile\" onchange = \"pca.import('reference pcaDesc pYear pMonth efDate');\" > <span><a href = \"./template/template.xls\">template</a></span></td>";
            html += "</tr>";

//        html += "<tr>";
//	html += "<td>&nbsp;</td>";
//	html += "<td>";
//	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
//	html += "</td>";
//	html += "</tr>";
            html += "</table>";

            return html;
        }

        public Object save() throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            HttpSession session = request.getSession();

            if (this.createPcaHeader() == 1) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;
                    Integer saved = 0;

                    if (this.sid == null) {

                        Integer sid = sys.generateId("PYPCADTLS", "ID");

                        query = "INSERT INTO PYPCADTLS "
                                + "("
                                + "ID, REFNO, PFNO, ITEMCODE, OLDAMOUNT, NEWAMOUNT,"
                                + "LINEDESC, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + sid + ", "
                                + "'" + this.refNo + "', "
                                + "'" + this.pfNo + "', "
                                + "'" + this.itemCode + "', "
                                + this.oldAmount + ", "
                                + this.newAmount + ", "
                                + "'" + this.lineDesc + "', "
                                + "'" + sys.getLogUser(session) + "', "
                                + "'" + sys.getLogDate() + "', "
                                + sys.getLogTime() + ", "
                                + "'" + sys.getClientIpAdr(request) + "'"
                                + ")";

                    } else {

                        query = "UPDATE PYPCADTLS SET "
                                + "PFNO         = '" + this.pfNo + "', "
                                + "ITEMCODE     = '" + this.itemCode + "', "
                                + "OLDAMOUNT    = " + this.oldAmount + ", "
                                + "NEWAMOUNT    = " + this.newAmount + ", "
                                + "LINEDESC     = '" + this.lineDesc + "', "
                                + "AUDITUSER    = '" + sys.getLogUser(session) + "', "
                                + "AUDITDATE    = '" + sys.getLogDate() + "', "
                                + "AUDITTIME    = " + sys.getLogTime() + ", "
                                + "AUDITIPADR   = '" + sys.getClientIpAdr(request) + "' "
                                + "WHERE ID     = " + this.sid;
                    }

                    saved = stmt.executeUpdate(query);

                    if (saved == 1) {
                        obj.put("success", new Integer(1));
                        obj.put("message", "Entry successfully made.");

                        obj.put("refNo", this.refNo);
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
                obj.put("message", "Oops! An Un-expected error occured while saving record header.");
            }

            return obj;
        }

        public Integer createPcaHeader() {
            Integer pcaHdrCreated = 0;
            Sys sys = new Sys();

            HttpSession session = request.getSession();

            if (this.refNo != null) {
                if (sys.recordExists(this.table, "REFNO = '" + this.refNo + "'")) {
                    pcaHdrCreated = 1;
                } else {
                    try {
                        Connection conn = ConnectionProvider.getConnection();
                        Statement stmt = conn.createStatement();

                        Integer id = sys.generateId(this.table, "ID");

                        String pcaNo = sys.getOne(this.table, "PCANO", "REFNO = '" + this.refNo + "'");
                        if (pcaNo == null) {
                            pcaNo = sys.getNextNo(this.table, "ID", "", "R", 7);
                        }

                        SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                        SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                        java.util.Date efDate = originalFormat.parse(this.efDate);
                        this.efDate = targetFormat.format(efDate);

                        String query = "INSERT INTO " + this.table + " "
                                + "(ID, REFNO, PCANO, PCADESC, "
                                + "PYEAR, PMONTH, EFDATE, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + id + ", "
                                + "'" + this.refNo + "', "
                                + "'" + pcaNo + "', "
                                + "'" + this.pcaDesc + "', "
                                + this.pYear + ", "
                                + this.pMonth + ", "
                                + "'" + this.efDate + "', "
                                + "'" + sys.getLogUser(session) + "', "
                                + "'" + sys.getLogDate() + "', "
                                + "'" + sys.getLogTime() + "', "
                                + "'" + sys.getClientIpAdr(request) + "'"
                                + ")";

                        pcaHdrCreated = stmt.executeUpdate(query);

                    } catch (SQLException e) {
                        e.getMessage();
                    } catch (Exception e) {
                        e.getMessage();
                    }
                }
            }

            return pcaHdrCreated;
        }

        public String getPcaEntries() {
            String html = "";
            Gui gui = new Gui();
            Sys sys = new Sys();

            if (sys.recordExists("VIEWPYPCADTLS", "REFNO = '" + this.refNo + "'")) {

                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>PCA No</th>";
                html += "<th>Staff No.</th>";
                html += "<th>Name</th>";
                html += "<th>Item No.</th>";
                html += "<th>Name</th>";
                html += "<th style = \"text-align: right;\">New Amount</th>";
                html += "<th style = \"text-align: right;\">Old Amount</th>";
                html += "<th style = \"text-align: right;\">Options</th>";
                html += "</tr>";

                Double sumNewAmount = 0.0;
                Double sumOldAmount = 0.0;

                try {

                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    Integer count = 1;

                    String query = "SELECT * FROM VIEWPYPCADTLS WHERE REFNO = '" + this.refNo + "'";

                    ResultSet rs = stmt.executeQuery(query);

                    while (rs.next()) {
                        Integer id = rs.getInt("ID");
                        String pcaNo = rs.getString("PCANO");
                        String pfNo = rs.getString("PFNO");
                        String fullName = rs.getString("FULLNAME");
                        String itemCode = rs.getString("ITEMCODE");
                        String itemName = rs.getString("ITEMNAME");
                        Integer approved = rs.getInt("APPROVED");
                        Double oldAmount = rs.getDouble("OLDAMOUNT");
                        Double newAmount = rs.getDouble("NEWAMOUNT");

                        String editLink = gui.formHref("onclick = \"pca.editPcaDtls(" + id + ");\"", request.getContextPath(), "", "edit", "edit", "", "");
                        String removeLink = gui.formHref("onclick = \"pca.purge(" + id + ", '" + itemName + "');\"", request.getContextPath(), "", "delete", "delete", "", "");
                        String lockLink = gui.formHref("onclick = \"alert('locked');\"", request.getContextPath(), "lock.png", "", "locked", "", "");

                        String opts = "";

                        if (approved == 1) {
                            opts = lockLink;
                        } else {
                            opts = editLink + " || " + removeLink;
                        }

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + pcaNo + "</td>";
                        html += "<td>" + pfNo + "</td>";
//                    html += "<td>"+ fullName +"</td>";
                        html += "<td>" + sys.shorten(fullName, 12) + "</td>";
                        html += "<td>" + itemCode + "</td>";
                        html += "<td>" + sys.shorten(itemName, 12) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(newAmount.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(oldAmount.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + opts + "</td>";
                        html += "</tr>";

                        sumNewAmount = sumNewAmount + newAmount;
                        sumOldAmount = sumOldAmount + oldAmount;

                        count++;
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "<tr>";
                html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"6\">Total</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\">" + sys.numberFormat(sumNewAmount.toString()) + "</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\">" + sys.numberFormat(sumOldAmount.toString()) + "</td>";
                html += "<td>&nbsp;</td>";
                html += "</tr>";

                html += "</table>";

            } else {
                html += "No PCA items record found.";
            }

            return html;
        }

        public Object editPcaDtls()  throws Exception {
            JSONObject obj = new JSONObject();
            Sys sys = new Sys();
            Gui gui = new Gui();
            if (sys.recordExists("PYPCADTLS", "ID = " + this.sid)) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query = "SELECT * FROM VIEWPYPCADTLS WHERE ID = " + this.sid + "";
                    ResultSet rs = stmt.executeQuery(query);

                    while (rs.next()) {
                        String id = rs.getString("ID");
                        String pfNo = rs.getString("PFNO");
                        String fullName = rs.getString("FULLNAME");
                        String itemCode = rs.getString("ITEMCODE");
                        String itemName = rs.getString("ITEMNAME");
                        String newAmount = rs.getString("NEWAMOUNT");
                        String oldAmount = rs.getString("OLDAMOUNT");
                        String lineDesc = rs.getString("LINEDESC");

                        obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                        obj.put("staffNo", pfNo);
                        obj.put("fullName", fullName);
                        obj.put("item", itemCode);
                        obj.put("itemName", itemName);
                        obj.put("newAmount", newAmount);
                        obj.put("oldAmount", oldAmount);
                        obj.put("lineDesc", lineDesc);

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
                    String query = "DELETE FROM PYPCADTLS WHERE ID = " + this.id;

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