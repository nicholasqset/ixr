<%@page import="org.json.JSONObject"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.gl.GLAccount"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class Items{
    HttpSession session=request.getSession();
    
    String table        = ""+session.getAttribute("comCode")+".PYITEMS";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String itemCode     = request.getParameter("code");
    String itemName     = request.getParameter("name");
    String itemHeader   = request.getParameter("header");
    String transType    = request.getParameter("transtype");
    String accountCode  = request.getParameter("glAccount");
    String itemPos      = request.getParameter("itempos");
    Integer recur      = request.getParameter("recur") != null? 1: null;
    
    public String getGrid(){
        
        
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        String dbType = ConnectionProvider.getDBType();
        
        Integer recordCount = sys.getRecordCount(this.table, "");
        
        if(recordCount > 0){
            String gridSql;
            String filterSql        = "";
            Integer startRecord     = 0;
            Integer maxRecord       = 10;

            Integer maxRecordHidden = request.getParameter("maxRecord") != null? Integer.parseInt(request.getParameter("maxRecord")): null;
            Integer pageSize        = maxRecordHidden != null? maxRecordHidden: maxRecord;
            maxRecord               = maxRecordHidden != null? maxRecordHidden: maxRecord;

            HttpSession session     = request.getSession();
            session.setAttribute("maxRecord", maxRecord);

            String act              = request.getParameter("act");

            if(act != null){
                if(act.equals("find")){
                    String find = request.getParameter("find");
                    if(find != null){
                        session.setAttribute("startRecord", startRecord);

                        ArrayList<String> list = new ArrayList();

                        list.add("ITEMCODE");
                        list.add("ITEMNAME");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                if(dbType.equals("postgres")){
                                    filterSql += " WHERE ( UPPER(CAST ("+ list.get(i) +" AS TEXT)) LIKE '%"+ find.toUpperCase()+ "%' ";
                                }else{
                                    filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
                                }
                            }else{
                                filterSql += " OR ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
                            }
                            filterSql += ")";
                        }
                    }
                }
            }

            Integer useGrid         = request.getParameter("maxRecord") != null? Integer.parseInt(request.getParameter("maxRecord")): null;
            String gridAction       = request.getParameter("gridAction");

            if(useGrid != null){
                if(gridAction.equals("gridNext")){
                    if (session.getAttribute("startRecord") != null) {
                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) >= startRecord){
                            session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) + pageSize);
                        }else{
                            session.setAttribute("startRecord", startRecord);
                        }

                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) == recordCount){
                            session.setAttribute("startRecord", startRecord);
                        }

                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) > recordCount){
                            session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) - pageSize);
                        }
                    }else{
                        session.setAttribute("startRecord", startRecord);
                    }
                }else if(gridAction.equals("gridPrevious")){
                    if (session.getAttribute("startRecord") != null) {
                        if(Integer.parseInt(session.getAttribute("startRecord").toString()) > startRecord){
                            session.setAttribute("startRecord", Integer.parseInt(session.getAttribute("startRecord").toString()) - pageSize);
                        }else{
                            session.setAttribute("startRecord", startRecord);
                        }
                    }else{
                        session.setAttribute("startRecord", startRecord);
                    }
                }else if(gridAction.equals("gridFirst")){
                    session.setAttribute("startRecord", startRecord);
                }else if(gridAction.equals("gridLast")){
                    session.setAttribute("startRecord", recordCount - pageSize);
                }else{
                    session.setAttribute("startRecord", 0);
                }
            }else{
                session.setAttribute("startRecord", 0);
            }

//            gridSql = "SELECT * FROM "+this.table+" "+filterSql+" ORDER BY ITEMCODE LIMIT "
//                    + session.getAttribute("startRecord")
//                    + " , "
//                    + session.getAttribute("maxRecord");
            
            String orderBy = "ITEMCODE ";
            String limitSql = "";

            switch(dbType){
                case "mysql":
                    limitSql = "LIMIT "+ session.getAttribute("startRecord")+ " , "+ session.getAttribute("maxRecord");
                    break;
                case "postgres":
                    limitSql = "OFFSET "+ session.getAttribute("startRecord")+ " LIMIT "+ session.getAttribute("maxRecord");
                    break;
            }

            gridSql = "SELECT * FROM "+ this.table+ " "+ filterSql+ " ORDER BY "+ orderBy+ limitSql;

            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(gridSql);

                Integer startRecordHidden = Integer.parseInt(session.getAttribute("startRecord").toString()) + Integer.parseInt(session.getAttribute("maxRecord").toString());

                html += gui.formInput("hidden", "maxRecord", 10, session.getAttribute("maxRecord").toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "totalRecord", 10, recordCount.toString(), "", "");
                html += gui.formInput("hidden", "startRecord", 10, startRecordHidden.toString(), "", "");

                html += "<table class = \"grid\" width=\"100%\" cellpadding=\"2\" cellspacing=\"0\" border=\"0\">";

                html += "<tr>";
                html += "<th>#</th>";
                html += "<th>Code</th>";
                html += "<th>Name</th>";
                html += "<th>Header</th>";
                html += "<th>Type</th>";
                html += "<th>GL Account</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String itemCode  = rs.getString("ITEMCODE");
                    String itemName  = rs.getString("ITEMNAME");
                    String itemHeader  = rs.getString("HDRCODE");
                    String transType   = rs.getString("TRANSTYPE");
                    String accountCode   = rs.getString("ACCOUNTCODE");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+bgcolor+"\">";
                    html += "<td>"+count+"</td>";
                    html += "<td>"+itemCode+"</td>";
                    html += "<td>"+itemName+"</td>";
                    html += "<td>"+itemHeader+"</td>";
                    html += "<td>"+transType+"</td>";
                    html += "<td>"+accountCode+"</td>";
                    html += "<td>"+edit+"</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
            }catch (SQLException e){
                html += e.getMessage();
            }
            catch (Exception e){
                html += e.getMessage();
            }
        }else{
            html += "No records found.";
        }
        
        return html;
    }
    
    public String getModule(){
        String html = "";
        Gui gui = new Gui();
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.table+ " WHERE ID = "+this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.itemCode       = rs.getString("ITEMCODE");		
                    this.itemName       = rs.getString("ITEMNAME");	
                    this.itemHeader     = rs.getString("HDRCODE");	
                    this.transType      = rs.getString("TRANSTYPE");	
                    this.accountCode    = rs.getString("ACCOUNTCODE");	
                    this.itemPos        = rs.getString("ITEMPOS");	
                    this.recur          = rs.getInt("RECUR");	
                }
            }catch (SQLException e){
                html += e.getMessage();
            }
            catch (Exception e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit=\"javascript:return false;\"");
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 15, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+gui.formIcon(request.getContextPath(),"page.png", "", "")+" "+gui.formLabel("code", " Code")+"</td>";
	html += "<td>"+gui.formInput("text", "code", 10, this.id != null? this.itemCode : "" , "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("name", " Name")+"</td>";
	html += "<td>"+gui.formInput("text", "name", 30, this.id != null? this.itemName : "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("header", " Header")+"</td>";
        html += "<td>"+ gui.formSelect("header", ""+session.getAttribute("comCode")+".PYPSLHDR", "HDRCODE", "HDRNAME", "HDRCODE", "", this.id != null? this.itemHeader : "", "onchange = \"\"", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("transtype", " Type")+"</td>";
        html += "<td>"+ gui.formSelect("transtype", ""+session.getAttribute("comCode")+".PYITP", "ITYPECODE", "ITYPENAME", "ITYPECODE", "", this.id != null? this.transType : "", "onchange = \"\"", true)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("glAccount", " GL Account")+"</td>";
//	html += "<td>"+gui.formInput("text", "glAccount", 30, this.id != null? this.accountCode : "", "", "")+"</td>";
	html += "<td>"+ gui.formAutoComplete("glAccount", 13, this.id != null? this.accountCode: "", "items.searchGLAccount", "glAccountHd", this.id != null? this.accountCode: "")+ " <span id = \"spAccountName\"></span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"actions-view-sort-ascending.png", "", "")+" "+gui.formLabel("itempos", " Display Position")+"</td>";
	html += "<td>"+gui.formInput("text", "itempos", 30, this.id != null? this.itemPos : "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+" "+gui.formLabel("recur", " Recurrs")+"</td>";
//	html += "<td>"+gui.formInput("text", "recur", 30, this.id != null? this.recur : "", "", "")+"</td>";
        html += "<td>"+gui.formCheckBox("recur", (this.id != null && this.recur == 1)? "checked": "", null, "", "", "")+"</td>";
	html += "</tr>";
        
//        html += "<tr>";
//	html += "<td>&nbsp;</td>";
//	html += "<td class = \"fade\">put more code here...tree if possible</td>";
//	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"items.save('code name');\"", "");
        if(this.id != null){
            html += gui.formButton(request.getContextPath(), "button", "btnDelete", "Delete", "delete.png", "onclick = \"items.purge("+this.id+",'"+this.itemName+"');\"", "");
        }
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getModule();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        html += gui.formEnd();
                
        return html;
    }
    
    public String searchGLAccount(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.accountCode = request.getParameter("glAccountHd");
        
        html += gui.getAutoColsSearch(session.getAttribute("comCode")+".GLACCOUNTS", "ACCOUNTCODE, ACCOUNTNAME", "", this.accountCode);
        
        return html;
    }
    
    public Object getGLAccount() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.accountCode == null || this.accountCode.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            GLAccount gLAccount = new GLAccount(this.accountCode, session.getAttribute("comCode").toString());
            
            obj.put("accountName", gLAccount.accountName);
            obj.put("normalBal", gLAccount.normalBal);
            
            obj.put("success", new Integer(1));
            obj.put("message", "GL Account '"+ gLAccount.accountCode+ "' successfully retrieved.");
            
        }
        
        return obj;
    }    
    
    public Object save() throws Exception{
        
        JSONObject obj = new JSONObject();
        Sys sys = new Sys();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
             
            String query;
            Integer saved = 0;
            
            if(this.id == null){
                
                Integer id = sys.generateId(this.table, "ID");
                
                query = "INSERT INTO "+this.table+" "
                    + "(ID, ITEMCODE, ITEMNAME, HDRCODE, TRANSTYPE, ACCOUNTCODE, ITEMPOS, RECUR, ITEMTYPE)"
                    + "VALUES"
                    + "("
                    + id+","
                    + "'"+ this.itemCode+ "', "
                    + "'"+ this.itemName+ "', "
                    + "'"+ this.itemHeader+ "', "
                    + "'"+ this.transType+ "', "
                    + "'"+ this.accountCode+ "', "
                    + "'"+ this.itemPos+ "', "
                    + this.recur+ ", "
                    + "'I'"
                    + ")";
                
            }else{
                
                query = "UPDATE "+this.table+" SET "                        
//                    + "ITEMCODE    = '"+this.itemCode+"', "
                    + "ITEMNAME     = '"+this.itemName+"', "
                    + "HDRCODE      = '"+this.itemHeader+"', "                        
                    + "TRANSTYPE    = '"+this.transType+"', "                        
                    + "ACCOUNTCODE  = '"+this.accountCode+"', "                        
                    + "ITEMPOS      = '"+this.itemPos+"', "                        
                    + "RECUR        = "+this.recur+" "                        
                    + "WHERE ID   = "+this.id;
            }
            
            saved = stmt.executeUpdate(query);
            
            if(saved == 1){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "Oops! An Un-expected error occured while saving record.");
            }
            
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
        
        return obj;
    }
    
    public Object purge() throws Exception{
        
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+this.table+" WHERE ID = "+this.id;
            
                Integer purged = stmt.executeUpdate(query);
                if(purged == 1){
                    obj.put("success", new Integer(1));
                    obj.put("message", "Entry successfully deleted.");
                }else{
                    obj.put("success", new Integer(0));
                    obj.put("message", "An error occured while deleting record.");
                }
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "An error occured while deleting record.");
            }
    
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
         return obj;
        
    }
    
}

%>