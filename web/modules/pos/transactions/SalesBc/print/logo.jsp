<%@page import="java.io.OutputStream"%>
<%@page import="java.sql.Blob"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%
    String dbType = ConnectionProvider.getDBType();
    String comCode      = session.getAttribute("comCode").toString();
    String companyCode   = request.getParameter("code");
    Blob img = null;
    byte[] imgData = null ;
    String fileType = "";
    
    if(companyCode != null && ! companyCode.trim().equals("")){
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;
        String query;
        
        stmt = conn.createStatement();
        query = "SELECT * FROM "+comCode+".CSCOLOGO WHERE COMPANYCODE = '"+companyCode+"'";
        
        ResultSet rs = stmt.executeQuery(query);
        
        while(rs.next()){
            
            fileType    = rs.getString("FILETYPE");	
            if(dbType.equals("postgres")){
                imgData = rs.getBytes("LOGO");
            }else{
                img         = rs.getBlob("LOGO");	
                imgData     = img.getBytes(1,(int)img.length());
            }
        }
        
    }
    
    response.setContentType(fileType);
    OutputStream o = response.getOutputStream();
    o.write(imgData);
    o.flush(); 
    o.close();
    
    
    
%>