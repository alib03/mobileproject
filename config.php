<?php
$host = 'localhost';
$db = 'currency_converter_db';
$user = 'your_db_username';
$pass = 'your_db_password';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
