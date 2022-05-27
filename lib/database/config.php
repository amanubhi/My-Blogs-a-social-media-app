<?php

$serverName = "localhost";
$username = "id17288513_admin";
$password = "r=ZznL*U}u4C-6qH";
$dbName = "id17288513_my_notes";


// creating connection to database

$con = mysqli_connect($serverName, $username, $password, $dbName);

if(mysqli_connect_errno()) {
	echo "Failed to connect!";
	exit();
}
//"Connection Success!";

?>