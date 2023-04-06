<%@page import="com.qset.finance.CoBank"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
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
    final class PrintRptRcn{
        
        String bkBranchCode   = request.getParameter("bankBranch");
        
        String rptName  = "Reconciliation Report";
        
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
            
            html += this.getRcnDtls();
            
            return html;
        }
        
        public String getRcnDtls(){
            String html = "";

            Sys sys = new Sys();
            
            if(system.recordExists("VIEWCBCB", "BKBRANCHCODE = '"+ this.bkBranchCode+ "'")){
                try{
                    String cbDrTotal_ = system.getOneAgt("VIEWCBCB", "SUM", "DRAMOUNT", "SM", "BKBRANCHCODE = '"+ this.bkBranchCode+ "'");
                    cbDrTotal_ = cbDrTotal_ != null? cbDrTotal_: "0";
                    Double cbDrTotal = Double.parseDouble(cbDrTotal_);
                    String cbCrTotal_ = system.getOneAgt("VIEWCBCB", "SUM", "CRAMOUNT", "SM", "BKBRANCHCODE = '"+ this.bkBranchCode+ "'");
                    cbCrTotal_ = cbCrTotal_ != null? cbCrTotal_: "0";
                    Double cbCrTotal = Double.parseDouble(cbCrTotal_);

                    Double cbCurBal = cbDrTotal - cbCrTotal;

                    String lblCbDrTotal = "";
                    String lblCbCrTotal = "";

                    if(cbCurBal >= 0){
                        lblCbDrTotal    = system.numberFormat(cbCurBal.toString());
                    }else{
                        Double cbCurBalP        = cbCurBal * -1;
                        lblCbCrTotal    = system.numberFormat(cbCurBalP.toString());
                    }
                
                    html += "<table width = \"100%\" class = \"header\" cellpadding = \"2\" cellspacing = \"0\" >";

                    html += "<tr>";
                    html += "<th nowrap>Reference</th>";
                    html += "<th nowrap>Description</th>";
                    html += "<th nowrap>Date</th>";
                    html += "<th nowrap>Account Code</th>";
                    html += "<th nowrap>Description</th>";
                    html += "<th style = \"text-align: right;\"  nowrap>Debit Amount</th>";
                    html += "<th style = \"text-align: right;\"  nowrap>Credit Amount</th>";
                    html += "<th style = \"text-align: right;\"  nowrap>Original Amount</th>";
                    html += "<th style = \"text-align: right;\"  nowrap>Recon. Amount</th>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td style = \"font-weight: bold;\">CB Current Balance</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ lblCbDrTotal+ "</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ lblCbCrTotal+ "</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    Double drVarPTotal  = 0.0;
                    Double crVarPTotal  = 0.0;
                    Double rcnBal        = 0.0;
                
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
                        String normalBal    = rs.getString("NORMALBAL");
                        Double drAmount     = rs.getDouble("DRAMOUNT");
                        Double crAmount     = rs.getDouble("CRAMOUNT");
                        Double rcnAmount    = rs.getDouble("RCNAMOUNT");
                        Double rcnVar       = rs.getDouble("RCNVAR");
                        
                        java.util.Date entryDate_ = originalFormat.parse(entryDate);
                        entryDate = targetFormat.format(entryDate_);
                        
                        Double orgAmount    = 0.0;
                        
                        Double drVar        = 0.0;
                        Double drVarP       = 0.0;
                        Double crVar        = 0.0;
                        Double crVarP       = 0.0;
                        Double drNF         = 0.0;
                        Double crNF         = 0.0;
                        
                        if(normalBal.equals("DR")){
                            orgAmount   = drAmount;
                            drVar       = rcnVar;
                            drVarP      = drVar * -1;
                            if(rcnAmount == 0 && rcnVar == 0){
                                orgAmount = 0.0;
                                drVarP    = drAmount;
                            }
                            if(drVarP < 0){
                                drNF = drVarP * -1;
                                drVarP = 0.0;
                            }
                        }else if(normalBal.equals("CR")){
                            orgAmount   = crAmount * -1;
                            crVar       = rcnVar;
                            crVarP      = crVar;
                            if(rcnAmount == 0 && rcnVar == 0){
                                orgAmount = 0.0;
                                crVarP    = crAmount;
                            }
                            if(crVarP < 0){
                                crNF = crVarP * -1;
                                crVarP = 0.0;
                            }
                        }
                        
                        drVarP = drVarP + crNF;
                        crVarP = crVarP + drNF;
                        
                        if(drVarP == -0){
                            drVarP = 0.0;
                        }
                        if(crVarP == -0){
                            crVarP = 0.0;
                        }
                        
                        html += "<tr>";
                        html += "<td nowrap>"+ refNo+ "</td>";
                        html += "<td nowrap>"+ refDesc+ "</td>";
                        html += "<td nowrap>"+ entryDate+ "</td>";
                        html += "<td nowrap>"+ accountCode+ "</td>";
                        html += "<td nowrap>"+ accountName+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(drVarP.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(crVarP.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(orgAmount.toString())+ "</td>";
                        html += "<td style = \"text-align: right;\">"+ system.numberFormat(rcnAmount.toString())+ "</td>";
                        html += "</tr>";

                        drVarPTotal = drVarPTotal + drVarP;
                        crVarPTotal = crVarPTotal + crVarP;
                    }
              
                    rcnBal = drVarPTotal - crVarPTotal;
                    
                    Double bkStmtBal = cbCurBal - rcnBal;
                    
                    String lblRcnDrBal = "";
                    String lblRcnCrBal = "";

                    if(bkStmtBal >= 0){
                        lblRcnDrBal = system.numberFormat(bkStmtBal.toString());
                    }else{
                        Double cbBalT = bkStmtBal * -1;
                        lblRcnCrBal = system.numberFormat(cbBalT.toString())+ " OD";
                    }

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td style = \"text-align: right;\" nowrap>____________</td>";
                    html += "<td style = \"text-align: right;\" nowrap>____________</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td style = \"font-weight: bold;\">Total</td>";
                    html += "<td style = \"text-align: right;\">"+ system.numberFormat(drVarPTotal.toString())+ "</td>";
                    html += "<td style = \"text-align: right;\">"+ system.numberFormat(crVarPTotal.toString())+ "</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td style = \"text-align: right;\" nowrap>____________</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td style = \"font-weight: bold;\">Bank Statement Balance</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ lblRcnDrBal+ "</td>";
                    html += "<td style = \"text-align: right; font-weight: bold;\">"+ lblRcnCrBal+ "</td>";
                    html += "<td>&nbsp;</td>";
                    html += "<td>&nbsp;</td>";
                    html += "</tr>";

                    html += "</table>";
                
                }catch(Exception e){
                    html += e.getMessage();
                }
                
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
    
    PrintRptRcn printRptRcn = new PrintRptRcn();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Reconciliation Report</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptRcn.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
