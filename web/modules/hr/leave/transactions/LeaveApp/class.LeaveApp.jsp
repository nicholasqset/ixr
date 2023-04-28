<%@page import="org.json.JSONObject"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.LocalDate"%>
<%@page import="com.qset.hr.LeaveSchedule"%>
<%@page import="com.qset.hr.LeaveType"%>
<%@page import="com.qset.hr.StaffProfile"%>
<%@page import="java.sql.SQLException"%>
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

final class LeaveApp{
    HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
    String table            = this.comCode+".HRLVAPPS";
    String view             = this.comCode+".VIEWHRLVAPPS";
    
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        
    String pfNo             = request.getParameter("staff");
    Integer pYear           = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    String lvTypeCode       = request.getParameter("leaveType");
    Integer rosterNo        = request.getParameter("roster") != null && ! request.getParameter("roster").trim().equals("")? Integer.parseInt(request.getParameter("roster")): null;
    Integer aplDays         = request.getParameter("aplDays") != null && ! request.getParameter("aplDays").trim().equals("")? Integer.parseInt(request.getParameter("aplDays")): 0;
    String startDate        = request.getParameter("startDate");
    String endDate          = request.getParameter("endDate");
    String returnDate       = request.getParameter("returnDate");
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
        Integer recordCount = sys.getRecordCount(this.view, "");
        
        if(recordCount > 0){
        
            String gridSql;
            String filterSql        = "";
            Integer startRecord     = 0;
            Integer maxRecord       = 10;

            Integer maxRecordHidden = request.getParameter("maxRecord") != null? Integer.parseInt(request.getParameter("maxRecord")): null;
            Integer pageSize        = maxRecordHidden != null? maxRecordHidden: maxRecord;
            maxRecord               = maxRecordHidden != null? maxRecordHidden: maxRecord;

            HttpSession session     = request.getSession();
            session.setAttribute("maxRecord", maxRecord);

            String act              = request.getParameter("act");

            if(act != null){
                if(act.equals("find")){
                    String find = request.getParameter("find");
                    if(find != null){
                        session.setAttribute("startRecord", startRecord);

                        ArrayList<String> list = new ArrayList();

                        list.add("DOCNO");
                        list.add("PFNO");
                        list.add("FULLNAME");
                        list.add("LVTYPECODE");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                if(dbType.equals("postgres")){
                                    filterSql += " WHERE ( UPPER(CAST ("+ list.get(i) +" AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
                                }else{
                                    filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
                                }
                            }else{
                                if(dbType.equals("postgres")){
                                    filterSql += " OR ( UPPER(CAST ("+ list.get(i)+ " AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
                                }else{
                                    filterSql += " OR ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
                                }
                            }
                            filterSql += ")";
                        }
                    }
                }
            }

            Integer useGrid         = request.getParameter("maxRecord") != null? Integer.parseInt(request.getParameter("maxRecord")): null;
            String gridAction       = request.getParameter("gridAction");

            if(useGrid != null){
                if(gridAction.equals("gridNext")){
                    if (session.getAttribute("startRecord") != null) {
                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) >= startRecord){
                            session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) + pageSize);
                        }else{
                            session.setAttribute("startRecord", startRecord);
                        }

                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) == recordCount){
                            session.setAttribute("startRecord", startRecord);
                        }

                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) > recordCount){
                            session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) - pageSize);
                        }
                    }else{
                        session.setAttribute("startRecord", startRecord);
                    }
                }else if(gridAction.equals("gridPrevious")){
                    if (session.getAttribute("startRecord") != null) {
                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) > startRecord){
                            session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) - pageSize);
                        }else{
                            session.setAttribute("startRecord", startRecord);
                        }
                    }else{
                        session.setAttribute("startRecord", startRecord);
                    }
                }else if(gridAction.equals("gridFirst")){
                    session.setAttribute("startRecord", startRecord);
                }else if(gridAction.equals("gridLast")){
                    session.setAttribute("startRecord", recordCount - pageSize);
                }else{
                    session.setAttribute("startRecord", 0);
                }
            }else{
                session.setAttribute("startRecord", 0);
            }

            String orderBy = "PFNO ";
            String limitSql = "";

            switch(dbType){
                case "mysql":
                    limitSql = "LIMIT "+ session.getAttribute("startRecord")+ " , "+ session.getAttribute("maxRecord");
                    break;
                case "postgres":
                    limitSql = "OFFSET "+ session.getAttribute("startRecord")+ " LIMIT "+ session.getAttribute("maxRecord");
                    break;
            }

            gridSql = "SELECT DISTINCT PFNO, FULLNAME FROM "+ this.view+ " "+ filterSql+ " ORDER BY "+ orderBy+ limitSql;

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(gridSql);

                Integer startRecordHidden = Integer.parseInt(session.getAttribute("startRecord").toString()) + Integer.parseInt(session.getAttribute("maxRecord").toString());

                html += gui.formInput("hidden", "maxRecord", 10, session.getAttribute("maxRecord").toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                html += "<table class = \"grid\" width=\"100%\" cellpadding=\"1\" cellspacing=\"0\" border=\"0\">";

                html += "<tr>";
                html += "<th>#</th>";
//                html += "<th>Document No</th>";
                html += "<th>Staff No</th>";
                html += "<th>Name</th>";
//                html += "<th>Year</th>";
//                html += "<th>Leave Type</th>";
//                html += "<th>Applied Days</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

//                    Integer id          = rs.getInt("ID");
//                    String docNo        = rs.getString("DOCNO");
                    String pfNo         = rs.getString("PFNO");
                    String fullName     = rs.getString("FULLNAME");
//                    Integer pYear       = rs.getInt("PYEAR");
//                    String lvTypeName   = rs.getString("LVTYPENAME");
//                    Integer aplDays     = rs.getInt("APLDAYS");
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"leaveApp.editModuleSb('"+ pfNo+ "')\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
//                    html += "<td>"+ docNo+ "</td>";
                    html += "<td>"+ pfNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
//                    html += "<td>"+ pYear+ "</td>";
//                    html += "<td>"+ lvTypeName+ "</td>";
//                    html += "<td>"+ aplDays+ "</td>";
                    html += "<td>"+ edit+ "</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
            }catch(SQLException e){
                html += e.getMessage();
            }catch(Exception e){
                html += e.getMessage();
            }
        }else{
            html += "No records found.";
        }
        
        return html;
    }
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getAppTab()+ "</div>";
        html += "</div>";
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Leave Application\'), 0, 625, 145, Array(true));";
        html += "</script>";
        
        html += "<div style = \"padding-top: 20px; border: 0;\">&nbsp;</div>";
        
        html += "<div id = \"dhtmlgoodies_tabView2\">";
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getDtlsTab()+ "</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getAttachTab()+ "</div>";
        html += "</div>";
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView2\', Array(\'Details\', \'Attachments\'), 0, 625, 104, Array(false, true));";
        html += "</script>";
        
        html += "<div style = \"padding-top: 22px; border: 0;\">&nbsp;</div>";
        
        html += "<div id = \"dvLvApEntries\">"+ this.getLvApEntries()+ "</div>";
        
        html += "<div style = \"padding-left: 10px; padding-top: 5px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"leaveApp.save('pfNo pYear leaveType  aplDays startDate endDate returnDate'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        return html;
    }
    
    public String getAppTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        String fullName    = "";
        
        if(this.pfNo != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT DISTINCT PFNO, FULLNAME FROM "+ this.view+ " WHERE PFNO = '"+ this.pfNo+ "'";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.pfNo       = rs.getString("PFNO");		
                    fullName        = rs.getString("FULLNAME");	
//                    this.pYear      = rs.getInt("PYEAR");
//                    this.aplDays    = rs.getInt("APLDAYS");
//                    this.lvTypeCode = rs.getString("LVTYPECODE");
//                    java.util.Date startDate = originalFormat.parse(this.startDate);
//                    this.startDate = targetFormat.format(startDate);
                    
                }
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        String defaultDate = sys.getLogDate();
        
        try{
            java.util.Date today = originalFormat.parse(defaultDate);
            defaultDate = targetFormat.format(today);
        }catch(ParseException e){
            html += e.getMessage();
        }catch (Exception e){
            html += e.getMessage();
        }
        
        html += "<div id = \"dvLvEntryId\">";
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+ this.id, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"17%\">"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("pfNo", " Staff No.")+ "</td>";
        html += "<td width = \"33%\">"+ gui.formAutoComplete("staff", 13, this.pfNo != null? ""+ this.pfNo: "", "leaveApp.searchStaff", "pfNo", this.pfNo != null? ""+ this.pfNo: "")+ "</td>";
	
	html += "<td width = \"17%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdStaffName\">"+ fullName+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Leave Year")+ "</td>";
        html += "<td colspan = \"3\">"+ gui.formSelect("pYear", this.comCode+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? "": ""+sys.getPeriodYear(this.comCode), "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"view-pim-calendar.png", "", "")+ gui.formLabel("leaveType", " Leave Type")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("leaveType", this.comCode+".HRLVTYPES", "LVTYPECODE", "LVTYPENAME", null, "", "", "onchange = \"leaveApp.getLvTypeDtls();\"", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td id = \"tdRosterNoLb\">&nbsp;</td>";
        html += "<td id = \"tdRosterNoFd\" colspan=\"3\">&nbsp;</td>";
        html += "</tr>";
        
        html += "<tr>";
        html += "<td>&nbsp;</td>";
        html += "<td id = \"tdLvTypeDtls\" colspan=\"3\"><div id = \"dvLvTypeDtls\">&nbsp;</div></td>";
        html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchStaff(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.pfNo = (request.getParameter("pfNo") != null && ! request.getParameter("pfNo").trim().equals(""))? request.getParameter("pfNo"): null;
        
        html += gui.getAutoColsSearch("HRSTAFFPROFILE", "PFNO, FULLNAME", "", this.pfNo);
        
        return html;
    }
    
    public JSONObject getStaffDtls() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.pfNo == null || this.pfNo.trim().equals("")){
            obj.put("success", 0);
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            StaffProfile staffProfile = new StaffProfile(this.pfNo, this.comCode);
            
            obj.put("staffName", staffProfile.fullName);
            
            obj.put("success", 1);
            obj.put("message", "Staff No '"+ this.pfNo+ "' details successfully retrieved.");
            
        }
        return obj;
    }
    
    public String getLvTypeDtls(){
        String html = "";
        
        LeaveType leaveType = new LeaveType(this.lvTypeCode);
        
        if(leaveType.lvType.equals("AN")){
            
            LeaveSchedule leaveSchedule = new LeaveSchedule(this.pfNo, this.pYear, this.lvTypeCode);
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
            
            html += "<tr>";
            html += "<td>"
                    + "<span class = \"fade\">Bal B/f:</span> "+ leaveSchedule.balBf
                    + ", <span class = \"fade\">Entitlement:</span> "+ leaveSchedule.entitlement
                    + ", <span class = \"fade\">Taken:</span> "+ leaveSchedule.taken
                    + ", <span class = \"fade\">Total Bal:</span> "+ leaveSchedule.balTotal
                    + "</td>";
            html += "</tr>";
            
            html += "</table>";
        }
        
        return html;
    }
    
    public String getDtlsTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        String defaultDate = sys.getLogDate();
        
        try{
            java.util.Date today = originalFormat.parse(defaultDate);
            defaultDate = targetFormat.format(today);
        }catch(ParseException e){
            html += e.getMessage();
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"17%\" nowrap>"+ gui.formIcon(request.getContextPath(),"pencil.png", "", "")+ gui.formLabel("aplDays", " Applied Days")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formInput("text", "aplDays", 10, "", "", "")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("startDate", " Start Date")+ "</td>";
        html += "<td colspan = \"3\">";
        html += gui.formDateTime(request.getContextPath(), "startDate", 12, defaultDate, false, "");
        html += "&nbsp;";
        html += gui.formHref("onclick = \"leaveApp.getDates();\"", request.getContextPath(), "", "...", "Calculate Dates", "", "smallButton");
        html += "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("endDate", " End Date")+ "</td>";
	html += "<td colspan = \"3\">"+ gui.formDateTime(request.getContextPath(), "endDate", 12, "", false, "disabled")+ "</td>";
        html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("returnDate", " Return Date")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formDateTime(request.getContextPath(), "returnDate", 12, "", false, "disabled")+ "</td>";
        html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public JSONObject getDates() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        
        try{
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
//            formatter = formatter.withLocale( putAppropriateLocaleHere );  // Locale specifies human language for translating, and cultural norms for lowercase/uppercase and abbreviations and such. Example: Locale.US or Locale.CANADA_FRENCH
            
            SimpleDateFormat osf = new SimpleDateFormat("dd-MM-yyyy");
            SimpleDateFormat nsf = new SimpleDateFormat("yyyy-MM-dd");
            
            java.util.Date startDate = osf.parse(this.startDate);
            this.startDate     = nsf.format(startDate);
            
//            LocalDate date = LocalDate.parse(system.getLogDate(), formatter);
            LocalDate date = LocalDate.parse(this.startDate, formatter);
            
            if(this.aplDays > 0){
//                LocalDate endDate       = system.getLEndDateWoW(date, (this.aplDays - 1));
//                LocalDate returnDate    = system.getLEndDateWoW(date, this.aplDays);
                
                LocalDate endDate       = sys.getLEndDateWoWH(date, (this.aplDays - 1));
                LocalDate returnDate    = sys.getLEndDateWoWH(date, this.aplDays);

                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

                java.util.Date endDate_     = originalFormat.parse(endDate.toString());
                java.util.Date returnDate_  = originalFormat.parse(returnDate.toString());
                
                String endDateF     = targetFormat.format(endDate_);
                String returnDateF  = targetFormat.format(returnDate_);

                obj.put("endDate", endDateF);
                obj.put("returnDate", returnDateF);

                obj.put("success", 1);
                obj.put("message", "Dates successfully retrieved.");
            }else{
                obj.put("success", 0);
                obj.put("message", "Invalid aplDays");
            }
        }catch(Exception e){
            obj.put("success", 0);
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public String getAttachTab(){
        String html = "";
        
//        Gui gui = new Gui();
//        Sys sys = new Sys();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "</table>";
        
        return html;
    }
    
    public JSONObject save() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        String query = "";
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            Integer saved = 0;

            SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
            SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

            java.util.Date startDate    = originalFormat.parse(this.startDate);
            java.util.Date endDate      = originalFormat.parse(this.endDate);
            java.util.Date returnDate   = originalFormat.parse(this.returnDate);
            
            this.startDate  = targetFormat.format(startDate);
            this.endDate    = targetFormat.format(endDate);
            this.returnDate = targetFormat.format(returnDate);

            LeaveType leaveType = new LeaveType(this.lvTypeCode);
            LeaveSchedule leaveSchedule = new LeaveSchedule(this.pfNo, this.pYear, this.lvTypeCode);
            
            Integer rts = 1;
            String msg = "";
            
            if(leaveType.lvType.equals("AN")){
                if(leaveSchedule.balTotal <= 0){
                    rts = 0;
                    msg = "Invalid leave days";
                }
            }
            
            if(rts == 1){
                if(this.id == null){
                    Integer id = sys.generateId(this.table, "ID");
                    String docNo = sys.getNextNo(this.table, "ID", "", "LV", 7);

                    query = "INSERT INTO "+ this.table+ " "
                            + "("
                            + "ID, DOCNO, PFNO, PYEAR, LVTYPECODE, ROSTERNO, "
                            + "APLDAYS, STARTDATE, ENDDATE, RETURNDATE, "
                            + "BALBF, FORFEITED, ENTITLEMENT, TAKEN, BALTOTAL, APRDAYS, "
                            + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                            + ")"
                            + "VALUES"
                            + "("
                            + id+ ", "
                            + "'"+ docNo+ "', "
                            + "'"+ this.pfNo+ "', "
                            + this.pYear+ ", "
                            + "'"+ this.lvTypeCode+ "', "
                            + this.rosterNo+ ", "
                            + this.aplDays+ ", "
                            + "'"+ this.startDate+ "', "
                            + "'"+ this.endDate+ "', "
                            + "'"+ this.returnDate+ "', "
                            + leaveSchedule.balBf+ ", "
                            + leaveSchedule.forfeited+ ", "
                            + leaveSchedule.entitlement+ ", "
                            + leaveSchedule.taken+ ", "
                            + leaveSchedule.balTotal+ ", "
                            + this.aplDays+ ", "
                            + "'"+ sys.getLogUser(session)+"', "
                            + "'"+ sys.getLogDate()+ "', "
                            + sys.getLogTime()+ ", "
                            + "'"+ sys.getClientIpAdr(request)+ "'"
                            + ")";
                }else{
                    query = "UPDATE "+ this.table+ " SET "
                            + "APLDAYS          = "+ this.aplDays+ ", "
                            + "STARTDATE        = '"+ this.startDate+ "', "
                            + "ENDDATE          = '"+ this.endDate+ "', "
                            + "RETURNDATE       = '"+ this.returnDate+ "', "
                            + "APRDAYS          = "+ this.aplDays+ ", "
                            + "AUDITUSER        = '"+ sys.getLogUser(session)+"', "
                            + "AUDITDATE        = '"+ sys.getLogDate()+ "', "
                            + "AUDITTIME        = '"+ sys.getLogTime()+ "', "
                            + "AUDITIPADR       = '"+ sys.getClientIpAdr(request)+ "'"
                            + "WHERE ID         = "+ this.id;
                }

                saved = stmt.executeUpdate(query);

                if(saved == 1){
                    obj.put("success", 1);
                    obj.put("message", "Entry successfully made.");
                }else{
                    obj.put("success", 0);
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }
            }else{
                obj.put("success", 0);
                obj.put("message", msg);
            }
        }catch (Exception e){
            obj.put("success", 0);
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public String getLvApEntries(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(this.comCode+".VIEWHRLVAPPS", "PFNO = '"+ this.pfNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Document No.</th>";
            html += "<th style = \"text-align: left;\">Applied Days</th>";
            html += "<th>Start Date</th>";
            html += "<th>Return Date</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM qset.VIEWHRLVAPPS WHERE PFNO = '"+ this.pfNo+ "' ORDER BY DOCNO";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    
                    String docNo        = rs.getString("DOCNO");
                    Integer aplDays     = rs.getInt("aplDays");
                    String startDate    = rs.getString("STARTDATE");
                    String returnDate   = rs.getString("RETURNDATE");
                    
                    java.util.Date startDate_ = originalFormat.parse(startDate);
                    startDate = targetFormat.format(startDate_);
                    
                    java.util.Date returnDate_ = originalFormat.parse(returnDate);
                    returnDate = targetFormat.format(returnDate_);
                    
                    String editLink     = gui.formHref("onclick = \"leaveApp.editLvApDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"leaveApp.purge("+ id+ ", '"+ docNo+ "');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    
                    String opts = "";
                    opts = editLink+ " || "+ removeLink;
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ docNo+ "</td>";
                    html += "<td style = \"text-align: left;\">"+ aplDays +"</td>";
                    html += "<td>"+ startDate+ "</td>";
                    html += "<td>"+ returnDate+ "</td>";
                    
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    count++;
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "</table>";
            
        }else{
            html += "No leave application record found.";
        }
        
        return html;
    }
    
    public JSONObject editLvApDtls() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists(this.table, "ID = "+ this.id +"")){
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM qset.VIEWHRLVAPPS WHERE ID = "+ this.id +" ";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String docNo        = rs.getString("DOCNO");
                    String pYear        = rs.getString("PYEAR");
                    String lvTypeCode   = rs.getString("LVTYPECODE");
                    String aplDays      = rs.getString("APLDAYS");
                    
                    String startDate    = rs.getString("STARTDATE");
                    String endDate      = rs.getString("ENDDATE");
                    String returnDate   = rs.getString("RETURNDATE");
                    
                    java.util.Date startDate_ = originalFormat.parse(startDate);
                    startDate = targetFormat.format(startDate_);
                    
                    java.util.Date endDate_ = originalFormat.parse(endDate);
                    endDate = targetFormat.format(endDate_);
                    
                    java.util.Date returnDate_ = originalFormat.parse(returnDate);
                    returnDate = targetFormat.format(returnDate_);
                    
                    obj.put("idUi", gui.formInput("hidden", "id", 15, id, "", ""));
                    obj.put("docNo", docNo);
                    obj.put("pYear", pYear);
                    obj.put("leaveType", lvTypeCode);
                    obj.put("aplDays", aplDays);
                    obj.put("startDate", startDate);
                    obj.put("endDate", endDate);
                    obj.put("returnDate", returnDate);
                    
                    obj.put("success", 1);
                    obj.put("message", "Record retrieved successfully.");
                    
                }
            }catch (SQLException e){
                obj.put("success", 0);
                obj.put("message", e.getMessage());
            }catch (Exception e){
                obj.put("success", 0);
                obj.put("message", e.getMessage());
            }
        }else{
            obj.put("success", 0);
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }
        
        return obj;
    }
    
    public JSONObject purge() throws Exception{
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+ this.table+ " WHERE ID = "+ this.id;
            
                Integer purged = stmt.executeUpdate(query);
                if(purged == 1){
                    obj.put("success", 1);
                    obj.put("message", "Entry successfully deleted.");
                }else{
                    obj.put("success", 0);
                    obj.put("message", "An error occured while deleting record.");
                }
            }else{
                obj.put("success", 0);
                obj.put("message", "An unexpected error occured while deleting record.");
            }
            
        }catch (Exception e){
            obj.put("success", 0);
            obj.put("message", e.getMessage());
        }
         
         return obj;
    }
    
}

%>