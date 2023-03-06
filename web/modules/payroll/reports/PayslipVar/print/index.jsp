<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="bean.hr.StaffProfile"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.commonsrv.Company"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.sys.Sys"%>
<%
    final class PrintRptPayslip{
        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        
        String pfNo     = request.getParameter("staff");
        Integer pYear1  = (request.getParameter("pYear1") != null && ! request.getParameter("pYear1").trim().equals(""))? Integer.parseInt(request.getParameter("pYear1")): null;
        Integer pMonth1 = (request.getParameter("pMonth1") != null && ! request.getParameter("pMonth1").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth1")): null;
        Integer pYear2  = request.getParameter("pYear2") != null && ! request.getParameter("pYear2").trim().equals("")? Integer.parseInt(request.getParameter("pYear2")): null;
        Integer pMonth2 = (request.getParameter("pMonth2") != null && ! request.getParameter("pMonth2").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth2")): null;
    
        String rptName  = "Payslip Variance";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
//                String comCode = sys.getOne("CSCOPROFILE", "COMPANYCODE", "");

                if(comCode != null){

                    Company company = new Company(comCode);

                    String imgLogoSrc;

                    if(sys.getOne("CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+comCode;
                    }else{
                        imgLogoSrc = request.getContextPath()+"/assets/img/logo/default-logo.png";
                    }

                    html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"header\" >";

                    html += "<tr>";
                    html += "<td align = \"center\" colspan = \"4\">"+ company.compName +"</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td width = \"33%\">&nbsp;</td>";
                    html += "<td rowspan = \"5\" align = \"center\"><img id = \"imgLogo\" height = \"128\" width = \"128\" src=\""+ imgLogoSrc +"\"></td>";
                    html += "<td width = \"33%\">&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td width = \"33%\">";
                    html += ""+ company.postalAdr +" - "+ company.postalCode +"  <br>";
                    html += "Email : "+ company.email +" <br>";
                    html += "Website : "+ company.website +" <br>";
                    html += "</td>";
                    html += "<td width = \"33%\">";
                    html += "Tel Office : "+ company.telephone +" <br>";
                    html += "Mobile : "+ company.cellphone +" ";
                    html += "</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td colspan = \"3\"  align = \"center\">"+ this.rptName+ "</td>";
                    html += "</tr>";

                    java.util.Date reportDate = originalFormat.parse(sys.getLogDate());
                    String reportDateLbl = targetFormat.format(reportDate);

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>"+ reportDateLbl+ "</td>";
                    html += "</tr>";

                    html += "</table>";
                }else{
                    html += "Company details not defined.";
                }
                
            }catch (Exception e){
                html += e.getMessage();
            }
            
            return html;
        }
        
        public String getReportDetails(){
            String html = "";
            
            StaffProfile staffProfile = new StaffProfile(this.pfNo, comCode);
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"20%\" class = \"bold\">Staff No</td>";
            html += "<td>"+ this.pfNo +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Name</td>";
            html += "<td>"+ staffProfile.fullName+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Period</td>";
            html += "<td>"+ this.pYear1+ " - "+ this.pMonth1+" to "+ this.pYear2+ " - "+ this.pMonth2+"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Pin No</td>";
            html += "<td>"+ staffProfile.pinNo+ "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getPayslip();
            
            return html;
        }
        
        public String getPayslip(){
            String html = "";

            Sys sys = new Sys();

            if(sys.recordExists(comCode+ ".VIEWPYSLIP", "PFNO = '"+ this.pfNo+ "' AND ((PYEAR = "+ this.pYear1+ " AND PMONTH = "+ this.pMonth1+ ") OR (PYEAR = "+ this.pYear2+ " AND PMONTH = "+ this.pMonth2+ "))")){

                HashMap<String, String> payslipHdrs = sys.getArray("SELECT HDRCODE, HDRNAME FROM "+ comCode+ ".PYPSLHDR ORDER BY HDRPOS");

                html += "<table width = \"100%\" class = \"header\" cellpadding = \"2\" cellspacing = \"0\" >";

                for (Map.Entry<String, String> entry : payslipHdrs.entrySet()){

                    String hdrCode = entry.getKey();
                    String hdrName = entry.getValue();

                    html += "<tr>";
                    html += "<td width = \"100%\" class = \"bold\">"+ hdrName+ "</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td><div style = \"padding-left: 5px;\">"+ this.getSlipHdrDtls(hdrCode) + "</div></td>";
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

            if(sys.recordExists(comCode+ ".VIEWPYSLIP", "PFNO = '"+ this.pfNo+ "' AND ((PYEAR = "+ this.pYear1+ " AND PMONTH = "+ this.pMonth1+ ") OR (PYEAR = "+ this.pYear2+ " AND PMONTH = "+ this.pMonth2+ ")) AND HDRCODE = '"+ hdrCode+ "'")){
                html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
                try{

                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    query = "SELECT DISTINCT ITEMCODE, ITEMNAME, ITEMPOS FROM "+ comCode+ ".VIEWPYSLIP WHERE PFNO = '"+ this.pfNo+ "' AND ((PYEAR = "+ this.pYear1+ " AND PMONTH = "+ this.pMonth1+ ") OR (PYEAR = "+ this.pYear2+ " AND PMONTH = "+ this.pMonth2+ ")) AND HDRCODE = '"+ hdrCode+ "' ORDER BY ITEMPOS";

                    ResultSet rs = stmt.executeQuery(query);

                    while(rs.next()){
                        String itemCode = rs.getString("ITEMCODE");
                        String itemName = rs.getString("ITEMNAME");

                        String amountP1_    = sys.getOne(comCode+ ".VIEWPYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ itemCode+ "' AND PYEAR = "+ this.pYear1+ " AND PMONTH = "+ this.pMonth1+ "");
                        amountP1_           = amountP1_ != null? amountP1_: "0";
                        Double amountP1     = Double.parseDouble(amountP1_);

                        String amountP2_    = sys.getOne(comCode+ ".VIEWPYSLIP", "AMOUNT", "PFNO = '"+ this.pfNo+ "' AND ITEMCODE = '"+ itemCode+ "' AND PYEAR = "+ this.pYear2+ " AND PMONTH = "+ this.pMonth2+ "");
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
        
        public String printRpt(){
            String html = "";
            
            html += this.getReportHeader();
            html += "<br>";
            html += this.getReportDetails();
            
            return html;
        }
    }
    
    PrintRptPayslip printRptPayslip = new PrintRptPayslip();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Payslip</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptPayslip.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
