<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class PyConfig{
    String table = "PYCONFIG";

    String bp           = request.getParameter("basicPay") != null? request.getParameter("basicPay"): "";
    String hs           = request.getParameter("houseAllw") != null? request.getParameter("houseAllw"): "";
    String cm           = request.getParameter("comtAllw") != null? request.getParameter("comtAllw"): "";
    String cr           = request.getParameter("carAllw") != null? request.getParameter("carAllw"): "";
    String gp           = request.getParameter("grossPay") != null? request.getParameter("grossPay"): "";
    String np           = request.getParameter("netPay") != null? request.getParameter("netPay"): "";
    String lv           = request.getParameter("leaveAll") != null? request.getParameter("leaveAll"): "";
    String cb           = request.getParameter("contrBenefit") != null? request.getParameter("contrBenefit"): "";
    String cp           = request.getParameter("chargePay") != null? request.getParameter("chargePay"): "";
    String tx           = request.getParameter("taxCharged") != null? request.getParameter("taxCharged"): "";
    String pr           = request.getParameter("psnrelief") != null? request.getParameter("psnrelief"): "";
    String ir           = request.getParameter("insrelief") != null? request.getParameter("insrelief"): "";
    String mb           = request.getParameter("mprbf") != null? request.getParameter("mprbf"): "";
    String mc           = request.getParameter("mprcf") != null? request.getParameter("mprcf"): "";
    String pe           = request.getParameter("paye") != null? request.getParameter("paye"): "";
    
    public String getModule(){
        String html = "";
        Gui gui = new Gui();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ this.table+ " WHERE ID = 1";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.bp     = rs.getString("BP");		
                this.hs     = rs.getString("HS");		
                this.cm     = rs.getString("CM");		
                this.cr     = rs.getString("CR");
                this.gp     = rs.getString("GP");		
                this.np     = rs.getString("NP");	
                this.lv     = rs.getString("LV");		
                this.cb     = rs.getString("CB");		
                this.cp     = rs.getString("CP");		
                this.tx     = rs.getString("TX");		
                this.pr     = rs.getString("PR");		
                this.ir     = rs.getString("IR");		
                this.mb     = rs.getString("MB");		
                this.mc     = rs.getString("MC");		
                this.pe     = rs.getString("PE");		
                		
            }
        }catch (SQLException e){
            html += e.getMessage();
        }
        catch (Exception e){
            html += e.getMessage();
        }

        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");

        html += "<table width = \"100%\" class = \"module\" cellpadding = \"2\" cellspacing = \"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("basicPay", " Basic Pay Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "basicPay", 15, this.bp , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("houseAllw", " House Allowance Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "houseAllw", 15, this.hs , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("comtAllw", " Commuter Allowance Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "comtAllw", 15, this.cm , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("carAllw", " Car Allowance Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "carAllw", 15, this.cr , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("grossPay", " Gross Pay Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "grossPay", 15, this.gp , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("netPay", " Net Pay Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "netPay", 15, this.np , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("leaveAll", " Leave Allowance Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "leaveAll", 15, this.lv , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("contrBenefit", " Contribution Benefit Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "contrBenefit", 15, this.cb , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("chargePay", " Chargeable Pay Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "chargePay", 15, this.cp , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("taxCharged", " Tax Charged Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "taxCharged", 15, this.tx , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("psnrelief", " Personal Relief Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "psnrelief", 15, this.pr , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("insrelief", " Insurance Relief Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "insrelief", 15, this.ir , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("mprbf", " Unused MPR B/f Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "mprbf", 15, this.mb , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("mprcf", " Unused MPR C/f Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "mprcf", 15, this.mc , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("paye", " PAYE Code")+"</td>";
	html += "<td>"+ gui.formInput("text", "paye", 15, this.pe , "", "")+"</td>";
	html += "</tr>";

        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"config.save('basicPay houseAllw comtAllw carAllw grossPay netPay leaveAll contrBenefit chargePay taxCharged psnrelief insrelief mprbf mprcf paye');\"", "");
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
        
        html += "</table>";
        html += gui.formEnd();

        return html;
    }
    
    public Object save(){
        Integer saved = 0;
        
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        
        String query;
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(!sys.recordExists(this.table, "")){
//                Integer id = sys.generateId(this.table, "ID");
                Integer id = 1;
                
                query = "INSERT INTO "+ this.table+ " "
                        + "(ID, BP, HS, CM, CR, GP, NP, LV, CB, CP, TX, PR, IR, MB, MC, PE)"
                        + "VALUES"
                        + "("
                        + id+ ","
                        + "'"+ this.bp+ "', "
                        + "'"+ this.hs+ "', "
                        + "'"+ this.cm+ "', "
                        + "'"+ this.cr+ "', "
                        + "'"+ this.gp+ "', "
                        + "'"+ this.np+ "', "
                        + "'"+ this.lv+ "', "
                        + "'"+ this.cb+ "', "
                        + "'"+ this.cp+ "', "
                        + "'"+ this.tx+ "', "
                        + "'"+ this.pr+ "', "
                        + "'"+ this.ir+ "', "
                        + "'"+ this.mb+ "', "
                        + "'"+ this.mc+ "', "
                        + "'"+ this.pe+ "'"
                        + ")";
                
            }else{
                query = "UPDATE "+ this.table+ " SET "
                        + "BP   = '"+ this.bp+ "', "
                        + "HS   = '"+ this.hs+ "', "
                        + "CM   = '"+ this.cm+ "', "
                        + "CR   = '"+ this.cr+ "', "
                        + "GP   = '"+ this.gp+ "', "
                        + "NP   = '"+ this.np+ "', "
                        + "LV   = '"+ this.lv+ "', "
                        + "CB   = '"+ this.cb+ "', "
                        + "CP   = '"+ this.cp+ "', "
                        + "TX   = '"+ this.tx+ "', "
                        + "PR   = '"+ this.pr+ "', "
                        + "IR   = '"+ this.ir+ "', "
                        + "MB   = '"+ this.mb+ "', "
                        + "MC   = '"+ this.mc+ "', "
                        + "PE   = '"+ this.pe+ "'";
                
                obj.put("message", query);
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
            }
        }
        catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }

}

%>