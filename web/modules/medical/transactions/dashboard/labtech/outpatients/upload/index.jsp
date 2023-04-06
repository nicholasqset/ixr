<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.DataInputStream"%>
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

    Enumeration params = request.getParameterNames();
    while (params.hasMoreElements()) {
        String paramName = (String) params.nextElement();
        out.println("Attribute Name = " + paramName + ", Value = " + request.getParameter(paramName) + "<br>");
    }
    String comCode = session.getAttribute("comCode").toString();

    Integer errorCount = 0;
    String errorMsg = "";

    String rid = request.getParameter("rid");
    String regNo = request.getParameter("regNo");

    Sys sys = new Sys();

    File file;
    int maxFileSize = 1024 * 1024 * 10;
    int maxMemSize = 1024 * 1024 * 10;

//   ServletContext context = pageContext.getServletContext();
//   String filePath = context.getInitParameter("file-upload");
    String webRootPath = application.getRealPath("/").replace('\\', '/');
    String relFilePath = "/documents/medical/labtech/";
    String filePath = webRootPath + "documents/medical/labtech/";
    // Verify the content type
    String contentType = request.getContentType();

//    out.println("x1");
    if ((contentType.indexOf("multipart/form-data") >= 0)) {
//        out.println("x2");
        DiskFileItemFactory factory = new DiskFileItemFactory();
        // maximum size that will be stored in memory
        factory.setSizeThreshold(maxMemSize);
        // Location to save data that is larger than maxMemSize.
//      factory.setRepository(new File("c:\\temp"));
        factory.setRepository(new File(filePath));
//out.println("x2");
        // Create a new file upload handler
        ServletFileUpload upload = new ServletFileUpload(factory);
        // maximum file size to be uploaded.
        upload.setSizeMax(maxFileSize);
        try {
            // Parse the request to get file items.
            List fileItems = upload.parseRequest(request);

            // Process the uploaded file items
            Iterator i = fileItems.iterator();
            String fileName = "";
            while (i.hasNext()) {
                FileItem fi = (FileItem) i.next();
                if (!fi.isFormField()) {
                    // Get the uploaded file parameters
                    String fieldName = fi.getFieldName();
                    fileName = fi.getName();
                    boolean isInMemory = fi.isInMemory();
                    long sizeInBytes = fi.getSize();
                    // Write the file
                    if (fileName.lastIndexOf("\\") >= 0) {
                        file = new File(filePath
                                + fileName.substring(fileName.lastIndexOf("\\")));
                    } else {
                        file = new File(filePath
                                + fileName.substring(fileName.lastIndexOf("\\") + 1));
                    }
                    fi.write(file);

                }

            }

//            out.println(fileName+"<br>");
            out.println(filePath + "<br>");

            File fileDir = new File(filePath);

            if (!fileDir.exists()) {
                fileDir.mkdir();
            }

            File f = new File(filePath + fileName);

//            FileInputStream fis = new FileInputStream(f);

            Connection con = ConnectionProvider.getConnection();
            Statement stmt;

            String query;

            stmt = con.createStatement();
            query = "DELETE FROM " + comCode + ".hmptlabdocs WHERE rid = '" + rid + "'";

//            out.println(query+"<br>");
            stmt.executeUpdate(query);

            PreparedStatement ps;

//            query = "INSERT INTO " + comCode + ".hmptlabdocs("
//                    + "rid, refno, filename, filesize, filetype, audituser, auditdate, auditip, filepath)"
//                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);";
            query = "INSERT INTO " + comCode + ".hmptlabdocs("
                    + "rid, refno, filename, filesize, filetype, filepath)"
                    + "VALUES (?, ?, ?, ?, ?, ?);";

//            out.println(query+"<br>");
            ps = con.prepareStatement(query);

//        ps.setInt(1, id);
            ps.setLong(1, Long.parseLong(rid));
            ps.setString(2, rid + "-" + regNo);
            ps.setString(3, fileName);
            ps.setLong(4, f.length());
            ps.setString(5, new MimetypesFileTypeMap().getContentType(f));
//            ps.setString(6, sys.getLogUser(session));
//            ps.setDate(7, java.sql.Date.valueOf(sys.getLogDate()));
////        ps.setInt(9, Integer.parseInt(sys.getLogTime()));
//            ps.setString(8, sys.getClientIpAdr(request));
            ps.setString(6, relFilePath + fileName);

            Integer saved = ps.executeUpdate();

            if (saved == 1) {
                // record saved

//                out.println("fileName=" + fileName + "<br>");
//                out.println("filePath=" + filePath + "<br>");

//                File fileDir = new File(filePath);
//
//                if (!fileDir.exists()) {
//                    fileDir.mkdir();
//                }

                //start
                DataInputStream in = new DataInputStream(request.getInputStream());
                int formDataLength = request.getContentLength();
                byte dataBytes[] = new byte[formDataLength];
                int byteRead = 0;
                int totalBytesRead = 0;
                while (totalBytesRead < formDataLength) {
                    byteRead = in.read(dataBytes, totalBytesRead, formDataLength);
                    totalBytesRead += byteRead;
                }

                String filex = new String(dataBytes);
                String saveFile = filex.substring(filex.indexOf("filename=\"") + 10);
                saveFile = saveFile.substring(0, saveFile.indexOf("\n"));
                saveFile = saveFile.substring(saveFile.lastIndexOf("\\") + 1, saveFile.indexOf("\""));
                int lastIndex = contentType.lastIndexOf("=");
                String boundary = contentType.substring(lastIndex + 1, contentType.length());
                int pos;
                pos = filex.indexOf("filename=\"");
                pos = filex.indexOf("\n", pos) + 1;
                pos = filex.indexOf("\n", pos) + 1;
                pos = filex.indexOf("\n", pos) + 1;
                int boundaryLocation = filex.indexOf(boundary, pos) - 4;
                int startPos = ((filex.substring(0, pos)).getBytes()).length;
                int endPos = ((filex.substring(0, boundaryLocation)).getBytes()).length;

                File f2 = new File(filePath + fileName);

                FileOutputStream fileOut = new FileOutputStream(f2);
                fileOut.write(dataBytes, startPos, (endPos - startPos));
                fileOut.flush();
                fileOut.close();

                //end
            } else {
                errorCount++;
                errorMsg = "Oops! An un-expected error occurred while trying to save.";
            }

            if (f.exists()) {
                f.delete();
            }

        } catch (Exception ex) {
            out.println(ex.getMessage() + "<br>");
            System.out.println(ex.getMessage());
        }
    } else {
        errorCount++;
        errorMsg = "Unable to upload photo.";
    }

%>
<html>
    <head>
        <title>upload doc</title>
    </head>
    <body>
        <script type="text/javascript">
            <%  if (errorCount > 0) {%>
            parent.registration.getUploadResponse(<%= errorCount%>, '<%= errorMsg%>');
            <%
            } else {%>
            parent.registration.getUploadResponse();
            <%}
            %>
        </script>
    </body>                                     
</html>