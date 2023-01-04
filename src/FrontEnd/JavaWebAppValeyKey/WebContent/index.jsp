
<html>
<br></br>
<h1>Hello ! Please choose Image to View : </h1>
<style>
body {
  background-color: #E6E6FA;
}
</style>
 <script Language="JavaScript">
        function getUrl(imageName) {

            document.getElementById('imageName').value = imageName;
            document.forms[0].submit();
        }
   </script> 
<form action="ValeyKeyServlet" method="post" target="_blank">
    <a id="corgi" style="font-size: 25px;" href="#" onclick="getUrl('corgi');return false;">Corgi</a> 
    <br></br>
    <a id="peki1" style="font-size: 25px;" href="#" onclick="getUrl('peki1');return false;">Peki1</a> 
     <br></br>
    <a id="peki2" style="font-size: 25px;" href="#" onclick="getUrl('peki2');return false;">Peki2</a> 
     <br></br>
    
    <input type="hidden" name="imageName" id="imageName" value="" />
</form>
</body>
</html>
