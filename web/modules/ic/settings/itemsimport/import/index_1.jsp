<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="org.apache.poi.poifs.filesystem.POIFSFileSystem"%>
<%@page import="java.io.BufferedInputStream"%>
<%@page import="javax.activation.MimetypesFileTypeMap"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.sql.Statement"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.List"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="java.io.File"%>
<%@page import="com.qset.sys.Sys"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFRow"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFSheet"%> 
<%@page import="org.apache.poi.hssf.usermodel.HSSFWorkbook"%>
<%@page import="org.apache.poi.ss.usermodel.Cell"%>
<%@page import="org.apache.poi.ss.usermodel.FormulaEvaluator"%>
<%@page import="org.apache.poi.ss.usermodel.Row"%>
<%
        
    Integer errorCount  = 0;
    String errorMsg     = "";
    Integer sucCount = 0;
    
    Sys system = new Sys();
    
    File file ;
    int maxFileSize = 1024 * 1024 * 10;
    int maxMemSize = 1024 * 1024 * 10;
   
   
    String webRootPath      = application.getRealPath("/").replace('\\', '/');
    String filePath         = webRootPath + "/tmp/";
    System.out.println("here2");
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
         
         System.out.println("here3");
        
//        out.println(fileName);
        
        File f = new File(filePath + fileName);
        
        String fileExtension = system.getFileExtension(f);
        
        if(! fileExtension.equals("xls")){
            errorCount++;
            errorMsg = "Invalid file detected.";
            
        }else{
            Connection con  = ConnectionProvider.getConnection();
            Statement stmt  = con.createStatement();
            
            System.out.println("here2zzzzz");

            String query;
            InputStream is      = new BufferedInputStream(new FileInputStream(f));
            
            POIFSFileSystem fs  = new POIFSFileSystem(is);
            HSSFWorkbook wb     = new HSSFWorkbook(fs);
            HSSFSheet sheet     = wb.getSheetAt(0);
            Iterator<?> rows    = sheet.rowIterator();
            Integer rowCount    = 0;
            
            System.out.println("here2zzzzz--------------");
            
            while (rows.hasNext()) {
                HSSFRow row = (HSSFRow) rows.next();
                
                System.out.println("hereoooooooooooooo09itewr");
                
                String itemCode     = row.getCell(0, org.apache.poi.ss.usermodel.Row.CREATE_NULL_AS_BLANK).toString();
                System.out.println("itemCode=="+ itemCode);
                String itemName     = row.getCell(1, org.apache.poi.ss.usermodel.Row.CREATE_NULL_AS_BLANK).toString();
                System.out.println("itemName=="+ itemName);
                
                Double qty          = 0.0;
                Double unitPrice    = 0.0;
                
                if(rowCount > 0){
//                    System.out.println("value="+ row.getCell(2, org.apache.poi.ss.usermodel.Row.CREATE_NULL_AS_BLANK));
//                    qty          = row.getCell(2, org.apache.poi.ss.usermodel.Row.CREATE_NULL_AS_BLANK) != null && ! row.getCell(2, org.apache.poi.ss.usermodel.Row.CREATE_NULL_AS_BLANK).toString().trim().equals("")? Double.parseDouble(row.getCell(2, org.apache.poi.ss.usermodel.Row.CREATE_NULL_AS_BLANK).toString()): 0.0;
//                    System.out.println("here1iuiuuu");
//                    System.out.println("value==="+ row.getCell(3, org.apache.poi.ss.usermodel.Row.CREATE_NULL_AS_BLANK).toString());
//                    unitPrice    = row.getCell(3, org.apache.poi.ss.usermodel.Row.CREATE_NULL_AS_BLANK) != null && ! row.getCell(3, org.apache.poi.ss.usermodel.Row.CREATE_NULL_AS_BLANK).toString().trim().equals("")? Double.parseDouble(row.getCell(3, org.apache.poi.ss.usermodel.Row.CREATE_NULL_AS_BLANK).toString()): 0.0;
//                    System.out.println("here1gfsgsdgs");
                }
                
//                Double unitPrice    = Double.parseDouble(row.getCell(3).toString());
                
//                itemCode = itemCode != null? itemCode.replaceAll("(?<=^\\d+)\\.0*$", ""): "";
                
                System.out.println("here");
                
                String idExisting = system.getOne("icitems", "id", "itemcode = '"+ itemCode+ "'");
                
                if(idExisting == null){
                    Integer id = system.generateId("icitems", "ID");

                    query = "INSERT INTO icitems "
                            + "("
                            + "id, itemcode, itemname, catcode, accsetcode, uomcode, unitcost,"
                            + "unitprice, stocked, qty, audituser, auditdate, audittime, auditipadr"
                            + ") "
                            + "VALUES"
                            + "("
                            + id+","
                            + "'"+itemCode+"',"
                            + "'"+itemName+"',"
                            + "'CAT001',"
                            + "'STD',"
                            + "'EA',"
                            + (unitPrice * 0.5)+ ","
                            + unitPrice+","
                            + "1,"
                            +qty+","
                            + "'"+system.getLogUser(session)+"',"
                            + "'"+system.getLogDate()+"',"
                            + "'"+system.getLogTime()+"',"
                            + "'"+system.getClientIpAdr(request)+"'"
                            + ")";
                }else{
                    query = "UPDATE icitems SET "
                            + "UNITCOST         = "+ (unitPrice * 0.5)+ ", "
                            + "UNITPRICE        = "+ (unitPrice)+ ", "
                            + "QTY              = "+ (qty)+ ", "
                            + "AUDITUSER        = '"+ system.getLogUser(session)+"', "
                            + "AUDITDATE        = '"+ system.getLogDate()+ "', "
                            + "AUDITTIME        = '"+ system.getLogTime()+ "', "
                            + "AUDITIPADR       = '"+ system.getClientIpAdr(request)+ "'"
                            
                            + "WHERE ID         = "+ idExisting;
                }

                if(rowCount > 0){
                    Integer saved = 0;
                           
//                    saved = stmt.executeUpdate(query);

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
        errorCount++;
        out.println(ex.getMessage());
        System.out.println(ex.getMessage());
      }
   }else{
      errorCount++;
      errorMsg = "Unable to import";
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