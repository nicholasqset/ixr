<%@page import="bean.medical.HmPyHdr"%>
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
    final class PrintRptBill {
        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
//        out.print(comCode);
        
        String pyNo = request.getParameter("billNo") != null && !request.getParameter("billNo").trim().equals("") ? request.getParameter("billNo") : null;
        String entryDate = request.getParameter("entryDate");
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
                        imgLogoSrc = request.getContextPath()+"/images/logo/default-logo.png";
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
                        imgLogoSrc = request.getContextPath() + "/images/logo/default-logo.png";
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
                html += "<th>Doc #</th>";
                html += "<th nowrap>Payment Mode</th>";
                html += "<th>Item</th>";
                html += "<th style = \"text-align: right;\">Quantity</th>";
                html += "<th style = \"text-align: right;\">Price</th>";
                html += "<th style = \"text-align: right;\">Tax</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";
                html += "</tr>";

                Double sumAmount = 0.0;
                Double sumTax = 0.0;
                Double sumTotal = 0.0;

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;
                    
                    SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                    SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                    java.util.Date entryDate = originalFormat.parse(this.entryDate);
                    String entryDateLbl = targetFormat.format(entryDate);

                    query = "SELECT * FROM "+this.comCode+".VIEWHMPYDTLS WHERE ENTRYDATE::DATE = '"+entryDateLbl+"' ORDER BY PYNO DESC, ITEMCODE";
                    
//                    html += query;

                    ResultSet rs = stmt.executeQuery(query);

                    Integer count = 1;

                    while (rs.next()) {
                        Integer id = rs.getInt("ID");
                        String pyNo = rs.getString("PYNO");
                        String pmcode = rs.getString("pmcode");
                        String itemName = rs.getString("ITEMNAME");
                        Double qty = rs.getDouble("QTY");
                        Double unitPrice = rs.getDouble("UNITPRICE");
                        Double taxAmount = rs.getDouble("TAXAMOUNT");
                        Double amount = rs.getDouble("AMOUNT");
                        Double total = rs.getDouble("TOTAL");
                        Integer taxIncl = rs.getInt("TAXINCL");

                        Double taxAmountAlt = taxIncl == 1 ? taxAmount : 0;

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + pyNo + "</td>";
                        html += "<td>" + pmcode + "</td>";
                        html += "<td>" + itemName + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(qty.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(unitPrice.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(taxAmountAlt.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(amount.toString()) + "</td>";

                        html += "</tr>";

                        sumAmount = sumAmount + amount;
                        sumTax = sumTax + taxAmountAlt;
                        sumTotal = sumTotal + total;

                        count++;
                    }

                    html += "<tr>";
                    html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"6\">Total</td>";

                    html += "<td style = \"text-align: right; font-weight: bold;\">" + sys.numberFormat(sumTax.toString()) + "</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">" + sys.numberFormat(sumAmount.toString()) + "</td>";
                    html += "</tr>";
                    
                    

                    html += "</tr>";
                    
                    html += "<br>";
                    
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

    PrintRptBill printRptBill = new PrintRptBill();
//    out.print(printRptBill.entryDate);

    Gui gui = new Gui();

%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Fiscal Bill</title>
        <%            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptBill.printRpt()%>

        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype"));%>

        <script language="javascript">
            Event.observe(window, 'load', function () {
                setTimeout('window.print();', '3000');
            });
        </script>
    </body>
</html>
