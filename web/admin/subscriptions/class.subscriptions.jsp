<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class Sub{
    String table        = "sys.subscriptions";
    String view         = "sys.viewsubscriptions";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
//    String pyear  = request.getParameter("pyear");
//    String amount     = request.getParameter("amount");
    
    public String getGrid(){
       String html = "";
        
        Gui gui = new Gui();
        
        Sys sys = new Sys();
        
        Integer recordCount = sys.getRecordCount(this.table, "");
        
        if(recordCount > 0){
            String gridSql;
            String filterSql = "";
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
                         
                        list.add("py_id");
                        list.add("comcode");
                        list.add("compname");
                        list.add("py_ref_no");
                        list.add("py_cellphone");
                        list.add("py_start_date");
                        list.add("py_end_date");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                filterSql += " WHERE ( UPPER(CAST("+list.get(i)+" AS character varying)) LIKE '%"+ find.toUpperCase()+ "%' ";
                            }else{
                                filterSql += " OR ( UPPER(CAST("+list.get(i)+" AS character varying)) LIKE '%"+ find.toUpperCase()+ "%' ";
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

           String orderBy = "py_start_date desc ";
           
                String limitSql = "";

                String dbType = ConnectionProvider.getDBType();

                switch(dbType){
                    case "mysql":
                        limitSql = "LIMIT "+ session.getAttribute("startRecord")+ " , "+ session.getAttribute("maxRecord");
                        break;
                    case "postgres":
                        limitSql = "OFFSET "+ session.getAttribute("startRecord")+ " LIMIT "+ session.getAttribute("maxRecord");
                        break;
                }

//                gridSql = "SELECT * FROM "+this.view+" ";
                
                gridSql = "SELECT * FROM "+this.view+" "+filterSql+" ORDER BY "+ orderBy+ limitSql;

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(gridSql);

                Integer startRecordHidden = Integer.parseInt(session.getAttribute("startRecord").toString()) + Integer.parseInt(session.getAttribute("maxRecord").toString());
               html +="<div class=\"col-md-12\">";
                html += gui.formInput("hidden", "maxRecord", 10, session.getAttribute("maxRecord").toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");
                html +="<h4>Subscriptions</h4>";

                html += "<table class = \"grid table\"  cellpadding=\"2\" cellspacing=\"0\" border=\"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th nowrap>Company Code</th>";
                html += "<th>Name</th>";
                html += "<th nowrap>Ref #</th>";
                html += "<th>Cellphone</th>";
                html += "<th>Amount</th>";
                html += "<th>Active</th>";
                html += "<th>Date Start</th>";
                html += "<th>End</th>";
                html += "<th nowrap>Paybill #</th>";
                 html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;
                
                String paybillNo = "939537";

                while(rs.next()){
                    Integer id          = rs.getInt("py_id");
                    String comCode      = rs.getString("comcode");
                    String comname      = rs.getString("compname");
                    String refNo        = rs.getString("py_ref_no");
                    String cellphone    = rs.getString("py_cellphone");
                    String amount       = rs.getString("py_amount");
                    String active       = rs.getString("py_active");
                    String startDate    = rs.getString("py_start_date");
                    String endDate      = rs.getString("py_end_date");
                    String optFld4      = rs.getString("py_opt_fld4");
                    
                    if(optFld4 != null){
                        paybillNo = optFld4;
                    }

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+count+"</td>";
                    html += "<td>"+comCode+"</td>";
                    html += "<td>"+comname+"</td>";
                    html += "<td>"+refNo+"</td>";
                    html += "<td>"+cellphone+"</td>";
                    html += "<td>"+sys.numberFormat(amount)+"</td>";
                    html += "<td>"+active+"</td>";
                    html += "<td nowrap>"+startDate+"</td>";
                    html += "<td nowrap>"+endDate+"</td>";
                    html += "<td nowrap>"+paybillNo+"</td>";
                    html += "<td>"+edit+"</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
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
//        
//        Gui gui = new Gui();
//        
//       Connection conn = ConnectionProvider.getConnection();
//        Statement stmt = null;
//        
//        if(this.id != null){
//            
//            try{
//                stmt = conn.createStatement();
//                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
//                ResultSet rs = stmt.executeQuery(query);
//                while(rs.next()){
//                    this.id    = rs.getInt("id");		
//                    this.amount       = rs.getString("amount");		
//                    this.pyear       = rs.getString("pyear");		
//                }
//            }catch (SQLException e){
//
//            }
//        }
//        
//        
//        
//        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
//        
//        if(this.id != null){
//            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
//        }
//        
//        html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
//              
//        html += "<tr>";
//	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("pyear", "Periodic year")+"</td>";
//	
//        html += "<td>"+gui.formInput("text", "pyear", 30, this.pyear != null? this.pyear: "", "", "")+"</td>";
//	html += "</tr>";
//        
//        html += "<tr>";
//	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("amount", "Amount")+"</td>";
//	
//        html += "<td>"+gui.formInput("text", "amount", 30, this.amount != null? this.amount: "", "", "")+"</td>";
//	html += "</tr>";
//        
//        html += "<tr>";
//	html += "<td>&nbsp;</td>";
//	html += "<td>";
//	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"subs.save('country code name');\"", "");
//        if(this.id != null){
//            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"subs.purge("+this.id+",'"+this.id+"');\"", "");
//        }
//	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
//	html += "</td>";
//	html += "</tr>";
//         
//        html += "</table>";
//        html += gui.formEnd();
//                 html +="</div>";
        return html;
    }
    
    
    public Object save() throws Exception{
        
        Integer saved = 0;
        
        JSONObject obj = new JSONObject();
        
        Sys sys = new Sys();
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        
        try{
            stmt = conn.createStatement();
            
            Integer id;
                    
            id = sys.generateId(this.table, "ID");
            
            String query = "";
            
//            if(this.id == null){
//                query = "INSERT INTO sys.syssubscriptions(amount,pyear)VALUES('"+this.amount+"','"+this.pyear+"')";
//            }else{
//                
//                query = "UPDATE "+this.table+" SET amount='"+this.amount+"',pyear ='"+this.pyear+"'WHERE ID ='"+this.id+"'";
//            }
            
           saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
            }
            
        }catch (Exception e){
              obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());

        }       
        return obj;
   }
    
    public Object purge() throws Exception{
        
         Connection conn = ConnectionProvider.getConnection();
         Statement stmt = null;
         
         JSONObject obj = new JSONObject();
         
         try{
            stmt = conn.createStatement();
            
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
            
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
         return obj;
        
    }
    
}

%>