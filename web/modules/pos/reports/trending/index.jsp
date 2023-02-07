<%-- 
    Document   : index
    Created on : Feb 7, 2023, 10:04:31 AM
    Author     : nicholas
--%>
<%
//String labels = "'p1', 'p2', 'p3', 'p4', 'p5'";
//String data = "4,3,2,5,1";
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Trending Products</title>
    </head>
    <body>
        <canvas class="my-4 w-100" id="myChart" width="900" height="380"></canvas>

        <script src="../../../../assets/js/jquery.js"></script>
        <script src="../../../../assets/js/chart.min.js"></script>
        <script>
            (() => {
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


                const ctx = document.getElementById('myChart');
                const myChart = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: lbls,
                        datasets: [{
                                label: 'Trending Products',
                                data: dt,
                                lineTension: 0,
                                backgroundColor: 'transparent',
                                borderColor: '#007bff',
                                borderWidth: 4,
                                pointBackgroundColor: '#007bff',
                            }]
                    },
                    options: {
                        legend: {
                            display: true
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    font: {
                                        style: 'normal',
                                        size: 16
                                    }
                                }
                            },
                            x: {
                                ticks: {
                                    font: {
                                        style: 'normal',
                                        size: 16
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
