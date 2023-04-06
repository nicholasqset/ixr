<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.hr.StaffProfile"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class Payslip{
    HttpSession session = request.getSession();
    String schema       = session.getAttribute("comCode").toString();
    
    String pfNo         = request.getParameter("staff");
    Integer pYear       = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
    Integer pMonth      = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
    
    
    public String getModule(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<table width = \"50%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td  nowrap>"+ gui.formIcon(request.getContextPath(), "user-properties.png", "", "")+" "+gui.formLabel("staff", "Staff No.")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formAutoComplete("staff", 13, "", "payslip.searchStaff", "pfNo", "")+ " "+ gui.formButton(request.getContextPath(), "button", "btnView", "", "arrow-right.png", "onclick = \"payslip.getPayslip();\"", "smallButton")+ "</td>";
//	html += "<td colspan = \"3\">"+ gui.formAutoComplete("staff", 13, "", "payslip.searchStaff", "pfNo", "")+ " "+ gui.formHref("onclick = \"payslip.getPayslip();\"", request.getContextPath(), "arrow-right.png", "view", "view", "", "")+ "</td>";
//	html += "<td colspan = \"3\">"+ gui.formAutoComplete("staff", 13, "", "payslip.searchStaff", "pfNo", "")+ " "+ gui.formHref("onclick = \"payslip.getPayslip();\"", "", "", "view", "view", "", "")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td  nowrap>"+ gui.formIcon(request.getContextPath(), "user.png", "", "")+" Staff Name</td>";
	html += "<td colspan = \"3\"><span id = \"spStaffName\">&nbsp;</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pYear", "Payroll Year")+ "</td>";
	html += "<td width = \"35%\">"+ gui.formSelect("pYear", schema+ ".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", ""+ sys.getPeriodYear(schema), "onchange = \"payslip.getPayslip();\"", false)+ "</td>";
	
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("pMonth", "Payroll Month")+ "</td>";
	html += "<td>"+ gui.formMonthSelect("pMonth", sys.getPeriodMonth(schema), "onchange = \"payslip.getPayslip();\"", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td colspan = \"3\"><div id = \"dvPayslip\">&nbsp;</div></td>";
	html += "</tr>";
         
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td colspan = \"3\">";
	html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"payslip.print('staff pYear pMonth');\"", "");
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
        
        html += gui.getAutoColsSearch(schema+ ".HRSTAFFPROFILE", "PFNO, FULLNAME", "", this.pfNo);
        
        return html;
    }
    
    public Object getStaffDtls() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.pfNo == null || this.pfNo.trim().equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            StaffProfile staffProfile = new StaffProfile(this.pfNo, schema);
            
            obj.put("staffName", staffProfile.fullName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Staff No '"+ this.pfNo+ "' details successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public String getPayslip(){
        String html = "";
        
        Sys sys = new Sys();
        
        if(sys.recordExists(schema+ ".VIEWPYSLIP", "PFNO = '"+ this.pfNo+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ "")){
            
            HashMap<String, String> payslipHdrs = sys.getArray("SELECT HDRCODE, HDRNAME FROM "+ schema+ ".PYPSLHDR ORDER BY HDRPOS");
            
            html += "<table width = \"60%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
            
            for (Map.Entry<String, String> entry : payslipHdrs.entrySet()){
//                System.out.println(entry.getKey() + "/" + entry.getValue());
                
                String hdrCode = entry.getKey();
                String hdrName = entry.getValue();
                
                html += "<tr>";
                html += "<td width = \"100%\" class = \"bold\">"+ hdrName+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td><div class = \"dvSlipItems\">"+ this.getSlipHdrDtls(hdrCode) + "</div></td>";
                html += "</tr>";
                
            }
            
            html += "</table>";
            
        }else{
            html += "No payslip items found.";
        }
        
        return html;
    }
    
    public String getSlipHdrDtls(String hdrCode){
        String html = "";
        
        Sys sys = new Sys();
        
        if(sys.recordExists(schema+ ".VIEWPYSLIP", "PFNO = '"+ this.pfNo+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " AND HDRCODE = '"+ hdrCode+ "'")){
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query;

                query = "SELECT * FROM "+schema+".VIEWPYSLIP WHERE PFNO = '"+ this.pfNo+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " AND HDRCODE = '"+ hdrCode+ "' ORDER BY ITEMPOS";

                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    
                    String itemName = rs.getString("ITEMNAME");
                    Double amount   = rs.getDouble("AMOUNT");
                    
                    html += "<tr>";
                    html += "<td width = \"50%\" nowrap>"+ itemName+ "</td>";
                    html += "<td style = \"text-align: right;\">"+ sys.numberFormat(amount.toString()) + "</td>";
                    html += "</tr>";
                    
                }
                
            }catch(Exception e){
                html += e.getMessage();
            }
            html += "</table>";
        }
        
        return html;
    }
    
}

%>