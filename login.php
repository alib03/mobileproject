<?php
include 'config.php';

$username = $_POST['username'];
$password = $_POST['password'];

$sql = "SELECT id, password FROM users WHERE username = '$username'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    if (password_verify($password, $row['password'])) {
        echo json_encode(["success" => true, "user_id" => $row['id']]);
    } else {
        echo json_encode(["success" => false, "error" => "Invalid password"]);
    }
} else {
    echo json_encode(["success" => false, "error" => "No user found"]);
}

$conn->close();
?>
