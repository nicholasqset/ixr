package com.qset.sys;

import com.qset.conn.ConnectionProvider;
import java.io.File;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
//import static java.time.temporal.TemporalQueries.localDate;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 *
 * @author nicholas
 */
public class Sys {

    public void log(String msg) {
        System.out.println("\n\n");
        System.out.println("sys_cus_log===" + msg);
    }

    public void logV2(Object obj) {
        System.out.println("\n\n");
        System.out.println("object log start...");
        System.out.println(obj);
        System.out.println("...object log end");
    }

    public Integer generateId(String table, String column) {
        Integer id = 1;
        column = column.isEmpty() ? "ID" : column;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT MAX(" + column + ")MX FROM " + table;
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                id = rs.getInt("MX") + 1;
            }
        } catch (SQLException e) {
            this.logV2(e.getMessage());
        }

        return id;
    }

    public Boolean userExists(String userId, String comCode) {
        Boolean userExists = false;

        Integer count = 0;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT COUNT(*) CT FROM "+comCode+".SYSUSRS WHERE USERID = '" + userId + "' ";

            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                count = rs.getInt("CT");
            }
        } catch (SQLException e) {

        }
        if (count > 0) {
            userExists = true;
        }

        return userExists;
    }

    public Boolean userHasRight(String roleCode, Integer childId) {
        Boolean hasRight = false;
        Integer count = 0;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT COUNT(*)CT FROM qset.SYSRIGHTS WHERE ROLECODE = '" + roleCode + "' AND CHILDID = " + childId;
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                count = rs.getInt("CT");
            }
        } catch (SQLException e) {
            e.getMessage();
        }

        if (count > 0) {
            hasRight = true;
        }

//        return hasRight;
        return true;
    }

    public String getFileExtension(File file) {
        String fileName = file.getName();
        if (fileName.lastIndexOf(".") != -1 && fileName.lastIndexOf(".") != 0) {
            return fileName.substring(fileName.lastIndexOf(".") + 1);
        } else {
            return "";
        }
    }

    public String getLogUser(HttpSession session) {
        String html = "";

        html += session.getAttribute("userId");

        return html;
    }

    public String getLogDate() {
        String html = "";

        Calendar calendar = Calendar.getInstance();
//        SimpleDateFormat dateFormat     = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
//        SimpleDateFormat dateFormat     = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSSX");

        String dateNow = dateFormat.format(calendar.getTime());
        html += dateNow;

//        Object zzz = new java.sql.Timestamp((dateTime).getTime());
        return html;
    }

    public String getLogDateV2() {
        String html = "";

        Calendar calendar = Calendar.getInstance();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

        String dateNow = dateFormat.format(calendar.getTime());
        html += dateNow;

        return html;
    }

    public String getFormatedDate(String sysDate) {
        String html = "";

        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy");

        try {
            java.util.Date sysDateNew = originalFormat.parse(sysDate);
            html += targetFormat.format(sysDateNew);
        } catch (ParseException e) {

        }

        return html;
    }

    public String getFormatedDateTime(String sysDateTime) {
        String html = "";

        SimpleDateFormat originalFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        SimpleDateFormat targetFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss.SSS");

        try {
            java.util.Date sysDateNew = originalFormat.parse(sysDateTime);
            html += targetFormat.format(sysDateNew);
        } catch (ParseException e) {
            this.logV2(e.getMessage());
        }

        return html;
    }

    public String getUnFormatedDateTime(String sysDateTime) {
        String html = "";

        SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss.SSS");
        SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");

        try {
            java.util.Date sysDateNew = originalFormat.parse(sysDateTime);
            html += targetFormat.format(sysDateNew);
        } catch (ParseException e) {
            this.logV2(e.getMessage());
        }

        return html;
    }

    public String getUnFormatedDateTimeV2(String sysDateTime) {
        String html = "";

        SimpleDateFormat originalFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm");
        SimpleDateFormat targetFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");

        try {
            java.util.Date sysDateNew = originalFormat.parse(sysDateTime);
            html += targetFormat.format(sysDateNew);
        } catch (ParseException e) {
            this.logV2(e.getMessage());
        }

        return html;
    }

    public String getLogTime() {
        String html = "";

        Calendar calendar = Calendar.getInstance();
        SimpleDateFormat timeFormat = new SimpleDateFormat("HHmmss");

        String timeNow = timeFormat.format(calendar.getTime());
        html += timeNow;

        return html;
    }

    public String getClientIpAdr(HttpServletRequest request) {
        String html = "";
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_CLUSTER_CLIENT_IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_FORWARDED_FOR");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_FORWARDED");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_VIA");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("REMOTE_ADDR");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }

        html += ip;

        return html;
    }

    public String getSysDefaultRole(String comCode) {
        String roleCode = "";

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT * FROM "+comCode+".SYSROLES WHERE ISDEFAULT = 1 ";
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                roleCode = rs.getString("ROLECODE");
            }
        } catch (SQLException e) {
            this.logV2(e.getMessage());
        }

        return roleCode;
    }

    public void createUser(String userId, String userName, String email, String cellPhone, String comCode) {
        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            if (!this.userExists(userId, comCode)) {
                Integer id = this.generateId(comCode+".sysusrs", "ID");
                String query = "INSERT INTO "+comCode+".sysusrs "
                        + "(ID, USERID, PASSWORD, USERNAME, EMAIL, CELLPHONE)"
                        + "VALUES"
                        + "("
                        + id + ","
                        + "'" + userId + "',"
                        + "'******',"
                        + "'" + userName + "',"
                        + "'" + email + "', "
                        + "'" + cellPhone + "'"
                        + ")";

                Integer saved = stmt.executeUpdate(query);
                if(saved > 0){
//                    this.updateCoUsers(comCode, userId);
                }

            }

        } catch (SQLException e) {
            this.logV2(e.getMessage());
        }
        
        this.updateCoUsers(comCode, userId);

    }
    
    public void updateCoUsers(String comCode, String userId){
        Sys sys = new Sys();
        Boolean userExists = sys.recordExists("sys.com_users", "cu_usr_id = '"+userId+"'");
        if(! userExists){
            try{
                Connection conn = ConnectionProvider.getConnection();
                Statement stmt = conn.createStatement();
                
                String query = ""
                        + "INSERT INTO sys.com_users "
                        + "("
                        + "cu_com_code, cu_usr_id"
                        + ")"
                        + "VALUES"
                        + "("
                        + "'"+comCode+"',"
                        + "'"+userId+"'"
                        + ")";       
                Integer saved = stmt.executeUpdate(query);
                if(saved > 0){
                    System.out.println("...user saved for co access..!");
                }else{
                    System.out.println("...user couldnt be saved for co access..");
                }
            }catch(SQLException e){
                System.out.println(e.getMessage());
            }
        }else{
            System.out.println("...user already exits..");
        }
    }

    public Boolean recordExists(String dataSource, String sqlWhere) {
        Boolean recordExists = false;

        Integer count = 0;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query;

            if (sqlWhere != null && !sqlWhere.trim().equals("")) {
                query = "SELECT COUNT(*)CT FROM " + dataSource + " WHERE " + sqlWhere;
            } else {
                query = "SELECT COUNT(*)CT FROM " + dataSource;
            }
            
//            this.logV2(query);

            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                count = rs.getInt("CT");
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }

        if (count > 0) {
            recordExists = true;
        }

        return recordExists;
    }

    public Integer getRecordCount(String dataSource, String sqlWhere) {
        String query;

        Integer count = 0;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            if (sqlWhere != null && !sqlWhere.trim().equals("")) {
                query = "SELECT COUNT(*)CT FROM " + dataSource + " WHERE " + sqlWhere;
            } else {
                query = "SELECT COUNT(*)CT FROM " + dataSource;
            }

            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                count = rs.getInt("CT");
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }

        return count;
    }

    public String getFiscalYear(String schema) {
        String fiscalYear = "";

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM " + schema + ".FNFISCALYEAR WHERE ACTIVE = 1 ";
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                fiscalYear = rs.getString("FISCALYEAR");
            }
        } catch (SQLException e) {
            System.out.println("error: " + e.getMessage());
        }

        return fiscalYear;
    }

    public String getNextNo(String table, String col, String sqlWhere, String mask, Integer padSize) {
        String nextNo = "";
        Integer nextNoMax = 0;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query;

            if (sqlWhere != null && !sqlWhere.trim().equals("")) {
                query = "SELECT MAX(" + col + ")MX FROM " + table + " WHERE " + sqlWhere;
            } else {
                query = "SELECT MAX(" + col + ")MX FROM " + table;
            }

            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                nextNoMax = rs.getInt("MX");
            }

        } catch (SQLException e) {
            nextNo += e.getMessage();
        }

        nextNoMax = nextNoMax + 1;

        if (mask != null && !mask.trim().equals("")) {
            nextNo = mask + String.format("%0" + padSize + "d", nextNoMax);
        } else {
            nextNo = String.format("%0" + padSize + "d", nextNoMax);
        }

        return nextNo;
    }

    public String getOne(String dataSrc, String col, String sqlWhere) {
        String colValue = null;
        String query;
        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            if (sqlWhere != null && !sqlWhere.trim().equals("")) {
                query = "SELECT " + col + " FROM " + dataSrc + " WHERE " + sqlWhere + " LIMIT 1";
            } else {
                query = "SELECT " + col + " FROM " + dataSrc + " LIMIT 1";
            }

//            System.out.println(query);
            ResultSet rs = stmt.executeQuery(query);

            while (rs.next()) {
                colValue = rs.getString(col);
            }

        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        return colValue;
    }

    public String getOneAgt(String dataSrc, String agt, String col, String colAlias, String sqlWhere) {
        String colValue = null;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query;
            if (sqlWhere != null && !sqlWhere.trim().equals("")) {
                query = "SELECT " + agt + "(" + col + ")" + colAlias + " FROM " + dataSrc + " WHERE " + sqlWhere + " LIMIT 1";
            } else {
                query = "SELECT " + agt + "(" + col + ")" + colAlias + " FROM " + dataSrc + " LIMIT 1";
            }

//            this.logV2(query);
            ResultSet rs = stmt.executeQuery(query);

            while (rs.next()) {
                colValue = rs.getString(colAlias);
            }

        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        return colValue;
    }
    
    public String getOneByQuery(String query){
        String colValue = null;
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
           
            
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                colValue = rs.getString("col");	
            }
            
        }catch(SQLException e){
            System.out.print(e.getMessage());
        }
        
        return colValue;
    }

    public Integer delete(String table, String sqlWhere) {
        Integer deleted = 0;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query;
            if (sqlWhere != null && !sqlWhere.trim().equals("")) {
                query = "DELETE FROM " + table + " WHERE " + sqlWhere + " ";
            } else {
                query = "DELETE FROM " + table + " ";
            }

            deleted = stmt.executeUpdate(query);

        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }

        return deleted;
    }

    public Integer getPeriodYear(String schema) {
        Integer pYear = 0;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT * FROM " + schema + ".FNFISCALPRD WHERE ACTIVE = 1 ";
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                pYear = rs.getInt("PYEAR");
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }

        return pYear;
    }

    public Integer getNextPeriodYear(String schema) {
        Integer nxtPyear;

        Integer curPyear = this.getPeriodYear(schema);
        Integer curPmonth = this.getPeriodMonth(schema);

        if (curPmonth == 12) {
            nxtPyear = curPyear + 1;
        } else {
            nxtPyear = curPyear;
        }

        return nxtPyear;
    }

    public Integer getPeriodMonth(String schema) {
        Integer pMonth = 0;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "SELECT * FROM " + schema + ".FNFISCALPRD WHERE ACTIVE = 1 ";
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                pMonth = rs.getInt("PMONTH");
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }

        return pMonth;
    }

    public Integer getNextPeriodMonth(String schema) {
        Integer nxtPmonth;

        Integer curPmonth = this.getPeriodMonth(schema);

        if (curPmonth == 12) {
            nxtPmonth = 1;
        } else {
            nxtPmonth = curPmonth + 1;
        }

        return nxtPmonth;
    }

    public String numberFormat(String number) {
        String html = "";

        number = number != null && !number.trim().equals("") ? number : "0";

        Double no = Double.parseDouble(number);
        DecimalFormat formatter = new DecimalFormat("#,###.00");

        html += formatter.format(no);

        return html;
    }

    public HashMap getArray(String sql) {
        HashMap<String, String> arrayMap = new HashMap();
        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                String colKey = rs.getString(1);
                String colValue = rs.getString(2);

                arrayMap.put(colKey, colValue);
            }
        } catch (SQLException e) {
            System.out.print(e.getMessage());
        }

        return arrayMap;
    }

    public String getMonthName(Integer month) {
        String html = "";

        switch (month) {
            case 1:
                html += "January";
                break;

            case 2:
                html += "February";
                break;

            case 3:
                html += "March";
                break;

            case 4:
                html += "April";
                break;

            case 5:
                html += "May";
                break;

            case 6:
                html += "June";
                break;

            case 7:
                html += "July";
                break;

            case 8:
                html += "August";
                break;

            case 9:
                html += "September";
                break;

            case 10:
                html += "October";
                break;

            case 11:
                html += "November";
                break;

            case 12:
                html += "December";
                break;

            default:
                html += "Wrong Month No.";
                break;
        }

        return html;
    }

    public String shorten(String s, Integer charNo) {
        String postS = "";

        if (s.length() > charNo) {
            postS = "...";
        }
        s = s.substring(0, Math.min(s.length(), charNo)) + postS;

        return s;
    }

    public LocalDate getLEndDateWoW(LocalDate date, int workdays) {//without weekends
        if (workdays < 1) {
            return date;
        }

        LocalDate result = date;
        int addedDays = 0;
        while (addedDays < workdays) {
            result = result.plusDays(1);
            if (!(result.getDayOfWeek() == DayOfWeek.SATURDAY
                    || result.getDayOfWeek() == DayOfWeek.SUNDAY)) {
                ++addedDays;
            }
        }

        return result;
    }

    public LocalDate getLEndDateWoWH(LocalDate date, int workdays) {//without weekends & holidays
        List<Date> holidays = this.getHolidays();

        if (workdays < 1) {
            return date;
        }

        Calendar cal = Calendar.getInstance();
//        cal.set(Calendar.HOUR_OF_DAY, 0);
//    cal.set(Calendar.MINUTE, 0);
//    cal.set(Calendar.SECOND, 0);
//    cal.set(Calendar.MILLISECOND, 0);
        Date ldToD = Date.from(date.atStartOfDay(ZoneId.systemDefault()).toInstant());
        cal.setTime(ldToD);

        LocalDate result = date;
        int addedDays = 0;
        while (addedDays < workdays) {
            result = result.plusDays(1);
            if (!(result.getDayOfWeek() == DayOfWeek.SATURDAY
                    || result.getDayOfWeek() == DayOfWeek.SUNDAY
                    || holidays.contains(cal.getTime()))) {
                ++addedDays;
            }
        }

        return result;
    }

    public ArrayList<Date> getHolidays() {
        ArrayList<Date> holidays = new ArrayList();

        try {
            Calendar calendar = Calendar.getInstance();
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy");

            String pYear = dateFormat.format(calendar.getTime());

            DateFormat df = new SimpleDateFormat("yyyy-MM-dd");

            holidays.add(df.parse(pYear + "-01-01"));
            holidays.add(df.parse(pYear + "-05-01"));
            holidays.add(df.parse(pYear + "-06-01"));
            holidays.add(df.parse(pYear + "-10-20"));
            holidays.add(df.parse(pYear + "-12-12"));
            holidays.add(df.parse(pYear + "-12-25"));
            holidays.add(df.parse(pYear + "-12-26"));

        } catch (ParseException e) {
            e.getMessage();
        }

        return holidays;
    }

    public Integer getPrevPeriodYear(String schema) {
        Integer prevYear = this.getPeriodYear(schema);
        Integer pMonth = this.getPeriodMonth(schema);

        if (pMonth == 1) {
            prevYear = prevYear - 1;
        }

        return prevYear;
    }

    public Integer getPrevPeriodMonth(String schema) {
        Integer pMonth = this.getPeriodMonth(schema);

        if (pMonth == 1) {
            pMonth = 12;
        } else {
            pMonth = pMonth - 1;
        }

        return pMonth;
    }

    public Boolean emailValid(String email) {
        Boolean emailValid = true;

//        String emailPattern = "[a-zA-Z0-9._-]+@[a-z]+\\.+[a-z]+";
        String emailPattern = "^[A-Za-z0-9+_.-]+@(.+)$";

        if (!email.matches(emailPattern)) {
            emailValid = false;
        }

        return emailValid;
    }

    public Boolean logUser(String comCode, String sesId, String userId, String logType) {
        Boolean logged = false;

        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query;

            query = "INSERT INTO " + comCode + ".sysses "
                    + "(sesid, userid, logtype, logdt)"
                    + "VALUES"
                    + "("
                    + "'" + sesId + "', "
                    + "'" + userId + "', "
                    + "'" + logType + "', "
                    + "now() "
                    + ")";

            Integer saved = stmt.executeUpdate(query);

            if (saved > 0) {
                logged = true;
            }

        } catch (SQLException e) {
            this.logV2(e.getMessage());
        } catch (Exception e) {
            this.logV2(e.getMessage());
        }

        return logged;
    }
    
    public Integer executeSql(String query){
        Integer queryExecuted = 0;
        try{
            
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            queryExecuted = stmt.executeUpdate(query);
            
        }catch(SQLException e){
            System.err.println(e.getMessage());
        }
        
        return queryExecuted;
    }

}
