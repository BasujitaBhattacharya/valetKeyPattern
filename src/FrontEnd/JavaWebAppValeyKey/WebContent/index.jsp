
<html>
<h1>Please choose Image to View : </h1>
<body>
 <script Language="JavaScript">
        function getUrl(imageName) {

            document.getElementById('imageName').value = imageName;
            document.forms[0].submit();
        }
   </script> 
<form action="ValeyKeyServlet" method="post" target="_blank">
    <a id="corgi" href="#" onclick="getUrl('corgi');return false;">Corgi</a> 
    <br></br>
    <a id="peki1" href="#" onclick="getUrl('peki1');return false;">Peki1</a> 
     <br></br>
    <a id="peki2" href="#" onclick="getUrl('peki2');return false;">Peki2</a> 
     <br></br>
    
    <input type="hidden" name="imageName" id="imageName" value="" />
</form>
</body>
</html>
