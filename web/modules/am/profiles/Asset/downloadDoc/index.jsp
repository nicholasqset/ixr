<%-- 
    Document   : index
    Created on : Dec 9, 2016, 5:15:10 PM
    Author     : nicholas
--%>
<%@page import="java.io.IOException"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.io.OutputStream"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.Blob"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%
    Integer id = Integer.parseInt(request.getParameter("docId"));
    
    final int BUFFER_SIZE = 4096;   
         
    Connection conn = ConnectionProvider.getConnection();

    try {

        // queries the database
        String sql = "SELECT * FROM AMASSETDOCS WHERE ID = ?";
        PreparedStatement statement = conn.prepareStatement(sql);
        statement.setInt(1, id);

        ResultSet result = statement.executeQuery();
        
        if (result.next()) {
            // gets file name and file blob data
            String fileName = result.getString("FILENAME");
//            Blob blob       = result.getBlob("DOC");
            
//            InputStream inputStream = blob.getBinaryStream();
            
            InputStream inputStream = result.getBinaryStream("DOC");
            int fileLength = inputStream.available();

            out.println("fileLength = " + fileLength);

            ServletContext context = getServletContext();

            // sets MIME type for the file download
            String mimeType = context.getMimeType(fileName);
            if (mimeType == null) {        
                mimeType = "application/octet-stream";
            }              

            // set content properties and header attributes for the response
            response.setContentType(mimeType);
            response.setContentLength(fileLength);
            String headerKey = "Content-Disposition";
            String headerValue = String.format("attachment; filename=\"%s\"", fileName);
            response.setHeader(headerKey, headerValue);

            // writes the file to the client
            OutputStream outStream = response.getOutputStream();

            byte[] buffer = new byte[BUFFER_SIZE];
            int bytesRead = -1;

            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outStream.write(buffer, 0, bytesRead);
            }

            inputStream.close();
            outStream.close();             
        } else {
            // no file found
            response.getWriter().print("File not found for the id: " + id);  
        }
    } catch (SQLException ex) {
        ex.printStackTrace();
        response.getWriter().print("SQL Error: " + ex.getMessage());
    } catch (IOException ex) {
        ex.printStackTrace();
        response.getWriter().print("IO Error: " + ex.getMessage());
    } finally {
        if (conn != null) {
            // closes the database connection
            
        }          
    }
    
%>
