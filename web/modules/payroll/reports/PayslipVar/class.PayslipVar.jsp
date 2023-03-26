<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="org.json.JSONObject"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%

final class PayslipVar{
    HttpSession session = request.getSession();
    String schema       = session.getAttribute("comCode").toString();
    
    String pfNo         = request.getParameter("staff");
    Integer pYear1      = (request.getParameter("pYear1") != null && ! request.getParameter("pYear1").trim().equals(""))? Integer.parseInt(request.getParameter("pYear1")): null;
    Integer pMonth1     = (request.getParameter("pMonth1") != null && ! request.getParameter("pMonth1").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth1")): null;
    Integer pYear2      = (request.getParameter("pYear2") != null && ! request.getParameter("pYear2").trim().equals(""))? Integer.parseInt(request.getParameter("pYear2")): null;
    Integer pMonth2     = (request.getParameter("pMonth2") != null && ! request.getParameter("pMonth2").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth2")): null;
    
    public String getModule(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        html += "<table width = \"72%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td  nowrap>"+ gui.formIcon(request.getContextPath(), "user-properties.png", "", "")+" "+gui.formLabel("staff", "Staff No.")+"</td>";
	html += "<td colspan = \"3\">"+ gui.formAutoComplete("staff", 13, "", "payslip.searchStaff", "pfNo", "")+ " "+ gui.formButton(request.getContextPath(), "button", "btnView", "", "arrow-right.png", "onclick = \"payslip.getPayslipVar();\"", "smallButton")+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td  nowrap>"+ gui.formIcon(request.getContextPath(), "user.png", "", "")+" Staff Name</td>";
	html += "<td colspan = \"3\"><span id = \"spStaffName\">&nbsp;</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td  nowrap>&nbsp;</td>";
	html += "<td  nowrap>Period 1</td>";
	html += "<td  nowrap>&nbsp;</td>";
	html += "<td  nowrap>Period 2</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
        html += gui.formSelect("pYear1", this.schema+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", ""+ sys.getPeriodYear(schema), "onchange = \"payslip.getPayslipVar();\"", false);
        html += "&nbsp;";
        html += gui.formMonthSelect("pMonth1", sys.getPeriodMonth(schema), "onchange = \"payslip.getPayslipVar();\"", true);
	html += "</td>";
        html += "<td nowrap>&nbsp;</td>";
	html += "<td>";
        html += gui.formSelect("pYear2", this.schema+".FNFISCALPRD", "PYEAR", "", "PYEAR DESC", "", ""+ sys.getPeriodYear(schema), "onchange = \"payslip.getPayslipVar();\"", false);
        html += "&nbsp;";
        html += gui.formMonthSelect("pMonth2", sys.getPeriodMonth(schema), "onchange = \"payslip.getPayslipVar();\"", true);
	html += "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td colspan = \"3\"><div id = \"dvPayslip\">&nbsp;</div></td>";
	html += "</tr>";
         
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td colspan = \"3\">";
	html += gui.formButton(request.getContextPath(), "button", "btnPrint", "Print", "printer.png", "onclick = \"payslip.print('staff pYear1 pMonth1');\"", "");
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
        
        html += gui.getAutoColsSearch("qset.HRSTAFFPROFILE", "PFNO, FULLNAME", "", this.pfNo);
        
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
    
    public String getPayslipVar(){
        String html = "";
        
        Sys sys = new Sys();
        
        if(sys.recordExists( schema+ ".VIEWPYSLIP", "PFNO = '"+ this.pfNo+ "' AND ((PYEAR = "+ this.pYear1+ " AND PMONTH = "+ this.pMonth1+ ") OR (PYEAR = "+ this.pYear2+ " AND PMONTH = "+ this.pMonth2+ "))")){
            
            HashMap<String, String> payslipHdrs = sys.getArray("SELECT HDRCODE, HDRNAME FROM "+ schema+ ".PYPSLHDR ORDER BY HDRPOS");
            
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
            
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
        
        if(sys.recordExists(schema+ ".VIEWPYSLIP", "PFNO = '"+ this.pfNo+ "' AND ((PYEAR = "+ this.pYear1+ " AND PMONTH = "+ this.pMonth1+ ") OR (PYEAR = "+ this.pYear2+ " AND PMONTH = "+ this.pMonth2+ ")) AND HDRCODE = '"+ hdrCode+ "'")){
            html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();

                String query;

                query = "SELECT DISTINCT ITEMCODE, ITEMNAME, ITEMPOS FROM "+ schema+ ".VIEWPYSLIP WHERE PFNO = '"+ this.pfNo+ "' AND ((PYEAR = "+ this.pYear1+ " AND PMONTH = "+ this.pMonth1+ ") OR (PYEAR = "+ this.pYear2+ " AND PMONTH = "+ this.pMonth2+ ")) AND HDRCODE = '"+ hdrCode+ "' ORDER BY ITEMPOS";

                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String itemCode = rs.getString("ITEMCODE");
                    String itemName = rs.getString("ITEMNAME");
                    
                    String amountP1_    = sys.getOne(schema+ ".VIEWPYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ itemCode+ "' AND PYEAR = "+ this.pYear1+ " AND PMONTH = "+ this.pMonth1+ "");
                    amountP1_           = amountP1_ != null? amountP1_: "0";
                    Double amountP1     = Double.parseDouble(amountP1_);
                    
                    String amountP2_    = sys.getOne(schema+ ".VIEWPYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ itemCode+ "' AND PYEAR = "+ this.pYear2+ " AND PMONTH = "+ this.pMonth2+ "");
                    amountP2_           = amountP2_ != null? amountP2_: "0";
                    Double amountP2     = Double.parseDouble(amountP2_);
                    
                    Double var = amountP2 - amountP1;
                    
                    String varColorCss = var == 0? "": "color: red;";
                    
                    html += "<tr>";
                    html += "<td width = \"25%\" nowrap>"+ itemName+ "</td>";
                    html += "<td width = \"25%\" style = \"text-align: right;\">"+ sys.numberFormat(amountP1.toString())+ "</td>";
                    html += "<td width = \"25%\" style = \"text-align: right;\">"+ sys.numberFormat(amountP2.toString())+ "</td>";
                    html += "<td style = \""+ varColorCss+ " text-align: right;\">"+ sys.numberFormat(var.toString())+ "</td>";
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