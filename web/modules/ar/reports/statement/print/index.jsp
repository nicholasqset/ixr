<%-- 
    Document   : index
    Created on : Dec 23, 2019, 2:55:45 PM
    Author     : nicholas
--%>

<%@page import="bean.ar.ARCustomerProfile"%>
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
    final class PrintRptStmt{
        HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        
        String customerNo   = request.getParameter("customerNo") != null && ! request.getParameter("customerNo").trim().equals("")? request.getParameter("customerNo"): null;
    
        String rptName      = "Customer Statement";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
                if(comCode != null){
                    Company company = new Company(comCode);

                    String imgLogoSrc;

                    if(sys.getOne(comCode+".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+comCode;
                    }else{
                        imgLogoSrc = request.getContextPath()+"/images/logo/default-logo.png";
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
            
            ARCustomerProfile aRCustomerProfile = new ARCustomerProfile(this.customerNo, this.comCode);
            
            String entryDateLbl = "";
            
                      
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"17%\" class = \"bold\">Customer No</td>";
            html += "<td>"+ this.customerNo +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Description</td>";
            html += "<td>"+ aRCustomerProfile.customerName+ "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getStmtDtls();
            
            return html;
        }
        
        public String getStmtDtls(){
            String html = "";
            Sys sys = new Sys();

            if(sys.recordExists(comCode+".VIEWAROB", "CUSTOMERNO = '"+ this.customerNo+ "'")){

                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

               html += "<tr>";
                html += "<th>#</th>";
                html += "<th style = \"text-align: left;\">Document No</th>";
                html += "<th style = \"text-align: left;\">Description</th>";
                html += "<th style = \"text-align: left;\">Type</th>";
                html += "<th style = \"text-align: left;\">Date</th>";
                html += "<th style = \"text-align: left;\">Reference</th>";
                html += "<th style = \"text-align: right;\">Amount</th>";
                html += "</tr>";
            
                Double sumAmount    = 0.0;

                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    query = "SELECT * FROM "+comCode+".VIEWAROB WHERE CUSTOMERNO = '"+ this.customerNo+ "' ORDER BY DOCDATE";

                    ResultSet rs = stmt.executeQuery(query);

                    Integer count  = 1;
                    
                    while(rs.next()){
                        String docNo        = rs.getString("DOCNO");
                        String docDesc      = rs.getString("DOCDESC");
                        String docType      = rs.getString("DOCTYPE");
                        String docDate      = rs.getString("DOCDATE");
                        
                        String refNo        = rs.getString("REFNO");
                        Double amount       = rs.getDouble("AMOUNT");
                        
                        amount  = docType.equals("PY")? amount * -1: amount;

                        html += "<tr>";
                        html += "<td>"+ count +"</td>";
                        html += "<td>"+ docNo +"</td>";
                        html += "<td>"+ docDesc +"</td>";
                        html += "<td>"+ docType +"</td>";
                        html += "<td>"+ docDate +"</td>";
                        html += "<td>"+ refNo +"</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(amount.toString()) +"</td>";
                        html += "</tr>";

                        sumAmount   = sumAmount + amount;

                        count++;
                    }
                    
                    html += "<tr>";
                    html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"6\">Total</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ sys.numberFormat(sumAmount.toString()) +"</td>";
                    html += "</tr>";
                    
                }catch (SQLException e){
                    html += e.getMessage();
                }catch (Exception e){
                    html += e.getMessage();
                }

                html += "</table>";

            }else{
                html += "No record found.";
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
    
    PrintRptStmt printRptStmt = new PrintRptStmt();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Customer Statement</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptStmt.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
