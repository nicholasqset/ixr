<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class ItemCharges{
    String table        = "HMITEMCHARGES";
    String view         = "VIEWHMITEMCHARGES";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    Integer pYear       = request.getParameter("pYear") != null && !request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth      = request.getParameter("pMonth") != null && !request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
    String itemCode     = request.getParameter("itemCode");
    Integer amount      = request.getParameter("amount") != null && !request.getParameter("amount").trim().equals("")? Integer.parseInt(request.getParameter("amount")): null;
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
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

                        ArrayList<String> list = new ArrayList<String>();

                        list.add("PYEAR");
                        list.add("PMONTH");
                        list.add("ITEMNAME");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+find+"%' ";
                            }else{
                                filterSql += " OR ( UPPER("+list.get(i)+") LIKE '%"+find+"%' ";
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
                }

            }else{
                if (session.getAttribute("startRecord") == null) {
                    session.setAttribute("startRecord", startRecord);
                }
            }

            gridSql = "SELECT * FROM "+this.view+" "+filterSql+" ORDER BY PYEAR DESC, PMONTH DESC, ITEMNAME LIMIT "
                    + session.getAttribute("startRecord")
                    + " , "
                    + session.getAttribute("maxRecord");

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
                html += "<th>Period Year</th>";
                html += "<th>Period Month</th>";
//                html += "<th>Item Code</th>";
                html += "<th>Item Name</th>";
                html += "<th>Amount</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String pYear        = rs.getString("PYEAR");
                    String pMonth       = rs.getString("PMONTH");
//                    String itemCode     = rs.getString("ITEMCODE");
                    String itemName     = rs.getString("ITEMNAME");
                    String amount       = rs.getString("AMOUNT");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ pYear+ "</td>";
                    html += "<td>"+ pMonth+ "</td>";
//                    html += "<td>"+ itemCode+ "</td>";
                    html += "<td>"+ itemName+ "</td>";
                    html += "<td>"+ amount+ "</td>";
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
        Sys sys = new Sys();
        
        if(this.id != null){
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.pYear      = rs.getInt("PYEAR");		
                    this.pMonth     = rs.getInt("PMONTH");		
                    this.itemCode   = rs.getString("ITEMCODE");		
                    this.amount     = rs.getInt("AMOUNT");
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("pYear", " Period Year")+"</td>";
        html += "<td>"+ gui.formSelect("pYear", "FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", this.id != null? ""+ this.pYear: ""+system.getPeriodYear(), "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("pMonth", " Period Month")+"</td>";
        html += "<td>"+ gui.formMonthSelect("pMonth", this.id != null? this.pMonth: system.getPeriodMonth(), "", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("itemCode", " Item")+"</td>";
        html += "<td>"+gui.formSelect("itemCode", "HMITEMS", "ITEMCODE", "ITEMNAME", "", "", this.id != null? this.itemCode: "", "", false)+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"coins.png", "", "")+ gui.formLabel("amount", " Amount")+"</td>";
	html += "<td>"+gui.formInput("text", "amount", 10, this.id != null? ""+ this.amount: "" , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"itemCharge.save('pYear pMonth itemCode amount');\"", "");
        if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"itemCharge.purge("+this.id+",'"+this.itemCode+"');\"", "");
        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
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
                Integer id = system.generateId(this.table, "ID");
                
                query = "INSERT INTO "+this.table+" "
                    + "(ID, PYEAR, PMONTH, ITEMCODE, AMOUNT)"
                    + "VALUES"
                    + "("
                    + id+ ","
                    + this.pYear+ ","
                    + this.pMonth+ ","
                    + "'"+this.itemCode+"',"
                    + this.amount+ ""
                    + ")";
            }else{
                
                query = "UPDATE "+this.table+" SET "
                    + "PYEAR        = "+ this.pYear+ ", "
                    + "PMONTH       = "+ this.pMonth+ ", "
                    + "ITEMCODE     = '"+ this.itemCode+ "', "
                    + "AMOUNT       = "+ this.amount+ " "
                    + "WHERE ID     = "+ this.id;
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An unexpected error occured while saving record");
            }
            
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        catch (Exception e){
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
        }
        catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
        return obj;
        
    }
    
}

%>