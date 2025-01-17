<%-- 
    Document   : index
    Created on : Jun 25, 2016, 7:09:51 PM
    Author     : nicholas
--%>
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

<%
    String comCode       = session.getAttribute("comCode").toString();
    
    try{
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        ResultSet rs;
        String query;
        
        Integer pYear   = (request.getParameter("pYear") != null && ! request.getParameter("pYear").trim().equals(""))? Integer.parseInt(request.getParameter("pYear")): null;
        Integer pMonth  = (request.getParameter("pMonth") != null && ! request.getParameter("pMonth").trim().equals(""))? Integer.parseInt(request.getParameter("pMonth")): null;
        
        String outputForm = "excel";
        
        String rptName = "NSSF";
        
        
        String webRootPath      = application.getRealPath("/").replace('\\', '/');
        String tempPath         = webRootPath+ "/tmp/reports/jasper/log/";
        File theDir = new File(tempPath);
        if (!theDir.exists()) {
            theDir.mkdirs();
        }
        String mainReportPath   = "";

        mainReportPath  = webRootPath+ "/reports/jasper/payroll/"+ rptName+ ".jrxml";

        JasperReport jasperMainReport = JasperCompileManager.compileReport(mainReportPath);

        JasperPrint jrPrint;

        stmt    = conn.createStatement();
            
//        query = ""
//                + "SELECT "
//                + "s.*, "
//                + "(SELECT amount FROM pyslip WHERE pfno = s.pfno AND itemcode = '410' AND pyear = "+ pYear+ " AND pmonth  = "+ pMonth+ ")nhif, "
//                + "'410' itemcode, "
//                + "(firstname||' '||middlename)fmname "
//                + "FROM "
//                + "viewstaffprofile s "
//                + "WHERE "
//                + "active = 1 AND "
//                + "pfno NOT IN (SELECT pfno FROM pystaffexempt WHERE itemcode = '410')"


            
        query = ""
                + "SELECT "
                + "s.*, "
                + comCode+ ".get_py_slip_amount(s.pfno, '405', "+ pYear+ ", "+ pMonth+ ") nssf_employee, "
                + comCode+ ".get_py_slip_amount(s.pfno, '415', "+ pYear+ ", "+ pMonth+ ") nssf_employer, "
                + comCode+ ".get_py_slip_amount(s.pfno, '406', "+ pYear+ ", "+ pMonth+ ") voluntary_nssf, "
                + "( "
                + comCode+ ".get_py_slip_amount(s.pfno, '405', "+ pYear+ ", "+ pMonth+ ") "
                + "+ "
                + comCode+ ".get_py_slip_amount(s.pfno, '415', "+ pYear+ ", "+ pMonth+ ") "
                + ") std_total, "
                + "("
                + comCode+ ".get_py_slip_amount(s.pfno, '405', "+ pYear+ ", "+ pMonth+ ") "
                + "+ "
                + comCode+ ".get_py_slip_amount(s.pfno, '415', "+ pYear+ ", "+ pMonth+ ") "
                + "+ "
                + comCode+ ".get_py_slip_amount(s.pfno, '406', "+ pYear+ ", "+ pMonth+ ")"
                + ") nssf_total "
                + "FROM "
                + comCode+ ".viewstaffprofile s "
                + "WHERE "
                + "active = 1 AND "
                + "pfno NOT IN (SELECT pfno FROM "+comCode+".pystaffexempt WHERE itemcode IN ('405', '415'))"
                + "";
        
//        out.println(query);

        rs      = stmt.executeQuery(query);

        Map<String, Object> params = new HashMap();
        params.put("REPORT_CONNECTION", conn);
        params.put("SUBREPORT_DIR", webRootPath+ "/reports/jasper/payroll/");
        params.put("p_comcode", comCode);

        JRResultSetDataSource resultSetDataSource = new JRResultSetDataSource(rs);

        jrPrint = JasperFillManager.fillReport(jasperMainReport, params, resultSetDataSource);
        if(outputForm.equals("html")){
            ServletOutputStream outStream = response.getOutputStream();

            JRHtmlExporter exporter = new JRHtmlExporter();
            exporter.setParameter(JRExporterParameter.JASPER_PRINT, jrPrint);
            exporter.setParameter(JRHtmlExporterParameter.IS_OUTPUT_IMAGES_TO_DIR, Boolean.TRUE);
            exporter.setParameter(JRHtmlExporterParameter.IMAGES_DIR_NAME, "./assets/img/");
            exporter.setParameter(JRHtmlExporterParameter.IMAGES_URI, "/assets/img/");
            exporter.setParameter(JRHtmlExporterParameter.IS_USING_IMAGES_TO_ALIGN, Boolean.FALSE);
            exporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outStream);
            exporter.exportReport();
        }else if(outputForm.equals("excel")){
            JRXlsExporter exporterXLS = new JRXlsExporter();
            exporterXLS.setParameter(JRXlsExporterParameter.JASPER_PRINT, jrPrint);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_ONE_PAGE_PER_SHEET, Boolean.TRUE);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_DETECT_CELL_TYPE, Boolean.TRUE);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_WHITE_PAGE_BACKGROUND, Boolean.FALSE);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_REMOVE_EMPTY_SPACE_BETWEEN_ROWS, Boolean.TRUE);
            exporterXLS.setParameter(JRExporterParameter.OUTPUT_FILE_NAME,tempPath+ rptName+ ".xls");
            exporterXLS.exportReport();
            File f = new File(tempPath+ rptName+ ".xls");
            FileInputStream fin = new FileInputStream(f);
            ServletOutputStream outStream = response.getOutputStream();
            response.setContentType("application/vnd.ms-excel");
            response.setHeader("Content-Disposition", "attachment;filename=\""+ rptName+ ".xls\"");

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
    }catch(Exception e){
        out.println(e.getMessage());
    }
    
%>
