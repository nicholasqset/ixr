<%@page import="java.util.ArrayList"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class StaffBanks{
    HttpSession session = request.getSession();
    String table        = session.getAttribute("comCode")+".PYSTAFFBANKS";
    String view         = session.getAttribute("comCode")+".VIEWPYSTAFFBANKS";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String pfNo         = request.getParameter("staff");
    String bkBranchCode = request.getParameter("bankBranch");
    String accountNo    = request.getParameter("accountNo");
    Double payPercent   = request.getParameter("payPercent") != null && ! request.getParameter("payPercent").trim().equals("")? Double.parseDouble(request.getParameter("payPercent")): null;
    
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

                        ArrayList<String> list = new ArrayList<String>();

                        list.add("PFNO");
                        list.add("FULLNAME");
                        list.add("BKBRANCHCODE");
                        list.add("BKBRANCHNAME");
                        
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                if(dbType.equals("postgres")){
                                    filterSql += " WHERE ( UPPER(CAST ("+ list.get(i) +" AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
                                }else{
                                    filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
                                }
                            }else{
                                filterSql += " OR ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
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

//            gridSql = "SELECT * FROM "+this.view+" "+filterSql+" ORDER BY BKBRANCHCODE LIMIT "
//                    + session.getAttribute("startRecord")
//                    + " , "
//                    + session.getAttribute("maxRecord");
            
            String orderBy = "BKBRANCHCODE ";
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

                html += "<table class = \"grid\" width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" border = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>PF No</th>";
                html += "<th>Name</th>";
                html += "<th>Bank Branch</th>";
                html += "<th>Account No </th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String pfNo         = rs.getString("PFNO");
                    String fullName     = rs.getString("FULLNAME");
                    String bkBrachName  = rs.getString("BKBRANCHNAME");
                    String accountNo    = rs.getString("ACCOUNTNO");
                    
                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ pfNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ bkBrachName+ "</td>";
                    html += "<td>"+ accountNo+ "</td>";
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
        
        String fullName     = "";
        String bkBranchName = "";
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.view+ " WHERE ID = "+ this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    	
                    this.pfNo           = rs.getString("PFNO");	
                    this.bkBranchCode   = rs.getString("BKBRANCHCODE");	
                    this.accountNo      = rs.getString("ACCOUNTNO");	
                    this.payPercent     = rs.getDouble("PAYPERCENT");	
                    fullName            = rs.getString("FULLNAME");
                    bkBranchName        = rs.getString("BKBRANCHNAME");
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
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing=\"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "user-properties.png", "", "")+" "+gui.formLabel("staff", "Staff")+"</td>";
	html += "<td>"+ gui.formAutoComplete("staff", 13, this.id != null? ""+ this.pfNo: "", "staffBanks.searchStaff", "pfNo", this.id != null? ""+ this.pfNo: "")+ " <span id = \"spStaffName\">"+ fullName+ "</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+" "+gui.formLabel("bankBranch", "Bank Branch")+"</td>";
	html += "<td>"+ gui.formAutoComplete("bankBranch", 13, this.id != null? ""+ this.bkBranchCode: "", "staffBanks.searchBkBranch", "bkBranchCode", this.id != null? ""+ this.bkBranchCode: "")+ " <span id = \"spBkBranchName\">"+ bkBranchName+ "</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("accountNo", " Account No.")+"</td>";
	html += "<td>"+ gui.formInput("text", "accountNo", 25, this.id != null? this.accountNo: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("payPercent", " Pay Percentage")+"</td>";
	html += "<td>"+ gui.formInput("text", "payPercent", 15, this.id != null? this.payPercent+ "": "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"staffBanks.save('bankBranch staff payPercent');\"", "");
        if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"staffBanks.purge("+this.id+",'"+this.bkBranchCode+"');\"", "");
        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
    public String searchBkBranch(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.bkBranchCode = (request.getParameter("bkBranchCode") != null && ! request.getParameter("bkBranchCode").trim().equals(""))? request.getParameter("bkBranchCode"): null;
        
        html += gui.getAutoColsSearch(session.getAttribute("comCode")+".FNBANKBRANCH", "BKBRANCHCODE, BKBRANCHNAME", "", this.bkBranchCode);
        
        return html;
    }
    
    public Object getBkBranchDtls() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        
        if(this.bkBranchCode == null || this.bkBranchCode.trim().equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            String bkBrachName = sys.getOne(session.getAttribute("comCode")+".FNBANKBRANCH", "BKBRANCHNAME", "BKBRANCHCODE = '"+ this.bkBranchCode+ "'");
            
            obj.put("bkBrachName", bkBrachName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Bank Branch Code '"+ this.bkBranchCode+ "' details successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String searchStaff(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.pfNo = (request.getParameter("pfNo") != null && ! request.getParameter("pfNo").trim().equals(""))? request.getParameter("pfNo"): null;
        
        html += gui.getAutoColsSearch(session.getAttribute("comCode")+".HRSTAFFPROFILE", "PFNO, FULLNAME", "", this.pfNo);
        
        return html;
    }
    
    public Object getStaffDtls() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.pfNo == null || this.pfNo.trim().equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            StaffProfile staffProfile = new StaffProfile(this.pfNo, session.getAttribute("comCode").toString());
            
            obj.put("staffName", staffProfile.fullName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Staff No '"+ this.pfNo+ "' details successfully retrieved.");
            
        }
        
        return obj;
    }
    
    
    public Object save() throws Exception{
        
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
             
            String query;
            Integer saved = 0;
            
            if(this.id == null){
                
                Integer id = sys.generateId(this.table, "ID");
                
                query = "INSERT INTO "+this.table+" "
                    + "(ID, PFNO, BKBRANCHCODE, ACCOUNTNO, PAYPERCENT)"
                    + "VALUES"
                    + "("
                    + id+ ","
                    + "'"+ this.pfNo+ "', "
                    + "'"+ this.bkBranchCode+ "', "
                    + "'"+ this.accountNo+ "', "
                    + ""+this.payPercent+" "
                    + ")";
                
            }else{
                
                query = "UPDATE "+this.table+" SET "
                        + "PFNO             = '"+this.pfNo+"', "
                        + "BKBRANCHCODE     = '"+this.bkBranchCode+"', "
                        + "ACCOUNTNO        = '"+this.accountNo+"', "
                        + "PAYPERCENT       = "+this.payPercent+" "
                        + "WHERE ID         = "+this.id;
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
    
    public Object purge() throws Exception{
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