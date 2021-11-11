<?php
header("HTTP/1.1 500 Readiness Check Failed");
$servername = $_ENV['DB_HOST'];
$dbname = $_ENV['DB_NAME']; 
$username = $_ENV['DB_USER']; 
$password = $_ENV['DB_PASSWORD']; 
$checkResult["status"] = "OK";

try {
  $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
  $stmt = $conn->prepare("SELECT * FROM ip2city limit 1"); 
  $stmt->execute();
  $checkResult["dbConnection"] = "OK";
  header("HTTP/1.1 200 OK");
}
catch(Exception $e) {
  $checkResult["status"] = "Failed!";
  $checkResult["dbConnection"] = $e->getMessage();
}
$conn = null;

$rJSON = json_encode($checkResult);
echo "$rJSON<br/>";
?>
Host: 2604734e9f8d<br/>
Host: e60658068fed<br/>
Host: ba19a5ef14c7<br/>
Host: 92b9f911b862<br/>
