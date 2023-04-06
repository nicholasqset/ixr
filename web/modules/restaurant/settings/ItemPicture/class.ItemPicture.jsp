<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.qset.gui.Gui"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>
<%

final class ItemPicture{
    String table        = "RTITEMPHOTOS";
    String view         = "VIEWRTITEMS";
        
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
    
    
    public String getGrid(){
        String html = "";
        
        Gui gui = new Gui();
        Sys sys = new Sys();
        
        Integer recordCount = system.getRecordCount(this.view, "");
        
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
                html += "<th>Quantity</th>";
                html += "<th>Options</th>";
                html += "</tr>";

                Integer count = Integer.parseInt(session.getAttribute("startRecord").toString()) + 1;

                while(rs.next()){

                    Integer id          = rs.getInt("ID");
                    String itemCode     = rs.getString("ITEMCODE");
                    String itemName     = rs.getString("ITEMNAME");
                    String catName      = rs.getString("CATNAME");
                    Double qty          = rs.getDouble("QTY");

                    String bgcolor = (count%2 > 0)? "#FFFFFF": "#F7F7F7";

                    String edit = gui.formHref("onclick = \"module.editModule("+id+")\"", request.getContextPath(), "attach.png", "attach", "Attach Picture", "", "");

                    html += "<tr bgcolor = \""+ bgcolor+ "\">";
                    html += "<td>"+ count+"</td>";
                    html += "<td>"+ itemCode+"</td>";
                    html += "<td>"+ itemName+"</td>";
                    html += "<td>"+ catName+"</td>";
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
        
        Gui gui = new Gui();
        
        if(this.id != null){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                String query = "SELECT * FROM "+ this.view+ " WHERE ID = "+ this.id;
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    this.itemCode       = rs.getString("ITEMCODE");		
                    this.itemName       = rs.getString("ITEMNAME");		
                    this.catCode        = rs.getString("CATCODE");	
                    this.accSetCode     = rs.getString("ACCSETCODE");	
                    this.uomCode        = rs.getString("UOMCODE");
                    this.unitCost       = rs.getDouble("UNITCOST");		
                    this.unitPrice      = rs.getDouble("UNITPRICE");	
                    this.stocked        = rs.getInt("STOCKED");	
                    this.qty            = rs.getDouble("QTY");
                }
            }catch (SQLException e){
                html += e.getMessage();
            }catch(Exception e){
                html += e.getMessage();
            }
        }
        
        String imgPhotoSrc;
        if(this.hasPhoto(this.itemCode)){
            imgPhotoSrc = "photo.jsp?itemCode="+ this.itemCode;
        }else{
            imgPhotoSrc = request.getContextPath()+"/assets/img/emblems/no-image.gif";
        }
        
//        html += gui.formStart("frmModule", "void%200", "post", "onSubmit = \"javascript: return false;\"");
 html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\"  action = \"./upload/\" enctype = \"multipart/form-data\" target = \"upload_iframe\">";
//        html += "<form name = \"frmModule\" id = \"frmModule\" method = \"post\" enctype = \"multipart/form-data\" target = \"_blank\">";
        
        if(this.id != null){
            html += gui.formInput("hidden", "id", 30, ""+this.id, "", "");
        }
        
        html += "<table width = \"100%\" class = \"module\" cellpadding=\"2\" cellspacing=\"0\" >";
        
        html += "<tr>";
	html += "<td width = \"15%\">"+ gui.formIcon(request.getContextPath(),"page.png", "", "")+ gui.formLabel("code", " Item Code")+ "</td>";
	html += "<td width = \"35%\">"+ gui.formInput("text", "code", 10, this.id != null? this.itemCode: "" , "", "")+"<span class = \"fade\"> i.e bar code</span></td>";
	html += "<td rowspan = \"10\">";
        html += "<div class = \"divPhoto\"><img id = \"imgPhoto\" src=\""+ imgPhotoSrc+ "\"></div>";
	html += "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-edit.png", "", "")+ gui.formLabel("name", " Item Name")+"</td>";
	html += "<td>"+ gui.formInput("text", "name", 35, this.id != null? this.itemName: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-white-edit.png", "", "")+ gui.formLabel("category", " Item Category")+"</td>";
	html += "<td>"+ gui.formSelect("category", "ICITEMCATS", "CATCODE", "CATNAME", "", "", this.id != null? this.catCode: "", "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"page-edit.png", "", "")+ gui.formLabel("accSetCode", " Account Set")+"</td>";
	html += "<td>"+ gui.formSelect("accSetCode", "ICACCSETS", "ACCSETCODE", "ACCSETNAME", "", "", this.id != null? this.accSetCode: "", "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(),"pencil.png", "", "")+ gui.formLabel("uom", " Unit of Measure")+"</td>";
	html += "<td>"+ gui.formSelect("uom", "ICUOM", "UOMCODE", "UOMNAME", "", "", this.id != null? this.uomCode: "", "", false)+ "</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("cost", " Item Cost")+"</td>";
	html += "<td>"+ gui.formInput("text", "cost", 20, this.id != null? ""+ this.unitCost: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "coins.png", "", "")+ gui.formLabel("price", " Item Price")+"</td>";
	html += "<td>"+ gui.formInput("text", "price", 20, this.id != null? ""+ this.unitPrice: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>"+ gui.formIcon(request.getContextPath(), "page-white-edit.png", "", "")+ gui.formLabel("stocked", " Stocked")+"</td>";
	html += "<td>"+ gui.formCheckBox("stocked", (this.id != null && this.stocked == 1)? "checked": "", null, "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td nowrap>"+ gui.formIcon(request.getContextPath(), "pencil.png", "", "")+ gui.formLabel("quantity", " Quantity")+"</td>";
	html += "<td>"+ gui.formInput("text", "quantity", 20, this.id != null? ""+ this.qty: "", "", "")+"</td>";
	html += "</tr>";
        
        html += "<tr>";
	html += "<td>&nbsp;</td>";
	html += "<td>";
	html += gui.formButton(request.getContextPath(), "button", "btnCancel", "Cancel", "reload.png", "onclick = \"module.getGrid();\"", "");
	html += "</td>";
	html += "</tr>";
         
        html += "</table>";
        
        
        if(this.id != null){
            html += " <script type=\"text/javascript\">"
                    +   "Event.observe(\'imgPhoto\', \'mouseover\' , function(){"
                    +       "if($(\'divPhotoOptions\')){"
                    +           "$(\'divPhotoOptions\')"
                    +           ".absolutize()"
                    +           ".setStyle({display:\'table-cell\'})"
                    +           ".clonePosition($(\'imgPhoto\'));"
                    +       "}"
                    +   "});"
                    + "</script>";
                        
            html += "<div id = \"divPhotoOptions\" onmouseout = \"itemCats.hidePhotoOptions();\" style = \"display: none; background-color: #000000; opacity: 0.4; text-align: center;\">";
            html += "<input name = \"photo\" id = \"photo\" type = \"file\" onchange = \"itemCats.uploadPhoto();\" style = \"display: none;\">";
            html += "<div style = \"padding-top: 42px;\">";
            html += "<a href = \"javascript:;\" onclick = \"$('photo').click();\">upload</a>";
            html += "</div>";
            if(this.hasPhoto(this.itemCode)){
                html += "<div >";
                html += gui.formHref("onclick = \"itemCats.purgePhoto('"+this.itemCode+"', '"+this.itemName+"')\"", request.getContextPath(), "", "remove", "remove", "", "");
                html += "</div>";
            }
            html += "</div>";
        }
        
        html += gui.formEnd();
        
        html += "<iframe name = \"upload_iframe\" id = \"upload_iframe\"></iframe>";
                
        return html;
    }
    
    public Boolean hasPhoto(String itemCode){
        Boolean hasPhoto = false;
        
        if(this.id != null){
            Connection con = ConnectionProvider.getConnection();
            Statement stmt = null;
            
            Integer count = 0;
            
            try{
                stmt = con.createStatement();
                String query = "SELECT COUNT(*)CT FROM RTITEMPHOTOS WHERE ITEMCODE = '"+itemCode+"'";
                ResultSet rs = stmt.executeQuery(query);
                while(rs.next()){
                    count      = rs.getInt("CT");		
                }
                if(count > 0){
                    hasPhoto = true;
                }
                
            }catch (SQLException e){
                e.printStackTrace();
            } 
        }
        
        return hasPhoto;
    }
    
    public Object purgePhoto(){
        
         Connection con = ConnectionProvider.getConnection();
         Statement stmt = null;
         
         JSONObject obj = new JSONObject();
         
         try{
            stmt = con.createStatement();
            
            if(this.itemCode != null && ! this.itemCode.trim().equals("")){
                String query = "DELETE FROM RTITEMPHOTOS WHERE ITEMCODE = '"+this.itemCode+"'";
            
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
        }catch (SQLException e){
            obj.put("success", new Integer(0));
            obj.put("message", e.getMessage());
        }
         
         return obj;
        
    } 
    
}

%>