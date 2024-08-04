<?php
include 'config.php';

$user_id = $_POST['user_id'];
$from_currency = $_POST['from_currency'];
$to_currency = $_POST['to_currency'];
$amount = $_POST['amount'];
$result = $_POST['result'];

$sql = "INSERT INTO conversion_history (user_id, from_currency, to_currency, amount, result) 
        VALUES ('$user_id', '$from_currency', '$to_currency', '$amount', '$result')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "error" => $conn->error]);
}

$conn->close();
?>
