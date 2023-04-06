<%-- 
    Document   : class.Reconciliation
    Created on : Aug 30, 2016, 12:19:27 PM
    Author     : nicholas
--%>

<%@page import="java.sql.SQLException"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.sys.Sys"%>
<%
    final class Reconciliation{
        String table            = "CBCB";
        
        Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
        String bkBranchCode_    = request.getParameter("bankBranch");
        String bkBranchCode     = bkBranchCode_ != null && bkBranchCode_.trim() != ""? bkBranchCode_: null;
        String batchNo_         = request.getParameter("batchNo");
        String batchNo          = batchNo_ != null && batchNo_.trim() != ""? batchNo_: null;
        String entryNo_         = request.getParameter("entryNo");
        String entryNo          = entryNo_ != null && entryNo_.trim() != ""? entryNo_: null;
        String refNo_           = request.getParameter("reference");
        String refNo            = refNo_ != null && refNo_.trim() != ""? refNo_: null;
        
        Double amount           = (request.getParameter("amount") != null && ! request.getParameter("amount").toString().trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;
        Double rcnAmount        = (request.getParameter("rcn") != null && ! request.getParameter("rcn").toString().trim().equals(""))? Double.parseDouble(request.getParameter("rcn")): 0.0;
        Double rcnVar           = 0.0;
        
        public String getModule(){
            String html = "";
            
            Gui gui = new Gui();
            
            html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
            
            html += "<div id = \"dhtmlgoodies_tabView1\">";
        
            html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getRcnEntriesTab()+ "</div>";

            html += "</div>";
            
            html += "<div id = \"dvBtns\" style = \"padding-left: 10px; padding-top: 37px; border: 0;\" >";
        
            html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
            
            html += "</div>";

            html += gui.formEnd();
            
            html += "<script type = \"text/javascript\">";
            html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Bank Reconciliation\'), 0, 706, 425, Array(false));";
            html += "</script>";
            
            return html;
        }
        
        public String getRcnEntriesTab(){
            String html = "";
            
            Gui gui = new Gui();
            
            HashMap<String, String> cbBatches   = new HashMap();
            HashMap<String, String> entries     = new HashMap();
            HashMap<String, String> references  = new HashMap();
            
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
            
            html += "<tr>";
            html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "building.png", "", "")+ gui.formLabel("bankBranch", " Bank")+"</td>";
            html += "<td>"+ gui.formSelect("bankBranch", "VIEWFNCOBANKS", "BKBRANCHCODE", "BKBRANCHNAME", "", "", "", "onchange = \"rcn.getRcnEntries(); rcn.getBatchUi();\"", false)+"</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("batchNo", " Batch No.")+"</td>";
            html += "<td id = \"tdBatchUi\">"+ gui.formArraySelect("batchNo", 200, cbBatches, "", true, "", true)+ "</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("entryNo", " Entry No.")+"</td>";
            html += "<td id = \"tdEntryUi\">"+ gui.formArraySelect("entryNo", 200, entries, "", true, "", true)+ "</td>";
            html += "</tr>";            
            
            html += "<tr>";
            html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("reference", " Reference No.")+"</td>";
            html += "<td id = \"tdReferenceUi\">"+ gui.formArraySelect("reference", 200, references, "", true, "", true)+ "</td>";
            html += "</tr>";
            
            html += "<tr>";
            html += "<td colspan = \"4\"><div id = \"dvRcn\">"+ this.getRcnEntries()+ "</div></td>";
            html += "</tr>";
            
            html += "</table>";
            
            return html;
        }
        
        public String getBatchUi(){
            String html = "";
            Gui gui = new Gui();
            Sys sys = new Sys();
            
            String filterSql = "SELECT DISTINCT BATCHNO, BATCHDESC FROM VIEWCBCB WHERE BKBRANCHCODE = '"+ this.bkBranchCode+"'";
            
            HashMap cbBatches = system.getArray(filterSql);
            
            html += gui.formArraySelect("batchNo", 200, cbBatches, "", true, "onchange = \"rcn.getRcnEntries(); rcn.getEntryUi();\"", true);
//            html += filterSql;
            
            return html;
        }
        
        public String getEntryUi(){
            String html = "";
            Gui gui = new Gui();
            Sys sys = new Sys();
            
            String filterSql = "SELECT DISTINCT ENTRYNO, ENTRYDESC FROM VIEWCBCB WHERE BKBRANCHCODE = '"+ this.bkBranchCode+"' AND BATCHNO = '"+ this.batchNo+"' ";
            
            HashMap entries = system.getArray(filterSql);
            
            html += gui.formArraySelect("entryNo", 200, entries, "", true, "onchange = \"rcn.getRcnEntries(); rcn.getReferenceUi();\"", true);
//            html += filterSql;
            
            return html;
        }
        
        public String getReferenceUi(){
            String html = "";
            Gui gui = new Gui();
            Sys sys = new Sys();
            
            String filterSql = "SELECT DISTINCT REFNO, REFDESC FROM VIEWCBCB WHERE BKBRANCHCODE = '"+ this.bkBranchCode+ "' AND BATCHNO = '"+ this.batchNo+ "' AND ENTRYNO = '"+ this.entryNo+ "'";
            
            HashMap references = system.getArray(filterSql);
            
            html += gui.formArraySelect("reference", 200, references, "", true, "onchange = \"rcn.getRcnEntries();\"", true);
//            html += filterSql;
            
            return html;
        }
        
        public String getRcnEntries(){
            String html = "";
            
            Sys sys = new Sys();
            
            Gui gui = new Gui();
            
            String filterSql = "BKBRANCHCODE = '"+ this.bkBranchCode+ "' ";
            
            if(this.batchNo != null){
                filterSql += "AND BATCHNO = '"+ this.batchNo+ "' ";
            }
            
            if(this.entryNo != null){
                filterSql += "AND ENTRYNO = '"+ this.entryNo+ "' ";
            }
            
            if(this.refNo != null){
                filterSql += "AND REFNO = '"+ this.refNo+ "' ";
            }
            
//            html += filterSql;
            
            if(system.recordExists("VIEWCBCB", filterSql)){
                html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
                
                html += "<tr>";
                html += "<th>#</th>";
//                html += "<th nowrap>Batch No</th>";
//                html += "<th nowrap>Entry No</th>";
                html += "<th>Reference</th>";
                html += "<th>Account</th>";
                html += "<th>Amount</th>";
                html += "<th nowrap>Reconciled Amount</th>";
                html += "<th>Variance</th>";
                html += "</tr>";
                
                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    
                    String query = "SELECT * FROM VIEWCBCB WHERE "+ filterSql +" ORDER BY BATCHNO, ENTRYNO, REFNO";
                    ResultSet rs = stmt.executeQuery(query);
                    
                    Integer count  = 1;
                    
                    while(rs.next()){
                        Integer id              = rs.getInt("ID");
//                        Integer batchNo     = rs.getInt("BATCHNO");
//                        Integer entryNo     = rs.getInt("ENTRYNO");
                        String refNo            = rs.getString("REFNO");
                        String refDesc          = rs.getString("REFDESC");
                        String accountCode      = rs.getString("ACCOUNTCODE");
                        String accountName      = rs.getString("ACCOUNTNAME");
                        String normalBal        = rs.getString("NORMALBAL");
                        
                        Double drAmount         = rs.getDouble("DRAMOUNT");
                        Double crAmount         = rs.getDouble("CRAMOUNT");
                        Double rcnAmount        = rs.getDouble("RCNAMOUNT");
                        Double rcnVar           = rs.getDouble("RCNVAR");
                        
                        Double amount = 0.0;
                        
                        if(normalBal.equals("DR")){
                            amount = drAmount;
                        }else if(normalBal.equals("CR")){
                            amount = crAmount;
                            amount = amount * -1;
                        }
                        
                        String amountUi = gui.formInput("text", "amount["+ id+ "]", 10, ""+ amount, "disabled", "");
                        String rcnUi    = gui.formInput("text", "rcn["+ id+ "]", 10, ""+ rcnAmount, "onkeyup = \"rcn.save("+ id+ ");\"", "");
                        String varUi    = gui.formInput("text", "var["+ id+ "]", 10, ""+ rcnVar, "disabled", "");
                        
                        html += "<tr>";
                        html += "<td>"+ count+ "</td>";
//                        html += "<td>"+ batchNo+ "</td>";
//                        html += "<td>"+ entryNo+ "</td>";
                        html += "<td nowrap>"+ refNo +" - "+ refDesc+ "</td>";
                        html += "<td nowrap>"+ accountCode +" - "+ accountName+ "</td>";
                        html += "<td>"+ amountUi +"</td>";
                        html += "<td>"+ rcnUi +"</td>";
                        html += "<td>"+ varUi +"</td>";
                        html += "</tr>";
                        
                        count++;
                    }
                    
                }catch(Exception e){
                    html += e.getMessage();
                }
                
                html += "</table>";
            }else{
                html += "No cash book entry records found.";
            }
            
            return html;
        }
        
        public Object save(){
        
            JSONObject obj = new JSONObject();

            String query = "";

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                Integer saved = 0;
                
                if(this.amount >= 0){
                    this.rcnVar = this.rcnAmount - this.amount;
                }else{
                    this.rcnVar = (this.amount * -1) + this.rcnAmount;
                }

                query = "UPDATE "+ this.table+ " SET "
                        + "RCNAMOUNT    = "+ this.rcnAmount+ ", "
                        + "RCNVAR       = "+ this.rcnVar+ " "
                        + "WHERE ID     = "+ this.id;

                saved = stmt.executeUpdate(query);

                if(saved == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");

                    obj.put("var", this.rcnVar);
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An unexpected error occured while saving record.");
                }

            }catch (SQLException e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage()+ query);
            }catch (Exception e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }

            return obj;
        }
    }
    
%>