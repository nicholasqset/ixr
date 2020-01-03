<%-- 
    Document   : index
    Created on : Jun 25, 2016, 7:09:51 PM
    Author     : nicholas
--%>
<%@page import="bean.ap.APPyHDR"%>
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
<%@page import="java.sql.*"%>
<%@page import="bean.sys.Sys"%>

<%
    
    try{
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        ResultSet rs;
        String query;
        
        Integer batchNo     = request.getParameter("batchNo") != null && ! request.getParameter("batchNo").trim().equals("")? Integer.parseInt(request.getParameter("batchNo")): null;
        String pyNo         = request.getParameter("paymentNo") != null && ! request.getParameter("paymentNo").trim().equals("")? request.getParameter("paymentNo"): null;
        
        APPyHDR aPPyHDR = new APPyHDR(batchNo, pyNo);
        
        if(aPPyHDR.isCheque){
            String webRootPath      = application.getRealPath("/").replace('\\', '/');
            String mainReportPath   = "";

            Sys sys = new Sys();
            
            String tplName = system.getOne("FNBKCHQTPLS", "TPLNAME", "BANKCODE = '"+ aPPyHDR.bankCode+ "' AND ISDFT = 1");

            mainReportPath  = webRootPath+ "/reports/jasper/ap/cheques/"+ aPPyHDR.bankCode+ "/"+ tplName;
            
            JasperReport jasperMainReport = JasperCompileManager.compileReport(mainReportPath);

            JasperPrint jrPrint;

                stmt    = conn.createStatement();
                query = " SELECT * FROM VIEWAPPYDTLS WHERE BATCHNO = "+ batchNo+ " AND PYNO = '"+ pyNo+ "' ";
                rs      = stmt.executeQuery(query);

                Map<String, Object> params = new HashMap();
                params.put("REPORT_CONNECTION", conn);

                JRResultSetDataSource resultSetDataSource = new JRResultSetDataSource(rs);

                jrPrint = JasperFillManager.fillReport(jasperMainReport, params, resultSetDataSource);
                ServletOutputStream outStream = response.getOutputStream();

                JRHtmlExporter exporter = new JRHtmlExporter();
                exporter.setParameter(JRExporterParameter.JASPER_PRINT, jrPrint);
                exporter.setParameter(JRHtmlExporterParameter.IS_OUTPUT_IMAGES_TO_DIR, Boolean.TRUE);
                exporter.setParameter(JRHtmlExporterParameter.IMAGES_DIR_NAME, "./images/");
                exporter.setParameter(JRHtmlExporterParameter.IMAGES_URI, "/images/");
                exporter.setParameter(JRHtmlExporterParameter.IS_USING_IMAGES_TO_ALIGN, Boolean.FALSE);
                exporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outStream);
                exporter.exportReport();
        }else{
            out.println("Oops! its not bank mode.");
        }
    }catch(Exception e){
        out.println(e.getMessage());
    }
    
%>
