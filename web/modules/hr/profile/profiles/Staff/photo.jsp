<%@page import="java.io.OutputStream"%>
<%@page import="java.sql.Blob"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%
    String comCode = session.getAttribute("comCode").toString();
    String pfNo   = request.getParameter("pfNo");
    
    Connection conn = ConnectionProvider.getConnection();
    Statement stmt = conn.createStatement();
    
    String dbType = ConnectionProvider.getDBType();
    
    Blob img        = null;
    byte[] imgData  = null ;
    String fileType = "";
    
    if(pfNo != null && ! pfNo.trim().equals("")){
        
        String query = "SELECT * FROM "+comCode+".HRSTAFFPHOTOS WHERE PFNO = '"+ pfNo+ "'";

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