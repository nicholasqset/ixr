<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFCell"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFRow"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFSheet"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFWorkbook"%>
<%@page import="org.apache.poi.poifs.filesystem.POIFSFileSystem"%>
<%@page import="java.io.BufferedInputStream"%>
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
    Integer sucCount = 0;
    
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
        
//        out.println(fileName);
        
        File f = new File(filePath + fileName);
        
        String fileExtension = system.getFileExtension(f);
        
        if(! fileExtension.equals("xls")){
            errorCount++;
            errorMsg = "Invalid file detected.";
            
        }else{
            
            Connection con      = ConnectionProvider.getConnection();
            Statement stmt;

            String query;
            InputStream is      = new BufferedInputStream(new FileInputStream(f));
            
            POIFSFileSystem fs  = new POIFSFileSystem(is);
            HSSFWorkbook wb     = new HSSFWorkbook(fs);
            HSSFSheet sheet     = wb.getSheetAt(0);
            Iterator<?> rows    = sheet.rowIterator();
            Integer rowCount    = 0;
            while (rows.hasNext()) {
                HSSFRow row = (HSSFRow) rows.next();
                
                String pfNo         = row.getCell(0).toString();
                String firstName    = row.getCell(1).toString();
                String middleName   = row.getCell(2).toString();
                String lastName     = row.getCell(3).toString();
                String genderCode   = row.getCell(4).toString();
                String dob          = row.getCell(5).toString();
                String countryCode  = row.getCell(6).toString();
                String nationalId   = row.getCell(7).toString();
                String postalAddr   = row.getCell(8).toString();
                String postalCode   = row.getCell(9).toString();
                String cellphone    = row.getCell(10).toString();
                String email        = row.getCell(11).toString();
                
                pfNo = pfNo.replaceAll("(?<=^\\d+)\\.0*$", "");
                
                Integer id;
                id = system.generateId("HRSTAFFPROFILE", "ID");
                
                query = "INSERT INTO HRSTAFFPROFILE "
                        + "(ID, PFNO, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, "
                        + "GENDERCODE, DOB, COUNTRYCODE, NATIONALID, "
                        + "POSTALADDR, POSTALCODE, CELLPHONE, EMAIL) "
                        + "VALUES"
                        + "("
                        + id+","
                        + "'"+pfNo+"',"
                        + "'"+firstName+"',"
                        + "'"+middleName+"',"
                        + "'"+lastName+"',"
                        + "'"+firstName+" "+middleName+" "+lastName+"',"
                        + "'"+genderCode+"',"
                        + "'"+system.getLogDate()+"',"
                        + "'"+countryCode+"',"
                        + "'"+nationalId+"',"
                        + "'"+postalAddr+"',"
                        + "'"+postalCode+"',"
                        + "'"+cellphone+"',"
                        + "'"+email+"'"
                        + ")";
                
                stmt = con.createStatement();
                
                if(rowCount > 0){
                    Integer saved = stmt.executeUpdate(query);
                    
                    if(saved == 1){
                        sucCount++;
                    }
                }
                   
                rowCount++;
            }

            if(f.exists()){
                f.delete();
            }
        }
         
      }catch(Exception ex) {
         out.println(ex.getMessage());
      }
   }else{
      errorCount++;
      errorMsg = "Unable to import.";
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
                    parent.staffsImport.getImpErrResp(<%= errorCount%>, '<%= errorMsg%>');
                <%
                }else{%>
                    parent.staffsImport.getImpSucResp(<%= sucCount%>);
                <%}
                %>
        </script>
    </body>
</html>