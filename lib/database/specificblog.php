<?php
include "config.php";
// used for posting and retrieving blogs

$json["errorMsgPost"] = "";
$json["errorMsgGet"] = "";
$json["didBlogRetrievalSucceed"] = false;
$json["blogs"] = [];
$json["tags"] = [];

$data = json_decode(file_get_contents('php://input'));
$_searchType = $data->{'searchType'};
$searchType = mysqli_real_escape_string($con, $_searchType);

$_pdate = $data->{"pdate"};
$pdate = mysqli_real_escape_string($con, $_pdate);
$_username = $data->{"username"};
$username = mysqli_real_escape_string($con, $_username);
$_tag = $data->{"tag"};
$tag = mysqli_real_escape_string($con, $_tag);

// retrieve blogs and tags
if ($searchType == "pdate"):
    $blogQuery = "SELECT * FROM blogs WHERE pdate = STR_TO_DATE('$pdate', '%Y-%m-%d')";
    $tagQuery = "SELECT * FROM blogstags WHERE blogstags.blogid in (SELECT blogid FROM blogs WHERE pdate = STR_TO_DATE('$pdate', '%Y-%m-%d')) ORDER BY blogid";
elseif ($searchType == "username"):
    //TODO: search using usernames
    $blogQuery = "SELECT DISTINCT blogs.*
                  FROM (SELECT *
                        FROM users
                        WHERE username LIKE '$username') as user, blogs, comments
                  WHERE user.userid = blogs.userid AND blogs.blogid NOT IN (SELECT blogid
                                                                           FROM comments
                                                                           WHERE sentiment LIKE 'negative')";
    $tagQuery = "SELECT * FROM blogstags WHERE blogstags.blogid in (SELECT blogs.blogid
                                                                      FROM (SELECT *
                                                                           FROM users
                                                                           WHERE username LIKE '$username') as user, blogs, comments
                                                                      WHERE user.userid = blogs.userid AND blogs.blogid NOT IN (SELECT blogid
                                                                                                                                  FROM comments
                                                                                                                                  WHERE sentiment LIKE 'negative')) ORDER BY blogid";
elseif ($searchType == "tag"):
    //TODO: search using usernames
    $blogQuery = "SELECT distinct blogs.*
                  FROM (SELECT blogid
                        FROM blogstags
                        WHERE tag LIKE '$tag') AS tags,blogs
                  WHERE tags.blogid = blogs.blogid";
     $tagQuery = "SELECT * FROM blogstags WHERE blogstags.blogid in (SELECT tags.blogid
                                                                       FROM (SELECT blogid
                                                                             FROM blogstags
                                                                             WHERE tag LIKE '$tag') AS tags,blogs
                                                                       WHERE tags.blogid = blogs.blogid) ORDER BY blogid";
    endif;


$blogResults = mysqli_query($con, $blogQuery);
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