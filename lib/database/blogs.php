<?php
include "config.php";
// used for posting and retrieving blogs

$json["errorMsgPost"] = "";
$json["errorMsgGet"] = "";
$json["didPostSucceed"] = false;
$json["didBlogRetrievalSucceed"] = false;
$json["blogs"] = [];
$json["tags"] = [];

$data = json_decode(file_get_contents('php://input'));
$_postType = $data->{'postType'};
$postType = mysqli_real_escape_string($con, $_postType);

if ($postType == "post") {
    //prepping for blog
    $_subject = $data->{"subject"};
    $_description = $data->{"description"};
    $_pdate = $data->{"pdate"};
    $_userid = $data->{"userid"};
    $_pre_tags = $data->{'tags'};

    $subject = mysqli_real_escape_string($con, $_subject);
    $description = mysqli_real_escape_string($con, $_description);
    $pdate = mysqli_real_escape_string($con, $_pdate);
    $userid = mysqli_real_escape_string($con, $_userid);
    $pre_tags = $_pre_tags;

    // escaping tags
    $tags = array_map(function($tag) use ($con){
        return  mysqli_real_escape_string($con, $tag);
    }, $pre_tags);

    // make sure this user has not posted more than 2 blogs today
    $query = "SELECT * FROM blogs WHERE 'pdate' = $pdate AND userid = $userid";
    $results = mysqli_query($con, $query);
    $count = mysqli_num_rows($results);
    if ($count < 2) {
        $results = [];
        $queries = [
            "LOCK TABLES blogs WRITE",
            "INSERT INTO blogs SET
                                subject = '$subject',
                                description = '$description',
                                pdate = '$pdate',
                                userid = '$userid'",
            "UNLOCK TABLES"
        ];
        // posting blog
        foreach($queries as $query) {
            $result = mysqli_query($con, $query);
            array_push($results, $result);
            // debug
            // echo "blogs";
            // echo "<br>";
            // echo $query;
            // echo "<br>";
            // echo mysqli_error($con);
            // echo "<br>";
        }
        // retrieving current blogs id
        $query = "SELECT blogid FROM blogs WHERE subject LIKE '$subject' AND description LIKE '$description' AND userid = $userid";
        $currentBlogId = mysqli_fetch_object(mysqli_query($con,$query))->blogid;
        // prepping for blogstags
        $queries = [
            "LOCK TABLES blogstags WRITE"
        ];
        // creating and pushing queries to queries array
        foreach($tags as $tag) {
            $query = "INSERT INTO blogstags SET blogid = '$currentBlogId', tag = '$tag'";
            array_push($queries, $query);
        }
        $query = "UNLOCK TABLES";
        array_push($queries, $query);
        // posting blog tags
        foreach($queries as $query) {
            $result = mysqli_query($con, $query);
            array_push($results, $result);
            // debug
            // echo "blog tags";
            // echo "<br>";
            // echo $query;
            // echo "<br>";
            // echo mysqli_error($con);
            // echo "<br>";
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
        // everything checks out so the queries were successful
        $json{"didPostSucceed"} = true;
    }
    else {
        // let the app know the user has reached their limit for the day
        $json["errorMsg"] = "User has already posted 2 blogs today";
    }
}
// retrieve blogs and tags
$blogQuery = "SELECT * FROM blogs ORDER BY pdate DESC";
$blogResults = mysqli_query($con, $blogQuery);
$tagQuery = "SELECT * FROM blogstags ORDER BY blogid";
$tagResults = mysqli_query($con, $tagQuery);
$count = mysqli_num_rows($blogResults);

if ($count > 0) {
    while($result = mysqli_fetch_assoc($blogResults)) {
        array_push($json["blogs"], $result);
    }
    while($result = mysqli_fetch_assoc($tagResults)) {
        array_push($json["tags"], $result);
    }
    $json["didBlogRetrievalSucceed"] = true;
}
else {
    $json["errorMsgGet"] = "No blogs were retrieved";
}

echo json_encode($json);

    ?>