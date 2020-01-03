<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.gui.Gui"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class StaffExempt{
    HttpSession session = request.getSession();
    String table        = session.getAttribute("comCode")+".PYSTAFFEXEMPT";
    String view         = session.getAttribute("comCode")+".VIEWPYSTAFFEXEMPT";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String itemCode     = request.getParameter("item");
    String pfNo         = request.getParameter("staff");
    Integer exempt      = request.getParameter("exempt") != null? 1: null;
    
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

                        list.add("ITEMCODE");
                        list.add("ITEMNAME");
                        list.add("PFNO");
//                        list.add("EXEMPT");
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

//            gridSql = "SELECT * FROM "+this.view+" "+filterSql+" ORDER BY ITEMCODE LIMIT "
//                    + session.getAttribute("startRecord")
//                    + " , "
//                    + session.getAttribute("maxRecord");
            
            String orderBy = "ITEMCODE ";
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
                html += "<th>Item Code</th>";
                html += "<th>Name </th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String pfNo         = rs.getString("PFNO");
                    String fullName     = rs.getString("FULLNAME");
                    String itemCode     = rs.getString("ITEMCODE");
                    String itemName     = rs.getString("ITEMNAME");
                    

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ pfNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "<td>"+ itemCode+ "</td>";
                    html += "<td>"+ itemName+ "</td>";
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
        
        String fullName = "";
        String itemName = "";
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.view+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.itemCode       = rs.getString("ITEMCODE");		
                    this.pfNo           = rs.getString("PFNO");	
                    this.exempt         = rs.getInt("EXEMPT");	
                    fullName            = rs.getString("FULLNAME");
                    itemName            = rs.getString("ITEMNAME");
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
        
        html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "user-properties.png", "", "")+" "+gui.formLabel("staff", "Staff")+"</td>";
	html += "<td>"+ gui.formAutoComplete("staff", 13, this.id != null? ""+ this.pfNo: "", "staffExempt.searchStaff", "pfNo", this.id != null? ""+ this.pfNo: "")+ " <span id = \"spStaffName\">"+ fullName+ "</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+" "+gui.formLabel("item", "Transaction")+"</td>";
	html += "<td>"+ gui.formAutoComplete("item", 13, this.id != null? ""+ this.itemCode: "", "staffExempt.searchItem", "itemCode", this.id != null? ""+ this.itemCode: "")+ " <span id = \"spItemName\">"+ itemName+ "</span></td>";
	html += "</tr>";
        
//        html += "<tr>";
//	html += "<td>"+ gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+ gui.formLabel("exempt", " Exempt")+"</td>";
//	html += "<td>"+ gui.formCheckBox("exempt", (this.id != null && this.exempt == 1)? "checked": "", null, "", "", "")+"</td>";
//	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"staffExempt.save('item staff');\"", "");
        if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"staffExempt.purge("+this.id+",'"+this.itemCode+"');\"", "");
        }
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
        
        html += gui.getAutoColsSearch(session.getAttribute("comCode")+".HRSTAFFPROFILE", "PFNO, FULLNAME", "", this.pfNo);
        
        return html;
    }
    
    public Object getStaffDtls(){
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
    
    public String searchItem(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.itemCode = (request.getParameter("itemCode") != null && ! request.getParameter("itemCode").trim().equals(""))? request.getParameter("itemCode"): null;
        
        html += gui.getAutoColsSearch(session.getAttribute("comCode")+".VIEWITEMS", "ITEMCODE, ITEMNAME", "", this.itemCode);
        
        return html;
    }
    
    public Object getItemDtls(){
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        
        if(this.itemCode == null || this.itemCode.trim().equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            String itemName = sys.getOne(session.getAttribute("comCode")+".VIEWITEMS", "ITEMNAME", "ITEMCODE = '"+ this.itemCode+ "'");
            
            obj.put("itemName", itemName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Item Code '"+ this.itemCode+ "' details successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object save(){
        
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
                    + "(ID, ITEMCODE, PFNO, EXEMPT)"
                    + "VALUES"
                    + "("
                    + id+","
                    + "'"+this.itemCode+"', "
                    + "'"+this.pfNo+"', "
                    + ""+this.exempt+" "
                    + ")";
                
            }else{
                
                query = "UPDATE "+this.table+" SET "
                    + "ITEMCODE     = '"+this.itemCode+"', "
                    + "PFNO         = '"+this.pfNo+"', "
                    + "EXEMPT       = "+this.exempt+" "
                    + "WHERE ID     = "+this.id;
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