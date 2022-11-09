<%@page import="org.json.JSONObject"%>
<%@page import="bean.high.HGStudentProfile"%>
<%@page import="bean.high.HighCalendar"%>
<%@page import="java.util.*"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>
<%@page import="bean.gui.*"%>
<%@page import="java.sql.*"%>
<%

final class PerFeesItem{
        
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").toString().trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String formCode         = request.getParameter("studentForm");
    String studTypeCode     = request.getParameter("studentType");
    String itemCode         = request.getParameter("item");
    Double amount           = (request.getParameter("amount") != null && ! request.getParameter("amount").toString().trim().equals(""))? Double.parseDouble(request.getParameter("amount")): 0.0;
    
    public String getModule(){
        String html = "";
        
        Gui gui = new Gui();
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
            
        html += "<div id = \"dhtmlgoodies_tabView1\">";
        
        html += "<div class = \"dhtmlgoodies_aTab\">"+this.getInvsTab()+"</div>";
        
        html += "</div>";
        
	html += "<div style=\"padding-left: 10px; padding-top: 37px; border: 0;\" >";
	html += gui.formButton(request.getContextPath(), "button", "btnProcess", "Invoice", "save.png", "onclick = \"perFeesItem.process('academicYear term studentForm studentType item amount'); return false;\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule(); return false;\"", "");
	html += "</div>";
        
        html += gui.formEnd();
        
        html += "<script type = \"text/javascript\">";
        html += "initTabs(\'dhtmlgoodies_tabView1\', Array(\'Invoices\'), 0, 625, 420, Array(false));";
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
        html += "<td>"+ gui.formSelect("academicYear", "HGACADEMICYEARS", "ACADEMICYEAR", "", "ACADEMICYEAR DESC", "", ""+ highCalendar.academicYear, "onchange = \"perFeesItem.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("term", " Term")+ "</td>";
	html += "<td>"+ gui.formSelect("term", "HGTERMS", "TERMCODE", "TERMNAME", "", "", highCalendar.termCode, "onchange = \"perFeesItem.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("studentForm", " Student Form")+ "</td>";
	html += "<td>"+ gui.formSelect("studentForm", "HGFORMS", "FORMCODE", "FORMNAME", "", "", "", "onchange = \"perFeesItem.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("studentType", " Student Type")+ "</td>";
	html += "<td>"+ gui.formSelect("studentType", "HGSTUDTYPES", "STUDTYPECODE", "STUDTYPENAME", "", "", this.id != null? this.studTypeCode: "", "onchange = \"perFeesItem.getStudents();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("item", " Fee Item")+ "</td>";
	html += "<td>"+ gui.formSelect("item", "HGITEMS", "ITEMCODE", "ITEMNAME", "", "", "", "onchange = \"perFeesItem.getStudents(); perFeesItem.getItemAmount();\"", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+gui.formIcon(request.getContextPath(),"money.png", "", "")+ gui.formLabel("amount", " Amount")+"</td>";
	html += "<td>"+gui.formInput("text", "amount", 15, "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td><div id = \"progress\">&nbsp;</div></td>";
	html += "</tr>";
        
       
        html += "<tr>";
	html += "<td colspan = \"2\" style = \"vertical-align: top;\"><div id = \"dvStudents\">"+ this.getStudents()+ "</div></td>";
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
                
        return html;
    }
    
    public Object getItemAmount() throws Exception{
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        
        String amount = sys.getOne("VIEWHGFSDETAILS", "AMOUNT", "ACADEMICYEAR = "+ this.academicYear+" AND "
                + "TERMCODE = '"+ this.termCode+ "' AND "
                + "FORMCODE = '"+ this.formCode+ "' AND "
                + "STUDTYPECODE = '"+ this.studTypeCode+ "' AND "
                + "ITEMCODE = '"+ this.itemCode+ "' "
                );
        
        amount = amount != null? amount: "0";
        
        obj.put("amount", amount);
                    
        
        return obj;
    }
    
    public String getStudents(){
        String html = "";
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        if(sys.recordExists("VIEWHGSTUDENTPROFILE", "FORMCODE = '"+ this.formCode+ "' AND STUDTYPECODE = '"+ this.studTypeCode+ "'")){
            
            String checkAll = gui.formCheckBox("checkall", "", "", "onchange = \"perFeesItem.checkAll();\"", "", "");
            
            html += "<table style = \"width: 100%;\" class = \"ugrid\" cellpadding = \"2\" cellspacing = \"0\">";
            
            html += "<tr>";
            html += "<th>"+ checkAll+ "</th>";
            html += "<th>Student No</th>";
            html += "<th>Name</th>";
            html += "</tr>";
            
            Double total   = 0.0;
            
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM VIEWHGSTUDENTPROFILE WHERE FORMCODE = '"+ this.formCode+ "' AND STUDTYPECODE = '"+ this.studTypeCode+ "' ORDER BY STUDENTNO";
                
                ResultSet rs = stmt.executeQuery(query);

                while(rs.next()){
                    String studentNo    = rs.getString("STUDENTNO");
                    String fullName     = rs.getString("FULLNAME");
                    
                    Boolean autoInvoiced = sys.recordExists("VIEWHGINVSDETAILS", "ACADEMICYEAR = "+ this.academicYear+ " AND "
                            + "TERMCODE     = '"+ this.termCode+"' AND "
                            + "STUDENTNO    = '"+ studentNo+"' AND "
                            + "INVTYPE      = 'PI' AND "
                            + "ITEMCODE     = '"+ this.itemCode+"' "
                            + "");
                    
                    String checked = autoInvoiced == true? "checked": "";
                    
                    String checkEach = gui.formArrayCheckBox("checkEach", checked, studentNo, "", "", "");
                    
                    html += "<tr>";
                    html += "<td>"+ checkEach+ "</td>";
                    html += "<td>"+ studentNo+ "</td>";
                    html += "<td>"+ fullName+ "</td>";
                    html += "</tr>";
                    
                    total = total + amount;
                    
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch (Exception e){
                html += e.getMessage();
            }
            
            html += "</table>";
        }else{
            html += "No invoices record found.";
        }
        
        return html;
    }
    
    
    
}

%>