<!DOCTYPE html>
<html>
<head>
    <style>
      .xyz span {
        cursor: pointer;
      }
      .xyz a {
        position: relative;
        overflow: hidden;
      }
      .xyz span:hover a {
        color: red;
      }
      .xyz a+input {
        position: absolute;
        top: 0;
        left: 0;
        opacity: 0;
      }
    </style>
</head>
<body>
    <span class="xyz"><a href='#'>Link!</a><input type='file' /></span>
    <script type="text/javascript">
        
    </script>
</body>
</html>