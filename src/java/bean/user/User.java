package bean.user;
import bean.conn.ConnectionProvider;
import java.sql.*;

/**
 *
 * @author nicholas
 */
public class User {
   
    public String userId;
    public String userName;
    public String email;
    public String cellphone;
    public String password;
    
    
//    public String userId;
//    public String name;
//    public String telephone;
//    public String cellphone;
//    public String email;
//    public String physicaladr;
//    public String postaladr;
//    public String postalcode;
//    public String website;
//    public String password;

    public User(String userId, String schema){
      
        Connection conn = ConnectionProvider.getConnection();
        Statement stmt;
     
        try{
            stmt = conn.createStatement();
            String query ="SELECT * FROM "+ schema+ ".viewsysusrs WHERE UPPER(USERID) = '"+userId.toUpperCase()+"' ";
//            String query ="SELECT * FROM sys.COMS WHERE UPPER(EMAIL) = '"+userId.toUpperCase()+"' ";
            try (ResultSet rs = stmt.executeQuery(query)) {
                while(rs.next()){
                    this.userId     = rs.getString("EMAIL");			
                    this.userName   = rs.getString("USERNAME");			
                    this.email      = rs.getString("EMAIL");
                    this.cellphone  = rs.getString("CELLPHONE");
                    this.password   = rs.getString("PASSWORD");
                }

            }
        }catch (SQLException  e){
            System.out.println(e.getMessage());
        } 
        
    }
 
    
}
