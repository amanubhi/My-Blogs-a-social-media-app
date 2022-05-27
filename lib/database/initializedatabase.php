<?php
include "config.php";
include "initializationquery.php";

$json["isSuccessful"] = false;
$count = 0;
foreach($sql as $query) {
    if(mysqli_query($con,$query)) {
        $count++;
    }
    // debug
/*    echo $query;
    echo "<br>";
    echo mysqli_error($con);
    echo "<br>"; */
}
// there are 35 total queries
if($count >= 35) {
    $json["isSuccessful"] = true;
}

echo json_encode($json);

    ?>