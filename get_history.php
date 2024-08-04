<?php
include 'config.php';

$user_id = $_GET['user_id'];

$sql = "SELECT from_currency, to_currency, amount, result, timestamp FROM conversion_history WHERE user_id = '$user_id' ORDER BY timestamp DESC";
$result = $conn->query($sql);

$history = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $history[] = $row;
    }
}

echo json_encode($history);

$conn->close();
?>
