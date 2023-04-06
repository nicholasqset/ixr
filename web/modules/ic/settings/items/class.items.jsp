<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.JSONObject"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="com.qset.ap.APSupplierProfile"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%

final class Items{
    HttpSession session = request.getSession();
    String comCode      = session.getAttribute("comCode").toString();
    String table        = comCode+".ICITEMS";
    String view         = comCode+".VIEWICITEMS";
        
    Integer id          = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    String itemCode     = request.getParameter("code");
    String itemName     = request.getParameter("name");
    String catCode      = request.getParameter("category");
    String accSetCode   = request.getParameter("accSetCode");
    String uomCode      = request.getParameter("uom");
    Double unitCost     = (request.getParameter("cost") != null && ! request.getParameter("cost").trim().equals(""))? Double.parseDouble(request.getParameter("cost")): 0.0;
    Double unitPrice    = (request.getParameter("price") != null && ! request.getParameter("price").trim().equals(""))? Double.parseDouble(request.getParameter("price")): 0.0;
    Integer stocked     = request.getParameter("stocked") != null? 1: null;
    Double qty          = (request.getParameter("quantity") != null && ! request.getParameter("quantity").trim().equals(""))? Double.parseDouble(request.getParameter("quantity")): 0.0;
    
    String supplierNo   = request.getParameter("supplierNo");
    String cmdtNo       = request.getParameter("cmdtNo");
    String serialNo     = request.getParameter("serialNo");
    String opt1         = request.getParameter("opt1");
    String opt2         = request.getParameter("opt2");
    String opt3         = request.getParameter("opt3");
    String opt4         = request.getParameter("opt4");
    
    String mfgdt        = request.getParameter("mfgdt");
    String expdt        = request.getParameter("expdt");
    String wsprice      = request.getParameter("wsprice");
    String minlevel     = request.getParameter("minlevel");
    String maxlevel     = request.getParameter("maxlevel");
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys system = new Sys();
        
        Integer recordCount = system.getRecordCount(this.table, "");
        
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
                        list.add("CATNAME");
                        for(int i = 0; i < list.size(); i++){
                            if(i == 0){
                                filterSql += " WHERE ( UPPER("+list.get(i)+") LIKE '%"+ find.toUpperCase()+ "%' ";
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

            String orderBy = "ITEMCODE ";
            String limitSql = "";

            String dbType = ConnectionProvider.getDBType();

            switch(dbType){
                case "mysql":
                    limitSql = "LIMIT "+ session.getAttribute("startRecord")+ " , "+ session.getAttribute("maxRecord");
                    break;
                case "postgres":
                    limitSql = "OFFSET "+ session.getAttribute("startRecord")+ " LIMIT "+ session.getAttribute("maxRecord");
                    break;
            }

            gridSql = "SELECT * FROM "+ this.view+ " "+ filterSql+ " ORDER BY "+ orderBy+ limitSql;

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
                html += "<th>Category</th>";
                html += "<th>Unit Cost</th>";
                html += "<th>Unit Price</th>";
                html += "<th>Quantity</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String itemCode     = rs.getString("ITEMCODE");
                    String itemName     = rs.getString("ITEMNAME");
                    String catName      = rs.getString("CATNAME");
                    Double unitCost     = rs.getDouble("UNITCOST");
                    Double unitPrice    = rs.getDouble("UNITPRICE");
                    Double qty          = rs.getDouble("QTY");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "pencil.png", "edit", "edit", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+"</td>";
                    html += "<td>"+ itemCode+"</td>";
                    html += "<td>"+ itemName+"</td>";
                    html += "<td>"+ catName+"</td>";
                    html += "<td>"+ system.numberFormat(unitCost.toString())+"</td>";
                    html += "<td>"+ system.numberFormat(unitPrice.toString())+"</td>";
                    html += "<td>"+ system.numberFormat(qty.toString())+"</td>";
                    html += "<td>"+ edit+ "</td>";
                    html += "</tr>";

                    count++;
                }
                html += "</table>";
            }catch(SQLException e){
                html += e.getMessage();
            }catch(Exception e){
                html += e.getMessage();
            }
        }else{
            html += "No records found.";
        }
        
        return html;
    }
    
    public String getModule(){
        String html = "";
        
        Sys sys = new Sys();
        Gui gui = new Gui();
        
        String fullName = "";
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.table+ " WHERE ID = "+ this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.itemCode       = rs.getString("ITEMCODE");		
                    this.itemName       = rs.getString("ITEMNAME");		
                    this.catCode        = rs.getString("CATCODE");	
                    this.accSetCode     = rs.getString("ACCSETCODE");	
                    this.uomCode        = rs.getString("UOMCODE");
                    this.supplierNo     = rs.getString("SUPPLIERNO");
                    this.cmdtNo         = rs.getString("CMDTNO");
                    this.serialNo       = rs.getString("SERIALNO");
                    this.unitCost       = rs.getDouble("UNITCOST");		
                    this.unitPrice      = rs.getDouble("UNITPRICE");	
                    this.stocked        = rs.getInt("STOCKED");	
                    this.qty            = rs.getDouble("QTY");
                    this.opt1           = rs.getString("OPT1");
                    this.opt2           = rs.getString("OPT2");
                    this.opt3           = rs.getString("OPT3");
                    this.opt4           = rs.getString("OPT4");
                    this.mfgdt           = rs.getString("mfgdt");
                    this.expdt           = rs.getString("expdt");
                    this.wsprice           = rs.getString("wsprice");
                    this.minlevel           = rs.getString("minlevel");
                    this.maxlevel           = rs.getString("maxlevel");
                    
                    APSupplierProfile aPSupplierProfile = new APSupplierProfile(this.supplierNo, comCode);
                    fullName = aPSupplierProfile.fullName;
                    
                    
                    SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
                    SimpleDateFormat targetFormat   = new SimpleDateFormat("dd-MM-yyyy");

                    try{
                        java.util.Date mfgdt = originalFormat.parse(this.mfgdt);
                        this.mfgdt = targetFormat.format(mfgdt);
                        java.util.Date expdt = originalFormat.parse(this.expdt);
                        this.expdt = targetFormat.format(expdt);
                    }catch(ParseException e){
                        sys.logV2(e.getMessage());
                    }
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
        
        html += "<tr>";
	html += "<td >"+ gui.formIcon(request.getContextPath(),"page.png", "", "")+ gui.formLabel("code", " Item Code")+ "</td>";
	html += "<td colspan=\"3\">"+ gui.formInput("text", "code", 20, this.id != null? this.itemCode: "" , "", "")+"<span class = \"fade\"> i.e bar code</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("name", " Item Name")+"</td>";
	html += "<td colspan=\"3\">"+ gui.formInput("text", "name", 35, this.id != null? this.itemName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+ gui.formLabel("category", " Item Category")+"</td>";
	html += "<td width = \"35%\">"+ gui.formSelect("category", comCode+".ICITEMCATS", "CATCODE", "CATNAME", "", "", this.id != null? this.catCode: "", "", false)+ "</td>";
	
	html += "<td width = \"15%\" nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("accSetCode", " Account Set")+"</td>";
	html += "<td>"+ gui.formSelect("accSetCode", comCode+".ICACCSETS", "ACCSETCODE", "ACCSETNAME", "", "", this.id != null? this.accSetCode: "", "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td  nowrap>"+ gui.formIcon(request.getContextPath(),"pencil.png", "", "")+ gui.formLabel("uom", " Unit of Measure")+"</td>";
	html += "<td >"+ gui.formSelect("uom", comCode+".ICUOM", "UOMCODE", "UOMNAME", "", "", this.id != null? this.uomCode: "", "", false)+ "</td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"user-properties.png", "", "")+ gui.formLabel("supplierNo", " Supplier")+ "</td>";
        html += "<td >"+ gui.formAutoComplete("supplierNo", 13, this.id != null? this.supplierNo: "", "items.searchSupplier", "supplierNoHd", this.id != null? this.supplierNo: "")+ " <span id = \"spFullName\">"+ fullName+ "</span></td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "pencil.png", "", "")+ gui.formLabel("cost", " Commodity No")+"</td>";
	html += "<td>"+ gui.formInput("text", "cmdtNo", 20, this.id != null? ""+ this.cmdtNo: "", "", "")+"</td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "pencil.png", "", "")+ gui.formLabel("cost", " Serial No")+"</td>";
	html += "<td>"+ gui.formInput("text", "serialNo", 20, this.id != null? ""+ this.serialNo: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("cost", " Item Cost")+"</td>";
	html += "<td>"+ gui.formInput("text", "cost", 20, this.id != null? ""+ this.unitCost: "0", "", "")+"</td>";
	
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("price", " Item Price")+"</td>";
	html += "<td>"+ gui.formInput("text", "price", 20, this.id != null? ""+ this.unitPrice: "0", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("wsprice", " Wholesale Price")+"</td>";
	html += "<td colspan=\"3\">"+ gui.formInput("text", "wsprice", 20, this.id != null? ""+ this.wsprice: "0", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("stocked", " Stocked")+"</td>";
	html += "<td>"+ gui.formCheckBox("stocked", (this.id != null && this.stocked == 1)? "checked": "", null, "", "", "")+"</td>";

	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "pencil.png", "", "")+ gui.formLabel("quantity", " Quantity")+"</td>";
	html += "<td>"+ gui.formInput("text", "quantity", 20, this.id != null? ""+ this.qty: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "pencil.png", "", "")+ gui.formLabel("minlevel", " Minimum Threshold")+"</td>";
	html += "<td >"+ gui.formInput("text", "minlevel", 20, this.id != null? ""+ this.minlevel: "0", "", "")+"</td>";
        
        html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "pencil.png", "", "")+ gui.formLabel("maxlevel", " Maximum Threshold")+"</td>";
	html += "<td >"+ gui.formInput("text", "maxlevel", 20, this.id != null? ""+ this.maxlevel: "0", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("mfgdt", " Manufacture Date")+"</td>";
	html += "<td>"+ gui.formDateTime(request.getContextPath(), "mfgdt", 20, this.id != null? ""+ this.mfgdt: "", true, "")+"</td>";

	html += "<td>"+ gui.formIcon(request.getContextPath(), "calendar.png", "", "")+ gui.formLabel("expdt", " Expiry Date")+"</td>";
	html += "<td>"+ gui.formDateTime(request.getContextPath(), "expdt", 20, this.id != null? ""+ this.expdt: "", true, "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td style = \"vertical-align: top;\" nowrap>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("cost", " Additional Info. ")+"</td>";
	html += "<td colspan=\"3\">"; 
            html += gui.formInput("text", "opt1", 35, this.id != null? ""+ this.opt1: "", "", "")+ "<br>";
            html += gui.formInput("text", "opt2", 35, this.id != null? ""+ this.opt2: "", "", "")+ "<br>";
            html += gui.formInput("text", "opt3", 35, this.id != null? ""+ this.opt3: "", "", "")+ "<br>";
            html += gui.formInput("text", "opt4", 35, this.id != null? ""+ this.opt4: "", "", "")+ "<br>";
	html += "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td colspan=\"3\">";
	html += gui.formButton(request.getContextPath(), "button", "btnSave", "Save", "save.png", "onclick = \"items.save('code name category accSetCode uom cost price quantity');\"", "");
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
    
    public String searchSupplier(){
        String html = "";
        
        Gui gui = new Gui();
        
        this.supplierNo = request.getParameter("supplierNoHd");
        
        html += gui.getAutoColsSearch(comCode+".APSUPPLIERS", "SUPPLIERNO, SUPPLIERNAME", "", this.supplierNo);
        
        return html;
    }
    
    public Object getSupplierProfile() throws Exception{
        JSONObject obj = new JSONObject();
        
        if(this.supplierNo == null || this.supplierNo.equals("")){
            obj.put("success", new Integer(0));
            obj.put("message", "Oops! An Un-expected error occured while retrieving record.");
        }else{
            
            APSupplierProfile aPSupplierProfile = new APSupplierProfile(this.supplierNo, comCode);
            
            obj.put("fullName", aPSupplierProfile.supplierName);
            
            obj.put("success", new Integer(1));
            obj.put("message", "Supplier No '"+ aPSupplierProfile.supplierNo+ "' successfully retrieved.");
            
        }
        
        return obj;
    }
    
    public Object save() throws Exception{
        JSONObject obj = new JSONObject();
        Sys system = new Sys();
        HttpSession session = request.getSession();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query;
            Integer saved = 0;
            
            SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
            SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

            try{
                java.util.Date mfgdt = originalFormat.parse(this.mfgdt);
                this.mfgdt = targetFormat.format(mfgdt);
                java.util.Date expdt = originalFormat.parse(this.expdt);
                this.expdt = targetFormat.format(expdt);
            }catch(ParseException e){
                system.logV2(e.getMessage());
            }
            
            if(this.id == null){
                system.log("========inserting");
                Integer id = system.generateId(this.table, "ID");
                query = "INSERT INTO "+this.table+" "
                        + "("
                        + "ID, ITEMCODE, ITEMNAME, CATCODE, ACCSETCODE, UOMCODE, SUPPLIERNO, CMDTNO, SERIALNO, "
                        + "UNITCOST, UNITPRICE, STOCKED, QTY, "
                        + "OPT1, OPT2, OPT3, OPT4, mfgdt, expdt, wsprice, minlevel, maxlevel, "
                        + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                        + ")"
                        + "VALUES"
                        + "("
                        + id+","
                        + "'"+ this.itemCode+ "', "
                        + "'"+ this.itemName+ "', "
                        + "'"+ this.catCode+ "', "
                        + "'"+ this.accSetCode+ "', "
                        + "'"+ this.uomCode+ "', "
                        + "'"+ this.supplierNo+ "', "
                        + "'"+ this.cmdtNo+ "', "
                        + "'"+ this.serialNo+ "', "
                        + this.unitCost+ ", "
                        + this.unitPrice+ ", "
                        + this.stocked+ ", "
                        + this.qty+ ", "
                        + "'"+ this.opt1+ "', "
                        + "'"+ this.opt2+ "', "
                        + "'"+ this.opt3+ "', "
                        + "'"+ this.opt4+ "', "
                        + "'"+ this.mfgdt+ "', "
                        + "'"+ this.expdt+ "', "
                        + "'"+ this.wsprice+ "', "
                        + "'"+ this.minlevel+ "', "
                        + "'"+ this.maxlevel+ "', "
                        + "'"+ system.getLogUser(session)+"', "
                        + "'"+ system.getLogDate()+ "', "
                        + "'"+ system.getLogTime()+ "', "
                        + "'"+ system.getClientIpAdr(request)+ "'"
                        + ")";
            }else{
                system.log("========updating");
                query = "UPDATE "+ this.table+ " SET "
//                        + "ITEMCODE     = '"+ this.itemCode+ "', "
                        + "ITEMNAME     = '"+ this.itemName+ "', "
                        + "CATCODE      = '"+ this.catCode+ "', "
                        + "ACCSETCODE   = '"+ this.accSetCode+ "', "
                        + "UOMCODE      = '"+ this.uomCode+ "', "
                        + "SUPPLIERNO   = '"+ this.supplierNo+ "', "
                        + "CMDTNO       = '"+ this.cmdtNo+ "', "
                        + "SERIALNO     = '"+ this.serialNo+ "', "
                        + "UNITCOST     = "+ this.unitCost+ ", "
                        + "UNITPRICE    = "+ this.unitPrice+ ", "
                        + "STOCKED      = "+ this.stocked+ ", "
                        + "QTY          = "+ this.qty+ ", "
                        + "OPT1         = '"+ this.opt1+ "', "
                        + "OPT2         = '"+ this.opt2+ "', "
                        + "OPT3         = '"+ this.opt3+ "', "
                        + "OPT4         = '"+ this.opt4+ "', "
                        
                        + "mfgdt        = '"+ this.mfgdt+ "', "
                        + "expdt        = '"+ this.expdt+ "', "
                        + "wsprice      = '"+ this.wsprice+ "', "
                        + "minlevel     = '"+ this.minlevel+ "', "
                        + "maxlevel     = '"+ this.maxlevel+ "', "
                        
                        + "AUDITUSER    = '"+ system.getLogUser(session)+ "', "
                        + "AUDITDATE    = '"+ system.getLogDate()+ "', "
                        + "AUDITTIME    = "+ system.getLogTime()+ ", "
                        + "AUDITIPADR   = '"+ system.getClientIpAdr(request)+ "' "
                        + "WHERE ID     = "+ this.id;
                system.log("========query=="+ query);
            }
            
            saved = stmt.executeUpdate(query);
            system.log("saved e="+ saved);
            
            if(saved > 0){
                obj.put("success", new Integer(1));
                obj.put("message", "Entry successfully made.");
            }else{
                obj.put("success", new Integer(0));
                obj.put("message", "An unexpected error occured while saving record.");
            }
            
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
            system.log("small e="+e.getMessage());
        }catch (Exception e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
            system.log("big e="+e.getMessage());
        }
        
        return obj;
    }
    
    public Object purge() throws Exception{
         
         JSONObject obj = new JSONObject();
         
         try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            if(this.id != null){
                String query = "DELETE FROM "+ this.table+ " WHERE ID = "+ this.id;
            
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
                obj.put("message", "An unexpected error occured while deleting record.");
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
    
}

%>