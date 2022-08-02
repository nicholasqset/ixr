 package bean.authenticate;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;
import bean.security.Security;
import bean.sys.Sys;
import java.security.NoSuchAlgorithmException;
 
public class Authenticate {
    public Boolean authenticated    = false;
    Integer count                   = 0;
    
    public Authenticate(String userId, String password) throws ParseException, NoSuchAlgorithmException{
        try{ 
            Sys sys = new Sys();
            Connection conn = ConnectionProvider.getConnection();
            Security security = new Security(); 
            
            String comCode = sys.getOne("sys.coms", "comCode", "upper(EMAIL) = '"+ userId.toUpperCase()+ "'");
//            select comCode first
            if(comCode != null){
                Statement stmt = conn.createStatement();
                String query   = "SELECT COUNT(USERID)CT FROM "+comCode+".SYSUSRS WHERE upper(USERID) = '"+userId.toUpperCase()+"' AND PASSWORD = '"+security.md5(password)+"' ";
                ResultSet rs   = stmt.executeQuery(query);
                while(rs.next()){
                    this.count = rs.getInt("CT");
                }
                
                if(this.count > 0){
                    this.authenticated = true;
                }
            }else{
                comCode = sys.getOne("sys.com_users", "cu_com_code", "upper(cu_usr_id) = '"+ userId.toUpperCase()+ "'");
                if(comCode != null){
                    Statement stmt = conn.createStatement();
                    String query   = "SELECT COUNT(USERID)CT FROM "+comCode+".SYSUSRS WHERE upper(USERID) = '"+userId.toUpperCase()+"' AND PASSWORD = '"+security.md5(password)+"' ";
                    ResultSet rs   = stmt.executeQuery(query);
                    while(rs.next()){
                        this.count = rs.getInt("CT");
                    }

                    if(this.count > 0){
                        this.authenticated = true;
                    }
                }
            }
        }catch (SQLException |AbstractMethodError|NoSuchAlgorithmException e){
            System.out.println(e.getMessage());
        }
    }
}
