package bean.high;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class HGExamConfig {

    public Integer minSbjs;

    public HGExamConfig() {
        try {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM HGEXAMCONFIG";
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
//                this.minSbjs = rs.getInt("MINSBJS");
            }

        } catch (SQLException e) {

        } catch (Exception e) {

        }

    }

}
