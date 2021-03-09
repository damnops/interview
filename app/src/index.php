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
Host: e805c6b8326a<br/>
Host: 5c3c51d3cd53<br/>
Host: e0643e9e776c<br/>
Host: 4ad79eb20144<br/>
Host: 4da4c10fe6a0<br/>
Host: 7247c4784b11<br/>
Host: 67869fa25842<br/>
Host: d4ecb0fae935<br/>
Host: aab8d6deada5<br/>
Host: f2f213ea6a53<br/>
Host: 21d1bbf02691<br/>
Host: 0430dc9a3672<br/>
Host: 020bad2074b4<br/>
Host: a7d682156e1b<br/>
Host: d4bbba06d5ea<br/>
Host: 66474cccb32b<br/>
Host: f1ca9dd32d34<br/>
Host: ac56d6c7ab62<br/>
Host: bedd62688abf<br/>
Host: 2f7952e08984<br/>
Host: d7b64adf28a2<br/>
Host: f1af7b4ad1e6<br/>
Host: 5e54529621d3<br/>
Host: 4bc1a7a31d45<br/>
Host: 8a1f37a9beb9<br/>
Host: 6cf191af47df<br/>
Host: 3c88d5baa665<br/>
Host: devops-joi-6cdf769889-hqpgj<br/>
Host: devops-joi-6cdf769889-hqpgj<br/>
Host: devops-joi-6cdf769889-hqpgj<br/>
Host: devops-joi-6cdf769889-hqpgj<br/>
Host: devops-joi-6cdf769889-nkhr9<br/>
Host: devops-joi-6cdf769889-nkhr9<br/>
Host: devops-joi-6cdf769889-nkhr9<br/>
Host: devops-joi-6cdf769889-nkhr9<br/>
Host: devops-joi-6cdf769889-nkhr9<br/>
Host: devops-joi-6cdf769889-nkhr9<br/>
Host: devops-joi-6cdf769889-nkhr9<br/>
Host: devops-joi-6cdf769889-nkhr9<br/>
Host: devops-joi-6cdf769889-nkhr9<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: 6d3d25e928ee<br/>
Host: 97cd11c472a7<br/>
Host: d58d0c5240e7<br/>
Host: a70045704644<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: 18a877042237<br/>
Host: d4ff3c268c40<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: c36f52876cfc<br/>
Host: 699a266d1c75<br/>
Host: devops-joi-6cdf769889-xkbz8<br/>
Host: 42c1a74bb94a<br/>
Host: devops-joi-6cdf769889-vfhqz<br/>
Host: devops-joi-6cdf769889-vfhqz<br/>
Host: devops-joi-6cdf769889-vfhqz<br/>
Host: devops-joi-6cdf769889-vfhqz<br/>
Host: devops-joi-6cdf769889-vfhqz<br/>
Host: devops-joi-6cdf769889-vfhqz<br/>
Host: devops-joi-6cdf769889-vfhqz<br/>
Host: devops-joi-6cdf769889-vfhqz<br/>
Host: devops-joi-6cdf769889-vfhqz<br/>
Host: devops-joi-6cdf769889-vfhqz<br/>
Host: devops-joi-6cdf769889-7j6h7<br/>
Host: devops-joi-6cdf769889-7j6h7<br/>
Host: devops-joi-6cdf769889-7j6h7<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-6cdf769889-rrgkl<br/>
Host: devops-joi-64df6c6744-pt42c<br/>
Host: devops-joi-64df6c6744-pt42c<br/>
Host: devops-joi-64df6c6744-pt42c<br/>
Host: devops-joi-64df6c6744-pt42c<br/>
Host: devops-joi-64df6c6744-pt42c<br/>
Host: devops-joi-64df6c6744-pt42c<br/>
Host: devops-joi-64df6c6744-pt42c<br/>
Host: devops-joi-64df6c6744-pt42c<br/>
Host: devops-joi-64df6c6744-pt42c<br/>
Host: d73fa62cf2b8<br/>
Host: 58d33cde2930<br/>
Host: devops-joi-86cdb67b5c-297rx<br/>
Host: devops-joi-86cdb67b5c-297rx<br/>
Host: devops-joi-86cdb67b5c-297rx<br/>
Host: devops-joi-86cdb67b5c-297rx<br/>
Host: devops-joi-86cdb67b5c-297rx<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-7785fbb6b5-6n2hb<br/>
Host: devops-joi-dcf4cfbf6-bvcqq<br/>
Host: devops-joi-dcf4cfbf6-bvcqq<br/>
Host: devops-joi-dcf4cfbf6-bvcqq<br/>
Host: devops-joi-dcf4cfbf6-bvcqq<br/>
Host: devops-joi-dcf4cfbf6-bvcqq<br/>
Host: devops-joi-dcf4cfbf6-g49zl<br/>
Host: devops-joi-dcf4cfbf6-g49zl<br/>
Host: devops-joi-dcf4cfbf6-g49zl<br/>
Host: devops-joi-dcf4cfbf6-g49zl<br/>
Host: devops-joi-dcf4cfbf6-x6jhn<br/>
Host: devops-joi-dcf4cfbf6-x6jhn<br/>
Host: devops-joi-dcf4cfbf6-x6jhn<br/>
Host: devops-joi-dcf4cfbf6-x6jhn<br/>
Host: devops-joi-dcf4cfbf6-x6jhn<br/>
Host: devops-joi-dcf4cfbf6-x6jhn<br/>
Host: devops-joi-dcf4cfbf6-7nlzz<br/>
Host: devops-joi-dcf4cfbf6-7nlzz<br/>
Host: devops-joi-dcf4cfbf6-7nlzz<br/>
Host: devops-joi-dcf4cfbf6-7nlzz<br/>
Host: devops-joi-dcf4cfbf6-7nlzz<br/>
Host: devops-joi-dcf4cfbf6-7nlzz<br/>
Host: devops-joi-57975f9b58-2r9jv<br/>
Host: devops-joi-57975f9b58-2r9jv<br/>
Host: devops-joi-57975f9b58-2r9jv<br/>
Host: devops-joi-768c579c65-xftrm<br/>
Host: devops-joi-768c579c65-xftrm<br/>
Host: devops-joi-768c579c65-xftrm<br/>
Host: devops-joi-768c579c65-xftrm<br/>
Host: devops-joi-768c579c65-xftrm<br/>
Host: devops-joi-59c485458f-4srll<br/>
Host: devops-joi-59c485458f-4srll<br/>
Host: devops-joi-59c485458f-4srll<br/>
Host: devops-joi-59c485458f-4srll<br/>
Host: devops-joi-59c485458f-4srll<br/>
Host: devops-joi-56bcd97745-sgkz8<br/>
Host: devops-joi-56bcd97745-sgkz8<br/>
Host: devops-joi-56bcd97745-sgkz8<br/>
Host: devops-joi-56bcd97745-sgkz8<br/>
Host: devops-joi-56bcd97745-sgkz8<br/>
Host: devops-joi-56bcd97745-sgkz8<br/>
Host: devops-joi-56bcd97745-sgkz8<br/>
Host: devops-joi-7785fbb6b5-nnznr<br/>
Host: devops-joi-7785fbb6b5-nnznr<br/>
Host: devops-joi-7785fbb6b5-nnznr<br/>
Host: devops-joi-7785fbb6b5-nnznr<br/>
Host: devops-joi-7785fbb6b5-nnznr<br/>
Host: devops-joi-d784b79bf-kqjsj<br/>
Host: devops-joi-d784b79bf-kqjsj<br/>
Host: devops-joi-6b4cf4d68f-rf9sq<br/>
Host: devops-joi-6b4cf4d68f-44ljb<br/>
Host: devops-joi-6b4cf4d68f-44ljb<br/>
Host: devops-joi-6b4cf4d68f-44ljb<br/>
Host: devops-joi-6b4cf4d68f-597nj<br/>
Host: devops-joi-847cd79bc6-848vs<br/>
Host: devops-joi-5c5bb66fb6-nr5xk<br/>
Host: devops-joi-645576dc79-t7lcg<br/>
Host: devops-joi-645576dc79-5jtjt<br/>
Host: f025dfac6048<br/>
Host: devops-joi-645576dc79-mzqbf<br/>
Host: devops-joi-645576dc79-vq222<br/>
Host: 19c1a4e1cd03<br/>
Host: 5eb6d6a71675<br/>
Host: 418fa58c6e72<br/>
Host: db82c0b6ea72<br/>
Host: devops-joi-68675fd7b4-sfs6d<br/>
