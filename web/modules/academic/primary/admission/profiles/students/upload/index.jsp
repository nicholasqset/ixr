<%@page import="javax.activation.MimetypesFileTypeMap"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.List"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="java.io.File"%>
<%@page import="bean.sys.Sys"%>
<%
        
    Integer errorCount  = 0;
    String errorMsg     = "";
    
    String studentNo         = request.getParameter("studentNo");
    
    Sys sys = new Sys();
    
    File file ;
    int maxFileSize = 1024 * 1024 * 10;
    int maxMemSize = 1024 * 1024 * 10;
   
    String webRootPath      = application.getRealPath("/").replace('\\', '/');
    String filePath         = webRootPath + "/tmp/";
   // Verify the content type
    String contentType = request.getContentType();
    if ((contentType.indexOf("multipart/form-data") >= 0)) {

      DiskFileItemFactory factory = new DiskFileItemFactory();
      // maximum size that will be stored in memory
      factory.setSizeThreshold(maxMemSize);
      // Location to save data that is larger than maxMemSize.
//      factory.setRepository(new File("c:\\temp"));
      factory.setRepository(new File(filePath));

      // Create a new file upload handler
      ServletFileUpload upload = new ServletFileUpload(factory);
      // maximum file size to be uploaded.
      upload.setSizeMax( maxFileSize );
      try{ 
         // Parse the request to get file items.
         List fileItems = upload.parseRequest(request);

         // Process the uploaded file items
         Iterator i = fileItems.iterator();
         String fileName = "";
         while ( i.hasNext () ) {
            FileItem fi = (FileItem)i.next();
            if ( !fi.isFormField () ){
                // Get the uploaded file parameters
                String fieldName = fi.getFieldName();
                fileName = fi.getName();
                boolean isInMemory = fi.isInMemory();
                long sizeInBytes = fi.getSize();
                // Write the file
                if( fileName.lastIndexOf("\\") >= 0 ){
                file = new File( filePath + 
                fileName.substring( fileName.lastIndexOf("\\"))) ;
                }else{
                file = new File( filePath + 
                fileName.substring(fileName.lastIndexOf("\\")+1)) ;
                }
                fi.write( file ) ;
                
            }
            
         }
        File f = new File(filePath + fileName);

        FileInputStream fis = new FileInputStream(f);

        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;

        String query;
         
        stmt = conn.createStatement();
        query = "DELETE FROM PRSTUDPHOTOS WHERE STUDENTNO = '"+studentNo+"'";
        Integer purged = stmt.executeUpdate(query);
        
        PreparedStatement ps;
        
        Integer id = system.generateId("PRSTUDPHOTOS", "ID");
        
        query = "INSERT INTO PRSTUDPHOTOS "
                    + "(ID, STUDENTNO, PHOTO, FILENAME, FILETYPE, FILESIZE) "
                    + " VALUES (?, ?, ?, ?, ?, ?)";
        
                    
        ps = conn.prepareStatement(query);
        ps.setInt(1, id);
        ps.setString(2, studentNo);
        ps.setBinaryStream(3, (InputStream) fis, (int) (f.length()));
        ps.setString(4, fileName);
        ps.setString(5, new MimetypesFileTypeMap().getContentType(f));
        ps.setLong(6, f.length());
                
        Integer saved = ps.executeUpdate();

        if(saved == 1){
            // record saved
        }else{
            errorCount++;
            errorMsg = "Oops! An un-expected error occurred while trying to save.";
        }
        
        if(f.exists()){
            f.delete();
        }
         
      }catch(Exception ex) {
         out.println(ex.getMessage());
      }
   }else{
      errorCount++;
      errorMsg = "Unable to upload photo.";
   }
   
%>
<html>
    <head>
        <title></title>
    </head>
    <body>
        <script type="text/javascript">
            <%
                if(errorCount > 0){%>
                    parent.students.getUploadResponse(<%= errorCount%>, '<%= errorMsg%>');
                <%
                }else{%>
                    parent.students.getUploadResponse();
                <%}
                %>
        </script>
    </body>
</html>