<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.primary.PRStudentProfile"%>
<%@page import="bean.primary.PrimaryCalendar"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class PerStudent{
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        String table            = comCode+".PRINVSHDR";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    Integer sid             = request.getParameter("sid") != null? Integer.parseInt(request.getParameter("sid")): null;
    String studentNo        = request.getParameter("studentNo");
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String invDesc          = request.getParameter("invDescription");
    String itemCode         = request.getParameter("item");
    Double amount           = (request.getParameter("amount") != null && ! request.getParameter("amount").toString().trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getInvoiceTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"perStudent.save('studentNo academicYear term invDescription item amount'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Invoice\'), 0, 625, 420, Array(false));";
        html += "</script>";
        
        
        return html;
    }
    
    public String getInvoiceTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        String fullName     = "";
        String studPrdName  = "";
        String studTypeName = "";
        
        if(this.id != null){
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.table+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.academicYear   = rs.getInt("ACADEMICYEAR");		
                    this.termCode       = rs.getString("TERMCODE");		
                }
            }catch(SQLException e){
                html += e.getMessage();
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        PrimaryCalendar primaryCalendar = new PrimaryCalendar(this.comCode);
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<div id = \"divFSDtlsSid\">";
        if(this.sid != null){
            html += gui.formInput("hidden", "sid", 30, ""+this.sid, "", "");
        }
        html += "</div>";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("studentNo", " Student No")+ "</td>";
        html += "<td width = \"35%\">"+ gui.formAutoComplete("studentNo", 15, this.id != null? this.studentNo: "", "perStudent.searchStudent", "studentNoHd", this.id != null? this.studentNo: "")+ "</td>";
	
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdFullName\">"+ fullName+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ " Student Period</td>";
        html += "<td id = \"tdStudentPeriod\">"+ studPrdName+ "</td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Student Type</td>";
	html += "<td id = \"tdStudentType\">"+ studTypeName+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("academicYear", " Academic Year")+ "</td>";
        html += "<td>"+ gui.formSelect("academicYear", ""+this.comCode+".PRACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", this.id != null? ""+ this.academicYear: ""+ primaryCalendar.academicYear, "onchange = \"perStudent.getInvItems();\"", false)+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("term", " Term")+ "</td>";
	html += "<td>"+ gui.formSelect("term", ""+this.comCode+".PRTERMS", "TERMCODE", "TERMNAME", "", "", this.id != null? this.termCode: primaryCalendar.termCode, "onchange = \"perStudent.getInvItems();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div class = \"hr\"></div></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"package.png", "", "")+ gui.formLabel("invDescription", " Invoice Description")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "invDescription", 25, "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("item", " Fee Item")+ "</td>";
	html += "<td colspan = \"3\">"+ gui.formSelect("item", ""+this.comCode+".PRITEMS", "ITEMCODE", "ITEMNAME", "", "", "", "onchange = \"perStudent.getItemAmount();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"money.png", "", "")+ gui.formLabel("amount", " Amount")+"</td>";
	html += "<td colspan = \"3\">"+gui.formInput("text", "amount", 15, "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvInvItems\">"+ this.getInvItems()+"</div></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchStudent(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.studentNo = request.getParameter("studentNoHd");
        
        html += gui.getAutoColsSearch(""+this.comCode+".PRSTUDENTS", "STUDENTNO, FULLNAME", "", this.studentNo);
        
        return html;
    }
    
    public Object getStudentProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.studentNo == null || this.studentNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo, this.comCode);
            
            obj.put("fullName", pRStudentProfile.fullName);
            
            obj.put("studentPeriod", pRStudentProfile.studPrdName);
            obj.put("studentType", pRStudentProfile.studTypeName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Student No '"+pRStudentProfile.studentNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String getInvItems(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(""+this.comCode+".VIEWPRINVSDETAILS", "STUDENTNO = '"+ this.studentNo+ "' AND "
                + "ACADEMICYEAR = "+ this.academicYear+ " AND "
                + "TERMCODE     = '"+ this.termCode+ "' AND "
                + "INVTYPE      = 'PS' AND "
                + "(PROCESSED IS NULL OR PROCESSED = 0)")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Invoice No</th>";
            html += "<th>Item</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "<th style = \"text-align: right;\">Options</th>";
            html += "</tr>";
            
            Double total   = 0.0;
            
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+this.comCode+".VIEWPRINVSDETAILS WHERE STUDENTNO = '"+ this.studentNo+ "' AND "
                        + "ACADEMICYEAR = "+ this.academicYear+ " AND "
                        + "TERMCODE     = '"+ this.termCode+ "' AND "
                        + "INVTYPE      = 'PS' AND "
                        + "(PROCESSED IS NULL OR PROCESSED = 0) ORDER BY ITEMNAME";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String invNo        = rs.getString("INVNO");
                    String itemName     = rs.getString("ITEMNAME");
                    Double amount       = rs.getDouble("AMOUNT");
                    
                    String editLink     = gui.formHref("onclick = \"perStudent.editInvDtls("+ id +");\"", request.getContextPath(), "", "edit", "edit", "", "");
                    String removeLink   = gui.formHref("onclick = \"perStudent.purge("+ id +", '"+ itemName +"');\"", request.getContextPath(), "", "delete", "delete", "", "");
                    
                    String opts = "";
                    opts = editLink+ " || "+ removeLink;
                    
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ invNo +"</td>";
                    html += "<td>"+ itemName +"</td>";
                    html += "<td style = \"text-align: right;\">"+ amount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ opts +"</td>";
                    html += "</tr>";
                    
                    total = total + amount;

                    count++;
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"3\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ total +"</td>";
            html += "<td>&nbsp;</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No invoice items record found.";
        }
        
        return html;
    }
    
    public Object getItemAmount() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        
        PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo, this.comCode);
        
        String amount = sys.getOne(""+this.comCode+".VIEWPRFSDETAILS", "AMOUNT", "ACADEMICYEAR = "+ this.academicYear+" AND "
                + "TERMCODE     = '"+ this.termCode+ "' AND "
                + "CLASSCODE    = '"+ pRStudentProfile.classCode+ "' AND "
                + "STUDTYPECODE = '"+ pRStudentProfile.studTypeCode+ "' AND "
                + "ITEMCODE     = '"+ this.itemCode+ "' "
                );
        
        amount = amount != null? amount: "0";
        
        obj.put("amount", amount);
                    
        
        return obj;
    }
    
    public Object editInvDtls() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        Gui gui = new Gui();
        if(sys.recordExists(""+this.comCode+".PRINVSDTLS", "ID = "+ this.sid +"")){
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM "+this.comCode+".VIEWPRINVSDETAILS WHERE ID = "+ this.sid +"";
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String id           = rs.getString("ID");
                    String invDesc      = rs.getString("invDesc");
                    String itemCode     = rs.getString("ITEMCODE");
                    String amount       = rs.getString("AMOUNT");
                    
                    obj.put("sidUi", gui.formInput("hidden", "sid", 15, id, "", ""));
                    obj.put("invDescription", invDesc);
                    obj.put("item", itemCode);
                    obj.put("amount", amount);
                    
                    obj.put("success", new Integer(1));
                    obj.put("message", "Record retrieved successfully.");
                    
                }
            }catch (SQLException e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }catch (Exception e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
            }
        }else{
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }
        
        return obj;
    }
    
    public Object save() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        String invNo = this.getInvHdr();
        
        if(invNo != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query;
                Integer saved = 0;

                if(this.sid == null){

                    Integer sid = sys.generateId(""+this.comCode+".PRINVSDTLS", "ID");

                    query = "INSERT INTO "+this.comCode+".PRINVSDTLS "
                                + "(ID, INVNO, ITEMCODE, AMOUNT, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + sid+ ", "
                                + "'"+ invNo+ "', "
                                + "'"+ this.itemCode+ "', "
                                + this.amount+ ", "
                                + "'"+ sys.getLogUser(session)+"', "
                                + "'"+ sys.getLogDate()+ "', "
                                + "'"+ sys.getLogTime()+ "', "
                                + "'"+ sys.getClientIpAdr(request)+ "'"
                                + ")";

                }else{

                    query = "UPDATE "+this.comCode+".PRINVSDTLS SET "
                            + "ITEMCODE     = '"+ this.itemCode+ "', "
                            + "AMOUNT       = "+ this.amount+ " "
                            
                            + "WHERE ID     = "+this.sid;
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
        }else{
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while saving record header.");
        }
        
        return obj;
    }
    
    public String getInvHdr(){
        
        Sys sys = new Sys();
        HttpSession session = request.getSession();
        
        String invNo = sys.getOne(this.table, "INVNO", "STUDENTNO = '"+ this.studentNo+ "' AND "
                        + "INVTYPE = 'PS' AND "
                        + "(PROCESSED IS NULL OR PROCESSED = 0)");
        
        if(invNo == null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer id = sys.generateId(this.table, "ID");
                invNo = sys.getNextNo(this.table, "ID", "", "IN", 7);
                
                String invType = "PS";

                String query = "INSERT INTO "+ this.table+ " "
                                + "(ID, ACADEMICYEAR, TERMCODE, STUDENTNO, INVNO, INVDESC, INVTYPE, INVDATE, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + id+ ", "
                                + this.academicYear+", "
                                + "'"+ this.termCode+ "', "
                                + "'"+ this.studentNo+ "', "
                                + "'"+ invNo+ "', "
                                + "'"+ this.invDesc+ "', "
                                + "'"+ invType+ "', "
                                + "'"+ sys.getLogDate()+ "', "
                                + "'"+ sys.getLogUser(session)+"', "
                                + "'"+ sys.getLogDate()+ "', "
                                + "'"+ sys.getLogTime()+ "', "
                                + "'"+ sys.getClientIpAdr(request)+ "'"
                                + ")";

                Integer invHdrCreated = stmt.executeUpdate(query);
                
                if(invHdrCreated == 1){
                    
                }else{
                    invNo = null;
                }

            }catch(SQLException e){
                e.getMessage();
            }catch(Exception e){
                e.getMessage();
            }
            
        }
        
        return invNo;
    }
    
    public Object purge() throws Exception{
         
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+this.comCode+".PRINVSDTLS WHERE ID = "+this.id;
            
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
    
}

%>