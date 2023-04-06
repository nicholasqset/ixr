<%@page import="com.qset.hr.LeaveType"%>
<%@page import="com.qset.hr.StaffProfile"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class Schedule{
    String table        = "qset.HRLVSCHEDULE";
    String view         = "qset.VIEWHRLVSCHEDULE";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String pfNo         = request.getParameter("staff");
    Integer pYear       = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    String lvTypeCode   = request.getParameter("leaveType");
    Integer balBf       = (request.getParameter("balBf") != null && ! request.getParameter("balBf").trim().equals(""))? Integer.parseInt(request.getParameter("balBf")): 0;
    Integer forfeited   = (request.getParameter("forfeited") != null && ! request.getParameter("forfeited").trim().equals(""))? Integer.parseInt(request.getParameter("forfeited")): 0;
    Integer entitlement = (request.getParameter("entitlement") != null && ! request.getParameter("entitlement").trim().equals(""))? Integer.parseInt(request.getParameter("entitlement")): 0;
    Integer taken       = (request.getParameter("taken") != null && ! request.getParameter("taken").trim().equals(""))? Integer.parseInt(request.getParameter("taken")): 0;
    Integer balTotal    = (request.getParameter("balTotal") != null && ! request.getParameter("balTotal").trim().equals(""))? Integer.parseInt(request.getParameter("balTotal")): 0;
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
        Integer recordCount = system.getRecordCount(this.table, "");
        
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

                        list.add("PFNO");
                        list.add("FULLNAME");
                        list.add("PYEAR");
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

            gridSql = "SELECT * FROM "+ this.view+ " "+ filterSql+ " ORDER BY "+ orderBy+ limitSql;

            try{
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
                html += "<th>Staff No</th>";
                html += "<th>Name</th>";
                html += "<th>Year</th>";
                html += "<th>Balance B/f</th>";
                html += "<th>Entitlement</th>";
                html += "<th>Taken</th>";
                html += "<th>Balance Total</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String pfNo         = rs.getString("PFNO");
                    String fullName     = rs.getString("FULLNAME");
                    String pYear        = rs.getString("PYEAR");
                    String balBf        = rs.getString("BALBF");
                    String entitlement  = rs.getString("ENTITLEMENT");
                    String taken        = rs.getString("TAKEN");
                    String balTotal     = rs.getString("BALTOTAL");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ pfNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ pYear+ "</td>";
                    html += "<td>"+ balBf+ "</td>";
                    html += "<td>"+ entitlement+ "</td>";
                    html += "<td>"+ taken+ "</td>";
                    html += "<td>"+ balTotal+ "</td>";
                    html += "<td>"+ edit+ "</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
            }catch (SQLException e){
                html += e.getMessage();
            }
            catch (Exception e){
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
        Sys sys = new Sys();
        
        String fullName = "";
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.table+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.pfNo           = rs.getString("PFNO");		
                    this.pYear          = rs.getInt("PYEAR");	
                    this.lvTypeCode     = rs.getString("LVTYPECODE");
                    this.balBf          = rs.getInt("BALBF");
                    this.forfeited      = rs.getInt("FORFEITED");
                    this.entitlement    = rs.getInt("ENTITLEMENT");
                    this.taken          = rs.getInt("TAKEN");
                    this.balTotal       = rs.getInt("BALTOTAL");
                }
            }catch (SQLException e){
                html += e.getMessage();
            }
            catch (Exception e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 15, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\">";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "user-properties.png", "", "")+ gui.formLabel("staff", " Staff")+"</td>";
	html += "<td>"+ gui.formAutoComplete("staff", 13, this.id != null? ""+ this.pfNo: "", "schedule.searchStaff", "pfNo", this.id != null? ""+ this.pfNo: "")+ " <span id = \"spStaffName\">"+ fullName+ "</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Leave Year")+ "</td>";
	html += "<td>"+ gui.formSelect("pYear", "FNFISCALPRD", "PYEAR", "", "PYEAR DESC", this.id != null? "PYEAR = "+ this.pYear: "PYEAR = "+system.getPeriodYear(), this.id != null? ""+ this.pYear: ""+system.getPeriodYear(), "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"view-pim-calendar.png", "", "")+ gui.formLabel("leaveType", " Leave Type")+"</td>";
	html += "<td>"+ gui.formSelect("leaveType", "HRLVTYPES", "LVTYPECODE", "LVTYPENAME", null, "LVTYPE = 'AN'", this.id != null? this.lvTypeCode: "", "onchange = \"schedule.getEntitlement();\"", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"pencil.png", "", "")+ gui.formLabel("balBf", " Balance B/F")+"</td>";
        html += "<td>"+ gui.formInput("text", "balBf", 15, this.id != null? this.balBf+ "": "", "onkeyup = \"schedule.getTotalBal();\"", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"pencil.png", "", "")+ gui.formLabel("forfeited", " Forfeited")+"</td>";
        html += "<td>"+ gui.formInput("text", "forfeited", 15, this.id != null? this.forfeited+ "": "", "onkeyup = \"\"", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"pencil.png", "", "")+ gui.formLabel("entitlement", " Entitlement")+"</td>";
        html += "<td>"+ gui.formInput("text", "entitlement", 15, this.id != null? this.entitlement+ "": "", "onkeyup = \"schedule.getTotalBal();\"", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"pencil.png", "", "")+ gui.formLabel("taken", " Taken")+"</td>";
        html += "<td>"+ gui.formInput("text", "taken", 15, this.id != null? this.taken+ "": "", "onkeyup = \"schedule.getTotalBal();\"", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"pencil.png", "", "")+ gui.formLabel("balTotal", " Total Balance")+"</td>";
        html += "<td>"+ gui.formInput("text", "balTotal", 15, this.id != null? this.balTotal+ "": "", "onkeyup = \"\"", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"schedule.save('staff pYear leaveType balBf forfeited entitlement taken balTotal');\"", "");
//        if(this.id != null){
//            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"schedule.purge("+this.id+",'"+this.pYear+"');\"", "");
//        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
    public String searchStaff(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.pfNo = (request.getParameter("pfNo") != null && ! request.getParameter("pfNo").trim().equals(""))? request.getParameter("pfNo"): null;
        
        html += gui.getAutoColsSearch("HRSTAFFPROFILE", "PFNO, FULLNAME", "", this.pfNo);
        
        return html;
    }
    
    public Object getStaffDtls(){
        JSONObject obj = new JSONObject();
        
        if(this.pfNo == null || this.pfNo.trim().equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            StaffProfile staffProfile = new StaffProfile(this.pfNo);
            
            obj.put("staffName", staffProfile.fullName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Staff No '"+ this.pfNo+ "' details successfully retrieved.");
            
        }
        return obj;
    }
    
    public Object getEntitlement(){
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        StaffProfile staffProfile = new StaffProfile(this.pfNo);
        
        LeaveType leaveType = new LeaveType(this.lvTypeCode);
        
        if(leaveType.lvType.equals("AN")){
            String days_ = system.getOne("HRLVDAYS", "DAYS", "LVTYPECODE = '"+ this.lvTypeCode+ "' AND GRADECODE = '"+ staffProfile.gradeCode+ "'");

            if(days_ != null && !days_.trim().equals("")){
                obj.put("entitlement", days_);

                obj.put("success", new Integer(1));
                obj.put("message", "Entitlement successfully obtained.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
            }
        }else{
            obj.put("entitlement", "0");
            
            obj.put("success", new Integer(1));
            obj.put("message", "Entitlement successfully obtained.");
        }
        
        return obj;
    }
    
    public Object save(){        
        JSONObject obj = new JSONObject();
        HttpSession session = request.getSession();
        Sys sys = new Sys();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
             
            String query;
            Integer saved = 0;
            
            if(this.id == null){
                
                Integer id = system.generateId(this.table, "ID");
                
                query = "INSERT INTO "+ this.table+ " "
                        + "("
                        + "ID, PFNO, PYEAR, LVTYPECODE, "
                        + "BALBF, FORFEITED, ENTITLEMENT, TAKEN, BALTOTAL, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+ ","
                        + "'"+ this.pfNo+ "', "
                        + "'"+ this.pYear+ "', "
                        + "'"+ this.lvTypeCode+ "', "
                        + this.balBf+ ", "
                        + this.forfeited+ ", "
                        + this.entitlement+ ", "
                        + this.taken+ ", "
                        + this.balTotal+ ", "
                        + "'"+ system.getLogUser(session)+ "', "
                        + "'"+ system.getLogDate()+ "', "
                        + system.getLogTime()+ ", "
                        + "'"+ system.getClientIpAdr(request)+ "' "
                        + ")";
                
            }else{
                query = "UPDATE "+this.table+" SET "
//                        + "PFNO   = '"+ this.pfNo+ "', "
//                        + "PYEAR   = '"+ this.pYear+ "', "
//                        + "LVTYPECODE       = '"+ this.lvTypeCode+ "', "
                        + "BALBF        = "+ this.balBf+ ", "
                        + "FORFEITED    = "+ this.forfeited+ ", "
                        + "ENTITLEMENT  = "+ this.entitlement+ ", "
                        + "TAKEN        = "+ this.taken+ ", "
                        + "BALTOTAL     = "+ this.balTotal+ ", "
                        + "AUDITUSER    = '"+ system.getLogUser(session)+ "', "
                        + "AUDITDATE    = '"+ system.getLogDate()+ "', "
                        + "AUDITTIME    = '"+ system.getLogTime()+ "', "
                        + "AUDITIPADR   = '"+ system.getClientIpAdr(request)+ "' "
                        + "WHERE ID     = "+ this.id;
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
            }
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public Object purge(){
        JSONObject obj = new JSONObject();
         
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+this.table+" WHERE ID = "+this.id;
            
                Integer purged = stmt.executeUpdate(query);
                if(purged == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully deleted.");
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured while deleting record.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "An error occured while deleting record.");
            }
            
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
        return obj;
        
    }
    
}

%>