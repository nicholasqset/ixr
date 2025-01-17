<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.io.*"%>
<%@page import="com.qset.sys.Sys"%>
<%
    Integer errorCount      = 0;
    String errorMsg         = "";
    
    String bankCode         = request.getParameter("bank");
    String tplCode          = request.getParameter("template");
    Integer id              = request.getParameter("id") != null? Integer.parseInt(request.getParameter("id")): null;
    
    String tplName;
    
    switch(tplCode){
        case "tpl1":
            tplName = "Template 1";
            break;
            
        case "tpl2":
            tplName = "Template 2";
            break;
        
        case "tpl3":
            tplName = "Template 3";
            break;
        
        default:
            tplName = "Template 0";
            break;
    }
    
    try{
        
        String webRootPath      = application.getRealPath("/").replace('\\', '/');
        String relReportPath    = "/reports/jasper/ap/cheques/";

        String reportDirPath    = webRootPath+ relReportPath;

        String reportPath       = reportDirPath+ "/"+ bankCode;

        String rptName          = "";
        String saveFile         = "";
        String contentType      = request.getContentType();

        if ((contentType != null) && (contentType.indexOf("multipart/form-data") >= 0)){

            DataInputStream in  = new DataInputStream(request.getInputStream());
            int formDataLength  = request.getContentLength();
            byte dataBytes[]    = new byte[formDataLength];
            int byteRead = 0;
            int totalBytesRead = 0;
            while (totalBytesRead < formDataLength) {
                byteRead = in.read(dataBytes, totalBytesRead, formDataLength);
                totalBytesRead += byteRead;
            }

            String file = new String(dataBytes);
            saveFile = file.substring(file.indexOf("filename=\"") + 10);
            saveFile = saveFile.substring(0, saveFile.indexOf("\n"));
            saveFile = saveFile.substring(saveFile.lastIndexOf("\\") + 1, saveFile.indexOf("\""));
            int lastIndex = contentType.lastIndexOf("=");
            String boundary = contentType.substring(lastIndex + 1, contentType.length());
            int pos;
            pos = file.indexOf("filename=\"");
            pos = file.indexOf("\n", pos) + 1;
            pos = file.indexOf("\n", pos) + 1;
            pos = file.indexOf("\n", pos) + 1;
            int boundaryLocation = file.indexOf(boundary, pos) - 4;
            int startPos = ((file.substring(0, pos)).getBytes()).length;
            int endPos = ((file.substring(0, boundaryLocation)).getBytes()).length;

            File reportDir = new File(reportPath); 

            if(! reportDir.exists()){ 
                reportDir.mkdir(); 
            } 
            
            rptName = saveFile;

            reportPath      = reportDirPath+ "/"+ bankCode+ "/";
            relReportPath   = relReportPath+ bankCode+ "/"+ saveFile;
            saveFile        = reportPath + saveFile;
            
            Sys sys = new Sys();
            
            File f = new File(saveFile);

            String fileExtension = system.getFileExtension(f);

            if(! fileExtension.equals("jrxml")){
                errorCount++;
                errorMsg = "Invalid file detected.";
            }else{
                FileOutputStream fileOut = new FileOutputStream(f);
                fileOut.write(dataBytes, startPos, (endPos - startPos));
                fileOut.flush();
                fileOut.close();

                if(!system.recordExists("FNBKCHQTPLS", "BANKCODE = '"+ bankCode+ "' AND TPLCODE = '"+ tplCode+"'")){
                    try{
                        Connection conn = ConnectionProvider.getConnection();
                        Statement stmt = conn.createStatement();

                        Integer sid = system.generateId("FNBKCHQTPLS", "ID");

                        String query;

                        query = "INSERT INTO qset.FNBKCHQTPLS "
                            + "(ID, BANKCODE, TPLCODE, TPLNAME) "
                            + " VALUES "
                            + "("
                            + sid+ ","
                            + "'"+ bankCode+ "', "
                            + "'"+ tplCode+ "', "
                            + "'"+ rptName+ "'"
                            + ")";

                        Integer saved = stmt.executeUpdate(query);

                        if(saved == 1){
                            // record saved
                        }else{
                            errorCount++;
                            errorMsg = "Oops! An un-expected error occurred while trying to save.";
                        }
                    }catch(SQLException e){
                        errorCount++;
                        errorMsg = e.getMessage();
                    }
                }
            }
        }else{
            errorCount++;
            errorMsg = "Invalid file detected.";
        }
    }catch(Exception e){
        errorCount++;
        errorMsg = e.getMessage();
    }
    
%>
<html>
    <head>
        <title></title>
    </head>
    <body>
        <script type="text/javascript">
            parent.bank.getUploadResponse(<%= errorCount%>, "<%= errorMsg%>", <%= id%>);
        </script>
    </body>
</html>