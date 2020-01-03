package bean.am;

import bean.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 *
 * @author nicholas
 */
public class AssetProfile {
    public String assetNo;
    public String assetDesc;
    public String aqNo;
    public String aqDate;
    public String catCode;
    public String serialNo;
    public String statusCode;
    public String depCode;
    public String depType;
    public String depStartDate;
    public Double estLife;
    public String estExpDate;
    public Double depRate;
    public Double opc;
    public Double acmDep;
    public Double nbv;
    public Double salv;
    public String insCo;
    public String insPlcNo;
    public String insDate;
    public Double insV;
    public String comments;
    
    public AssetProfile(String assetNo){
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM VIEWAMASSETS WHERE ASSETNO = '"+ assetNo+ "' ";
            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                this.assetNo        = rs.getString("ASSETNO");
                this.assetDesc      = rs.getString("ASSETDESC");
                this.aqNo           = rs.getString("AQNO");
                this.aqDate         = rs.getString("AQDATE");
                this.catCode        = rs.getString("CATCODE");
                this.serialNo       = rs.getString("SERIALNO");
                this.statusCode     = rs.getString("STATUSCODE");
                this.depCode        = rs.getString("DEPCODE");
                this.depType        = rs.getString("DEPTYPE");
                this.depStartDate   = rs.getString("DEPSTARTDATE");
                this.estLife        = rs.getDouble("ESTLIFE");
                this.estExpDate     = rs.getString("ESTEXPDATE");
                this.depRate        = rs.getDouble("DEPRATE");
                this.opc            = rs.getDouble("OPC");
                this.acmDep         = rs.getDouble("ACMDEP");
                this.nbv            = rs.getDouble("NBV");
                this.salv           = rs.getDouble("SALV");
                this.insCo          = rs.getString("INSCO");
                this.insPlcNo       = rs.getString("INSPLCNO");
                this.insDate        = rs.getString("INSDATE");
                this.insV           = rs.getDouble("INSV");
                this.comments       = rs.getString("COMMENTS");
            }
        }catch(Exception e){
            e.getMessage();
        }
        
    }
}