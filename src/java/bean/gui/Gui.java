package bean.gui;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;


/**
 *
 * @author nicholas
 */
public class Gui {
    
    public String loadCss(String cssPath, String cssName){
        return "<style type=text/css>@import url( \""+cssPath+"/assets/css/"+cssName+".css\");</style>";
    }
    
    public String loadCssFeLibs(String cssPath, String cssName){
        return "<style type=text/css>@import url( \""+cssPath+"/"+cssName+".css\");</style>";
    }
    
    public String loadJs(String jsPath, String jsName){
        return "<script type=\"text/javascript\" src=\""+jsPath+"/assets/js/"+jsName+".js\"></script>";
    }
    
    public String formStart(String id, String action, String method, String javascript){
        return "<form id=\""+id+"\" name=\""+id+"\"  method=\""+method+"\" action=\""+action+"\" "+javascript+">";
    }
    
    public String formEnd(){
        return "</form>";
    }
    
    public String formIcon(String iconPath, String iconName, String iconId, String title){
        String iconfile	= iconPath+"/assets/img/icons/"+iconName;
  	return  "<img src=\""+iconfile+"\" id=\""+iconId+"\"  title=\""+title+"\" border=\"0\" >";
    }
    
    public String formLabel(String forName, String labelName){
        return "<label for=\""+forName+"\">"+labelName+"</label>";
    }
    
    public String  returnTable(String tablename){
        
        return null;
    }
    
    public String formInput(String type, String id, Integer size, String defaultValue, String javascript, String options){
        String input;
        switch (type){
              case "text":
                  input = "<input type = \"text\" autocomplete = \"off\" id=\""+id+"\" name = \""+id+"\"  size=\""+size+"\" value=\""+defaultValue+"\" "+javascript+"  "+ options+" >";	
              break;
              case "password":
                  input =   "<input type = \"password\" id = \""+id+"\" name = \""+id+"\" size=\""+size+"\" value=\""+defaultValue+"\" "+javascript+">";	
              break;
               
              case "hidden":
                  input =   "<input type = \"hidden\" id = \""+id+"\" name = \""+id+"\"  size=\""+size+"\" value=\""+defaultValue+"\">";
              break;
              case "textarea":
                  input = "<textarea id = \""+id+"\" name = \""+id+"\" cols = \""+size+"\"  rows = \"2\" "+javascript+" "+options+">"+defaultValue+"</textarea>";	
              break;
                  case "file":
                  input = "<input type = \"file\" id=\""+id+"\" name = \""+id+"\"  size=\""+size+"\" value=\""+defaultValue+"\" "+javascript+"  "+ options+" >";	
              break;
              default:
                  input = "<input type = \"text\" name = \""+id+"\" id = \""+id+"\"   size = \""+size+"\" autocomplete = \"off\" value=\""+defaultValue+"\" "+javascript+" "+options+">";	
              break;
        }
        
        return input;
    }
    
    public String formButton(String iconPath, String type, String id, String label, String icon, String javascript, String style){
         String iconSrc = "<img src=\""+iconPath+"/assets/img/icons/"+icon+"\">";
         icon = (icon != null && !icon.isEmpty())? iconSrc: "";
        
         String button = "";
         
         switch (type){
             case "submit":
                 button = "<input type=\"submit\"class=\"btn form-control\" id=\""+id+"\" name=\""+id+"\" value=\""+label+"\" "+javascript+" class=\""+style+"\" >"; 	
             break;		
 	 
             case "reset":
                 button = "<input type=\"reset\" id=\""+id+"\" name=\""+id+"\" value=\""+label+"\" "+javascript+" class=\""+style+"\" >"; 	
             break;
 	 
             case "button":
                 button = "<button id=\""+id+"\" name=\""+id+"\"   "+javascript+"  class=\""+style+"\" >"+icon+"  "+label+"</button>"; 	
             break;
         }
         return button;
    }
    
    public String formAjaxIcon(String iconPath, String iconName){
        String iconFile = iconPath+"/assets/img/ajax/"+iconName;
	
	String ajaxIcon = "<img src=\""+iconFile+"\" border=\"0\" id=\""+iconName+"\">";
	
	return ajaxIcon;
    }
    
    public String formHref(String javascript, String iconPath, String icon, String name, String title , String id, String style){
        String html = "";
        String hrefId = ! id.isEmpty()? id: id.replace(" ", "")+"href_"+title;
        
        icon = ! icon.isEmpty()? "<img src=\""+iconPath+"/assets/img/icons/"+icon+"\" border=\"0\" >": "";
        
	html += "<a href = \"javascript:;\" ";
	html += " id = \""+hrefId+"\" ";
	html += javascript;
	html += " title = \""+title+"\"  class = \""+style+"\" >";
	html += !icon.isEmpty()? icon+' '+name: name;
	html += "</a>";
	
        return html;
 
    }
    
    public String formSelect(String id, String table, String valueCol, String textCol, String orderCol, String sqlWhere, String defaultValue, String options, Boolean showValueCol){
        String html = "";
        String selectSql;
        String value;
        String text = null;
        
        String orderColNew = orderCol;
        
        if(textCol != null && ! textCol.trim().equals("")){
           if(orderCol != null && ! orderCol.trim().equals("")){
                if(orderColNew.contains("DESC")){
                    orderColNew = orderColNew.replace("DESC", ""); 
                }
                selectSql  = "SELECT DISTINCT "+ valueCol+ ", "+textCol+ ", "+ orderColNew+ " FROM "+table;
           }else{
                selectSql  = "SELECT DISTINCT "+valueCol+", "+textCol+" FROM "+table;
           }
        }else{
           if(orderCol != null && ! orderCol.trim().equals("")){
                if(orderColNew.contains("DESC")){
                    orderColNew = orderColNew.replace("DESC", ""); 
                }
                selectSql  = "SELECT DISTINCT "+valueCol+ ", "+ orderColNew+ " FROM "+table;
           }else{
                selectSql  = "SELECT DISTINCT "+valueCol+" FROM "+table;
           }
        }

        selectSql += (sqlWhere != null && ! sqlWhere.trim().equals(""))? " WHERE "+ sqlWhere: "";

        if(orderCol != null && ! orderCol.trim().equals("")){
            selectSql += " ORDER BY "+ orderCol+ " ";
        }else{
            if(valueCol != null && ! valueCol.trim().equals("")){
                selectSql += " ORDER BY "+valueCol+" ";
            }else{
                selectSql += " ORDER BY "+textCol+" ";
            }
        }  
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(selectSql);
//            System.out.println("selectSql=="+ selectSql);
            html  += "<select name = \""+id+"\" id=\""+id+"\" "+options+">";
            html  += "<option value=\"\">...</option>";
            while(rs.next()){
                value      = rs.getString(valueCol);		
                if(textCol != null && ! textCol.trim().equals("")){
                    text      = rs.getString(textCol);
                }
                html += "<option value=\""+value+"\"";
                html += (defaultValue != null && ! defaultValue.trim().equals("") && defaultValue.equals(value))? " selected": "";
                html += " >";
                html += showValueCol == true? value: "";
                html += showValueCol == true? " : ": "";
                html += text != null ? text : value;
                html += "</option>";
            }
            html += "</select>";
        }catch (SQLException e){
            System.out.println(e.getMessage());
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
        
        return html;
    }
    
    public String formCheckBox(String id, String checked, String value, String javascript, String disabled, String style){
        String html = "";
        
        checked = checked.equals("checked")? "checked": "";
        
        if(value != null && ! value.equals("")){
            
            html += "<input type=\"checkbox\" name=\""+id+"\" id=\""+id+"\"   class=\""+style+"\"  value=\""+value+"\"  "+checked+" "+javascript+" "+disabled+">";  
        }else{
            html += "<input type=\"checkbox\" name=\""+id+"\" id=\""+id+"\"   class=\""+style+"\"  "+checked+" "+javascript+" "+disabled+">";  
        }
        
        return html;
    }
    
    public String formAutoComplete(String id, Integer size, String defaultValue, String javascript, String hiddenFieldId, String defaultHiddenValue){
        String html = "";
        
        html += "<input type = \"text\" name = \""+id+"\" id = \""+id+"\" class = \"autocomplete\" autocomplete = \"off\" size = \""+size+"\" value = \""+defaultValue+"\" onfocus = \""+javascript+"('"+id+"');\" ondblclick = \"this.value = ''\">";
	html += "<input type = \"hidden\"  name = \""+hiddenFieldId+"\" id = \""+hiddenFieldId+"\" value = \""+defaultHiddenValue+"\" >";
	html += "<div id = \""+id+"Div\" class = \"autocomplete\" style = \"display: none;\"></div>";
        
        return html;
    }
    
    public  String getAutoColsSearch(String table, String columns, String whereSql, String searchIndex){
        String html = "";
        
        String dbType = ConnectionProvider.getDBType();
        
        Integer count = 0;
        
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;
        
        if(table != null && columns != null && searchIndex != null){
            
            searchIndex = searchIndex.trim();
            
            String searchSql = "SELECT DISTINCT ";
            
            String[] cols = columns.split(",");
            
            for(int i = 0; i < cols.length; i++){
                String appendCols = (i+1) == cols.length? "": ",";
                searchSql += cols[i]+appendCols;
            }
            
            searchSql += " FROM ";
            searchSql += table;
            searchSql += " WHERE ";
            
            if(whereSql != null && ! whereSql.equals("")){
                searchSql += whereSql+ " AND ";
            }
            
            for(int j = 0; j < cols.length; j++){
                if(j == 0 && j < cols.length){
                    if(dbType.equals("postgres")){
                        searchSql += " (UPPER(CAST("+ cols[j]+ " AS TEXT)) LIKE '%"+ searchIndex.toUpperCase()+ "%' ";
                    }else{
                        searchSql += " (UPPER("+ cols[j]+ ") LIKE '%"+searchIndex.toUpperCase()+"%' ";
                    }
                }else{
                    if(dbType.equals("postgres")){
                        searchSql += " OR UPPER(CAST("+ cols[j]+ " AS TEXT)) LIKE '%"+searchIndex.toUpperCase()+"%' )";
                    }else{
                        searchSql += " OR UPPER("+ cols[j]+ ") LIKE '%"+searchIndex.toUpperCase()+"%' )";
                    }
                }
            }
            
            searchSql += " LIMIT 10 ";
            
            try{
                stmt = conn.createStatement();
                
//                System.out.println("searchSql="+ searchSql);
                
                ResultSet rs = stmt.executeQuery(searchSql);
                    
                html +=  "<ul>";

                while(rs.next()){

                    String searchName   = rs.getString(2) != null? rs.getString(2): rs.getString(1);

                    html +=  "<li id = \""+rs.getString(1)+"\"><b>"+rs.getString(1)+"</b>";

                    if(rs.getString(2) != null && !rs.getString(2).equals(rs.getString(1)) ){
                        html +=  "<span class = \"informal\">"+searchName+"</span>";
                    }else{
                        html +=  "<span class = \"informal\">&nbsp;</span>";
                    }

                    html +=  "</li>";

                    count++;
                }
                    
                if(count == 0){
                    html +=  "<li>";
                    html +=  "<span class = \"informal\">No results found for "+searchIndex+"</span>";
                    html +=  "</li>";
                }
                
                html +=  "</ul>";
                
            }catch (SQLException e){

            }
            
        }else{
            html +=  "<ul>";
            html +=  "<li>";
            html +=  "<span class = \"informal\">Unable to search</span>";
            html +=  "</li>";
            html +=  "</ul>";
        }
        
        return html;
    }
    
    public String formDateTime(String rootPath, String id, Integer size, String defaultValue, Boolean showTime, String options){
        String html = "";
            
        Calendar calendar = Calendar.getInstance();
        SimpleDateFormat dateFormat     = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        
        String dateNow  = showTime ? dateTimeFormat.format(calendar.getTime()) : dateFormat.format(calendar.getTime());
	defaultValue    = defaultValue != null ? defaultValue : dateNow;
        
        html += "<input type = \"textbox\" name = \""+id+"\" id = \""+id+"\"  size = \""+size+"\" value=\""+defaultValue+"\" autocomplete = \"off\" "+options+" style = \"height: 24px;\">";
		
        html += "<script type=\"text/javascript\">";
		
        if (showTime) {
//            html +=  " var picker = new Control.DatePicker('"+id+"',{icon: '"+rootPath+"/assets/img/icons/calendar.png',timePicker: true,timePickerAdjacent: true, use24hrs: true,locale: 'en_GB'})";			
            html +=  " var picker = new Control.DatePicker('"+id+"',{timePicker: true,timePickerAdjacent: true, use24hrs: true,locale: 'en_GB'})";			
        }else{
//            html +=   "var picker = new Control.DatePicker('"+id+"',{icon: '"+rootPath+"/assets/img/icons/calendar.png',timePicker: false,timePickerAdjacent: true, use24hrs: true,locale: 'en_GB'})";
            html +=   "var picker = new Control.DatePicker('"+id+"',{timePicker: false,timePickerAdjacent: true, use24hrs: true,locale: 'en_GB'})";
        }
        html += "</script>";
        
        return html;
    }
    
    public String formArraySelect(String id, Integer width, HashMap<String, String> hashMap, String defaultValue, Boolean showValueCol, String options, Boolean blankOption){
	String html = "";
        
        html += "<select name = \""+ id+ "\" id=\""+ id+ "\"  style = \"width : "+ width+ "px\" "+ options+ ">";
        
        if(blankOption){
            html += "<option value = \"\">...</option>";
        }
        
        if(hashMap.size() > 0){
            
            TreeMap<String, String> treeMap = new TreeMap();
            treeMap.putAll(hashMap);
            
            for (Map.Entry<String, String> entry : treeMap.entrySet()){
                String key      = entry.getKey();
                String value    = entry.getValue();
                
                html += "<option value = \""+key+"\"";
                html += defaultValue != null && defaultValue.equals(key) ? " selected": "";
                html += " >";
                html += showValueCol == true? key: "";
                html += showValueCol == true? " : ": "";
                html += value != null ? value : key;
                html += "</option>";
                
            }
         }
        html += "</select>";

        return html;
    }
    
    public String formDbDataSrcSelect(String id, String defaultValue, String options){
        String html = "";
        
        html += "<select name = \""+id+"\" id = \""+id+"\" "+options+">";
        html += "<option value = \"\">...</option>"; 
        try{
            
            Connection conn = ConnectionProvider.getConnection();
            ResultSet rs;
            
            DatabaseMetaData md = conn.getMetaData();
            
            rs = md.getTables(null, null, null, new String[]{"TABLE", "VIEW" });
            
            while (rs.next()) {
                String tableOrViewName = rs.getString("TABLE_NAME");
                html += "<option value = \""+tableOrViewName+"\" "; 
                html += defaultValue != null && ! defaultValue.equals("") && defaultValue.equals(tableOrViewName)? " selected ": ""; 
                html += ">"+tableOrViewName+"</option>"; 
            }
            
        }catch(SQLException e){
            e.getMessage();
        }
        
        html += "</select>"; 
        
        return html;
    }
    
    public String formDataSrcColSelect(String id, String table, String defaultValue, String options){
        String html = "";
        
        html += "<select name = \""+id+"\" id = \""+id+"\" "+options+">";
        html += "<option value = \"\">...</option>"; 
        
        if(table != null && ! table.trim().equals("")){
            try{
            
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt;
                stmt = conn.createStatement();
                
                String query = " SELECT * FROM "+table+" ";
                
                ResultSet rs = stmt.executeQuery(query);
                ResultSetMetaData md = rs.getMetaData();

                for (int i = 1; i <= md.getColumnCount(); i++){
                    String colName      = md.getColumnLabel(i);
                    html += "<option value = \""+colName+"\" "; 
                    html += defaultValue != null && ! defaultValue.equals("") && defaultValue.equals(colName)? " selected ": ""; 
                    html += ">"+colName+"</option>";
                }

            }catch(SQLException e){
                html += e.getMessage();
            }
        }
        
        html += "</select>";
                
        return html;
    }
    
    public String formInfoMsg(String msg){
        String html = "";
        html += "<div class = \"info\">"+ msg +"</div>";
        return html;
    }
    
    public String formSuccessMsg(String msg){
        String html = "";
        html += "<div class = \"success\">"+ msg +"</div>";
        return html;
    }
    
    public String formWarningMsg(String msg){
        String html = "";
        html += "<div class = \"warning\">"+ msg +"</div>";
        return html;
    }
    
    public String formErrorMsg(String msg){
        String html = "";
        html += "<div class = \"error\">"+ msg +"</div>";
        return html;
    }
    
    public String formValidationMsg(String msg){
        String html = "";
        html += "<div class = \"validation\">"+ msg +"</div>";
        return html;
    }
    
    public String formYearSelect(String id, Integer startYear, Integer endYear, Integer defaultValue, String options, Boolean blankOption){
        String html = "";
        html += "<select name = \""+ id+ "\" id = \""+ id+ "\"  style = \"width : 100px\" "+ options+ ">";
        
        if(blankOption){
            html += "<option value = \"\">...</option>";
        }
        
        if(startYear <= endYear){
            for(int i = endYear; i >= startYear; i--){
                html += "<option value = \""+i+"\"";
                html += defaultValue != null && defaultValue.equals(i) ? " selected": "";
                html += " >";
                html += i;
                html += "</option>";
            }
        }
        
        html += "</select>";
        
        return html;
    }
    
    public String formMonthSelect(String id, Integer defaultValue, String options, Boolean blankOption){
        String html = "";
        
        html += "<select name = \""+ id+ "\" id = \""+ id+ "\"  style = \"width : 100px\" "+ options+ ">";
        
        if(blankOption){
            html += "<option value = \"\">...</option>";
        }
        
        TreeMap<Integer, String> treeMap = new TreeMap();
        
        treeMap.put(1, "January");
        treeMap.put(2, "February");
        treeMap.put(3, "March");
        
        treeMap.put(4, "April");
        treeMap.put(5, "May");
        treeMap.put(6, "June");
        
        treeMap.put(7, "July");
        treeMap.put(8, "August");
        treeMap.put(9, "September");
        
        treeMap.put(10, "October");
        treeMap.put(11, "November");
        treeMap.put(12, "December");
        
        if(treeMap.size() > 0){
            
            for (Map.Entry<Integer, String> entry : treeMap.entrySet()){
                Integer key     = entry.getKey();
                String value    = entry.getValue();
                
                html += "<option value = \""+key+"\"";
                
                html += defaultValue != null && defaultValue.equals(key) ? " selected": "";
                
                html += " >";
                html += value != null ? value : key;
                html += "</option>";
            }
         }
        html += "</select>";
        
        return html;
    }
    
    public String formOneMonthSelect(String id, Integer selectedMonth, String options, Boolean blankOption){
        String html = "";
        
        html += "<select name = \""+ id+ "\" id = \""+ id+ "\"  style = \"width : 100px\" "+ options+ ">";
        
        if(blankOption){
            html += "<option value = \"\">...</option>";
        }
        
        TreeMap<Integer, String> treeMap = new TreeMap();
        
        treeMap.put(1, "January");
        treeMap.put(2, "February");
        treeMap.put(3, "March");
        
        treeMap.put(4, "April");
        treeMap.put(5, "May");
        treeMap.put(6, "June");
        
        treeMap.put(7, "July");
        treeMap.put(8, "August");
        treeMap.put(9, "September");
        
        treeMap.put(10, "October");
        treeMap.put(11, "November");
        treeMap.put(12, "December");
        
        if(selectedMonth > 0){
            if(treeMap.size() > 0){
            
                for (Map.Entry<Integer, String> entry : treeMap.entrySet()){
                    Integer key     = entry.getKey();
                    String value    = entry.getValue();

                    if(selectedMonth.equals(key)){
                        html += "<option value = \""+key+"\" selected >";
                        html += value != null ? value : key;
                        html += "</option>";
                    }
                }
            }
        }
        
        html += "</select>";
        
        return html;
    }
    
    public String formArrayCheckBox(String name, String checked, String value, String javascript, String disabled, String style){
        String html = "";
        
        checked = checked.equals("checked")? "checked": "";
        
        if(value != null && ! value.equals("")){
            
            html += "<input type=\"checkbox\" name=\""+name+"\"  class=\""+style+"\"  value=\""+value+"\"  "+checked+" "+javascript+" "+disabled+">";  
        }else{
            html += "<input type=\"checkbox\" name=\""+name+"\"  class=\""+style+"\"  "+checked+" "+javascript+" "+disabled+">";  
        }
        
        return html;
    }
    /*
    public String formArrayInput(String type, String id, String name, Integer size, String defaultValue, String javascript, String options){
        String input;
        switch (type){
              case "text":
                  input = "<input type = \"text\" id = \""+id+ "\" name = \""+name+"\"  size=\""+size+"\" value=\""+defaultValue+"\" "+javascript+"  "+options+" autocomplete = \"off\">";	
              break;
              case "password":
                  input =   "<input type = \"password\" id = \""+id+ "\" name = \""+name+"\" size=\""+size+"\" value=\""+defaultValue+"\" "+javascript+">";	
              break;
              case "hidden":
                  input =   "<input type = \"hidden\" id = \""+id+ "\" name = \""+name+"\" size=\""+size+"\" value=\""+defaultValue+"\">";
              break;
              case "textarea":
                  input = "<textarea id = \""+id+"\" name = \""+name+"\" cols = \""+size+"\"  rows = \"2\" "+javascript+" "+options+">"+defaultValue+"</textarea>";	
              break;
              default:
                  input = "<input type = \"text\" id = \""+id+"\" name = \""+name+"\" size = \""+size+"\" value=\""+defaultValue+"\" "+javascript+" "+options+" autocomplete = \"off\">";	
              break;
        }
        
        return input;
    }
    */
}