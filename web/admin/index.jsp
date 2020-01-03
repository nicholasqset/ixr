<%
    Boolean showPage = false;
//    Boolean showPage = true;
%>
<!--<link href="../css/bootstrap.css" type="text/css" rel="stylesheet">          
<script src="../js/jquery-2.2.3.min.js" type="text/javascript"></script>
<script src="../js/bootstrap.js"></script>-->

<!--<script type="text/javascript">
    $(document).ready(function(){
        $("#myModal").modal('show');
    });
</script>-->
<!--<div id="myModal" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Login</h4>
            </div>
            <div class="modal-body">
                <p>Enter both username and password</p>
                <form>
                    <div class="form-group">
                        <input type="text" class="form-control" placeholder="Usernames">
                    </div>
                    <div class="form-group">
                        <input type="password" class="form-control" placeholder="Password ">
                    </div>
                    <button type="submit" class="btn btn-primary">Subscribe</button>
                </form>
            </div>
        </div>
    </div>
</div>-->

<%
//    String act = request.getParameter("act");
//    if(act != null){
//       if(act.equals("logout")){
//           session.invalidate();
//           response.sendRedirect("./");
//           return;
//        }
//    }
   
//    if ((session.getAttribute("userId") == null) || (session.getAttribute("userId").toString().trim().equals(""))) {
    if(showPage){
        %>
        <jsp:include page="./ixr_admin.jsp" />
        <%
    } else {
        %>
       <%--<jsp:include page="./ixr_admin.jsp" />--%>
       <%
           }
           %>