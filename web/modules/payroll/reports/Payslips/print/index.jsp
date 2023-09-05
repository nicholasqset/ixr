<%-- 
    Document   : index
    Created on : Jun 25, 2016, 7:09:51 PM
    Author     : nicholas
--%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.OutputStream"%>
<%@page import="net.sf.jasperreports.engine.JasperRunManager"%>
<%@page import="com.qset.gui.Gui"%>
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
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="java.sql.*"%>
<%@page import="com.qset.sys.Sys"%>
<%@page trimDirectiveWhitespaces="true" %>


<%
    String comCode = session.getAttribute("comCode").toString();
    Sys sys = new Sys();
    try {

        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        ResultSet rs;
        String query;

        Integer pYear = (request.getParameter("pYear") != null && !request.getParameter("pYear").trim().equals("")) ? Integer.parseInt(request.getParameter("pYear")) : null;
        Integer pMonth = (request.getParameter("pMonth") != null && !request.getParameter("pMonth").trim().equals("")) ? Integer.parseInt(request.getParameter("pMonth")) : null;

        String outputForm = "pdf";

        String rptName = "payslips";

        String webRootPath = application.getRealPath("/").replace('\\', '/');
        String tempPath = webRootPath + "/tmp/reports/jasper/log/";
        File theDir = new File(tempPath);
        if (!theDir.exists()) {
            theDir.mkdirs();
        }
        String mainReportPath = "";

        mainReportPath = webRootPath + "/reports/jasper/payroll/" + rptName + ".jrxml";

        JasperReport jasperMainReport = JasperCompileManager.compileReport(mainReportPath);

        JasperPrint jrPrint;

        stmt = conn.createStatement();

        query = ""
                + "SELECT "
                + "*, qset.get_month_name(" + pMonth + ") "
                + "FROM "
                + comCode + ".viewpyslip "
                + "WHERE "
                + "pyear = " + pYear + " AND "
                + "pmonth = " + pMonth + " AND "
                + "hdrtype NOT IN ('IN') "
                + "";

//        System.out.println(query);
        rs = stmt.executeQuery(query);

        Map<String, Object> params = new HashMap();
        params.put("REPORT_CONNECTION", conn);
        params.put("SUBREPORT_DIR", webRootPath + "/reports/jasper/payroll/");
        params.put("p_comcode", comCode);

        JRResultSetDataSource resultSetDataSource = new JRResultSetDataSource(rs);

        jrPrint = JasperFillManager.fillReport(jasperMainReport, params, resultSetDataSource);
        if (outputForm.equals("html")) {
            ServletOutputStream outStream = response.getOutputStream();

            JRHtmlExporter exporter = new JRHtmlExporter();
            exporter.setParameter(JRExporterParameter.JASPER_PRINT, jrPrint);
            exporter.setParameter(JRHtmlExporterParameter.IS_OUTPUT_IMAGES_TO_DIR, Boolean.TRUE);
            exporter.setParameter(JRHtmlExporterParameter.IMAGES_DIR_NAME, "./assets/img/");
            exporter.setParameter(JRHtmlExporterParameter.IMAGES_URI, "/assets/img/");
            exporter.setParameter(JRHtmlExporterParameter.IS_USING_IMAGES_TO_ALIGN, Boolean.FALSE);
            exporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outStream);
            exporter.exportReport();

            Gui gui = new Gui();
            out.print(gui.loadJs(request.getContextPath(), "scriptaculous/lib/prototype"));
%>
<script language="javascript">
    Event.observe(window, 'load', function () {
        setTimeout('window.print();', '3000');
    });
</script>
<%
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
        } else {
//            File file = new File(mainReportPath.replace("jrxml", "jasper"));
// 
//            byte[] bytes = null;
//            bytes = JasperRunManager.runReportToPdf(file.getPath(), params, conn);
// 
//            response.setContentType("application/pdf");
//            response.setContentLength(bytes.length);
//
//            OutputStream o = response.getOutputStream();
//            o.write(bytes, 0, bytes.length);
//            o.flush(); 
//            o.close();
//            JasperPrint print = JasperFillManager.fillReport(report, new HashMap(), jasperReports); 
//            long start = System.currentTimeMillis(); 
            long start = sys.curTimeMillis();
            File file = new File(tempPath + rptName + "_" + comCode + "_" + start + ".pdf");
//            OutputStream output = new FileOutputStream(file);
//            JasperExportManager.exportReportToPdfStream(jrPrint, output);

//            FileInputStream fin = new FileInputStream(file);
//
//            ServletOutputStream outStream = response.getOutputStream();
//            response.setContentType("application/pdf");
//            response.setHeader("Content-Disposition", "attachment;filename=\"" + rptName + ".pdf\"");
//            JasperExportManager.exportReportToPdfStream(jrPrint, output);
//            JasperRunManager.runReportToPdfStream(fin, outStream, params);
//            byte[] buffer = new byte[1024];
//            int n = 0;
//            while ((n = fin.read(buffer)) != -1) {
//                outStream.write(buffer, 0, n);
//                out.print(buffer);
//            }
//
//            outStream.flush();
//            outStream.close();
//            fin.close();
            response.setContentType("application/x-download");
            response.addHeader("Content-disposition", "attachment;filename=\"" + rptName + ".pdf\"");
            OutputStream out2 = response.getOutputStream();
            JasperExportManager.exportReportToPdfStream(jrPrint, out2);

            if (file.exists()) {
                file.delete();
            }

        }
    } catch (Exception e) {
        //        out.println(e.getMessage());
        sys.logV2(e.getMessage());
    }

%>
