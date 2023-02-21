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
    final class PrintRpt {

        HttpSession session = request.getSession();
        String comCode = session.getAttribute("comCode").toString();
//        out.print(comCode);

        String catCode = request.getParameter("category");
        String stockGroup = request.getParameter("stockGroup");

        String rptName = "Stock";

        public String getReportHeader() {
            String html = "";
            Sys system = new Sys();

            try {
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm");
//                String companyCode = system.getOne("sys.coms", "COMCODE", "");

                if (comCode != null) {

                    Company company = new Company(comCode);

                    String imgLogoSrc;

                    if (system.getOne(comCode + ".CSCOLOGO", "LOGO", "COMPANYCODE = '" + comCode + "'") != null) {
                        imgLogoSrc = "logo.jsp?code=" + comCode;
                    } else {
                        imgLogoSrc = request.getContextPath() + "/images/logo/default-logo.png";
                    }

                    html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"header\">";

                    html += "<tr>";
                    html += "<td style = \"font-weight: bold; text-align: center;\">" + company.compName + "</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td style = \"text-align: center;\">" + company.physicalAdr + "</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td style = \"text-align: center;\">" + company.cellphone + "</td>";
                    html += "</tr>";
                    html += "</table>";

                    html += "<div style = \"width: 100%; padding: 7px; border-top: 1px solid #000; border-bottom: 1px solid #000; text-align:center;\">" + this.rptName + "</div>";

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

            html += this.getPyDtls();

            return html;
        }

        public String getPyDtls() {
            String html = "";
            Sys sys = new Sys();

            if (sys.recordExists(this.comCode + ".VIEWICITEMS", "")) {
            
                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Item #</th>";
                html += "<th>Name</th>";
                html += "<th style = \"text-align: right;\">Original Stock</th>";
                html += "<th style = \"text-align: right;\">Quantity</th>";
                html += "<th style = \"text-align: right;\">Cost</th>";
                html += "<th style = \"text-align: right;\">Price</th>";
                html += "<th style = \"text-align: right;\">Total Price</th>";
                html += "</tr>";

                Double sumAmount = 0.0;
                Double sumTax = 0.0;
                Double sumTotal = 0.0;

                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    if (stockGroup.equals("low")) {
                        if (catCode.trim().equals("") || catCode == null) {
                            query = "SELECT * FROM " + this.comCode + ".VIEWICITEMS WHERE qty <= minlevel AND STOCKED = 1 ORDER BY ITEMCODE";
                        } else {
                            query = " SELECT * FROM " + session.getAttribute("comCode") + ".VIEWICITEMS WHERE catcode = '" + catCode + "' AND qty <= minlevel AND STOCKED = 1 ";
                        }
                    } else if (stockGroup.equals("exp")) {
                        if (catCode.trim().equals("") || catCode == null) {
                            query = "SELECT * FROM " + this.comCode + ".VIEWICITEMS WHERE expdt < '"+sys.getLogDate()+"' ORDER BY ITEMCODE";
                        } else {
                            query = " SELECT * FROM " + session.getAttribute("comCode") + ".VIEWICITEMS WHERE catcode = '" + catCode + "' AND expdt < '"+sys.getLogDate()+"'";
                        }
                    } else {
                        if (catCode.trim().equals("") || catCode == null) {
                            query = "SELECT * FROM " + this.comCode + ".VIEWICITEMS WHERE 1 = 1 ORDER BY ITEMCODE";
                        } else {
                            query = " SELECT * FROM " + session.getAttribute("comCode") + ".VIEWICITEMS WHERE catcode = '" + catCode + "' ";
                        }
                    }

                    ResultSet rs = stmt.executeQuery(query);

                    Integer count = 1;

                    while (rs.next()) {
                        Integer id = rs.getInt("ID");
                        String itemCode = rs.getString("ITEMCODE");
                        String itemName = rs.getString("ITEMNAME");
                        Double maxlevel = rs.getDouble("maxlevel");
                        Double qty = rs.getDouble("QTY");
                        Double unitCost = rs.getDouble("UNITCOST");
                        Double unitPrice = rs.getDouble("UNITPRICE");

                        Double amount = qty * unitPrice;

                        html += "<tr>";
                        html += "<td>" + count + "</td>";
                        html += "<td>" + itemCode + "</td>";
                        html += "<td>" + itemName + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(maxlevel.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(qty.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(unitCost.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(unitPrice.toString()) + "</td>";
                        html += "<td style = \"text-align: right;\">" + sys.numberFormat(amount.toString()) + "</td>";

                        html += "</tr>";

                        sumAmount = sumAmount + amount;

                        count++;
                    }

                    html += "<tr>";
                    html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"7\">Total</td>";

                    html += "<td style = \"text-align: right; font-weight: bold;\">" + sys.numberFormat(sumAmount.toString()) + "</td>";
                    html += "</tr>";

                    html += "</tr>";

                    html += "<br>";

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

    Gui gui = new Gui();

%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Stock</title>
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
