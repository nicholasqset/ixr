package com.qset.payroll;

import com.qset.conn.ConnectionProvider;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import com.qset.sys.Sys;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 *
 * @author nicholas
 */
public class Payroll {
    String schema;
    
    public Payroll(String schema){
        this.schema = schema;
    }
    
//    public String getIncomeTax(Double taxableSal){
    public Double getIncomeTax(Double taxableSal){
        String html = "";
        Double totalTax = 0.0;
        
        Sys system = new Sys();
        
        Integer pYear = system.getPeriodYear(this.schema);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            String query = "SELECT * FROM "+ this.schema+ ".PYTAXRATES WHERE PYEAR = "+ pYear +" ORDER BY AMTMIN";
            ResultSet rs = stmt.executeQuery(query);
            
            Double chargeableAmt;
            Double taxableSalDiff = taxableSal;
            Double amtTxdTotal = 0.0;
            

            while(rs.next()){
                Double amtMin   = rs.getDouble("AMTMIN");
                Double amtMax   = rs.getDouble("AMTMAX");
                Double rate     = rs.getDouble("RATE");
                Double amtTxd   = rs.getDouble("AMTTXD");
                
                html += "amtMin = '"+ amtMin+ "' <br>";
                html += "amtMax = '"+ amtMax+ "' <br>";
                html += "rate   = '"+ rate+ "' <br>";
                html += "amtTxd = '"+ amtTxd+ "' <br><br>";
                html += "taxableSal = '"+ taxableSal+ "' <br>";
                html += "taxableSalDiff = '"+ taxableSalDiff+ "' <br><br>";
                
                if(amtTxd == -1.0){
                    if(taxableSalDiff > 0){
                        taxableSalDiff  = taxableSal - amtTxdTotal;
                        chargeableAmt   = taxableSalDiff;
                    }else{
                        taxableSalDiff  = 0.0;
                        chargeableAmt   = 0.0;
                    }
                    
                }else{
                    if(taxableSalDiff > amtTxd){
                        taxableSalDiff  = taxableSalDiff - amtTxd;
                        chargeableAmt = amtTxd;
                    }else{
                        if(taxableSalDiff > 0){
                            chargeableAmt   = taxableSalDiff;
                            taxableSalDiff  = taxableSalDiff - amtTxd;
                        }else{
                            taxableSalDiff  = 0.0;
                            chargeableAmt   = 0.0;
                        }
                    }
                }
                
                html += "chargeableAmt = '"+ chargeableAmt+ "' <br>";
                
                Double taxCharged = rate/100 * chargeableAmt;
                
                html += "taxCharged = '"+ taxCharged+ "' <br>";
                
                amtTxdTotal = amtTxdTotal + amtTxd;
                html += "amtTxdTotal = '"+ amtTxdTotal+ "' <br>";
                
                totalTax = totalTax + taxCharged;
                html += "totalTax = '"+ totalTax+ "' <br>";
                
                html += "<hr>";
            }
            
        }catch (Exception e){
            e.getMessage();
        }
        
//        return html;
        return totalTax;
    }
    
    public Double getNHIFRate(Double grossPay){
//    public String getNHIFRate(Double grossPay){
//        String html = "";
        
        Double nHIFRate = 0.0;
        
        Sys system = new Sys();
        
        Integer pYear = system.getPeriodYear(this.schema);
        
        try{
            Connection conn  = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            String query = "SELECT * FROM "+ this.schema+ ".PYNHIFRATES WHERE PYEAR = "+ pYear +" ORDER BY AMTMIN";
            ResultSet rs = stmt.executeQuery(query);
            
            while(rs.next()){
                Double amtMin   = rs.getDouble("AMTMIN");
                Double amtMax   = rs.getDouble("AMTMAX");
                Double rate     = rs.getDouble("RATE");
                
//                html += "amtMin = '"+ amtMin+ "' <br>";
//                html += "amtMax = '"+ amtMax+ "' <br>";
//                html += "rate   = '"+ rate+ "' <br><br>";
//                
//                html += "grossPay   = '"+ grossPay+ "' <br>";
                
                if (amtMin <= grossPay && grossPay <= amtMax){
                    nHIFRate = rate;
                }
                
//                html += "<hr>";
                
            }
            
        }catch(Exception e){
            e.getMessage();
        }
        
//        html += nHIFRate;
//        return html;
        return nHIFRate;
    }
    
    public String process( String staffNo, Integer pYear, Integer pMonth){
        String html = ""; 
        Sys system = new Sys();

        ScriptEngineManager scriptEngineManager = new ScriptEngineManager();
        ScriptEngine scriptEngine = scriptEngineManager.getEngineByName("js");
     
     //list of math chars to skip when finding itemcode & fmlcode in formula string
     
        HashMap<Integer,String> MathCharsList = new HashMap(); 
        MathCharsList.put(0,"(");
        MathCharsList.put(1,")");
        MathCharsList.put(2,"+");
        MathCharsList.put(3,"-");
        MathCharsList.put(4,"/");
        MathCharsList.put(5,"*");
        MathCharsList.put(6,"%");
        MathCharsList.put(7,"^");     
     
     //map to hold results
//     HashMap<String,Double> StaffResults = new HashMap(); 
        HashMap<String,Double> StaffItems = new HashMap(); 
        HashMap<String,Integer> StaffExemptItems = new HashMap(); 
        HashMap<String,Double> StaffLoanItems = new HashMap(); 
        HashMap<String,Double> StaffDepositItems = new HashMap(); 
        HashMap<String,String> LoanItems = new HashMap(); 
        HashMap<String,String> DepositItems = new HashMap();
        HashMap<String,Double> HeaderSums = new HashMap(); 
        HashMap<String,String> Items = new HashMap(); 
        HashMap<String,String> itemHeaders = new HashMap();           
        HashMap<String,String> formularsArray = new HashMap(); 
              
     //get items 
     //////////////////////////////////////////////////////////////////////////////////     
     
      try{
       Connection conn = ConnectionProvider.getConnection();
       Statement stmt = conn.createStatement();
        
       String query = "SELECT ITEMCODE, ITEMNAME FROM "+ this.schema+ ".PYITEMS ";

        ResultSet rs = stmt.executeQuery(query);
        while(rs.next()){
            
            String ItemCode        = rs.getString("ITEMCODE");
            String ItemName        = rs.getString("ITEMNAME");

            Items.put( ItemCode, ItemName );  

            
        }
       }catch(Exception e){
            html += e.getMessage();
       }
     //////////////////////////////////////////////////////////////////////////////////    
     
     //get item headers
      try{
       Connection conn = ConnectionProvider.getConnection();
       Statement stmt = conn.createStatement();
        
       String query = "SELECT HDRCODE,HDRNAME FROM "+ this.schema+ ".PYPSLHDR ";

        ResultSet rs = stmt.executeQuery(query);
        while(rs.next()){
            
            String HdrCode        = rs.getString("HDRCODE");
            String HdrName        = rs.getString("HDRNAME");

            itemHeaders.put( HdrCode, HdrName); 
            
            //preset header sum=null
            HeaderSums.put(HdrCode, 0.0 );

        }
       }catch(Exception e){
            html += e.getMessage();
       }
     //////////////////////////////////////////////////////////////////////////////////
         
     //get exempted items
     
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
        
            String query = "SELECT ITEMCODE,EXEMPT FROM "+ this.schema+ ".VIEWPYSTAFFEXEMPT WHERE PFNO = '"+ staffNo + "' ";

            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){

                String ExemptItemCode    = rs.getString("ITEMCODE");
                Integer IsExempt         = rs.getInt("EXEMPT");

                StaffExemptItems.put( ExemptItemCode, IsExempt);             
            }
        }catch(Exception e){
            html += e.getMessage();
       }
      
       html += "<hr> staff exempt items <br>";
      
       for(Map.Entry m:StaffExemptItems.entrySet()){  
        html += m.getKey()+" "+m.getValue() + "<br>"; 
       } 
       
       html += "<hr>";
     
     //////////////////////////////////////////////////////////////////////////////////
          
     
     //get staff items into an array
     //////////////////////////////////////////////////////////////////////////////////
       
      try{
       Connection conn = ConnectionProvider.getConnection();
       Statement stmt = conn.createStatement();
        
       String query = "SELECT ITEMCODE, AMOUNT, HDRCODE FROM "+ this.schema+ ".VIEWPYSTAFFITEMS WHERE PFNO = '"+ staffNo + "' AND PYEAR="+ pYear +" AND PMONTH="+ pMonth +" ";

        ResultSet rs = stmt.executeQuery(query);
        while(rs.next()){
            
            String ItemCode        = rs.getString("ITEMCODE");
            Double Amount          = rs.getDouble("AMOUNT");
            String HdrCode         = rs.getString("HDRCODE");
                        
            //check if exempt            
            if(StaffExemptItems.containsKey( ItemCode )){
               //exempted 
               html += "<font color=\"red\">Exempting Item " + ItemCode + "...</font> <br>";
               
               //remove if present is map
               StaffItems.remove( ItemCode );
               
            }else{

            StaffItems.put( ItemCode, Amount); 
            
            //store items sum per header, to be used in any formular requiring sum(header)
            if( HeaderSums.get(HdrCode) != null ){
              Double HAmount = HeaderSums.get(HdrCode);
              Double NewHAmt = HAmount + Amount;
              HeaderSums.put( HdrCode, NewHAmt );//increament header amount
              html += "Header " + HdrCode + " update item " + ItemCode + " to now  " + Amount + "<br> ";
            }else{
              HeaderSums.put( HdrCode, Amount);//set header sum 
              html += "Header " + HdrCode + " added item " + ItemCode + " is now  " + Amount + "<br> ";
            }
         }//if not expemt
        }//get staff items
       }catch(Exception e){
            html += e.getMessage();
       }
     //////////////////////////////////////////////////////////////////////////////////
      html += "<hr> staff items <br>";
      
      for(Map.Entry m:StaffItems.entrySet()){  
         html += m.getKey()+" "+m.getValue() + "<br>"; 
      } 
     
     //get staff loans items into an array
     //////////////////////////////////////////////////////////////////////////////////
   
      try{
       Connection conn = ConnectionProvider.getConnection();
       Statement stmt = conn.createStatement();
        
       String query = "SELECT ITEMCODE, AMOUNT, HDRCODE, ISLOANREP,ISLOANBAL,ITEMREP,ITEMBAL FROM "+ this.schema+ ".VIEWPYSTAFFLOANS WHERE PFNO = '"+ staffNo + "' AND PYEAR="+ pYear +" AND PMONTH="+ pMonth +" ";

        ResultSet rs = stmt.executeQuery(query);
        while(rs.next()){
            
            String ItemCode        = rs.getString("ITEMCODE");
            Double Amount          = rs.getDouble("AMOUNT");
            String HdrCode         = rs.getString("HDRCODE");
            Integer IsLoanRep      = rs.getInt("ISLOANREP");
            Integer IsLoanBal      = rs.getInt("ISLOANBAL");             
            
            //check if exempt            
            if(StaffExemptItems.containsKey( ItemCode )){
               //exempted 
            }else{
            
             if(IsLoanBal==1){
              StaffItems.put( ItemCode, Amount);  
             }
            
            if(IsLoanRep==1){
                
                String ItemRep        = rs.getString("ITEMREP");
                String ItemBal        = rs.getString("ITEMBAL");
          
                StaffItems.put( ItemCode, Amount);    
             
                LoanItems.put( ItemRep, ItemBal );             
             
                StaffLoanItems.put( ItemCode, Amount);             
            
//                store items sum per header, to be used in any formular requiring sum(header)
           
                if( HeaderSums.get(HdrCode) != null ){
                    Double HAmount = HeaderSums.get(HdrCode);
//                    Double NewHAmt = HAmount + Amount;
                    Double NewHAmt = HAmount + 0;
                    HeaderSums.put( HdrCode, NewHAmt );//increament header amount
                    html += "HAmount= "+ HAmount+ "<br>";
                    html += "NewHAmt= "+ NewHAmt+ "<br>";
                    html += "Header " + HdrCode + "  update loan item " + ItemCode + " with  " + Amount + " to   " + NewHAmt + "<br> ";
                }else{
                    HeaderSums.put( HdrCode, Amount);//set header sum 
                    html += "Header " + HdrCode + " added loan item " + ItemCode + " to  " + Amount + "<br> ";
                }
            
            }//if item is loan repayment
          }//if not exempted
        }//while get  loan items
       }catch(Exception e){
            html += e.getMessage();
       }
     //////////////////////////////////////////////////////////////////////////////////
      html += "<hr>loan mapped items <br>";      
      for(Map.Entry m:LoanItems.entrySet()){  
         html += m.getKey()+" "+m.getValue() + "<br>"; 
      } 
      
      html += "<hr>loan items <br>";      
      for(Map.Entry m:StaffLoanItems.entrySet()){  
         html += m.getKey()+" "+m.getValue() + "<br>"; 
      } 
      html += "<hr>";      
      
      
//        get loan rep & loan bal
        for(Map.Entry m:StaffLoanItems.entrySet()){ 
            String LoaItemRep  = m.getKey().toString();
            String LoanItemBal = LoanItems.get( LoaItemRep );
            Double LoanAmount  = Double.parseDouble( m.getValue().toString() );
            Double LoanBal     = StaffItems.get( LoanItemBal );
            
//            niklas add check null
//            LoanBal = LoanBal != null? LoanBal: 0.0;
            
            html += " loan amount = " + LoanAmount + " <br>";
            html += " loan bal = " + LoanBal + " <br>";
        
            if( LoanAmount >= LoanBal  ){            
                LoanAmount  = LoanBal;
                LoanBal     = 0.0;
                StaffItems.put( LoaItemRep, LoanAmount );
                StaffItems.put( LoanItemBal, LoanBal );
            }else{
                LoanBal = LoanBal - LoanAmount;
                StaffItems.put( LoanItemBal, LoanBal );
            }
        
            html += " loan item rep " + LoaItemRep + "  has amount " + LoanAmount + " <br>";
            html += " loan item bal " + LoanItemBal + "  has amount " + LoanBal + " <br>";
        
        } 
        html += "<hr>";
         
        
      
     //get staff deposit items into an array
     //////////////////////////////////////////////////////////////////////////////////
   
      try{
       Connection conn = ConnectionProvider.getConnection();
       Statement stmt = conn.createStatement();
        
       String query = "SELECT ITEMCODE,AMOUNT,HDRCODE,ISDEPO,ISCUMM,ITEMDEP,ITEMCUM FROM "+ this.schema+ ".VIEWSTAFFDEPITEMS WHERE PFNO = '"+ staffNo + "' AND PYEAR="+ pYear +" AND PMONTH="+ pMonth +" ";

        ResultSet rs = stmt.executeQuery(query);
        while(rs.next()){
            
            String ItemCode        = rs.getString("ITEMCODE");
            Double Amount          = rs.getDouble("AMOUNT");
            String HdrCode         = rs.getString("HDRCODE");
            Integer IsDepo         = rs.getInt("ISDEPO");
            Integer IsCumm         = rs.getInt("ISCUMM");             
            
            //check if exempt            
            if(StaffExemptItems.containsKey( ItemCode )){
               //exempted 
            }else{
            
             if(IsCumm==1){
              StaffItems.put( ItemCode, Amount);  
             }
            
             if(IsDepo==1){
                
             String ItemDep        = rs.getString("ITEMDEP");
             String ItemCumm       = rs.getString("ITEMCUM");
          
             StaffItems.put( ItemCode, Amount);    
             
             DepositItems.put( ItemDep, ItemCumm );             
             
             StaffDepositItems.put( ItemCode, Amount);             
            
            //store items sum per header, to be used in any formular requiring sum(header)
           
            if( HeaderSums.get(HdrCode)!=null ){
              Double HAmount = HeaderSums.get(HdrCode);
              Double NewHAmt = HAmount + Amount;
              HeaderSums.put( HdrCode, NewHAmt );//increament header amount
              html += "Header " + HdrCode + "  update deposit item " + ItemCode + " with  " + Amount + " to   " + NewHAmt + "<br> ";
            }else{
              HeaderSums.put( HdrCode, Amount);//set header sum 
              html += "Header " + HdrCode + " added deposit item " + ItemCode + " to  " + Amount + "<br> ";
            }
            
           }//if item is loan repayment
          }//if not exempted
        }//while get  loan items
       }catch(Exception e){
            html += e.getMessage();
       }
     //////////////////////////////////////////////////////////////////////////////////
      html += "<hr>deposit mapped items <br>";      
      for(Map.Entry m:DepositItems.entrySet()){  
         html += m.getKey()+" "+m.getValue() + "<br>"; 
      } 
      
      html += "<hr>staff deposit items <br>";      
      for(Map.Entry m:StaffDepositItems.entrySet()){  
         html += m.getKey()+" "+m.getValue() + "<br>"; 
      } 
      html += "<hr>";      
      
      //get loan rep & loan bal
      for(Map.Entry m:StaffDepositItems.entrySet()){ 
          
        String DepoItemDepo   = m.getKey().toString();
        String DepoItemCumm   = DepositItems.get( DepoItemDepo );
        Double DepoAmount     = Double.parseDouble( m.getValue().toString() );
        Double CummAmount     = StaffItems.get( DepoItemCumm );
        
        //increament cumm amount
        CummAmount = CummAmount + DepoAmount;
        
        StaffItems.put( DepoItemCumm, CummAmount );        
        
        html += " depo item depo " + DepoItemDepo + "  has amount " + DepoAmount + " <br>";
        html += " depo item cumm " + DepoItemCumm + "  has amount " + CummAmount + " <br>";
        
      } 
      html += "<hr>";
     
     //fomula calc
     //////////////////////////////////////////////////////////////////////////////////
               
      try{
       Connection conn = ConnectionProvider.getConnection();
       //Statement stmt = conn.createStatement();
       Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        
       String query = "SELECT FMLCODE,FMLNAME,FMTCODE,FORMULAR FROM "+this.schema+".PYFML ORDER BY ITEMPOS ";

        ResultSet rs = stmt.executeQuery(query);
               
        //store in fmls in array
        while(rs.next()){
            
            String fmlCode    = rs.getString("FMLCODE");
            String fmlName    = rs.getString("FMLNAME");
            String fmtType    = rs.getString("FMTCODE");
           
            String FormularStr    = rs.getString("FORMULAR");
            
            html += "<font color=\"#333\" =====> "+fmlCode+" : "+fmtType+" : "+fmlName+" : " + FormularStr + "</font><br>";

            formularsArray.put( fmlCode, fmlName); 
            
        }
        
        html += "<hr>";
        
        //scroll back to first row
        rs.beforeFirst();        
        
        //loop fml and get math strin to execute
               
        while(rs.next()){
            
            String fmlCode        = rs.getString("FMLCODE");
            String fmlName        = rs.getString("FMLNAME");
            String FormularStr    = rs.getString("FORMULAR");
            String fmtCode        = rs.getString("FMTCODE");
            String fmtType        = rs.getString("FMTCODE");
            Double Result;
            String MathStr =  "";
            
            html += "<font color=orange =====> "+fmlCode+" "+fmtType+" : : "+fmlName+" : " + FormularStr + "</font><br>";
                   
            //check if formular is exempt
            if(StaffExemptItems.containsKey( fmlCode )){
              //exempted 
               html += "<font color=\"red\">Exempting Formula " + fmlCode + " : "+fmlName+".</font> <br>";
               
               //remove if present is map
               StaffItems.remove( fmlCode );
               
            }else{                
            
            switch(fmtCode){
                   case "calculate_TaxRate":
                   
                   Double CalcBase = StaffItems.get(FormularStr);                  
                   Double myTax = this.getIncomeTax( CalcBase );
                   MathStr  += "  "+ myTax +"  ";
                   
                   html += "<font color=orange > =====> calculate_TaxRate "+CalcBase+" = "+myTax+" </font><br>";
                   
                  break;
                  case "calculate_NHIFRate":
//                   MathStr +=  calculate_NHIFRate;
//                   MathStr +=  "1700";
                    Double CalcBaseNHIF = StaffItems.get(FormularStr);                  
                    Double myNHIFRate = this.getNHIFRate(CalcBaseNHIF );
                    MathStr  += "  "+ myNHIFRate +"  ";
                    html += "<font color=violet > =====> calculate_NHIFRate "+CalcBaseNHIF+" = "+myNHIFRate+" </font><br>";
                  break;
                  case "calculate_InsuranceRelief":
//                   MathStr +=  calculate_InsuranceRelief;
                  break;
                  case "Constant_Value":
                   MathStr +=  FormularStr;
                  break;
                  case "User_Defined":
                   
                    //split formular in an array 
                    String[] FormularStrArray = FormularStr.split("\\s+", -1 );     
                    List<String> formularList = Arrays.asList(FormularStrArray);
            
                //loop formular array parts
                for (int i = 0; i < formularList.size(); i++) {

                 String formularChar = formularList.get(i);

                //check if part in an itemcode in staff transactions
                 if(StaffItems.containsKey( formularChar )){
                  
                     String ItemDesc = Items.containsKey( formularChar ) ? Items.get( formularChar ) : formularsArray.get( formularChar );
                  
                  html += "<font color=red> =====> fml part found in staff trans " + formularChar + " : "+ ItemDesc +"   </font><font color=blue> with value <b> "+StaffItems.get( formularChar)+" </b></font><br>";
                  MathStr += StaffItems.get( formularChar);
                 }else 


                //check if part in an itemcode in math chars lis
                 if(MathCharsList.containsValue( formularChar )){
                  html += "<font color=blue> =====> math char  </font><font color=blue> as symbol <b> "+ formularChar +" </b></font><br>";
                  MathStr +=  formularChar;
                 }else


                //check if part in headers
                 if( HeaderSums.containsKey( formularChar )){
                  html += "<font color=\"#ea1ee0\"> =====> fml part found in headers " + formularChar + "  </font><font color=blue> with value <b> "+ HeaderSums.get( formularChar ) +" </b></font><br>";
                  MathStr +=  HeaderSums.get( formularChar );
                 }else

                //else
                 if(Items.containsKey( formularChar )){
                  html += "<font color=\"#f9a7de\" > =====> fml part found in items array " + formularChar + "  </font><font color=blue> with name <b> "+ Items.get( formularChar ) +" </b> value set=0</font><br>";
    
                  MathStr +=  "0";
                 }else
                     
                 if(formularsArray.containsKey( formularChar )){
                  html += "<font color=green> =====> fml part found in formularsArray " + formularChar + "  </font><font color=blue> with value <b> "+ formularChar +" </b></font><br>";
    //              MathStr +=  formularsArray.get( formularChar );
                  MathStr +=  formularChar;
                 }else
                 {
                  html += "<font color=brown> =====> fml part not found " + formularChar + "  </font><font color=blue> with value <b>  "+ formularChar +" </b></font><br>"; 
                  //switch calc method
    //             
                  //f*cking formularChar not a staff item , formula, payroll item or math-char
                  MathStr +=  formularChar;


                 }

                }
            
            break;//case fml = user defined
           }
            
              scriptEngine.eval("var output ="+MathStr+" ");
              String output = (String) scriptEngine.get("output").toString();
              Result = Double.parseDouble(output);
              
              //round result
//              Double ResultFinal = Math.round(Result*1,2);
              Double ResultFinal = Math.round(Result*100.0)/100.0;              

             //Result = Double.parseDouble(scriptEngine.eval(MathStr).toString());         

    
            html += "<br><font color=\"#f00\">" + fmlCode +"=";
            html += MathStr;
            html += "=";
            html += ResultFinal;
            html += "</font><hr>";
            
            
            StaffItems.put( fmlCode, ResultFinal ); 
            
          }//if formular not exempted
        }//loop each formular
       }catch(SQLException | ScriptException | NumberFormatException e){
            html += e.getMessage();
       }
     //////////////////////////////////////////////////////////////////////////////////
     
           
      html += "<hr>";
           
      
         for (int i = 0; i < MathCharsList.size(); i++) {
            String ItemCodeLoop = MathCharsList.get(i);
            html += MathCharsList.get(i) + "<br>";
          }
      
      
      html += "<hr>";
      
      for(Map.Entry m:StaffItems.entrySet()){  
         html += m.getKey()+" "+m.getValue() + "<br>"; 
      } 
      
      html += "<hr>";
      
      for(Map.Entry f:formularsArray.entrySet()){  
         html += f.getKey()+" "+f.getValue() + "<br>";
      } 
      
      html += "<hr>";
      
      for(Map.Entry h:itemHeaders.entrySet()){  
         html += h.getKey()+" "+h.getValue() + "<br>";
      }  
      
      html += "<hr>";
      
      for(Map.Entry h:HeaderSums.entrySet()){  
         html += h.getKey()+" "+h.getValue() + "<br>";
      }
      
      //finaly insert
      try {
       Connection connDel = ConnectionProvider.getConnection();
       Statement stmtDel = connDel.createStatement();             
       String queryDelete = "DELETE FROM "+ this.schema+ ".PYSLIP WHERE PFNO = '"+ staffNo + "' AND PYEAR="+ pYear +" AND PMONTH="+ pMonth +" ";
//       String queryDelete = "DELETE FROM PYSLIP  ";
       stmtDel.execute( queryDelete );        
      }catch(Exception e){
        html += e.getMessage();
      }

      for(Map.Entry m:StaffItems.entrySet()){  
          
       Double Amount = Double.parseDouble( m.getValue().toString() );
               
       if( Amount > 0 ){    
        try {
           
            Connection connUpdate = ConnectionProvider.getConnection();
            Statement stmtUpdate = connUpdate.createStatement();             
            String queryUpdate; 
            
            html += "<font color=\"blue\">Staff " + staffNo + ": inserting payroll item "+ m.getKey() +" with "+ Amount +" </font><br>";
            
            queryUpdate = "INSERT INTO "+ this.schema+ ".PYSLIP "
                    + "(ID, PFNO, ITEMCODE, PYEAR, PMONTH, AMOUNT )"
                    + "VALUES"
                    + "("
                    + system.generateId(this.schema+ ".PYSLIP", "ID")+ ", "
                    + "'"+ staffNo +"', "
                    + "'"+ m.getKey() +"', "
                    + pYear +", "
                    + pMonth +", "
                    + Amount +" "                   
                    + ")";
             
             stmtUpdate.executeUpdate(queryUpdate);
             
            }catch(Exception e){
             html += e.getMessage();
            }
          }
        }
        /**/
      return html;
    }
    
    public Integer periodEnd(String pfNo, String itemCode, Integer pYear, Integer pMonth, Double amount, HttpSession session, HttpServletRequest request){
        Integer processed = 0;
        
        Sys system = new Sys();
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt  = conn.createStatement();
            
            Integer id = system.generateId(this.schema+ ".PYSTAFFITEMS", "ID");

            String query = "INSERT INTO "+ this.schema+ ".PYSTAFFITEMS "
                    + "(ID, PFNO, ITEMCODE, PYEAR, PMONTH, AMOUNT, "
                    + "AUDITUSER, AUDITDATE, AUDITTIME, AUDITIPADR"
                    + ")"
                    + "VALUES"
                    + "("
                    + id+ ","
                    + "'"+ pfNo+ "', "
                    + "'"+ itemCode+ "', "
                    + ""+ pYear+ ", "
                    + ""+ pMonth+ ", "
                    + ""+ amount+ ", "
                    + "'"+ system.getLogUser(session) +"', "
                    + "'"+ system.getLogDate() +"', "
                    + "'"+ system.getLogTime() +"', "
                    + "'"+ system.getClientIpAdr(request) +"'"
                    + ")";

            processed = stmt.executeUpdate(query);
            
        }catch(SQLException e){
            System.out.println(e.getMessage());
        }
        
        return processed;
    }
    
    public String yearEnd(Integer pYear){
        String html = "";
        
        html += this.cfTax(pYear);
        html += this.cfNHIF(pYear);
        
        return html;
    }
    
    public String cfTax(Integer pYear){
        String html = "";
        
        Sys system = new Sys();
        
        system.delete(this.schema+ ".PYTAXRATES", "PYEAR = "+ pYear);
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            Integer prevYear = pYear - 1;

            String query = "SELECT * FROM "+ this.schema+ ".PYTAXRATES WHERE PYEAR = "+ prevYear+ " ";

            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                
                Double amtMin   = rs.getDouble("AMTMIN");
                Double amtMax   = rs.getDouble("AMTMAX");
                Double rate     = rs.getDouble("RATE");
                Double amtTxd   = rs.getDouble("AMTTXD");
                
                Integer id = system.generateId(this.schema+ ".PYTAXRATES", "ID");
                
                String queryIns = "INSERT INTO "+ this.schema+ ".PYTAXRATES "
                    + "(ID, PYEAR, AMTMIN, AMTMAX, RATE, AMTTXD "
                    + ")"
                    + "VALUES"
                    + "("
                    + id+ ","
                    + ""+ pYear+ ", "
                    + ""+ amtMin+ ", "
                    + ""+ amtMax+ ", "
                    + ""+ rate+ ", "
                    + ""+ amtTxd+ " "
                    + ")";
                
                Statement stmtIns = conn.createStatement();
                
                stmtIns.executeUpdate(queryIns);
                
            }
        }catch(Exception e){
            html += e.getMessage();
        }
        
        return html;
    }
    
    public String cfNHIF(Integer pYear){
        String html = "";
        
        Sys system = new Sys();
        
        system.delete(this.schema+ ".PYNHIFRATES", "PYEAR = "+ pYear);
        
        try{
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();
            
            Integer prevYear = pYear - 1;

            String query = "SELECT * FROM "+ this.schema+ ".PYNHIFRATES WHERE PYEAR = "+ prevYear+ " ";

            ResultSet rs = stmt.executeQuery(query);
            while(rs.next()){
                
                Double amtMin   = rs.getDouble("AMTMIN");
                Double amtMax   = rs.getDouble("AMTMAX");
                Double rate     = rs.getDouble("RATE");
                
                Integer id = system.generateId(this.schema+ ".PYNHIFRATES", "ID");
                
                String queryIns = "INSERT INTO "+ this.schema+ ".PYNHIFRATES "
                    + "(ID, PYEAR, AMTMIN, AMTMAX, RATE "
                    + ")"
                    + "VALUES"
                    + "("
                    + id+ ","
                    + ""+ pYear+ ", "
                    + ""+ amtMin+ ", "
                    + ""+ amtMax+ ", "
                    + ""+ rate+ " "
                    + ")";
                
                Statement stmtIns = conn.createStatement();
                
                stmtIns.executeUpdate(queryIns);
                
            }
        }catch(Exception e){
            html += e.getMessage();
        }
        
        return html;
    }
    
}
