<%@page import="org.json.JSONObject"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.ar.AccountsReceivable"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class Batch{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    String table            = comCode+".ARPYBATCHES";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    Integer batchNo     = (request.getParameter("batchNo") != null && ! request.getParameter("batchNo").trim().equals(""))? Integer.parseInt(request.getParameter("batchNo")): null;
    String batchDesc    = request.getParameter("desc");
    String batchSource  = request.getParameter("batchSource");
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
        AccountsReceivable accountsReceivable = new AccountsReceivable(comCode);
        
        Integer recordCount = sys.getRecordCount(this.table, "");
        
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

                        list.add("BATCHNO");
                        list.add("BATCHDESC");
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

            String orderBy = "BATCHNO DESC ";
            String limitSql = "";

            switch(dbType){
                case "mysql":
                    limitSql = "LIMIT "+ session.getAttribute("startRecord")+ " , "+ session.getAttribute("maxRecord");
                    break;
                case "postgres":
                    limitSql = "OFFSET "+ session.getAttribute("startRecord")+ " LIMIT "+ session.getAttribute("maxRecord");
                    break;
            }
            
            gridSql = "SELECT * FROM "+ this.table+ " "+ filterSql+ " ORDER BY "+ orderBy+ limitSql;

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
                html += "<th>Batch No</th>";
                html += "<th>Description</th>";
                html += "<th>Ready To Post</th>";
                html += "<th>Posted</th>";
                html += "<th>Batch Total</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    Integer batchNo     = rs.getInt("BATCHNO");
                    String batchDesc    = rs.getString("BATCHDESC");
                    Integer rtp         = rs.getInt("RTP");
                    Integer posted      = rs.getInt("POSTED");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";
                    
                    String rtpUi = "";
                    if(rtp == 1){
                        rtpUi = gui.formCheckBox("rtp_"+ id, "checked", "", "", "disabled", "");
                    }else{
                        rtpUi = gui.formCheckBox("rtp_"+ id, "", "", "onchange = \"batches.rtp("+ id+ ", "+ batchNo+ ", '"+ batchDesc+ "');\"", "", "");
                    }
                    
                    String postedUi = "";
                    if(posted == 1){
                        postedUi = gui.formCheckBox("posted_"+ id, "checked", "", "", "disabled", "");
                    }else{
                        if(rtp == 1){
                            postedUi = gui.formCheckBox("posted_"+ id, "", "", "onchange = \"batches.post("+ id+ ", "+ batchNo+ ", '"+ batchDesc+ "');\"", "", "");
                        }else{
                            postedUi = gui.formIcon(request.getContextPath(), "hourglass.png", "", "");
                        }
                    }
                    
//                    Double batchTotal = 0.0;
//                    
//                    String batchTotalStr = sys.getOne("ARPYDTLS", "SUM(APLAMOUNT)", "BATCHNO = '"+ batchNo+ "'");
//                    if(batchTotalStr != null){
//                        batchTotal = Double.parseDouble(batchTotalStr);
//                    }
                    
                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ batchNo+ "</td>";
                    html += "<td>"+ batchDesc+ "</td>";
                    html += "<td>"+ rtpUi+ "</td>";
                    html += "<td>"+ postedUi+ "</td>";
                    html += "<td>"+ sys.numberFormat(accountsReceivable.getPyBatchAmount(batchNo).toString())+ "</td>";
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
        
        Integer rtp = null;
        
        if(this.id != null){
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+this.table+" WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.batchDesc      = rs.getString("BATCHDESC");		
                    rtp                 = rs.getInt("RTP");		
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("desc", " Batch Description")+"</td>";
	html += "<td>"+ gui.formInput("text", "desc", 35, this.id != null? this.batchDesc: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
        String btnSave = "";
        if(this.id == null){
            btnSave = gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"batches.save('desc');\"", "");
        }else{
            if(rtp == 0 || rtp == null){
                btnSave = gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"batches.save('desc batchSource');\"", "");
            }
        }
        
        html += btnSave;
	
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getGrid();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
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
                    + "(ID, BATCHNO, BATCHDESC, DATECREATED, DATEEDITED)"
                    + "VALUES"
                    + "("
                    + id+ ","
                    + id+ ","
                    + "'"+ this.batchDesc+ "', "
                    + "'"+ sys.getLogDate()+ "', "
                    + "'"+ sys.getLogDate()+ "'"
                    + ")";
            }else{
                
                query = "UPDATE "+ this.table+ " SET "
                    + "BATCHDESC    = '"+ this.batchDesc+ "', "
                    + "DATEEDITED   = '"+ sys.getLogDate()+ "'"
                    + "WHERE ID     = "+ this.id;
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "An unexpected error occured while saving record.");
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
                obj.put("message", "An unexpected error occured while deleting record.");
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
    
    public Object rtp() throws Exception{
        JSONObject obj = new JSONObject();
         
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            AccountsReceivable accountsReceivable = new AccountsReceivable(comCode);
            
            Integer rts = 1;
            String msg = "Ok";
            
            if(accountsReceivable.getPyBatchAmount(this.batchNo) == 0){
                rts = 0;
                msg = "Invalid batch amount";
            }
            
            if(this.id == null){
                rts = 0;
                msg = "An unexpected error occured";
            }

            if(rts == 1){
                String query = "UPDATE "+ this.table+ " SET RTP = 1 WHERE ID = "+ this.id;
                Integer rtp = stmt.executeUpdate(query);
                if(rtp == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Batch successfully made ready to post.");
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", msg);
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
    
    public Object post() throws Exception{
         JSONObject obj = new JSONObject();
         HttpSession session = request.getSession();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            AccountsReceivable accountsReceivable = new AccountsReceivable(comCode);
            
            Integer rts = 1;
            String msg = "";
            
            if(this.batchNo == null){
                rts = 0;
                msg = "Invalid batch";
            }
            
            if(this.id == null){
                rts = 0;
                msg = "An unexpected error occured";
            }
            
            Integer batchPosted = accountsReceivable.postPyBatch(this.batchNo, session, request);
            
            if(! batchPosted.equals(1)){
                rts = 0;
                msg = "Batch could not be posted..";
            }
            
            if(rts == 1){
                String query = "UPDATE "+ this.table+ " SET POSTED = 1 WHERE ID = "+ this.id;
//                String query = "UPDATE "+this.table+" SET POSTED = NULL WHERE ID = "+ this.id;

                Integer rtp = stmt.executeUpdate(query);

                if(rtp == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Batch successfully posted.");
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured while posting batch.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", msg);
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