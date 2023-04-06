<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.qset.hr.StaffProfile"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.commonsrv.Company"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.sys.Sys"%>
<%
    final class PrintRptPayslip{
        
        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
        
        String pfNo     = request.getParameter("staff");
        Integer pYear   = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth  = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
    
        String rptName  = "Payslip";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
//                String companyCode = sys.getOne("sys.coms", "COMPANYCODE", "");

                if(comCode != null){

                    Company company = new Company(comCode);

                    String imgLogoSrc;

                    if(sys.getOne(comCode+ ".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode +"'") != null){
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
            html += "<td>"+ this.pYear+ " - "+ this.pMonth+"</td>";
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

            if(sys.recordExists(comCode+ ".VIEWPYSLIP", "PFNO = '"+ this.pfNo+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ "")){

                HashMap<String, String> payslipHdrs = sys.getArray("SELECT HDRCODE, HDRNAME FROM "+comCode+".PYPSLHDR ORDER BY HDRPOS");

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

            if(sys.recordExists(comCode+ ".VIEWPYSLIP", "PFNO = '"+ this.pfNo+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " AND HDRCODE = '"+ hdrCode+ "'")){
                html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
                try{

                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    query = "SELECT * FROM "+ comCode+ ".VIEWPYSLIP WHERE PFNO = '"+ this.pfNo+ "' AND PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " AND HDRCODE = '"+ hdrCode+ "' ORDER BY ITEMPOS";

                    ResultSet rs = stmt.executeQuery(query);

                    while(rs.next()){

                        String itemName = rs.getString("ITEMNAME");
                        Double amount   = rs.getDouble("AMOUNT");

                        html += "<tr>";
                        html += "<td width = \"20%\" nowrap>"+ itemName+ "</td>";
                        html += "<td width = \"52%\" style = \"text-align: right;\">"+ sys.numberFormat(amount.toString()) + "</td>";
                        html += "<td>&nbsp;</td>";
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
