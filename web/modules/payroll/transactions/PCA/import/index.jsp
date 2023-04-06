<%@page import="org.apache.poi.ss.usermodel.Cell"%>
<%@page import="org.apache.poi.ss.usermodel.DataFormatter"%>
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
<%
    final class ImportPCA{
        String table            = "PYPCAHDR";
        String refNo            = request.getParameter("reference") != null && ! request.getParameter("reference").trim().equals("")? request.getParameter("reference"): null;
        String pcaDesc          = request.getParameter("pcaDesc");
        Integer pYear           = request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals("")? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth          = request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals("")? Integer.parseInt(request.getParameter("pMonth")): null;
        String efDate           = request.getParameter("efDate");
        
        public Integer createPcaHeader(){
            Integer pcaHdrCreated = 0;
            Sys sys = new Sys();

            HttpSession session = request.getSession();

            if(this.refNo != null){
                if(system.recordExists(this.table, "REFNO = '"+ this.refNo+ "'")){
                    pcaHdrCreated = 1;
                }else{
                    try{
                        Connection conn = ConnectionProvider.getConnection();
                        Statement stmt = conn.createStatement();

                        Integer id = system.generateId(this.table, "ID");

                        String pcaNo = system.getOne(this.table, "PCANO", "REFNO = '"+ this.refNo+ "'");
                        if(pcaNo == null){
                            pcaNo = system.getNextNo(this.table, "ID", "", "R", 7);
                        }

                        SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
                        SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

                        java.util.Date efDate = originalFormat.parse(this.efDate);
                        this.efDate = targetFormat.format(efDate);

                        String query = "INSERT INTO "+ this.table+ " "
                                + "(ID, REFNO, PCANO, PCADESC, "
                                + "PYEAR, PMONTH, EFDATE, "
                                + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                + ")"
                                + "VALUES"
                                + "("
                                + id+ ", "
                                + "'"+ this.refNo+ "', "
                                + "'"+ pcaNo+ "', "
                                + "'"+ this.pcaDesc+ "', "
                                + this.pYear+ ", "
                                + this.pMonth+ ", "
                                + "'"+ this.efDate+ "', "
                                + "'"+ system.getLogUser(session)+"', "
                                + "'"+ system.getLogDate()+ "', "
                                + "'"+ system.getLogTime()+ "', "
                                + "'"+ system.getClientIpAdr(request)+ "'"
                                + ")";

                        pcaHdrCreated = stmt.executeUpdate(query);

                    }catch(Exception e){
                        e.getMessage();
                    }
                }
            }

            return pcaHdrCreated;
        }

    }
        
    Integer errorCount  = 0;
    String errorMsg     = "";
    Integer sucCount    = 0;
    
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
//        maximum size that will be stored in memory
        factory.setSizeThreshold(maxMemSize);
//        Location to save data that is larger than maxMemSize.
//        factory.setRepository(new File("c:\\temp"));
        factory.setRepository(new File(filePath));

//        Create a new file upload handler
        ServletFileUpload upload = new ServletFileUpload(factory);
//        maximum file size to be uploaded.
        upload.setSizeMax( maxFileSize );
        try{ 
//            Parse the request to get file items.
            List fileItems = upload.parseRequest(request);
            
//            Process the uploaded file items
            Iterator i = fileItems.iterator();
            String fileName = "";
            while ( i.hasNext () ) {
                FileItem fi = (FileItem)i.next();
                if ( !fi.isFormField () ){
//                    Get the uploaded file parameters
//                    String fieldName = fi.getFieldName();
                    fileName = fi.getName();
//                    boolean isInMemory = fi.isInMemory();
//                    long sizeInBytes = fi.getSize();
//                    Write the file
                    if( fileName.lastIndexOf("\\") >= 0 ){
                        file = new File( filePath + 
                        fileName.substring( fileName.lastIndexOf("\\"))) ;
                    }else{
                        file = new File( filePath + 
                        fileName.substring(fileName.lastIndexOf("\\")+1)) ;
                    }
                    fi.write(file) ;
                }
            }
        
//            out.println(fileName);
        
            File f = new File(filePath + fileName);
        
            String fileExtension = system.getFileExtension(f);
        
            if(! fileExtension.equals("xls")){
                errorCount++;
                errorMsg = "Invalid file detected.";
            }else{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt  = conn.createStatement();

                String query;
            
                ImportPCA pcaImp = new ImportPCA();
            
                InputStream is      = new BufferedInputStream(new FileInputStream(f));
            
                POIFSFileSystem fs  = new POIFSFileSystem(is);
                HSSFWorkbook wb     = new HSSFWorkbook(fs);
                HSSFSheet sheet     = wb.getSheetAt(0);
                Iterator<?> rows    = sheet.rowIterator();
                Integer rowCount    = 0;
                Integer j;
                while (rows.hasNext()) {
                    HSSFRow row = (HSSFRow) rows.next();

                    String pfNo         = row.getCell(0).toString();
                    String itemCode     = row.getCell(1).toString();

                    j = rowCount == 0? 1: rowCount; 
                
//                    out.print("<br>Bj = "+ j);
//                    out.print("<br>BrowCount = "+ rowCount);
                
                    DataFormatter df = new DataFormatter();
                    Cell cell = sheet.getRow(j).getCell(2);
                    String newAmount_ = df.formatCellValue(cell);
                
                    pfNo = pfNo.replaceAll("(?<=^\\d+)\\.0*$", "");
                    Double newAmount = Double.parseDouble(newAmount_);
                
                    if(pcaImp.createPcaHeader() == 1){
                        Integer id = system.generateId("PYPCADTLS", "ID");

                        String sqlWhere = "PFNO = '"+ pfNo+ "' AND ITEMCODE = '"+ itemCode+ "' AND PYEAR = '"+ system.getPrevPeriodYear()+ "' AND PMONTH = '"+ system.getPrevPeriodMonth()+ "'";
                        String oldAmount_ = system.getOne("PYSLIP", "AMOUNT", sqlWhere);
                        oldAmount_ = oldAmount_ != null? oldAmount_: "0";
                        Double oldAmount = Double.parseDouble(oldAmount_);

                        query = "INSERT INTO PYPCADTLS "
                                    + "("
                                    + "ID, REFNO, PFNO, ITEMCODE, OLDAMOUNT, NEWAMOUNT,"
                                    + "LINEDESC, "
                                    + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                                    + ")"
                                    + "VALUES"
                                    + "("
                                    + id+ ", "
                                    + "'"+ pcaImp.refNo+ "', "
                                    + "'"+ pfNo+ "', "
                                    + "'"+ itemCode+ "', "
                                    + oldAmount+ ", "
                                    + newAmount+ ", "
                                    + "'IMP-"+ pcaImp.refNo+ "', "
                                    + "'"+ system.getLogUser(session)+ "', "
                                    + "'"+ system.getLogDate()+ "', "
                                    + system.getLogTime()+ ", "
                                    + "'"+ system.getClientIpAdr(request)+ "'"
                                    + ")";

                        if(rowCount > 0){
                            Integer saved = stmt.executeUpdate(query);
                            if(saved == 1){
                                sucCount++;
                            }
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
        <title>Import PCA</title>
    </head>
    <body>
        <script type="text/javascript">
            <%
                if(errorCount > 0){%>
                    parent.pca.getImpErrResp(<%= errorCount%>, '<%= errorMsg%>');
                <%
                }else{%>
                    parent.pca.getImpSucResp(<%= sucCount%>);
                <%}
                %>
        </script>
    </body>
</html>