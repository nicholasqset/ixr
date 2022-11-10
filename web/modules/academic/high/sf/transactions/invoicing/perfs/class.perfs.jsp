<%@page import="bean.high.HighCalendar"%>
<%@page import="java.util.*"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class PerFS{
    HttpSession session     = request.getSession();
        String comCode          = session.getAttribute("comCode").toString();
        String table            = comCode+".HGFSHDR";
    String view             = comCode+".VIEWHGFSHEADER";
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String formCode         = request.getParameter("studentForm");
    String studTypeCode     = request.getParameter("studentType");
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getInvsTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Invoice", "save.png", "onclick = \"perFS.invoice('academicYear term studentForm studentType item amount'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Auto Invoice\'), 0, 625, 420, Array(false));";
        html += "</script>";
        
        return html;
    }
    
    public String getInvsTab(){
        String html = "";
        
        Gui gui = new Gui();
        
        HighCalendar highCalendar = new HighCalendar();
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"calendar.png", "", "")+ gui.formLabel("academicYear", " Academic Year")+ "</td>";
        html += "<td>"+ gui.formSelect("academicYear", ""+this.comCode+".HGACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", ""+ highCalendar.academicYear, "onchange = \"perFS.getFSDtls();perFS.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("term", " Term")+ "</td>";
	html += "<td>"+ gui.formSelect("term", ""+this.comCode+".HGTERMS", "TERMCODE", "TERMNAME", "", "", highCalendar.termCode, "onchange = \"perFS.getFSDtls();perFS.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("studentForm", " Student Form")+ "</td>";
	html += "<td>"+ gui.formSelect("studentForm", ""+this.comCode+".HGFORMS", "FORMCODE", "FORMNAME", "", "", "", "onchange = \"perFS.getFSDtls();perFS.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("studentType", " Student Type")+ "</td>";
	html += "<td>"+ gui.formSelect("studentType", ""+this.comCode+".HGSTUDTYPES", "STUDTYPECODE", "STUDTYPENAME", "", "", "", "onchange = \"perFS.getFSDtls();perFS.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td><div id = \"progress\">&nbsp;</div></td>";
	html += "</tr>";
        
//        html += "<tr>";
//	html += "<td colspan = \"2\"><div class = \"hr\"></div></td>";
//	html += "</tr>";
        
        html += "<tr>";
	html += "<td colspan = \"2\">";
        
        html += "<table width = \"100%\" class = \"module\" cellpadding = \"5\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"50%\" style = \"vertical-align: top;\"><div id = \"dvStudents\">"+ this.getStudents()+ "</div></td>";
	html += "<td style = \"vertical-align: top;\"><div id = \"dvFSDtls\">"+ this.getFSDtls()+ "</div></td>";
	html += "</tr>";
        
	html += "</table>";
        
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public String getStudents(){
        String html = "";
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        if(sys.recordExists(""+this.comCode+".VIEWHGSTUDENTPROFILE", "FORMCODE = '"+ this.formCode+ "' AND TERMCODE = '"+ this.termCode+ "' AND STUDTYPECODE = '"+ this.studTypeCode+ "'")){
            
            String checkAll = gui.formCheckBox("checkall", "", "", "onchange = \"perFS.checkAll();\"", "", "");
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>"+ checkAll+ "</th>";
            html += "<th>Student No</th>";
            html += "<th>Name</th>";
            html += "</tr>";
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+this.comCode+".VIEWHGSTUDENTPROFILE WHERE FORMCODE = '"+ this.formCode+ "' AND TERMCODE = '"+ this.termCode+ "' AND STUDTYPECODE = '"+ this.studTypeCode+ "' ORDER BY STUDENTNO";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String studentNo    = rs.getString("STUDENTNO");
                    String fullName     = rs.getString("FULLNAME");
                    
                    Boolean autoInvoiced = sys.recordExists(""+this.comCode+".VIEWHGINVSDETAILS", "ACADEMICYEAR = "+ this.academicYear+ " AND "
                            + "TERMCODE     = '"+ this.termCode+"' AND "
                            + "STUDENTNO    = '"+ studentNo+"' AND "
                            + "INVTYPE      = 'AT' "
                            + ""
                            + "");
                    
                    String checked = autoInvoiced == true? "checked": "";
                    
                    String checkEach = gui.formArrayCheckBox("checkEach", checked, studentNo, "", "", "");
                    
                    html += "<tr>";
//                    html += "<td>"+ count+ "</td>";
                    html += "<td>"+ checkEach+ "</td>";
                    html += "<td>"+ studentNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
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
            html += "No students record found.";
        }
        
        return html;
    }
    
    public String getFSDtls(){
        String html = "";
        
        Sys sys = new Sys();
        
        if(sys.recordExists(""+this.comCode+".VIEWHGFSDETAILS", "ACADEMICYEAR = "+ this.academicYear+ " AND "
                + "TERMCODE     = '"+ this.termCode+ "' AND "
                + "FORMCODE     = '"+ this.formCode+ "' AND "
                + "STUDTYPECODE = '"+ this.studTypeCode+ "' ")){
            
            
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>#</th>";
            html += "<th>Item</th>";
            html += "<th style = \"text-align: right;\">Amount</th>";
            html += "</tr>";
            
            Double total   = 0.0;
            
            try{
                
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                Integer count  = 1;
                
                String query = "SELECT * FROM "+this.comCode+".VIEWHGFSDETAILS WHERE ACADEMICYEAR = "+ this.academicYear+ " AND "
                        + "TERMCODE     = '"+ this.termCode+ "' AND "
                        + "FORMCODE     = '"+ this.formCode+ "' AND "
                        + "STUDTYPECODE = '"+ this.studTypeCode+ "' ";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String itemName     = rs.getString("ITEMNAME");
                    Double amount       = rs.getDouble("AMOUNT");
                    
                    String amountLbl    = sys.numberFormat(amount.toString());
                    
                    html += "<tr>";
                    html += "<td>"+ count +"</td>";
                    html += "<td>"+ itemName +"</td>";
//                    html += "<td style = \"text-align: right;\">"+ amount +"</td>";
                    html += "<td style = \"text-align: right;\">"+ amountLbl +"</td>";
                    html += "</tr>";
                    
                    total = total + amount;

                    count++;
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            String totalLbl    = sys.numberFormat(total.toString());
            
            html += "<tr>";
            html += "<td style = \"text-align: center; font-weight: bold;\" colspan = \"2\">Total</td>";
//            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ total +"</td>";
            html += "<td style = \"text-align: right; font-weight: bold;\" >"+ totalLbl +"</td>";
            html += "</tr>";
            
            html += "</table>";
            
        }else{
            html += "No fees structure items record found.";
        }
        
        return html;
    }
    
}

%>