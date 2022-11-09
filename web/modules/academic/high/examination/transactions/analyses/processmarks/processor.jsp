<%@page import="bean.academic.Academic"%>
<%@page import="bean.high.HighSchool"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="bean.sys.Sys"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<head>
  <title>Process Marks Backend</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>

<script type="text/javascript">
  // KHTML browser don't share javascripts between iframes
  var is_khtml = navigator.appName.match("Konqueror") || navigator.appVersion.match("KHTML");
  if (is_khtml)
  {
    var prototypejs = document.createElement('script');
    prototypejs.setAttribute('type','text/javascript');
    prototypejs.setAttribute('src','<%=request.getContextPath()+"/js/scriptaculous/lib/prototype.js" %>');
    var head = document.getElementsByTagName('head');
    head[0].appendChild(prototypejs);
  }
  // load the comet object
  var comet = window.parent.comet;
</script>
<%

final class Process{
    
    Integer academicYear    = (request.getParameter("academicYear") != null && ! request.getParameter("academicYear").trim().equals(""))? Integer.parseInt(request.getParameter("academicYear")): null;
    String termCode         = request.getParameter("term");
    String formCode         = request.getParameter("studentForm");
    String examCode         = request.getParameter("exam");
    
    public void getCoreSubjects(){
        Sys sys = new Sys();
        if(sys.recordExists("VIEWHGGRPSBJS", "FORMCODE = '"+ this.formCode+ "'")){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT * FROM VIEWHGGRPSBJS WHERE FORMCODE = '"+ this.formCode+ "' AND MINGRPSBJS > 0";
                ResultSet rs = stmt.executeQuery(query);
                
                while(rs.next()){
                    String subjectGrpCode   = rs.getString("SUBJECTGRPCODE");
                    Integer minGrpSbjs      = rs.getInt("MINGRPSBJS");
                    
                    this.setCoreSubject(subjectGrpCode, minGrpSbjs);
                }
            }catch (SQLException e){
                e.getMessage();
            }catch (Exception e){
                e.getMessage();
            }
        }
    }
    
    public Integer setCoreSubject(String subjectGrpCode, Integer minGrpSbjs){
        Integer subjectSet = 0;
        
        Sys sys = new Sys();
        
        if(sys.recordExists("VIEWHGSTUDENTMARKS", "ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTGRPCODE = '"+ subjectGrpCode+ "'")){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = "SELECT DISTINCT STUDENTNO FROM VIEWHGSTUDENTMARKS WHERE ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTGRPCODE = '"+ subjectGrpCode+ "' ORDER BY STUDENTNO";
                ResultSet rs = stmt.executeQuery(query);
                
                while(rs.next()){
                    String studentNo    = rs.getString("STUDENTNO");
                    
                    this.insertCoreSubject(studentNo, subjectGrpCode, minGrpSbjs);
                    
                }
            }catch (SQLException e){
                e.getMessage();
            }catch (Exception e){
                e.getMessage();
            }
        }
        
        return subjectSet;
    }
    
    public Integer insertCoreSubject(String studentNo, String subjectGrpCode, Integer minGrpSbjs){
        Integer subjectSet = 0;
        
        HttpSession session = request.getSession();
        HighSchool highSchool = new HighSchool();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT * FROM VIEWHGSTUDENTMARKS WHERE STUDENTNO = '"+ studentNo+ "' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTGRPCODE = '"+ subjectGrpCode+ "' ORDER BY SCORE DESC LIMIT "+ minGrpSbjs;
            ResultSet rs = stmt.executeQuery(query);

            while(rs.next()){
                    String subjectCode    = rs.getString("SUBJECTCODE");
                    highSchool.insertCoreSubject(studentNo, this.academicYear, this.termCode, this.examCode, subjectCode, session, request);
            }
        }catch (SQLException e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
        
        return subjectSet;
    }
    
    public String getElectiveSubjects(){
        String html = "";
        Sys sys = new Sys();
        try{
            Integer minFormSbjs = 0;
            minFormSbjs = Integer.parseInt(sys.getOne("HGFORMSBJS", "MINFORMSBJS", "FORMCODE = '"+ this.formCode+ "'")); 
            
            Integer minGrpSbjs = 0;
            minGrpSbjs = Integer.parseInt(sys.getOne("HGGRPSBJS", "SUM(MINGRPSBJS)", "FORMCODE = '"+ this.formCode+ "'"));
            
            Integer electiveSbjs = minFormSbjs - minGrpSbjs;
            
            if(electiveSbjs > 0){
                html += this.setElectiveSubject(electiveSbjs);
            }
            
        }catch (Exception e){
            e.getMessage();
        }
        
        return html;
    
    }
    
    public String setElectiveSubject(Integer electiveSbjs){
        Integer subjectSet = 0;
        String html = "";
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT DISTINCT STUDENTNO  FROM VIEWHGSTUDENTMARKS WHERE "
                    + "ACADEMICYEAR = "+ this.academicYear+ " AND "
                    + "TERMCODE = '"+ this.termCode+ "' AND "
                    + "EXAMCODE = '"+ this.examCode+ "' "
                    + "ORDER BY STUDENTNO";
            
            html += query;
            html += "<hr>";
            
            ResultSet rs = stmt.executeQuery(query);

            while(rs.next()){
                String studentNo    = rs.getString("STUDENTNO");

                html += this.insertElectiveSubject(studentNo, electiveSbjs);

            }
        }catch (SQLException e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
        
//        return subjectSet;
        return html;
    }
    
    public String insertElectiveSubject(String studentNo, Integer electiveSbjs){
        Integer subjectSet = 0;
        
        String html = "";
        
        HttpSession session = request.getSession();
        HighSchool highSchool = new HighSchool();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT SUBJECTCODE FROM VIEWHGSTUDENTMARKS WHERE "
                    + "STUDENTNO = '"+ studentNo+ "' AND "
                    + "ACADEMICYEAR = "+ this.academicYear+ " AND "
                    + "TERMCODE = '"+ this.termCode+ "' AND "
                    + "EXAMCODE = '"+ this.examCode+ "' AND "
                    + "SUBJECTCODE NOT IN(SELECT SUBJECTCODE FROM HGSTUDCORESBJS WHERE "
                        + "STUDENTNO = '"+ studentNo+ "' AND "
                        + "ACADEMICYEAR = "+ this.academicYear+ " AND "
                        + "TERMCODE = '"+ this.termCode+ "' AND "
                        + "EXAMCODE = '"+ this.examCode+ "' "
                        + ")"
                    + "ORDER BY SCORE DESC LIMIT "+ electiveSbjs;
            
            html += query;
            html += "<hr>";
            
            ResultSet rs = stmt.executeQuery(query);

            while(rs.next()){
                    String subjectCode    = rs.getString("SUBJECTCODE");
                    highSchool.insertElectiveSubject(studentNo, this.academicYear, this.termCode, this.examCode, subjectCode, session, request);
            }
        }catch (SQLException e){
            e.getMessage();
        }catch (Exception e){
            e.getMessage();
        }
        
        return html;
//        return subjectSet;
    }
    
    
    public String populateMkSheet(){
        String html = "";
        HttpSession session = request.getSession();
        Sys sys = new Sys();
        HighSchool highSchool = new HighSchool();
        
        Academic academic = new Academic();
        
        Integer minFormSbjs = 0;
        minFormSbjs = Integer.parseInt(sys.getOne("HGFORMSBJS", "MINFORMSBJS", "FORMCODE = '"+ this.formCode+ "'"));
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT * FROM VIEWHGSELSBJSTTS WHERE ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' ORDER BY TOTAL DESC, STUDENTNO";
            html += query;
            html += "<hr>";
            ResultSet rs = stmt.executeQuery(query);

            while(rs.next()){
                
                String studentNo    = rs.getString("STUDENTNO");
                Double total        = rs.getDouble("TOTAL");
                
                Double studAvg = total / minFormSbjs;
                String grade = academic.getGrade((double)Math.round(studAvg));
                
                
                String engStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ENG' ");
                String engSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ENG' ");
                String engAst = (engStr != null && engSbj == null)? "*": "";
                engStr = engStr != null? engStr: "0";
                Double eng  = Double.parseDouble(engStr);
                String engGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ENG' ");
                engGrd = (engGrd != null && ! engGrd.trim().equals(""))? engGrd+ engAst: "na";
                
                String kisStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'KIS' ");
                String kisSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'KIS' ");
                String kisAst = (kisStr != null && kisSbj == null)? "*": "";
                kisStr = kisStr != null? kisStr: "0";
                Double kis  = Double.parseDouble(kisStr);
                String kisGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'KIS' ");
                kisGrd = (kisGrd != null && ! kisGrd.trim().equals(""))? kisGrd+ kisAst: "na";
                
                String matStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'MAT' ");
                String matSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'MAT' ");
                String matAst = (matStr != null && matSbj == null)? "*": "";
                matStr = matStr != null? matStr: "0";
                Double mat  = Double.parseDouble(matStr);
                String matGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'MAT' ");
                matGrd = (matGrd != null && ! matGrd.trim().equals(""))? matGrd+ matAst: "na";
                
                String bioStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'BIO' ");
                String bioSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'BIO' ");
                String bioAst = (bioStr != null && bioSbj == null)? "*": "";
                bioStr = bioStr != null? bioStr: "0";
                Double bio  = Double.parseDouble(bioStr);
                String bioGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'BIO' ");
                bioGrd = (bioGrd != null && ! bioGrd.trim().equals(""))? bioGrd+ bioAst: "na";

                String phyStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'PHY' ");
                String phySbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'PHY' ");
                String phyAst = (phyStr != null && phySbj == null)? "*": "";
                phyStr = phyStr != null? phyStr: "0";
                Double phy  = Double.parseDouble(phyStr);
                String phyGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'PHY' ");
                phyGrd = (phyGrd != null && ! phyGrd.trim().equals(""))? phyGrd+ phyAst: "na";
                
                String cheStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'CHE' ");
                String cheSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'CHE' ");
                String cheAst = (cheStr != null && cheSbj == null)? "*": "";
                cheStr = cheStr != null? cheStr: "0";
                Double che  = Double.parseDouble(cheStr);
                String cheGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'CHE' ");
                cheGrd = (cheGrd != null && ! cheGrd.trim().equals(""))? cheGrd+ cheAst: "na";
                
                String gscStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'GSC' ");
                String gscSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'GSC' ");
                String gscAst = (gscStr != null && gscSbj == null)? "*": "";
                gscStr = gscStr != null? gscStr: "0";
                Double gsc  = Double.parseDouble(gscStr);
                gsc = (gsc != null)? gsc : 0.0;
                String gscGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'GSC' ");
                gscGrd = (gscGrd != null && ! gscGrd.trim().equals(""))? gscGrd+ gscAst: "na";
                
                String higStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'HIG' ");
                String higSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'HIG' ");
                String higAst = (higStr != null && higSbj == null)? "*": "";
                higStr = higStr != null? higStr: "0";
                Double hig  = Double.parseDouble(higStr);
                String higGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'HIG' ");
                higGrd = (higGrd != null && ! higGrd.trim().equals(""))? higGrd+ higAst: "na";
                
                String geoStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'GEO' ");
                String geoSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'GEO' ");
                String geoAst = (geoStr != null && geoSbj == null)? "*": "";
                geoStr = geoStr != null? geoStr: "0";
                Double geo  = Double.parseDouble(geoStr);
                String geoGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'GEO' ");
                geoGrd = (geoGrd != null && ! geoGrd.trim().equals(""))? geoGrd+ geoAst: "na";
                
                String creStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'CRE' ");
                String creSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'CRE' ");
                String creAst = (creStr != null && creSbj == null)? "*": "";
                creStr = creStr != null? creStr: "0";
                Double cre  = Double.parseDouble(creStr);
                String creGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'CRE' ");
                creGrd = (creGrd != null && ! creGrd.trim().equals(""))? creGrd+ creAst: "na";
                
                String ireStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'IRE' ");
                String ireSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'IRE' ");
                String ireAst = (ireStr != null && ireSbj == null)? "*": "";
                ireStr = ireStr != null? ireStr: "0";
                Double ire  = Double.parseDouble(ireStr);
                String ireGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'IRE' ");
                ireGrd = (ireGrd != null && ! ireGrd.trim().equals(""))? ireGrd+ ireAst: "na";
                
                String hreStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'HRE' ");
                String hreSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'HRE' ");
                String hreAst = (hreStr != null && hreSbj == null)? "*": "";
                hreStr = hreStr != null? hreStr: "0";
                Double hre  = Double.parseDouble(hreStr);
                String hreGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'HRE' ");
                hreGrd = (hreGrd != null && ! hreGrd.trim().equals(""))? hreGrd+ hreAst: "na";
                
                String hscStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'HSC' ");
                String hscSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'HSC' ");
                String hscAst = (hscStr != null && hscSbj == null)? "*": "";
                hscStr = hscStr != null? hscStr: "0";
                Double hsc  = Double.parseDouble(hscStr);
                String hscGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'HSC' ");
                hscGrd = (hscGrd != null && ! hscGrd.trim().equals(""))? hscGrd+ hscAst: "na";
                
                String atdStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ATD' ");
                String atdSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ATD' ");
                String atdAst = (atdStr != null && atdSbj == null)? "*": "";
                atdStr = atdStr != null? atdStr: "0";
                Double atd  = Double.parseDouble(atdStr);
                String atdGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ATD' ");
                atdGrd = (atdGrd != null && ! atdGrd.trim().equals(""))? atdGrd+ atdAst: "na";
                
                String agrStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'AGR' ");
                String agrSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'AGR' ");
                String agrAst = (agrStr != null && agrSbj == null)? "*": "";
                agrStr = agrStr != null? agrStr: "0";
                Double agr  = Double.parseDouble(agrStr);
                String agrGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'AGR' ");
                agrGrd = (agrGrd != null && ! agrGrd.trim().equals(""))? agrGrd+ agrAst: "na";
                
                String cstStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'CST' ");
                String cstSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'CST' ");
                String cstAst = (cstStr != null && cstSbj == null)? "*": "";
                cstStr = cstStr != null? cstStr: "0";
                Double cst  = Double.parseDouble(cstStr);
                String cstGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'CST' ");
                cstGrd = (cstGrd != null && ! cstGrd.trim().equals(""))? cstGrd+ cstAst: "";
                
                String avtStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'AVT' ");
                String avtSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'AVT' ");
                String avtAst = (avtStr != null && avtSbj == null)? "*": "";
                avtStr = avtStr != null? avtStr: "0";
                Double avt  = Double.parseDouble(avtStr);
                String avtGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'AVT' ");
                avtGrd = (avtGrd != null && ! avtGrd.trim().equals(""))? avtGrd+ avtAst: "na";
                
                String frnStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'FRN' ");
                String frnSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'FRN' ");
                String frnAst = (frnStr != null && frnSbj == null)? "*": "";
                frnStr = frnStr != null? frnStr: "0";
                Double frn  = Double.parseDouble(frnStr);
                String frnGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'FRN' ");
                frnGrd = (frnGrd != null && ! frnGrd.trim().equals(""))? frnGrd+ frnAst: "na";
                
                String gmnStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'GMN' ");
                String gmnSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'GMN' ");
                String gmnAst = (gmnStr != null && gmnSbj == null)? "*": "";
                gmnStr = gmnStr != null? gmnStr: "0";
                Double gmn  = Double.parseDouble(gmnStr);
                String gmnGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'GMN' ");
                gmnGrd = (gmnGrd != null && ! gmnGrd.trim().equals(""))? gmnGrd+ gmnAst: "na";
                
                String arbStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ABR' ");
                String arbSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ABR' ");
                String arbAst = (arbStr != null && arbSbj == null)? "*": "";
                arbStr = arbStr != null? arbStr: "0";
                Double arb  = Double.parseDouble(arbStr);
                String arbGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'ARB' ");
                arbGrd = (arbGrd != null && ! arbGrd.trim().equals(""))? arbGrd+ arbAst: "na";
                
                String musStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'MUS' ");
                String musSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'MUS' ");
                String musAst = (musStr != null && musSbj == null)? "*": "";
                musStr = musStr != null? musStr: "0";
                Double mus  = Double.parseDouble(musStr);
                String musGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'MUS' ");
                musGrd = (musGrd != null && ! musGrd.trim().equals(""))? musGrd+ musAst: "na";
                
                String bstStr = sys.getOne("HGSTUDENTMARKS", "SCORE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'BST' ");
                String bstSbj = sys.getOne("VIEWHGSELSBJS", "SUBJECTCODE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'BST' ");
                String bstAst = (bstStr != null && bstSbj == null)? "*": "";
                bstStr = bstStr != null? bstStr: "0";
                Double bst  = Double.parseDouble(bstStr);
                String bstGrd = sys.getOne("HGSTUDENTMARKS", "GRADE", "STUDENTNO = '"+ studentNo+"' AND ACADEMICYEAR = "+ this.academicYear+ " AND TERMCODE = '"+ this.termCode+ "' AND EXAMCODE = '"+ this.examCode+ "' AND SUBJECTCODE = 'BST' ");
                bstGrd = (bstGrd != null && ! bstGrd.trim().equals(""))? bstGrd+ bstAst: "na";
                
                highSchool.createMkSheetEntry(studentNo, this.academicYear, this.termCode, this.examCode, eng, engGrd, kis, kisGrd, mat, matGrd, bio, bioGrd, phy, phyGrd, che, cheGrd, gsc, gscGrd, hig, higGrd, geo, geoGrd, cre, creGrd, ire, ireGrd, hre, hreGrd, hsc, hscGrd, atd, atdGrd, agr, agrGrd, cst, cstGrd, avt, avtGrd, frn, frnGrd, gmn, gmnGrd, arb, arbGrd, mus, musGrd, bst, bstGrd, total, studAvg, grade, session, request);

            }
            
        }catch (SQLException e){
            html += e.getMessage();
        }catch (Exception e){
            html += e.getMessage();
        }
        
        return html;
    }
    
    
}

Process process = new Process();

for(int i = 1; i <= 3; i++){
    
    if(i == 1){
        process.getCoreSubjects();
    }
    else if (i == 2){
        process.getElectiveSubjects();
    }
    else if(i == 3){
        out.print(process.populateMkSheet());
    }
        
    if((i - 1) < 3){
        out.print("<script type = \"text/javascript\">");
        out.print("comet.showProgress("+ i +", "+ 3 +");");
        out.print("</script>") ;
    }

    if(i == 3){
        out.print("<script type = \"text/javascript\">");
        out.print("comet.taskComplete();");
        out.print("</script>") ;
    }
    
    out.flush(); // used to send the echoed data to the client
    Thread.sleep(7); // a little break to unload the server CPU
}

    
%>
        
    </body>
</html>