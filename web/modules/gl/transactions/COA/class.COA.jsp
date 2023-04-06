<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="org.json.JSONObject"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.gl.GLCOA"%>
<%@page import="com.qset.gl.GLAccount"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class COA{
    HttpSession session     = request.getSession();
    String comCode          = session.getAttribute("comCode").toString();
    
    Sys sys = new Sys();
    
    Integer pYear           = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): sys.getPeriodYear(comCode);
    Integer pMonth          = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): sys.getPeriodMonth(comCode);
    String accountCode      = request.getParameter("glAccount");
    
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getCOATab()+ "</div>";
        
        html += "</div>";
        
	html += "<div id = \"dvBtns\" style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
        
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"coa.save(' pYear pMonth'); return false;\"", "");
        html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"coa.print('pYear pMonth'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Chart of Accounts\'), 0, 625, 415, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getCOATab(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"1\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", " Fiscal Year")+ "</td>";
        html += "<td width = \"35%\">"+ gui.formSelect("pYear", comCode+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", ""+ sys.getPeriodYear(comCode), "onchange = \"coa.getCOA();\"", false)+"</td>";
	
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", " Period")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", sys.getPeriodMonth(comCode), "onchange = \"coa.getCOA();\"", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("glAccount", " Account")+ "</td>";
        html += "<td>"+ gui.formAutoComplete("glAccount", 13, "", "coa.searchGLAccount", "glAccountHd", "")+ "</td>";
	
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdAccountName\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"4\"><div id = \"dvCOA\">"+ this.getCOA()+ "</div></td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String searchGLAccount(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.accountCode = request.getParameter("glAccountHd");
        
        html += gui.getAutoColsSearch(comCode+".GLACCOUNTS", "ACCOUNTCODE, ACCOUNTNAME", "", this.accountCode);
        
        return html;
    }
    
    public Object getGLAccount() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.accountCode == null || this.accountCode.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            GLAccount gLAccount = new GLAccount(this.accountCode, comCode);
            
            obj.put("accountName", gLAccount.accountName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "GL Account '"+ gLAccount.accountCode+ "' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object save() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        GLCOA gLCOA = new GLCOA(comCode);
        HttpSession session = request.getSession();
        
        if(sys.recordExists(comCode+".VIEWGLACCOUNTS", "")){
            Integer bdgCreated = 0;
           try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
               
                String query;
                
                if(this.accountCode != null && ! this.accountCode.trim().equals("")){
                    query = "SELECT * FROM "+comCode+".VIEWGLACCOUNTS WHERE ACCOUNTCODE = '"+ this.accountCode+ "' ORDER BY ACCOUNTCODE";
                }else{
                    query = "SELECT * FROM "+comCode+".VIEWGLACCOUNTS ORDER BY ACCOUNTCODE";
                }
                
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    String accountCode  = rs.getString("ACCOUNTCODE");
                    
                    Double amount = 0.0;
                    
                    String amount_ = request.getParameter("budget"+ accountCode);
                    
                    if(amount_ != null && ! amount_.trim().equals("")){
                        amount = Double.parseDouble(amount_);
                    }
                    
                    bdgCreated = gLCOA.createBdg(this.pYear, this.pMonth, accountCode, amount, session, request);
                }
           
                if(bdgCreated > 0){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully made.");
                }else{
                     obj.put("success", new Integer(0));
                     obj.put("message", "Oops! Could not save accounts budget.");
                }
           }catch (SQLException e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
           }catch(Exception e){
                obj.put("success", new Integer(0));
                obj.put("message", e.getMessage());
           }
        }else{
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! Could get any GL Account.");
        }
        
        return obj;
    }
    
    public String getCOA(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        GLCOA gLCOA = new GLCOA(comCode);
        
        if(sys.recordExists(comCode+".VIEWGLACCOUNTS", "")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"1\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Account</th>";
            html += "<th>Description</th>";
            html += "<th>Type</th>";
            html += "<th>Balance</th>";
            html += "<th>Amount</th>";
            html += "<th>Budget</th>";
            html += "</tr>";
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query;
                
                if(this.accountCode != null && ! this.accountCode.trim().equals("")){
                    query = "SELECT * FROM "+comCode+".VIEWGLACCOUNTS WHERE ACCOUNTCODE = '"+ this.accountCode+ "' ORDER BY ACCOUNTCODE";
                }else{
                    query = "SELECT * FROM "+comCode+".VIEWGLACCOUNTS ORDER BY ACCOUNTCODE";
                }
                
                ResultSet rs = stmt.executeQuery(query);
                
                Integer count  = 1;
                
                while(rs.next()){
                    Integer id          = rs.getInt("ID");
                    String accountCode  = rs.getString("ACCOUNTCODE");
                    String accountName  = rs.getString("ACCOUNTNAME");
                    String accTypeName  = rs.getString("ACCTYPENAME");
                    String normalBal    = rs.getString("NORMALBAL");
                    
                    String normalBal_   = "";
                    if(normalBal.equals("DR")){
                        normalBal_ = "Debit";
                    }else if(normalBal.equals("CR")){
                        normalBal_ = "Credit";
                    }
                    
                    Double accBal = gLCOA.getAccountBal(this.pYear, this.pMonth, accountCode);
                    
                    Double bdg = 0.0;
                    String bdg_ = sys.getOne(comCode+".GLBDG", "AMOUNT", "PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " AND ACCOUNTCODE = '"+ accountCode+ "'");
                    bdg = (bdg_ != null && ! bdg_.trim().equals(""))? Double.parseDouble(bdg_): bdg;
                    String bdgUI = gui.formInput("text", "budget"+ accountCode, 10, ""+ bdg, "onkeyup = \"\"", "");
                    
                    html += "<tr>";
                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ accountCode+ "</td>";
                    html += "<td>"+ accountName+ "</td>";
                    html += "<td>"+ accTypeName+ "</td>";
                    html += "<td>"+ normalBal_+ "</td>";
                    html += "<td>"+ sys.numberFormat(accBal.toString())+ "</td>";
                    html += "<td>"+ bdgUI+ "</td>";
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
            html += "No GL Accounts record found.";
        }
        
        return html;
    }
    
    
}

%>