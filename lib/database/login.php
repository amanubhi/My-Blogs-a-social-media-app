<?php
  include "config.php";

    $username = mysqli_real_escape_string($con,$_POST['username']);
    $password = mysqli_real_escape_string($con,$_POST['password']);

    $sql = "SELECT userid, username FROM users WHERE username LIKE '$username' and password LIKE '$password'";
    $result = mysqli_query($con,$sql);
    $count = mysqli_num_rows($result);

    $json["isSuccessful"] = false;
    $json["errorMsg"] = "";
    $json["user"] = array();

    if($count > 0) {
        $userlist = array();

        array_push($json["user"], mysqli_fetch_assoc($result));
        $json["isSuccessful"] = true;

    }else {
       $json["errorMsg"] = "Your Login Name or Password is invalid";
    }

    echo json_encode($json);
  ?>