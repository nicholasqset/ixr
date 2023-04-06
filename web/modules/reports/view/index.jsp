<%-- 
    Document   : index
    Created on : Dec 11, 2011, 11:16:46 AM
    Author     : Gakumo
--%>
<%@page import="net.sf.jasperreports.engine.export.JRTextExporterParameter"%>
<%@page import="net.sf.jasperreports.engine.export.JRTextExporter"%>
<%@page import="net.sf.jasperreports.engine.export.JRHtmlExporterParameter"%>
<%@page import="net.sf.jasperreports.engine.export.JRHtmlExporter"%>
<%@page import="net.sf.jasperreports.engine.JRExporterParameter"%>
<%@page import="net.sf.jasperreports.engine.export.JRXlsExporterParameter"%>
<%@page import="net.sf.jasperreports.engine.export.JRXlsExporter"%>
<%@page import="net.sf.jasperreports.engine.JasperExportManager"%>
<%@page import="net.sf.jasperreports.engine.JREmptyDataSource"%>
<%@page import="net.sf.jasperreports.engine.JasperFillManager"%>
<%@page import="net.sf.jasperreports.engine.JRResultSetDataSource"%>
<%@page import="net.sf.jasperreports.engine.JasperPrint"%>
<%@page import="net.sf.jasperreports.engine.JasperReport"%>
<%@page import="net.sf.jasperreports.engine.JasperCompileManager"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSetMetaData"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page import="com.qset.conn.ConnectionProvider"%>
<%@page import="com.qset.sys.Sys"%>

<%
    try{
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt = null;
        ResultSet rs;
        String query;
        
        String id               = request.getParameter("id");
        String outputForm       = request.getParameter("outputForm");
        
        String webRootPath      = application.getRealPath("/").replace('\\', '/');
        String tempPath         = webRootPath+ "/tmp/reports/jasper/log/";
        String mainReportPath   = "";
        String subReportPath    = "";
        String rptName          = "";
        String rptDesc          = "";
        String dataSrc          = "";
        String menuCode         = "";
        String rptFilter        = "";
        
        if(id != null && !id.trim().equals("")){
            try{
                stmt = conn.createStatement();
                query = "SELECT * FROM MDRPTS WHERE ID = "+ id;
                rs = stmt.executeQuery(query);
                while(rs.next()){
                    rptName      = rs.getString("RPTNAME");		
                    rptDesc      = rs.getString("RPTDESC");		
                    dataSrc      = rs.getString("DATASRC");	
                    menuCode     = rs.getString("MENUCODE");	

                    if(dataSrc != null && ! dataSrc.trim().equals("")){
                        ResultSet rset = stmt.executeQuery("SELECT * FROM "+dataSrc+"");
                        ResultSetMetaData md = rset.getMetaData();
                        Integer count = 1;
                        for (int i = 1; i <= md.getColumnCount(); i++){
                            String colName      = md.getColumnLabel(i);

                            String colFltr = request.getParameter("col["+colName+"]");

                            if(colFltr != null && ! colFltr.trim().equals("")){

                                if(count == 1){
                                   rptFilter += " WHERE "+colName+" = '"+colFltr+"' "; 
                                }else{
                                    rptFilter += " AND "+colName+" = '"+colFltr+"' "; 
                                }

                                count++;
                            }
                        }
                    }
                }
            }catch (SQLException e){
                out.println(e.getMessage());
            }
            
        }
        
        mainReportPath  = webRootPath+ "reports/jasper/"+ menuCode+ "/"+ rptName;
        
//        out.print(mainReportPath);
        
        JasperReport jasperMainReport = JasperCompileManager.compileReport(mainReportPath);
//        out.print(jasperMainReport.getQuery().getText());
        
        JasperPrint jrPrint;
        
        if(dataSrc != null && ! dataSrc.trim().equals("")){
            stmt    = conn.createStatement();
//            query = " SELECT * FROM "+dataSrc+" "+rptFilter+" ";
            query   = jasperMainReport.getQuery().getText()+ " "+ rptFilter+ " ";
            rs      = stmt.executeQuery(query);
            
            Map<String, Object> params = new HashMap();
            params.put("REPORT_CONNECTION", conn);
            
            try{
                Statement s    = conn.createStatement();
                String q = "SELECT * FROM MDSUBRPTS WHERE IDRPT = "+id;
                ResultSet r = s.executeQuery(q);
                Integer count = 1;
                while(r.next()){
                    String subRptName = r.getString("SUBRPTNAME");
                    subReportPath  = webRootPath+ "/reports/jasper/"+ menuCode+ "/"+ subRptName;
                    JasperReport jasperSubReport = JasperCompileManager.compileReport(subReportPath);
                    JasperCompileManager.compileReportToFile(subReportPath);
                    params.put("jasperSubReportParameter"+ count, jasperSubReport);
                    
                    count++;
                }
            }catch (SQLException e){
                out.println(e.getMessage());
            }
            
            JRResultSetDataSource resultSetDataSource = new JRResultSetDataSource(rs);
            
            jrPrint = JasperFillManager.fillReport(jasperMainReport, params, resultSetDataSource);
        }else{
            jrPrint = JasperFillManager.fillReport(jasperMainReport,null, new JREmptyDataSource());
        }
        
        if(outputForm.equals("pdf")){
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=\""+rptDesc+".pdf\"");
            JasperExportManager.exportReportToPdfStream(jrPrint, response.getOutputStream());
        }else if(outputForm.equals("excel")){
            JRXlsExporter exporterXLS = new JRXlsExporter();
            exporterXLS.setParameter(JRXlsExporterParameter.JASPER_PRINT, jrPrint);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_ONE_PAGE_PER_SHEET, Boolean.TRUE);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_DETECT_CELL_TYPE, Boolean.TRUE);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_WHITE_PAGE_BACKGROUND, Boolean.FALSE);
            exporterXLS.setParameter(JRXlsExporterParameter.IS_REMOVE_EMPTY_SPACE_BETWEEN_ROWS, Boolean.TRUE);
            exporterXLS.setParameter(JRExporterParameter.OUTPUT_FILE_NAME,tempPath+rptDesc+".xls");
            exporterXLS.exportReport();
            File f = new File(tempPath+rptDesc+".xls");
            FileInputStream fin = new FileInputStream(f);
            ServletOutputStream outStream = response.getOutputStream();
            response.setContentType("application/vnd.ms-excel");
            response.setHeader("Content-Disposition", "attachment;filename=\""+rptDesc+".xls\"");

            byte[] buffer = new byte[1024];
            int n = 0;
            while ((n = fin.read(buffer)) != -1) {
                outStream.write(buffer, 0, n);
                out.print(buffer); 
            }

            outStream.flush();
            fin.close();
            outStream.close(); 
        }else if(outputForm.equals("html")){
            ServletOutputStream outStream = response.getOutputStream();
            
            JRHtmlExporter exporter = new JRHtmlExporter();
            exporter.setParameter(JRExporterParameter.JASPER_PRINT, jrPrint);
            exporter.setParameter(JRHtmlExporterParameter.IS_OUTPUT_IMAGES_TO_DIR, Boolean.TRUE);
            exporter.setParameter(JRHtmlExporterParameter.IMAGES_DIR_NAME, "./assets/img/");
            exporter.setParameter(JRHtmlExporterParameter.IMAGES_URI, "/assets/img/");
            exporter.setParameter(JRHtmlExporterParameter.IS_USING_IMAGES_TO_ALIGN, Boolean.FALSE);
            exporter.setParameter(JRExporterParameter.OUTPUT_STREAM, outStream);
            exporter.exportReport();
        }else if(outputForm.equals("text")){
            JRTextExporter exporterTxt = new JRTextExporter();
            exporterTxt.setParameter(JRExporterParameter.JASPER_PRINT, jrPrint);

            exporterTxt.setParameter(JRExporterParameter.OUTPUT_FILE_NAME,tempPath+rptDesc+".txt");


            exporterTxt.setParameter(JRTextExporterParameter.PAGE_WIDTH, new Integer(110));
            exporterTxt.setParameter(JRTextExporterParameter.PAGE_HEIGHT, new Integer(99));
            exporterTxt.exportReport();

            File f = new File(tempPath+rptDesc+".txt");
            FileInputStream fin = new FileInputStream(f);
            ServletOutputStream outStream = response.getOutputStream();
            response.setContentType("application/text");
            response.setHeader("Content-Disposition", "attachment;filename=\""+rptDesc+".txt\"");

            byte[] buffer = new byte[1024];
            int n = 0;
            while ((n = fin.read(buffer)) != -1) {
                outStream.write(buffer, 0, n);
                out.println(buffer);
            }

            outStream.flush();
            fin.close();
            outStream.close();
        }else{
            out.println("Oops! unable to get output form.");
        }
        
    }catch(Exception e){
        out.println(e.getMessage());
    }
    
%>