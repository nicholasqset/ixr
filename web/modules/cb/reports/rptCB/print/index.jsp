<%@page import="bean.finance.CoBank"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
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
    final class PrintRptCb{
        
        String bkBranchCode   = request.getParameter("bankBranch");
        
        String rptName  = "Cash Book Report";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                
                String companyCode = system.getOne("CSCOPROFILE", "COMPANYCODE", "");

                if(companyCode != null){

                    Company company = new Company(companyCode);

                    String imgLogoSrc;

                    if(system.getOne("CSCOLOGO", "LOGO", "COMPANYCODE = '"+ companyCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+companyCode;
                    }else{
                        imgLogoSrc = request.getContextPath()+"/assets/img/logo/default-logo.png";
                    }

                    html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"header\" >";

                    html += "<tr>";
                    html += "<td align = \"center\" colspan = \"4\">"+ company.companyName +"</td>";
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

                    java.util.Date reportDate = originalFormat.parse(system.getLogDate());
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
            
            CoBank coBank = new CoBank(this.bkBranchCode);
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"20%\" class = \"bold\">Bank Code</td>";
            html += "<td>"+ this.bkBranchCode+ "</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td width = \"20%\" class = \"bold\">Description</td>";
            html += "<td>"+ coBank.bkBranchName+ "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getCbDtls();
            
            return html;
        }
        
        public String getCbDtls(){
            String html = "";

            Sys sys = new Sys();
            
            if(system.recordExists("VIEWCBCB", "BKBRANCHCODE = '"+ this.bkBranchCode+ "'")){
                
                html += "<table width = \"100%\" class = \"header\" cellpadding = \"2\" cellspacing = \"0\" >";

                html += "<tr>";
                html += "<th nowrap>Reference</th>";
                html += "<th nowrap>Description</th>";
                html += "<th nowrap>Date</th>";
                html += "<th nowrap>Account Code</th>";
                html += "<th nowrap>Description</th>";
                html += "<th style = \"text-align: right;\"  nowrap>Debit Amount</th>";
                html += "<th style = \"text-align: right;\"  nowrap>Credit Amount</th>";
                html += "</tr>";
                
                Double drTotal  = 0.0;
                Double crTotal  = 0.0;
                Double cbBal    = 0.0;
                
                try{
                    SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                    SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                    
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query = "SELECT * FROM VIEWCBCB WHERE BKBRANCHCODE = '"+ this.bkBranchCode+ "' ORDER BY ENTRYDATE";

                    ResultSet rs = stmt.executeQuery(query);

                    while(rs.next()){
                        String refNo        = rs.getString("REFNO");
                        String refDesc      = rs.getString("REFDESC");
                        String entryDate    = rs.getString("ENTRYDATE");
                        String accountCode  = rs.getString("ACCOUNTCODE");
                        String accountName  = rs.getString("ACCOUNTNAME");
                        Double drAmount     = rs.getDouble("DRAMOUNT");
                        Double crAmount     = rs.getDouble("CRAMOUNT");
                        
                        java.util.Date entryDate_ = originalFormat.parse(entryDate);
                        entryDate = targetFormat.format(entryDate_);
                        
                        html += "<tr>";
                        html += "<td nowrap>"+ refNo+ "</td>";
                        html += "<td nowrap>"+ refDesc+ "</td>";
                        html += "<td nowrap>"+ entryDate+ "</td>";
                        html += "<td nowrap>"+ accountCode+ "</td>";
                        html += "<td nowrap>"+ accountName+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(drAmount.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(crAmount.toString())+ "</td>";
                        html += "</tr>";

                        drTotal = drTotal + drAmount;
                        crTotal = crTotal + crAmount;
                    }
                    
                }catch(Exception e){
                    html += e.getMessage();
                }
                
                cbBal = drTotal - crTotal;
                
                String lblCbDrBal = "";
                String lblCbCrBal = "";
                
                if(cbBal >= 0){
                    lblCbDrBal = system.numberFormat(cbBal.toString());
                }else{
                    Double cbBalT = cbBal * -1;
                    lblCbCrBal = system.numberFormat(cbBalT.toString())+ " OD";
                }
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td style = \"text-align: right;\" nowrap>____________</td>";
                html += "<td style = \"text-align: right;\" nowrap>____________</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td style = \"font-weight: bold;\">Total</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(drTotal.toString())+ "</td>";
                html += "<td style = \"text-align: right;\">"+ system.numberFormat(crTotal.toString())+ "</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td style = \"text-align: right;\" nowrap>____________</td>";
                html += "<td>&nbsp;</td>";
                html += "</tr>";
                
                html += "<tr>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td>&nbsp;</td>";
                html += "<td style = \"font-weight: bold;\">Closing Balance</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\">"+ lblCbDrBal+ "</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\">"+ lblCbCrBal+ "</td>";
                html += "</tr>";
                
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
    
    PrintRptCb printRptCb = new PrintRptCb();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>CB Report</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptCb.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
