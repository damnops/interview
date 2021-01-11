<style type="text/css"> 
      table { 
          border-collapse:collapse;border:solid #999;border-width:1px 0 0 1px; 
       } 
       table th, table td { 
          border:solid #999; border-width:0 1px 1px 0;padding:5px; 
       } 
</style> 
    
<table style='border: solid 1px black;'>
<tr><th>ipFrom</th><th>ipTo</th><th>Country</th><th>countryCode</th></tr>
<?php
class TableRows extends RecursiveIteratorIterator { 
    function __construct($it) { 
        parent::__construct($it, self::LEAVES_ONLY); 
    }

    function current() {
        return "<td>" . parent::current(). "</td>";
    }

    function beginChildren() { 
        echo "<tr>"; 
    } 

    function endChildren() { 
        echo "</tr>" . "\n";
    } 
} 

$servername = $_ENV['DB_HOST'];
$dbname = $_ENV['DB_NAME']; 
$username = $_ENV['DB_USER']; 
$password = $_ENV['DB_PASSWORD']; 
$start = rand();

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $stmt = $conn->prepare("SELECT ipFROM, ipTO, countryName, countryCode FROM ip2city where ipFROM > $start limit 10"); 
    $stmt->execute();

    // set the resulting array to associative
    $result = $stmt->setFetchMode(PDO::FETCH_ASSOC); 
    foreach(new TableRows(new RecursiveArrayIterator($stmt->fetchAll())) as $k=>$v) { 
        echo $v;
    }
}
catch(PDOException $e) {
    echo "Error: " . $e->getMessage();
}
$conn = null;
echo "</table>";
?>
