<?php
include_once("dbconnect.php");

if (isset($_GET['cartid'])) {
    $cartId = $_GET['cartid'];

    $sqlRemoveFromCart = "DELETE FROM `tbl_carts` WHERE `cart_id` = '$cartId'";

    if ($conn->query($sqlRemoveFromCart) === TRUE) {
        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
