<%@page import="com.qset.medical.HmPyHdr"%>
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
    final class PrintRpt {
        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
//        out.print(comCode);
        
        String entryDate1        = request.getParameter("entryDate1");
        String entryDate2        = request.getParameter("entryDate2");
//        out.print(entryDate);
        String rptName = "Patient Bill";
        
        public String getReportHeader(){
            String html = "";
            Sys system = new Sys();
            
            try{
//                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy HH:mm");
                
//                String companyCode = system.getOne("sys.coms", "COMCODE", "");

                if(comCode != null){

                    Company company = new Company(comCode);

                    String imgLogoSrc;

                    if(system.getOne(comCode+".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+comCode;
                    }else{
                        imgLogoSrc = request.getContextPath()+"/assets/img/logo/default-logo.png";
                    }

                    html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"header\">";

                    html += "<tr>";
//                    html += "<td colspan = \"4\" style = \"text-align: center; font-weight: bold;\">"+ company.companyName +"</td>";
//                    html += "<td colspan = \"4\" style = \"font-weight: bold;\">"+ company.companyName +"</td>";
                    html += "<td style = \"font-weight: bold; text-align: center;\">"+ company.compName +"</td>";
                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td width = \"33%\">&nbsp;</td>";
//                    html += "<td rowspan = \"5\" align = \"center\"><img id = \"imgLogo\" height = \"128\" width = \"128\" src=\""+ imgLogoSrc +"\"></td>";
//                    html += "<td width = \"33%\">&nbsp;</td>";
//                    html += "</tr>";

                    html += "<tr>";
                    html += "<td style = \"text-align: center;\">"+ company.physicalAdr +"</td>";
                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td style = \"text-align: center;\">"+ company.postalAdr +" - "+ company.postalCode +"</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td>"+ company.email +"</td>";
//                    html += "</tr>";
//
//                    html += "<tr>";
//                    html += "<td>"+ company.website +"</td>";
//                    html += "</tr>";

                    html += "<tr>";
//                    html += "<td>"+ company.telephone +"</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td style = \"text-align: center;\">"+ company.cellphone +"</td>";
                    html += "</tr>";
                     
//                    html += "Mobile : "+ company.cellphone +" ";
//                    html += "";
                    
//                    html += "<td width = \"33%\">";
//                    html += "</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>&nbsp;</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>&nbsp;</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>&nbsp;</td>";
//                    html += "</tr>";

//                    html += "<tr>";
//                    html += "<td colspan = \"3\"  align = \"center\">"+ this.rptName+ "</td>";
//                    html += "<td>"+ this.rptName+ "</td>";
//                    html += "</tr>";
                    
//                    java.util.Date now = new java.util.Date();
//
//                    String reportDateLbl = targetFormat.format(now);

//                    html += "<tr>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>&nbsp;</td>";
//                    html += "<td>"+ reportDateLbl+ "</td>";
//                    html += "</tr>";

                    html += "</table>";
                    
                    //                    html += "<tr>";
//                    html += "<td colspan = \"3\"  align = \"center\">"+ this.rptName+ "</td>";
//                    html += "<td>"+ this.rptName+ "</td>";
//                    html += "</tr>";
                
                    html += "<div style = \"width: 100%; padding: 7px; border-top: 1px solid #000; border-bottom: 1px solid #000; text-align:center;\">"+ this.rptName+ "</div>";

                }else{
                    html += "Company details not defined.";
                }
                
            }catch (Exception e){
                html += e.getMessage();
            }
            
            return html;
        }

        public String getReportHeaderx() {
            String html = "";
            Sys sys = new Sys();

            try {
                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm");

                String companyCode = sys.getOne(this.comCode+".CSCOPROFILE", "COMPANYCODE", "");
                
                html += "xx<br>"+ companyCode;
                

                if (companyCode != null) {

                    Company company = new Company(companyCode);

                    String imgLogoSrc;

                    if (sys.getOne(this.comCode+".CSCOLOGO", "LOGO", "COMPANYCODE = '" + companyCode + "'") != null) {
                        imgLogoSrc = "logo.jsp?code=" + companyCode;
                    } else {
                        imgLogoSrc = request.getContextPath() + "/assets/img/logo/default-logo.png";
                    }

                    html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"header\" >";

                    html += "<tr>";
                    html += "<td align = \"center\" colspan = \"4\">" + company.compName + "</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td width = \"33%\">&nbsp;</td>";
                    html += "<td rowspan = \"5\" align = \"center\"><img id = \"imgLogo\" height = \"128\" width = \"128\" src = \"" + imgLogoSrc + "\"></td>";
                    html += "<td width = \"33%\">&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td width = \"33%\">";
                    html += "" + company.postalAdr + " - " + company.postalCode + "  <br>";
                    html += "Email : " + company.email + " <br>";
                    html += "Website : " + company.website + " <br>";
                    html += "</td>";
                    html += "<td width = \"33%\">";
                    html += "Tel Office : " + company.telephone + " <br>";
                    html += "Mobile : " + company.cellphone + " ";
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
                    html += "<td colspan = \"3\"  align = \"center\">" + this.rptName + "</td>";
                    html += "</tr>";

                    java.util.Date now = new java.util.Date();

                    String reportDateLbl = targetFormat.format(now);

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>" + reportDateLbl + "</td>";
                    html += "</tr>";

                    html += "</table>";
                } else {
                    html += "Company details not defined.";
                }

            } catch (Exception e) {
                html += e.getMessage();
            }
            
            

            return html;
        }

        public String getReportDetails() {
            String html = "";

//            Sys sys = new Sys();
//
//            HmPyHdr hmPyHdr = new HmPyHdr(pyNo, this.comCode);
//
//            String entryDateLbl = "";
//
//            try {
//                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
//                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");
//
//                java.util.Date entryDate = originalFormat.parse(hmPyHdr.entryDate);
//                entryDateLbl = targetFormat.format(entryDate);
//            } catch (Exception e) {
//                html += e.getMessage();
//            }
//
//            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\">";
//
//            html += "<tr>";
//            html += "<td width = \"17%\" class = \"bold\">Bill No</td>";
//            html += "<td>" + this.pyNo + "</td>";
//            html += "</tr>";
//
//            html += "<tr>";
//            html += "<td class = \"bold\">Description</td>";
//            html += "<td>" + hmPyHdr.pyDesc + "</td>";
//            html += "</tr>";
//
//            html += "<tr>";
//            html += "<td class = \"bold\">Bill Date</td>";
//            html += "<td>" + entryDateLbl + "</td>";
//            html += "</tr>";
//
//            html += "<tr>";
//            html += "<td class = \"bold\">Period</td>";
//            html += "<td>" + hmPyHdr.pYear + " - " + hmPyHdr.pMonth + "</td>";
//            html += "</tr>";
//
//            html += "<tr>";
//            html += "<td class = \"bold\">Patient</td>";
//            html += "<td>" + hmPyHdr.fullName + "</td>";
//            html += "</tr>";
//
//            html += "<tr>";
//            html += "<td class = \"bold\">Tendered</td>";
//            html += "<td>" + sys.numberFormat(hmPyHdr.tender.toString()) + "</td>";
//            html += "</tr>";
//
//            html += "<tr>";
//            html += "<td class = \"bold\">Change</td>";
//            html += "<td>" + sys.numberFormat(hmPyHdr.change.toString()) + "</td>";
//            html += "</tr>";
//
//            html += "</table>";
//
//            html += "<br>";

            html += this.getPyDtls();

            return html;
        }

        public String getPyDtls() {
            String html = "";
            Sys sys = new Sys();

            if (sys.recordExists(this.comCode+".VIEWHMPYDTLS", "")) {

                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>User Id</th>";
                html += "<th>Type</th>";
                html += "<th>Date</th>";
                html += "</tr>";

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;
                    
                    SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                    SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                    java.util.Date entryDate1 = originalFormat.parse(this.entryDate1);
                    String entryDateLbl1 = targetFormat.format(entryDate1);
                    java.util.Date entryDate2 = originalFormat.parse(this.entryDate2);
                    String entryDateLbl2 = targetFormat.format(entryDate2);

                    query = " SELECT * FROM "+comCode+".sysses WHERE logdt::DATE BETWEEN '"+ entryDateLbl1+ "' AND '"+ entryDateLbl2+ "'  ORDER BY logdt DESC";
                    
//                    html += query;

                    ResultSet rs = stmt.executeQuery(query);

                    Integer count = 1;

                    while (rs.next()) {
                        Integer id = rs.getInt("ID");
                        String userid = rs.getString("userid");
                        String logtype = rs.getString("logtype");
                        String logdt = rs.getString("logdt");

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + userid + "</td>";
                        html += "<td>" + logtype + "</td>";
                        html += "<td>" + logdt + "</td>";

                        html += "</tr>";

                        count++;
                    }
                    
//                    html += "<br>";
                    
//                    html += "<table>";
//                    
//                    html += "<tr>";
//                    html += "<td style = \"text-align: left; font-weight: bold;\" colspan = \"\">Till No:</td>";
//                    html += "<td style = \"text-align: left; font-weight: bold;\" colspan = \"5\">510 6387</td>";
//                    
//                    html += "</table>";

                } catch (Exception e) {
                    html += e.getMessage();
                }

                html += "</table>";

            } else {
                html += "No record found.";
            }

            return html;
        }

        public String printRpt() {
            String html = "";

//            html += this.getReportHeader();
//            html += "<br>";
            html += this.getReportDetails();

            return html;
        }
    }

    PrintRpt printRpt = new PrintRpt();
//    out.print(printRptBill.entryDate);

    Gui gui = new Gui();

%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>User Logs</title>
        <%            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRpt.printRpt()%>

        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype"));%>

        <script language="javascript">
            Event.observe(window, 'load', function () {
                setTimeout('window.print();', '3000');
            });
        </script>
    </body>
</html>
