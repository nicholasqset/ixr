<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.finance.FinConfig"%>
<%@page import="bean.medical.HMStaffProfile"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.medical.PatientProfile"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class OutPatients{
//    String table    = "HMTRIAGE";
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
    String table        = comCode+".HMTRIAGE";
    String view     = comCode+".VIEWNURSEOPDS";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String regNo            = request.getParameter("regNo");
    String regType          = "";
    String ptNo             = "";
    String drNo             = "";
    String nrNo             = "";
    
    String pulseRate        = request.getParameter("pulseRate");
    String bloodPressure    = request.getParameter("bloodPressure");
    Double temperature      = request.getParameter("temperature") != null? Double.parseDouble(request.getParameter("temperature")): 0.00;
    String respiration      = request.getParameter("respiration");
    Double height           = request.getParameter("height") != null? Double.parseDouble(request.getParameter("height")): 0.00;
    Double weight           = request.getParameter("weight") != null? Double.parseDouble(request.getParameter("weight")): 0.00;
    
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

                        list.add("REGNO");
                        list.add("PTNO");
                        list.add("FULLNAME");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                if(dbType.equals("postgres")){
                                    filterSql += " WHERE ( UPPER(CAST ("+ list.get(i) +" AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
                                }else{
                                    filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
                                }
                            }else{
                                if(dbType.equals("postgres")){
                                    filterSql += " OR ( UPPER(CAST ("+ list.get(i) +" AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
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

            String orderBy = "REGNO DESC ";
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
                html += "<th>Reg No</th>";
                html += "<th>Reg Type</th>";
                html += "<th>Patient No</th>";
                html += "<th>Patient Name</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String regNo        = rs.getString("REGNO");
                    String regType      = rs.getString("REGTYPE");
                    String ptNo         = rs.getString("PTNO");
                    String fullName     = rs.getString("FULLNAME");

                    String regTypeLbl = "Unknown";

                    if(regType.equals("N")){
                        regTypeLbl = "New Patient";
                    }else if(regType.equals("R")){
                        regTypeLbl = "Return Patient";
                    }

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "view", "view", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+count+"</td>";
                    html += "<td>"+regNo+"</td>";
                    html += "<td>"+regTypeLbl+"</td>";
                    html += "<td>"+ptNo+"</td>";
                    html += "<td>"+fullName+"</td>";
                    html += "<td>"+edit+"</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
            }catch (Exception e){
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
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getProfileTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getHistoryTab()+"</div>";
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getVitalParamTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style = \"padding-left: 10px; padding-top: 40px; border: 0;\" >";
        
        html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"dashboard.save('bloodPressure');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Back", "arrow-left.png", "onclick = \"module.getGrid();\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Profile\', \'History\', \'Vital Parameters\'), 0, 625, 350, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getProfileTab(){
        String html = "";
        Gui gui = new Gui();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;
        
        String drNo = "";
        String drName = "";
        String nrNo = "";
        String nrName = "";
        
        try{
            stmt = conn.createStatement();
            String query = "SELECT * FROM "+this.view+" WHERE ID = "+this.id;
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.regNo      = rs.getString("REGNO");		
                this.regType    = rs.getString("REGTYPE");		
                this.ptNo       = rs.getString("PTNO");		
                drNo            = rs.getString("DRNO");		
                drName          = rs.getString("DRNAME");		
                nrNo            = rs.getString("NRNO");		
                nrName          = rs.getString("NRNAME");
            }
        }catch (Exception e){
            html += e.getMessage();
        }
        
        html += gui.formInput("hidden", "id", 15, ""+this.id, "", "");
          
        PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);
        
        String regTypeLbl = "Unknown";
                    
        if(this.regType.equals("N")){
            regTypeLbl = "New Patient";
        }else if(this.regType.equals("R")){
            regTypeLbl = "Return Patient";
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"22%\" class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" Registration No.</td>";
        html += "<td >"+this.regNo + gui.formInput("hidden", "regNo", 15, this.regNo, "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\"  nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" Registration Type</td>";
	html += "<td>"+regTypeLbl +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"patient-male.png", "", "")+" Patient</td>";
	html += "<td nowrap>"+this.ptNo + " - " + patientProfile.fullName + gui.formInput("hidden", "ptNo", 15, ptNo, "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"gender.png", "", "")+" Gender</td>";
	html += "<td>"+patientProfile.genderName+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "")+" Date of Birth</td>";
	html += "<td>"+patientProfile.dob+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"mobile-phone.png", "", "")+" Cellphone</td>";
	html += "<td>"+patientProfile.cellphone+"</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"doctor-male.png", "", "")+" Doctor</td>";
	html += "<td nowrap>"+drNo + " - " + drName +"</td>";
	html += "</tr>";
        
        html += "<tr>";
        html += "<td class = \"bold\">"+gui.formIcon(request.getContextPath(),"doctor-female.png", "", "")+" Nurse</td>";
	html += "<td nowrap>"+nrNo + " - " + nrName +"</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String getHistoryTab(){
        String html = "";
        Gui gui = new Gui();
        
        PatientProfile patientProfile = new PatientProfile(this.ptNo, this.comCode);
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"22%\" class = \"bold\">"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" Allergies</td>";
	html += "<td >"+ patientProfile.allergies +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" Warnings</td>";
	html += "<td >"+ patientProfile.warns +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" Family History</td>";
	html += "<td >"+ patientProfile.familyHist +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" Personal History</td>";
	html += "<td >"+ patientProfile.selfHist +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" Past Medical History</td>";
	html += "<td >"+ patientProfile.pastMedHist +"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td class = \"bold\" nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+" Social History</td>";
	html += "<td>"+ patientProfile.socialHist +"</td>";
	html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public String getVitalParamTab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(this.table, "REGNO = '"+this.regNo+"'")){
            
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt;

            try{
                stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE REGNO = '"+this.regNo+"'";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.pulseRate          = rs.getString("PULSERATE");	
                    this.bloodPressure      = rs.getString("BLOODPRESSURE");
                    this.temperature        = rs.getDouble("TEMPERATURE");
                    this.respiration        = rs.getString("RESPIRATION");
                    this.height             = rs.getDouble("HEIGHT");
                    this.weight             = rs.getDouble("WEIGHT");
                }
            }catch (Exception e){
                html += e.getMessage();
            }
            
        }else{
            this.pulseRate      = "";	
            this.bloodPressure  = "";
            this.respiration    = "";
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+gui.formLabel("pulseRate", " Pulse Rate")+"</td>";
	html += "<td >"+gui.formInput("text", "pulseRate", 15, this.pulseRate, "", "")+"<span class = \"fade\"> /min</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+gui.formLabel("bloodPressure", " Blood Pressure")+"</td>";
	html += "<td >"+gui.formInput("text", "bloodPressure", 15, this.bloodPressure, "", "")+"<span class = \"fade\"> mm of Hg</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+gui.formLabel("temperature", " Temperature")+"</td>";
	html += "<td >"+gui.formInput("text", "temperature", 15, ""+this.temperature, "", "")+"<span class = \"fade\"> C</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+gui.formLabel("respiration", " Respiration")+"</td>";
	html += "<td >"+gui.formInput("text", "respiration", 15, this.respiration, "", "")+"<span class = \"fade\"> /min</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+gui.formLabel("height", " Height")+"</td>";
	html += "<td >"+gui.formInput("text", "height", 15, ""+this.height, "", "")+"<span class = \"fade\"> cm</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+gui.formLabel("weight", " Weight")+"</td>";
	html += "<td >"+gui.formInput("text", "weight", 15, ""+this.weight, "", "")+"<span class = \"fade\"> Kg</span></td>";
	html += "</tr>";
        
        html += "</table>";
        
        return html;
    }
    
    public Object save() throws Exception{
        
        HttpSession session = request.getSession();
        
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt ;
        
        try{
            if(! sys.recordExists(this.table, "REGNO = '"+this.regNo+"'")){
                
                stmt = conn.createStatement();
            
                Integer id          = sys.generateId(this.table, "ID");
                String pulseRate    = sys.getNextNo(this.table, "ID", "", "RCP", 7);

                String query;

                query = "INSERT INTO "+this.table+" "
                    + "(ID, REGNO, PULSERATE, BLOODPRESSURE, TEMPERATURE, RESPIRATION, HEIGHT, WEIGHT, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR)"
                    + "VALUES"
                    + "("
                    + id+", "
                    + "'"+this.regNo+"', "
                    + "'"+this.pulseRate+"', "
                    + "'"+this.bloodPressure+"', "
                    + this.temperature+", "
                    + "'"+this.respiration+"', "
                    + "'"+this.height+"', "
                    + "'"+this.weight+"', "
                    + "'"+sys.getLogUser(session)+"', "
                    + "'"+sys.getLogDate()+"', "
                    + "'"+sys.getLogTime()+"', "
                    + "'"+sys.getClientIpAdr(request)+"'"
                    + ")";
                
                Integer saved = stmt.executeUpdate(query);

                if(saved == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");
                    
                    obj.put("pulseRate", pulseRate);
                    stmt.executeUpdate("UPDATE HMREGISTRATION SET TRIAGED = 1 WHERE REGNO = '"+this.regNo+"'");
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "Oops! An Un-expected error occured while saving record.");
                }
                
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Entry already made");
            }
            
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    
    
        
}

%>