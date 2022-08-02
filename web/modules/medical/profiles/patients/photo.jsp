<%@page import="java.io.OutputStream"%>
<%@page import="java.sql.Blob"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%
    String ptNo   = request.getParameter("ptNo");
    Blob img = null;
    byte[] imgData = null ;
    String fileType = "";
    
    if(ptNo != null && ! ptNo.trim().equals("")){
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;
        String query;
        
        stmt = conn.createStatement();
        query = "SELECT * FROM HMPTPHOTOS WHERE PTNO = '"+ptNo+"'";
        
        out.print(query);
        
        ResultSet rs = stmt.executeQuery(query);
        
        while(rs.next()){
            
            fileType    = rs.getString("FILETYPE");	
            img         = rs.getBlob("PHOTO");	
            imgData     = img.getBytes(1,(int)img.length());
        }
        
    }
    
    response.setContentType(fileType);
    OutputStream o = response.getOutputStream();
    o.write(imgData);
    o.flush(); 
    o.close();
    
%>