<%@page import="bean.primary.PRStudentProfile"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class StudentInquiry{
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String studentNo        = request.getParameter("studentNo");
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        String btnManualLoad = gui.formButton(request.getContextPath(), "button", "btnLoad", "View", "arrow-right.png", "onclick = \"studentInquiry.loadStudmanually();\"", "");
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("studentNo", " Student No")+ "</td>";
        html += "<td>"+ gui.formAutoComplete("studentNo", 15, "", "studentInquiry.searchStudent", "studentNoHd", "")+ " "+ btnManualLoad+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Name</td>";
	html += "<td id = \"tdFullName\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ " Student Period</td>";
        html += "<td id = \"tdStudentPeriod\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ " Student Type</td>";
	html += "<td id = \"tdStudentType\">&nbsp;</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\">&nbsp;</td>";
	html += "</tr>";
        
        html += "</table>";
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+ this.getStatementTab()+ "</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 40px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"studentInquiry.print('studentNo'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Statement\'), 0, 625, 300, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String searchStudent(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.studentNo = request.getParameter("studentNoHd");
        
        html += gui.getAutoColsSearch("PRSTUDENTS", "STUDENTNO, FULLNAME", "", this.studentNo);
        
        return html;
    }
    
    public Object getStudentProfile(){
        JSONObject obj = new JSONObject();
        
        if(this.studentNo == null || this.studentNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            PRStudentProfile pRStudentProfile = new PRStudentProfile(this.studentNo);
            
            obj.put("fullName", pRStudentProfile.fullName);
            
            obj.put("studentPeriod", pRStudentProfile.studPrdName);
            obj.put("studentType", pRStudentProfile.studTypeName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Student No '"+pRStudentProfile.studentNo+"' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String getStatementTab(){
        String html = "";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td colspan = \"2\" style = \"vertical-align: top;\"><div id = \"dvStatement\">"+ this.getStatement()+ "</div></td>";
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String getStatement(){
        String html = "";
        Sys sys = new Sys();
        
        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
        
        if(system.recordExists("VIEWPROBS", "STUDENTNO = '"+ this.studentNo+ "'")){
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>Document No</th>";
            html += "<th>Type</th>";
            html += "<th>Date</th>";
            html += "<th>Description</th>";
            html += "<th style = \"text-align: right;\">Debit</th>";
            html += "<th style = \"text-align: right;\">Credit</th>";
            html += "<th style = \"text-align: right;\">Total</th>";
            html += "</tr>";
            
            Double grossTotal = 0.00;
            String grossTotalLbl = "";
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT STUDENTNO, DOCNO, DOCDESC, DOCTYPE, ENTRYDATE, SUM(AMOUNT) TOTAL "
                        + "FROM VIEWPROBS "
                        + "WHERE STUDENTNO = '"+ this.studentNo+ "' "
                        + "GROUP BY STUDENTNO, DOCNO, DOCDESC, DOCTYPE, ENTRYDATE "
                        + "ORDER BY ENTRYDATE";

                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String docNo        = rs.getString("DOCNO");
                    String docType      = rs.getString("DOCTYPE");
                    String entryDate    = rs.getString("ENTRYDATE");
                    String docDesc      = rs.getString("DOCDESC");
                    Double total        = rs.getDouble("TOTAL");
                    
                    Double dr = 0.00;
                    Double cr = 0.00;
                    Double totalAcc = 0.00;
                    
                    String docTypeLbl = "";
                    
                    switch(docType){
                        case "IN":
                            docTypeLbl  = "Invoice";
                            dr          = total;
                            cr          = 0.00;
                            totalAcc    = total;
                            break;
                        case "DN":
                            docTypeLbl  = "Debit Note";
                            dr          = total;
                            cr          = 0.00;
                            totalAcc    = total;
                            break;
                            
                        case "RC": 
                            docTypeLbl  = "Receipt";
                            dr          = 0.00;
                            cr          = total;
                            totalAcc    = total * -1;
                            break;
                        case "CN":
                            docTypeLbl  = "Credit Note";
                            dr          = 0.00;
                            cr          = total;
                            totalAcc    = total * -1;
                            break;
                        
                    }
                    
                    java.util.Date docDate = originalFormat.parse(entryDate);
                    entryDate = targetFormat.format(docDate);
                    
                    String drLbl = system.numberFormat(dr.toString());
                    String crLbl = system.numberFormat(cr.toString());
                    
                    grossTotal = grossTotal +totalAcc;
                    
                    grossTotalLbl = system.numberFormat(grossTotal.toString());
                    
                    html += "<tr>";
                    html += "<td>"+ docNo+ "</td>";
                    html += "<td>"+ docTypeLbl+ "</td>";
                    html += "<td>"+ entryDate+ "</td>";
                    html += "<td>"+ docDesc+ "</td>";
                    html += "<td style = \"text-align: right;\">"+ drLbl +"</td>";
                    html += "<td style = \"text-align: right;\">"+ crLbl+"</td>";
                    html += "<td style = \"text-align: right;\">"+ grossTotalLbl +"</td>";
                    html += "</tr>";
                    
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            grossTotalLbl = system.numberFormat(grossTotal.toString());
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"6\">Total</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ grossTotalLbl+"</td>";
            html += "</tr>";
            
            html += "</table>";
        }else{
            html += "No record found.";
        }
        
        return html;
    }
    
    
    
}

%>