<%-- 
    Document   : index
    Created on : Jun 25, 2016, 7:09:51 PM
    Author     : nicholas
--%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.Map"%>
<%@page import="net.sf.jasperreports.engine.util.JRLoader"%>
<%@page import="java.util.HashMap"%>
<%@page import="net.sf.jasperreports.engine.JREmptyDataSource"%>
<%@page import="net.sf.jasperreports.engine.export.JRXlsExporterParameter"%>
<%@page import="net.sf.jasperreports.engine.export.JRXlsExporter"%>
<%@page import="net.sf.jasperreports.engine.JasperExportManager"%>
<%@page import="net.sf.jasperreports.view.JasperViewer"%>
<%@page import="net.sf.jasperreports.engine.JasperPrint"%>
<%@page import="net.sf.jasperreports.engine.JasperFillManager"%>
<%@page import="net.sf.jasperreports.engine.JasperReport"%>
<%@page import="net.sf.jasperreports.engine.JasperCompileManager"%>
<%@page import="net.sf.jasperreports.engine.export.JRTextExporterParameter"%>
<%@page import="net.sf.jasperreports.engine.export.JRTextExporter"%>
<%@page import="net.sf.jasperreports.engine.export.JRHtmlExporterParameter"%>
<%@page import="net.sf.jasperreports.engine.JRExporterParameter"%>
<%@page import="net.sf.jasperreports.engine.export.JRHtmlExporter"%>
<%@page import="net.sf.jasperreports.engine.JRResultSetDataSource"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="bean.sys.Sys"%>

<%
    String comCode = session.getAttribute("comCode").toString();
    String stockGroup = request.getParameter("stockGroup");
    
    Sys sys = new Sys();
    
    try {
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        ResultSet rs;
        String query;

        String catCode = request.getParameter("category");

        SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy");
        SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd");

//        String outputForm = "html";
        String outputForm = "excel";

        String rptName = "items";

        String webRootPath = application.getRealPath("/").replace('\\', '/');

        String tempPath = webRootPath + "/tmp/reports/jasper/log/";
        //create file
        File theDir = new File(tempPath);
        if (!theDir.exists()) {
            theDir.mkdirs();
        }

        String mainReportPath = "";

        mainReportPath = webRootPath + "/reports/jasper/ic/" + rptName + ".jrxml";

        JasperReport jasperMainReport = JasperCompileManager.compileReport(mainReportPath);

        JasperPrint jrPrint;

        stmt = conn.createStatement();

//        if (catCode.trim().equals("") || catCode == null) {
//            query = " SELECT * FROM " + session.getAttribute("comCode") + ".VIEWICITEMS ";
//        } else {
//            query = " SELECT * FROM " + session.getAttribute("comCode") + ".VIEWICITEMS WHERE catcode = '" + catCode + "' ";
//        }
        if (stockGroup.equals("low")) {
            if (catCode.trim().equals("") || catCode == null) {
                query = "SELECT * FROM " + comCode + ".VIEWICITEMS WHERE qty <= minlevel AND STOCKED = 1 ORDER BY ITEMCODE";
            } else {
                query = " SELECT * FROM " + session.getAttribute("comCode") + ".VIEWICITEMS WHERE catcode = '" + catCode + "' AND qty <= minlevel AND STOCKED = 1 ";
            }
        } else if (stockGroup.equals("exp")) {
            if (catCode.trim().equals("") || catCode == null) {
                query = "SELECT * FROM " + comCode + ".VIEWICITEMS WHERE expdt < '" + sys.getLogDate() + "' ORDER BY ITEMCODE";
            } else {
                query = " SELECT * FROM " + session.getAttribute("comCode") + ".VIEWICITEMS WHERE catcode = '" + catCode + "' AND expdt < '" + sys.getLogDate() + "'";
            }
        } else {
            if (catCode.trim().equals("") || catCode == null) {
                query = "SELECT * FROM " + comCode + ".VIEWICITEMS WHERE 1 = 1 ORDER BY ITEMCODE";
            } else {
                query = " SELECT * FROM " + session.getAttribute("comCode") + ".VIEWICITEMS WHERE catcode = '" + catCode + "' ";
            }
        }

        rs = stmt.executeQuery(query);

        Map<String, Object> params = new HashMap();
        params.put("REPORT_CONNECTION", conn);
        params.put("SUBREPORT_DIR", webRootPath + "/reports/jasper/ic/");
        params.put("p_comcode", comCode);

        JRResultSetDataSource resultSetDataSource = new JRResultSetDataSource(rs);

        jrPrint = JasperFillManager.fillReport(jasperMainReport, params, resultSetDataSource);
        if (outputForm.equals("html")) {
            ServletOutputStream outStream = response.getOutputStream();

            JRHtmlExporter exporter = new JRHtmlExporter();
            exporter.setParameter(JRExporterParameter.JASPER_PRINT, jrPrint);
            exporter.setParameter(JRHtmlExporterParameter.IS_OUTPUT_IMAGES_TO_DIR, Boolean.TRUE);
            exporter.setParameter(JRHtmlExporterParameter.IMAGES_DIR_NAME, "./images/");
            exporter.setParameter(JRHtmlExporterParameter.IMAGES_URI, "/images/");
            exporter.setParameter(JRHtmlExporterParameter.IS_USING_IMAGES_TO_ALIGN, Boolean.FALSE);
            exporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outStream);
            exporter.exportReport();
        } else if (outputForm.equals("excel")) {
            JRXlsExporter exporterXLS = new JRXlsExporter();
            exporterXLS.setParameter(JRXlsExporterParameter.JASPER_PRINT, jrPrint);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_ONE_PAGE_PER_SHEET, Boolean.TRUE);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_DETECT_CELL_TYPE, Boolean.TRUE);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_WHITE_PAGE_BACKGROUND, Boolean.FALSE);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_REMOVE_EMPTY_SPACE_BETWEEN_ROWS, Boolean.TRUE);
            exporterXLS.setParameter(JRExporterParameter.OUTPUT_FILE_NAME, tempPath + rptName + ".xls");
            exporterXLS.exportReport();
            File f = new File(tempPath + rptName + ".xls");
            FileInputStream fin = new FileInputStream(f);
            ServletOutputStream outStream = response.getOutputStream();
            response.setContentType("application/vnd.ms-excel");
            response.setHeader("Content-Disposition", "attachment;filename=\"" + rptName + ".xls\"");

            byte[] buffer = new byte[1024];
            int n = 0;
            while ((n = fin.read(buffer)) != -1) {
                outStream.write(buffer, 0, n);
                out.print(buffer);
            }

            outStream.flush();
            fin.close();
            outStream.close();
        }
    } catch (Exception e) {
        out.println(e.getMessage());

    }

%>