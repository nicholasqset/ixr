<%-- 
    Document   : index
    Created on : Oct 7, 2015, 5:58:37 PM
    Author     : Nicholas
--%>
<%@page import="java.util.Enumeration"%>
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
    final class PrintRptTB{
        
        String rptName  = "Trial Balance";
        HttpSession session = request.getSession();
        String comCode      = session.getAttribute("comCode").toString();
        
        Integer pYear   = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth  = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
        Integer cuml    = (request.getParameter("cuml") != null && request.getParameter("cuml").trim().equals("on"))? 1: 0;
    
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
            
            html += "<table width = \"100%\" cellpadding = \"1\" cellspacing = \"0\" class = \"header\">";

            html += "<tr>";
            html += "<td width = \"17%\" class = \"bold\">Fiscal Year</td>";
            html += "<td>"+ this.pYear +"</td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td class = \"bold\">Fiscal Period</td>";
            html += "<td>"+ this.pMonth +"</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getTBDetails();
            
            return html;
        }
        
        public String getTBDetails(){
            String html = "";
            Sys sys = new Sys();

            if(sys.recordExists(comCode+".VIEWGLTB", "PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ "")){

                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>Account No</th>";
                html += "<th>Description</th>";
                html += "<th style = \"text-align: right;\">Debit</th>";
                html += "<th style = \"text-align: right;\">Credit</th>";
                html += "</tr>";
                
                Double smDrTotal = 0.0;
                Double smCrTotal = 0.0;
                
                Double drAmtTotal = 0.0;
                Double crAmtTotal = 0.0;
                
                

                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    
                    String query = "";
//                    System.out.println("query==="+ query);
                    if(this.cuml == 1){
//                        System.out.println("query2===");
                        String fiscalYear = sys.getOne("qset.fnfiscalprd", "FISCALYEAR", "PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ "");
//                        System.out.println("query2==="+ fiscalYear);
                        query = "SELECT * FROM "+comCode+".VIEWGLTBSMFY WHERE "
                            + "FISCALYEAR    = '"+ fiscalYear+ "' "
                            + "ORDER BY SORTORDER, ACCGRPCODE";
                    }else{
//                        System.out.println("query2===");
                        query = "SELECT * FROM "+comCode+".VIEWGLTBSM WHERE "
                            + "PYEAR    = "+ this.pYear+ " AND "
                            + "PMONTH   = "+ this.pMonth+ " "
                            + "ORDER BY SORTORDER, ACCGRPCODE";
                    }
                    
//                    out.println("query==="+ query);
                    System.out.println("query==="+ query);

                    ResultSet rs = stmt.executeQuery(query);
                    
                    while(rs.next()){
                        String accountCode  = rs.getString("ACCOUNTCODE");
                        String accountName  = rs.getString("ACCOUNTNAME");
                        String accType      = rs.getString("ACCTYPE");
                        
                        Double smDrAmount   = rs.getDouble("SMDRAMOUNT");
                        Double smCrAmount   = rs.getDouble("SMCRAMOUNT");
                        
                        Double drAmt_ = 0.0;
                        Double crAmt_ = 0.0;
                        
                        Double drAmt = 0.0;
                        Double crAmt = 0.0;
                        
                        switch(accType){
                            case "DR":                                
                                drAmt_ = smDrAmount - smCrAmount;
                                System.out.println("xyz side"+ drAmt_);
                                crAmt_ = 0.0;
                                if(drAmt_ < 0){
                                    drAmt = 0.0;
                                    crAmt = drAmt_ * -1;
                                }else{
                                    drAmt = drAmt_;
                                    crAmt_ = 0.0;
                                }
                                break;
                            case "CR":
                                drAmt_ = 0.0;
                                crAmt_ = smCrAmount - smDrAmount;
                                if(crAmt_ < 0){
                                    crAmt = 0.0;
                                    drAmt = crAmt_ * -1;
                                }else{
                                    drAmt = 0.0;
                                    crAmt = crAmt_;
                                }
                                break;
                        }

                        html += "<tr>";
                        html += "<td>"+ accountCode+ "</td>";
                        html += "<td>"+ accountName+ "</td>";
//                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(smDrAmount.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(drAmt.toString()) +"</td>";
//                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(smCrAmount.toString()) +"</td>";
                        html += "<td style = \"text-align: right;\">"+ sys.numberFormat(crAmt.toString()) +"</td>";
                        html += "</tr>";
                        
                        smDrTotal = smDrTotal + smDrAmount;
                        smCrTotal = smCrTotal + smDrAmount;
                        
                        drAmtTotal = drAmtTotal + drAmt;
                        crAmtTotal = crAmtTotal + crAmt;

                    }
                }catch (SQLException e){
                    html += e.getMessage();
                }catch (Exception e){
                    html += e.getMessage();
                }
                
                html += "<tr>";
                html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"2\">Total</td>";
//                html += "<td style = \"text-align: right; font-weight: bold;\" >"+ sys.numberFormat(smDrTotal.toString())+"</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\" >"+ sys.numberFormat(drAmtTotal.toString())+"</td>";
//                html += "<td style = \"text-align: right; font-weight: bold;\" >"+ sys.numberFormat(smCrTotal.toString())+"</td>";
                html += "<td style = \"text-align: right; font-weight: bold;\" >"+ sys.numberFormat(crAmtTotal.toString())+"</td>";
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
//    Enumeration params = request.getParameterNames(); 
//    while(params.hasMoreElements()){
//        String paramName = (String)params.nextElement();
//        out.print("Attribute Name = "+paramName+", Value = "+request.getParameter(paramName)+"<br>");
//    }
    
    PrintRptTB printRptTB = new PrintRptTB();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Trial Balance</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptTB.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
