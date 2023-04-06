<%-- 
    Document   : index
    Created on : Oct 7, 2015, 5:58:37 PM
    Author     : Nicholas
--%>
<%@page import="com.qset.gl.GLCOA"%>
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
    final class PrintRptBS{
        HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        
        Integer pYear       = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth      = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
        String accountCode  = request.getParameter("glAccount");
    
        String rptName  = "";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
                SimpleDateFormat targetFormat2  = new SimpleDateFormat("MMMMM dd, yyyy");
                
//                Date convertedDate = originalFormat.parse(sys.getLogDate());
                Date convertedDate = originalFormat.parse(this.pYear+ "-"+ this.pMonth+ "-"+ "01");
                Calendar c = Calendar.getInstance();
                c.setTime(convertedDate);
                c.set(Calendar.DAY_OF_MONTH, c.getActualMaximum(Calendar.DAY_OF_MONTH));
                
                this.rptName  = "Chart of Accounts ";

//                String comCode = sys.getOne("CSCOPROFILE", "COMPANYCODE", "");

                if(comCode != null){

                    Company company = new Company(comCode);

                    String imgLogoSrc;

                    if(sys.getOne(comCode+".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ comCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+comCode;
                    }else{
                        imgLogoSrc = request.getContextPath()+"/assets/img/logo/default-logo.png";
                    }

                    html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"header\" >";

                    html += "<tr>";
                    html += "<td style = \"text-align: center; font-weight :bold; \" colspan = \"4\">"+ company.compName +"</td>";
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
            html += "<td>"+ this.pMonth+ "</td>";
            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
            html += this.getPLDetails();
            
            return html;
        }
        
        public String getPLDetails(){
            String html = "";
            Sys sys = new Sys();
            GLCOA gLCOA = new GLCOA(comCode);

            if(sys.recordExists(comCode+".VIEWGLACCOUNTS", "")){

                html += "<table style = \"width: 100%;\" class = \"details\" cellpadding = \"2\" cellspacing = \"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Account</th>";
                html += "<th>Description</th>";
                html += "<th>Type</th>";
                html += "<th>Balance</th>";
                html += "<th>Amount</th>";
                html += "<th>Budget</th>";
                html += "</tr>";

                try{
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();

                    String query;

                    if(this.accountCode != null && ! this.accountCode.trim().equals("")){
                        query = "SELECT * FROM "+comCode+".VIEWGLACCOUNTS WHERE ACCOUNTCODE = '"+ this.accountCode+ "' ORDER BY ACCOUNTCODE";
                    }else{
                        query = "SELECT * FROM "+comCode+".VIEWGLACCOUNTS ORDER BY ACCOUNTCODE";
                    }

                    ResultSet rs = stmt.executeQuery(query);

                    Integer count  = 1;

                    while(rs.next()){
                        String accountCode  = rs.getString("ACCOUNTCODE");
                        String accountName  = rs.getString("ACCOUNTNAME");
                        String accTypeName  = rs.getString("ACCTYPENAME");
                        String normalBal    = rs.getString("NORMALBAL");

                        String normalBal_   = "";
                        if(normalBal.equals("DR")){
                            normalBal_ = "Debit";
                        }else if(normalBal.equals("CR")){
                            normalBal_ = "Credit";
                        }

                        Double accBal = gLCOA.getAccountBal(this.pYear, this.pMonth, accountCode);

                        Double bdg = 0.0;
                        String bdg_ = sys.getOne(comCode+".GLBDG", "AMOUNT", "PYEAR = "+ this.pYear+ " AND PMONTH = "+ this.pMonth+ " AND ACCOUNTCODE = '"+ accountCode+ "'");
                        bdg = (bdg_ != null && ! bdg_.trim().equals(""))? Double.parseDouble(bdg_): bdg;

                        html += "<tr>";
                        html += "<td>"+ count+ "</td>";
                        html += "<td>"+ accountCode+ "</td>";
                        html += "<td>"+ accountName+ "</td>";
                        html += "<td>"+ accTypeName+ "</td>";
                        html += "<td>"+ normalBal_+ "</td>";
                        html += "<td>"+ sys.numberFormat(accBal.toString())+ "</td>";
                        html += "<td>"+ sys.numberFormat(bdg.toString())+ "</td>";
                        html += "</tr>";

                        count++;
                    }
                }catch (SQLException e){
                    html += e.getMessage();
                }catch (Exception e){
                    html += e.getMessage();
                }

                html += "</table>";

            }else{
                html += "No GL Accounts record found.";
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
    
    PrintRptBS printRptBS = new PrintRptBS();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Chart of Accounts</title>
        <% 
            out.print(gui.loadCss(request.getContextPath(), "reports"));
        %>
    </head>
    <body>
        <%= printRptBS.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
