package com.qset.am;

/**
 *
 * @author nicholas
 */
public class AssetDep {
    public Double depV      = 0.0;
    public Double acmDepV   = 0.0;
    public Double nbvE      = 0.0;
    
    public AssetDep(String assetNo, String comCode){
        AssetProfile assetProfile = new AssetProfile(assetNo, comCode);
        
        switch(assetProfile.depType){
            case "SL":
                this.depV       = (assetProfile.opc - assetProfile.salv) / assetProfile.estLife;
                this.depV       = this.depV / 12;
                this.acmDepV    = assetProfile.acmDep + this.depV;
                this.nbvE       = assetProfile.opc - this.acmDepV;
                break;
                
            case "DB":
                this.depV       = (2 / assetProfile.estLife) * (assetProfile.opc - assetProfile.acmDep);
                this.depV       = this.depV / 12;
                this.acmDepV    = assetProfile.acmDep + this.depV;
                this.nbvE       = assetProfile.opc - this.acmDepV;
                break;
        }
        
    }
    
}
