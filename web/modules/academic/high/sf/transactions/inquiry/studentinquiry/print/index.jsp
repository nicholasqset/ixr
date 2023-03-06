<%-- 
    Document   : index
    Created on : Oct 7, 2015, 5:58:37 PM
    Author     : Nicholas
--%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="bean.high.HGStudentProfile"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.commonsrv.Company"%>
<%@page import="bean.gui.Gui"%>
<%@page import="bean.sys.Sys"%>
<%
    final class RptStudentInquiry{
        HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        public String studentNo = request.getParameter("studentNo");
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

                String companyCode = sys.getOne("CSCOPROFILE", "COMPANYCODE", "");

                if(companyCode != null){

                    Company company = new Company(companyCode);

                    String imgLogoSrc;

                    if(sys.getOne("CSCOLOGO", "LOGO", "COMPANYCODE = '"+ companyCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+companyCode;
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
                    html += "<td colspan = \"3\"  align = \"center\">Student Statement</td>";
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
            
            HGStudentProfile hGStudentProfile = new  HGStudentProfile(this.studentNo, this.comCode);
                
            html += "<table width = \"100%\" cellpadding = \"1\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"17%\" class = \"bold\">Student No</td>";
            html += "<td>"+ this.studentNo +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Name</td>";
            html += "<td>"+ hGStudentProfile.fullName +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Gender</td>";
            html += "<td>"+ hGStudentProfile.genderName +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Student Period</td>";
            html += "<td>"+ hGStudentProfile.studPrdName +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Student Type</td>";
            html += "<td>"+ hGStudentProfile.studTypeName +"</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getStudentStatement(this.studentNo);
            
            return html;
        }
        
        public String getStudentStatement(String studentNo){
            String html = "";
            Sys sys = new Sys();

            SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

            if(sys.recordExists("VIEWHGOBS", "STUDENTNO = '"+ this.studentNo+ "'")){

                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

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
                            + "FROM VIEWHGOBS "
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

                        String drLbl = sys.numberFormat(dr.toString());
                        String crLbl = sys.numberFormat(cr.toString());

                        grossTotal = grossTotal +totalAcc;

                        grossTotalLbl = sys.numberFormat(grossTotal.toString());

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

                grossTotalLbl = sys.numberFormat(grossTotal.toString());

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
        
        public String printInvoice(){
            String html = "";
            
            html += this.getReportHeader();
            html += "<br>";
            html += this.getReportDetails();
            
            return html;
        }
    }
    
    RptStudentInquiry rptInvoice = new RptStudentInquiry();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Student Statement</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= rptInvoice.printInvoice() %>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
