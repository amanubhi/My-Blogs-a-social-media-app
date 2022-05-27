<?php
include "config.php";
// used for posting and retrieving blogs

$json["errorMsgPost"] = "";
$json["errorMsgGet"] = "";
$json["didUserRetrievalSucceed"] = false;
$json["users"] = [];

$data = json_decode(file_get_contents('php://input'));

$_searchType = $data->{'searchType'};
$searchType = mysqli_real_escape_string($con, $_searchType);
$_non_escaped_usernames = $data->{"usernames"};
$non_escaped_usernames = $_non_escaped_usernames;
$_pdate = $data->{'pdate'};
$pdate = mysqli_real_escape_string($con, $_pdate);

if ($searchType == "usernames"):
    // escaping usernames
    $usernames = array_map(function($username) use ($con){
        return  mysqli_real_escape_string($con, $username);
    }, $non_escaped_usernames);

    $count = count($usernames);
    $fromSubQuery = '';
    $whereQuery = 'WHERE';
    for ($index = 0; $index < $count; $index++) {
        if($index > 0) {
            $whereQuery .= "AND";
        }
        $username = $usernames[$index];
        $follower = "follower" .($index+1);
        $fromSubQuery .= " (SELECT * FROM follows WHERE followerid in (SELECT userid FROM users WHERE username LIKE '$username')) AS $follower" . ",";
        $whereQuery .= " $follower.leaderid = users.userid ";
    }
    $userQuery = "SELECT users.username, users.userid
                  FROM $fromSubQuery users
                  $whereQuery";
elseif ($searchType == "pdate"):
    $userQuery = "SELECT users.username, users.userid, maxPost.count
                  FROM users, (SELECT MAX(postPerUser.count) AS count
                                      FROM (SELECT COUNT(*) AS count
                                         FROM blogs
                                         WHERE pdate = STR_TO_DATE('$pdate', '%Y-%m-%d')
                                         GROUP BY userid) AS postPerUser) AS maxPost, (SELECT userid, COUNT(*) AS count
                                                                                         FROM blogs
                                                                                         WHERE pdate = STR_TO_DATE('$pdate', '%Y-%m-%d')
                                                                                         GROUP BY userid) AS postPerUser
                  WHERE users.userid =postPerUser.userid AND maxPost.count = postPerUser.count
                  GROUP BY users.userid";
elseif ($searchType == "default"):
    $userQuery = "SELECT username, userid
                  FROM users
                  WHERE userid NOT IN (SELECT authorid
                                      FROM comments)";
    endif;

$userResults = mysqli_query($con, $userQuery);
$count = mysqli_num_rows($userResults);

if ($count > 0) {
    while($result = mysqli_fetch_assoc($userResults)) {
        array_push($json["users"], $result);
    }
    $json["didUserRetrievalSucceed"] = true;
}
else {
    $json["errorMsgGet"] = "No users were retrieved";
}

echo json_encode($json);

    ?>