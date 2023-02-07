<%-- 
    Document   : index
    Created on : Feb 7, 2023, 10:04:31 AM
    Author     : nicholas
--%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="bean.conn.ConnectionProvider"%>
<%@page import="java.sql.Connection"%>
<%@page import="bean.sys.Sys"%>
<%
    String comCode = session.getAttribute("comCode").toString();
//    String labels = "'p1', 'p2', 'p3', 'p4', 'p5'";
    String labels = "";
//    String[] labels = null;
//    ArrayList<String> labels = new ArrayList<>();

//    String data = "4,3,2,5,1";
//    String data = "";
    ArrayList<Double> data = new ArrayList<>();

    Sys sys = new Sys();

    try {
        Boolean recordExists = sys.recordExists("" + comCode + ".viewpspydtls", "");

        if (recordExists) {
            Connection conn = ConnectionProvider.getConnection();
            Statement stmt = conn.createStatement();

            String query = "select qty, itemname from " + comCode + ".viewpspydtls "
                    + "where itemname is not null "
                    + "group by qty, itemname "
                    + "order by qty desc "
                    + "limit 100 "
                    + "";

//                            sys.logV2(query);
            ResultSet rs = stmt.executeQuery(query);

//                    JSONArray jSONArray = new JSONArray();
            while (rs.next()) {
                String itemname = rs.getString("itemname");
                Double qty = rs.getDouble("qty");
                
                labels += ",'"+itemname+"'";
//                labels.add(itemname);
                
//                data += ","+data+"";
                data.add(qty);

//                        JSONObject jSONObject2 = new JSONObject();
//                        jSONObject2.put("qty", qty);
//                        jSONObject2.put("itemname", itemname);
//                        jSONArray.put(jSONObject2);
            }

//                    jSONObject.put("data", jSONArray);
            sys.log("success");
        } else {
            sys.log("no record found ");
        }
    } catch (Exception e) {
        sys.log(e.getMessage());

    }
    
        labels = labels.substring(1);
//        out.println(labels);
//        data = data.substring(1);

%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Trending Products</title>
        <link rel="stylesheet" href="../../../../assets/bootstrap/css/bootstrap.min.css">
    </head>
    <body>
        <div>
            <canvas class="my-4 w-100" id="myChart" width="960" height="380"></canvas>
        </div>

        <script src="../../../../assets/js/jquery.js"></script>
        <script src="../../../../assets/js/chart.min.js"></script>
        <script>
            (() => {
                /*
                var lbls = new Array();
                var dt = new Array();

                var settings = {
                    "url": "parser.jsp",
                    "method": "POST",
                    "timeout": 0,
                    "headers": {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    "data": {
                        "function": "getTrendProds"
                    }
                };

                $.ajax(settings).done(function (response) {
//                    console.log(response);
                    response = JSON.parse(response);
                    if (response.status === 1) {
                        $.each(response.data, function (i, data) {
                            var itemname = data.itemname;
                            var qty = data.qty;
                            lbls.push(itemname);
                            dt.push(qty);


                        });
                    } else {
                        alert(response.message || 'error');
                    }
                });
                */

                const ctx = document.getElementById('myChart');
                const myChart = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: [<%= labels %>],
                        datasets: [{
                                label: 'Trending Products',
                                data: <%= data %>,
                                lineTension: 0,
                                backgroundColor: 'transparent',
                                borderColor: '#007bff',
                                borderWidth: 4,
                                pointBackgroundColor: '#007bff',
                            }]
                    },
                    options: {
                        legend: {
                            display: false
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    font: {
                                        style: 'normal',
                                    }
                                }
                            },
                            x: {
                                ticks: {
                                    font: {
                                        style: 'normal',
                                    }
                                }
                            }
                        }

                    }
                });

            })();


        </script>
    </body>
</html>
