package bean.conn;

import static bean.conn.Provider.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author nicholas
 */
public class ConnectionProvider {
    static Connection conn = null;
    static String dBType = null;
    
    static{
        try{
            Class.forName(DRIVER);
            conn = DriverManager.getConnection(CONNECTION_URL, USERNAME, PASSWORD);
            
            dBType = DBTYPE;
        }catch(ClassNotFoundException | SQLException e){
            System.out.print(e);
        }
        
    }
    
    public static Connection getConnection(){
        return conn;
    }
    
    public static String getDBType(){
        return dBType;
    }
    
}
