setInterval("checkResult();",5000);
var ajax = typeof XMLHttpRequest == "undefined"?new ActiveXObject('Microsoft.XMLHttp'):new XMLHttpRequest();
function checkResult(){
var pagePiece=document.getElementById("result");
ajax.open("GET", "result_final.html");
ajax.send(null);
ajax.onreadystatechange = function(){
if(ajax.readyState==4 && ajax.status ==200){
pagePiece.innerHTML=ajax.responseText;
}}}
