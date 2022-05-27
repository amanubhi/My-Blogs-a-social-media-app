<?php
include "config.php";
// REGISTER USER


$first_name = mysqli_real_escape_string($con, $_POST["first_name"]);
$last_name = mysqli_real_escape_string($con, $_POST["last_name"]);
$username = mysqli_real_escape_string($con, $_POST["username"]);
$email = mysqli_real_escape_string($con, $_POST["email"]);
$password = mysqli_real_escape_string($con, $_POST["password"]);

$sql = "SELECT * FROM registered_user WHERE username LIKE '$username' OR email LIKE '$email'";
$results = mysqli_query($con,$sql);
$count = mysqli_num_rows($results);

if($count > 0) {
    echo json_encode("Username or Email already taken");
}
else{
        $query = "INSERT INTO registered_user SET
                                first_name = '$first_name',
                                last_name = '$last_name',
                                username = '$username',
                                email = '$email',
                                password = '$password'";
    $results = mysqli_query($con, $query);

    if($results>0)
    {
        echo json_encode("Success");
    }
}
    ?>