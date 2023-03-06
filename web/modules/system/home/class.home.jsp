<%@page import="bean.gui.Gui"%>
<%

final class Home{
    
    public String view(){
        String html = "";
        
        return html;
    }
    
    public String manage(){
        String html = "";
        
        Gui gui = new Gui();
        
        String img_alt = "";
	
	html += "<div class = \"home\" >";
	html += "<img src = \"../../../assets/img/tm/tm.png\" title=\"XR ERP\" width = \"170\" height = \"170\" alt = \""+img_alt+"\" longdesc = \""+img_alt+"\" />";

	html += "</div>";
        
        return html;
    }
    
    public String save(){
        String html = "";
        
        return html;
    }
    
    public String purge(){
        String html = "";
        
        return html;
    }
    
}

%>
