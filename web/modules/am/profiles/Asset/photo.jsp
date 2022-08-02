<%@page import="java.io.OutputStream"%>
<%@page import="java.sql.Blob"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%
    String assetNo   = request.getParameter("assetNo");
    
    Connection conn = ConnectionProvider.getConnection();
    Statement stmt = conn.createStatement();
    
    String dbType = ConnectionProvider.getDBType();
    
    Blob img        = null;
    byte[] imgData  = null ;
    String fileType = "";
    
    if(assetNo != null && ! assetNo.trim().equals("")){
        
        String query = "SELECT * FROM AMASSETPHOTOS WHERE ASSETNO = '"+ assetNo+ "'";

        ResultSet rs = stmt.executeQuery(query);

        while(rs.next()){
            fileType    = rs.getString("FILETYPE");
            
            if(dbType.equals("postgres")){
                imgData = rs.getBytes("PHOTO");
            }else{
                img         = rs.getBlob("PHOTO");	
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