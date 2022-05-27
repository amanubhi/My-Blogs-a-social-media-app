<?php
include "config.php";
// used for posting and retrieving blogs

$json["errorMsgPost"] = "";
$json["errorMsgGet"] = "";
$json["didPostSucceed"] = false;
$json["didCommentRetrievalSucceed"] = false;
$json["comments"] = [];

$postType = mysqli_real_escape_string($con, $_POST["postType"]);
$blogid = mysqli_real_escape_string($con, $_POST["blogid"]);

if ($postType == "post") {
    //prepping for comments

    $sentiment = mysqli_real_escape_string($con, $_POST["sentiment"]);
    $description = mysqli_real_escape_string($con, $_POST["description"]);
    $cdate = mysqli_real_escape_string($con, $_POST["cdate"]);
    $authorid = mysqli_real_escape_string($con, $_POST["authorid"]);

    // make sure this blog does not belong to the current user
    $query = "SELECT * FROM blogs WHERE blogid = '$blogid' AND userid = '$authorid'";
    $result = mysqli_query($con, $query);
    $count = mysqli_num_rows($result);

    if($count > 0) {
        // user owns this blog they cannot comment
        $json["errorMsgPost"] = "User owns this blog they cannot post!";
        echo json_encode($json);
        exit();
    }
     // make sure the user has not already commented
    $query = "SELECT * FROM comments WHERE blogid = '$blogid' AND authorid = '$authorid'";
    $result = mysqli_query($con, $query);
    $count = mysqli_num_rows($result);

    if($count > 0) {
        // user cannot comment more than once on this blog
        $json["errorMsgPost"] = "User has already reached their comment limit on this blog";
        echo json_encode($json);
        exit();
        }

    $queries = [
                "LOCK TABLES comments WRITE",
                "INSERT INTO comments SET
                                    sentiment = '$sentiment',
                                    description = '$description',
                                    cdate = '$cdate',
                                    blogid = '$blogid',
                                    authorid = '$authorid'",
                "UNLOCK TABLES" ];
    // executing queries
    $results = [];
        foreach($queries as $query) {
            $result = mysqli_query($con, $query);
            array_push($results, $result);
            // debug
            //echo "comments";
            //echo "<br>";
            //echo $query;
            //echo "<br>";
            //echo mysqli_error($con);
            //echo "<br>";
        }
        // done posting check if everything went well
        foreach($results as $result) {
            // if any of the queries failed exit the script
            if(!$result) {
                $json["errorMsgPost"] = "Query failed";
                echo json_encode($json);
                exit();
            }
        }
        $json["didPostSucceed"] = true;
}
// retrieving comments
$query = "SELECT * FROM comments WHERE blogid = '$blogid' ORDER BY commentid DESC";
$results = mysqli_query($con, $query);
$count = mysqli_num_rows($results);
if ($count > 0) {
    while($result = mysqli_fetch_assoc($results)) {
        array_push($json["comments"], $result);
    }
    $json["didCommentRetrievalSucceed"] = true;
}
echo json_encode($json);

    ?>