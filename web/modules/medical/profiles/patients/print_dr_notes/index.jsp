<%-- 
    Document   : index
    Created on : Jan 16, 2023, 10:16:51 AM
    Author     : nicholas
--%>
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
    final class PrintRptBill{
        HttpSession session = request.getSession();
        String comCode      = session.getAttribute("comCode").toString();
        String regNo = request.getParameter("regNo");
    
        String rptName  = "Doctor Notes";
        
        String table = comCode + ".HMREGISTRATION";
        
        String drNotes = request.getParameter("dr_notes") != null ? request.getParameter("dr_notes") : "";
        
        public String getReportHeader(){
            String html = "";
            Sys sys = new Sys();
            
            try{
                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy HH:mm");
                
                String companyCode = sys.getOne(""+this.comCode+".CSCOPROFILE", "COMPANYCODE", "");
                
//                html += "companyCode="+ companyCode;

                if(companyCode != null){

                    Company company = new Company(this.comCode);

                    String imgLogoSrc;

                    if(sys.getOne(""+this.comCode+".CSCOLOGO", "LOGO", "COMPANYCODE = '"+ this.comCode +"'") != null){
                        imgLogoSrc = "logo.jsp?code="+this.comCode;
                    }else{
                        imgLogoSrc = request.getContextPath()+"/assets/img/logo/default-logo.png";
                    }

                    html += "<table width =\"100%\" cellpadding = \"2\" cellspacing = \"0\"  class = \"header\" style=\"margin: 16px;\">";

                    html += "<tr>";
                    html += "<td align = \"center\" colspan = \"4\">"+ company.compName +"</td>";
                    html += "</tr>";

                    html += "<tr>";
                    html += "<td width = \"33%\">&nbsp;</td>";
                    html += "<td rowspan = \"5\" align = \"center\"><img id = \"imgLogo\" height = \"128\" width = \"128\" src = \""+ imgLogoSrc +"\"></td>";
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
                    
                    java.util.Date now = new java.util.Date();

                    String reportDateLbl = targetFormat.format(now);

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
            
            Sys sys = new Sys();
            
            if (sys.recordExists(this.table, "REGNO = '" + this.regNo + "'")) {
                try {
                    Connection conn = ConnectionProvider.getConnection();
                    Statement stmt = conn.createStatement();
                    String query = "SELECT * FROM " + this.table + " WHERE REGNO = '" + this.regNo + "'";
                    ResultSet rs = stmt.executeQuery(query);
                    while (rs.next()) {
                        this.drNotes = rs.getString("dr_notes");
                    }
                } catch (Exception e) {
                    html += e.getMessage();
                }

            }
            
            String[] arrOfStr = this.drNotes.split("\n");
            this.drNotes = String.join("<br>", arrOfStr);
            this.drNotes = this.drNotes != null ? this.drNotes : "";
            
//            
//            HmPyHdr hmPyHdr = new HmPyHdr(pyNo, this.comCode);
//            
//            String entryDateLbl = "";
//            
//            try{
//                SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
//                SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");
//
//                java.util.Date entryDate = originalFormat.parse(hmPyHdr.entryDate);
//                entryDateLbl = targetFormat.format(entryDate);
//            }catch(Exception e){
//                html += e.getMessage();
//            }
            
            html += "<table width = \"100%\" cellpadding = \"2\" cellspacing = \"0\" class = \"header\" style=\"margin: 16px;\">";

            html += "<tr>";
            html += "<td><hr></td>";
            html += "</tr>";

            html += "<tr>";
            html += "<td>"+ this.drNotes +"</td>";
            html += "</tr>";

//            html += "<tr>";
//            html += "<td class = \"bold\">Description</td>";
//            html += "<td>"+ hmPyHdr.pyDesc+ "</td>";
//            html += "</tr>";
//
//            html += "<tr>";
//            html += "<td class = \"bold\">Bill Date</td>";
//            html += "<td>"+ entryDateLbl+ "</td>";
//            html += "</tr>";
//
//            html += "<tr>";
//            html += "<td class = \"bold\">Period</td>";
//            html += "<td>"+ hmPyHdr.pYear+ " - "+ hmPyHdr.pMonth+ "</td>";
//            html += "</tr>";
//
//            html += "<tr>";
//            html += "<td class = \"bold\">Customer</td>";
//            html += "<td>"+ hmPyHdr.fullName+ "</td>";
//            html += "</tr>";

            html += "</table>";
            
            html += "<br>";
            
//            html += this.getPyDtls();
            
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
    
    PrintRptBill printRptBill = new PrintRptBill();
    
    Gui gui = new Gui();
    
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Doctor Notes</title>
    </head>
    <body>
        <%= printRptBill.printRpt()%>
        
        <% out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype")); %>
        
        <script language="javascript">
            Event.observe(window,'load',function(){
                setTimeout('window.print();', '3000');
            });
       </script>
    </body>
</html>
