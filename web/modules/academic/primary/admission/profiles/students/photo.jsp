<%@page import="java.io.OutputStream"%>
<%@page import="java.sql.Blob"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%
    String studentNo   = request.getParameter("studentNo");
    Blob img = null;
    byte[] imgData = null ;
    String fileType = "";
    
    if(studentNo != null && ! studentNo.trim().equals("")){
        Connection conn = ConnectionProvider.getConnection();
        
        String dbType = ConnectionProvider.getDBType();
        
        Statement stmt;
        String query;
        
        stmt = conn.createStatement();
        query = "SELECT * FROM PRSTUDPHOTOS WHERE STUDENTNO = '"+studentNo+"'";
        
//        out.print(query);
        
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