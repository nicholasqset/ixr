<%@page import="com.qset.authenticate.Authenticate"%>
<%@page import="com.qset.sys.Sys"%>
<%

    String message;
    String userId   = request.getParameter("userId"); 
    userId = userId != null? userId: "";
    String password = request.getParameter("password"); 
    password = password != null? password: "";
    
    Authenticate authenticate   = new Authenticate(userId, password);
    
    if(authenticate.authenticated){
        session.setAttribute("userId", userId.toUpperCase());
        Sys sys = new Sys();
        String comCode = sys.getOne("sys.coms", "comCode", "upper(email) = '"+ userId.toUpperCase()+"'");
        if(comCode == null){
            comCode = sys.getOne("sys.com_users", "cu_com_code", "upper(cu_usr_id) = '"+ userId.toUpperCase()+ "'");
        }
        
//        System.out.println("userId="+userId);
//        System.out.println("userId="+ session.getAttribute("userId"));
//        System.out.println("comCode="+comCode);
        if(comCode == null){
            message = "Invalid credentials";
        }else{
            session.setAttribute("comCode", comCode);
            message = "ok";
            
            sys.logUser(comCode, session.getId(), userId, "in");
        }
        response.sendRedirect("../");
    }else{
        message = "Invalid credentials";
        response.sendRedirect("../?m="+message);
    }
    
//    response.sendRedirect("../?m="+message);
%>