package bean.sys;

import bean.conn.ConnectionProvider;
import bean.security.Security;
import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

/**
 *
 * @author nicholas
 */
public class Threader {
    
    public Boolean accountCreated (String comCode, String email, String cellphone, String password){
        Boolean accountCreated = false;
        
        try{
            ExecutorService service = Executors.newFixedThreadPool(3);
 
            Future<Boolean> retBoolean = service.submit(new RetBoolean(comCode, email, cellphone, password));
            accountCreated = retBoolean.get();

            service.shutdown();
        }catch(InterruptedException | ExecutionException e){
            System.out.println(e.getMessage());
        }
        
        return accountCreated;
    }
    
    
    class RetBoolean implements Callable<Boolean> {
        String comCode, email, cellphone, password;
        
        RetBoolean(String comCode, String email, String cellphone, String password) {
            this.comCode    = comCode;
            this.email      = email;
            this.cellphone  = cellphone;
            this.password   = password;
        }

        @Override
        public Boolean call() {
            try{
                Connection conn     = ConnectionProvider.getConnection();
                Statement stmt      = conn.createStatement();
                // create a schema using comCode
                String query ="CREATE SCHEMA "+this.comCode+"  AUTHORIZATION postgres;";
                stmt.executeUpdate(query);
                System.out.println("created empty schema===="+ this.comCode+"--"+ this.email);

                // copy schema qset to the new created schema

                Process p = Runtime.getRuntime().exec(new String[]{"bash","-c","pg_dump -U postgres --schema='qset' ixr | sed 's/qset/"+this.comCode+"/g' | psql -U postgres -d ixr"});
                p.waitFor();
                int exitVal = p.exitValue();
                System.out.println("exitVal==="+ exitVal);
                System.out.println("done creating schema");
                // wait 10 seconds for the schema to finish copying
//                    Thread.sleep(10000); 
//                System.out.println("60 seconds done");

//                kill the process 
                p.destroy(); 
                System.out.println("Process destroyed"); 
                System.out.println("...now updating schema"); 

                Security security = new Security();

                // update sysusrs table in the new created schema
                String query1 = "UPDATE "+this.comCode+".sysusrs SET userId = '"+this.email+"', email = '"+this.email+"', cellphone = '"+ this.cellphone+"', password='"+security.md5(this.password)+"' WHERE id = '1'";
                stmt.executeUpdate(query1);

                String query2 = "UPDATE "+this.comCode+".sysusrpvgs SET userId='"+this.email+"'";
                stmt.executeUpdate(query2);
                System.out.println("done updating schema...."); 

                System.out.println("...should be done"); 

                return true;
                                    
            }catch(IOException | InterruptedException | NoSuchAlgorithmException | SQLException e){
                System.out.println(e.getMessage());
            }

            return false;
        }
    }
    
}


