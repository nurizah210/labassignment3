<?php
//error_reporting(0);

if (!isset($_POST['userid']) && !isset($_POST['isbn']) && !isset($_POST['title'])) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

$bookid = $_POST['bookid'];
$userid = $_POST['userid'];
$isbn = $_POST['isbn'];
$title = addslashes($_POST['title']);
$desc = addslashes($_POST['desc']);
$author = addslashes($_POST['author']);
$price = $_POST['price'];
$qty = $_POST['qty'];
$status = $_POST['status'];
$image = $_POST['image'];
if ($image != "NA"){
    $decoded_string = base64_decode($image);
}

$sqlupdate = "UPDATE `tbl_books` SET `book_isbn`='$isbn',`book_title`='$title',`book_desc`='$desc',`book_author`='$author',`book_price`='$price',`book_qty`='$qty',`book_status`='$status' WHERE `book_id` = '$bookid'";

if ($conn->query($sqlupdate) === TRUE) {
    if ($image != "NA"){
        $path = '../assets/books/' . $bookid  . '.png';
        file_put_contents($path, $decoded_string);
    }
    
    // Update book quantity in cart
    if (isset($_POST['new_qty'])) {
        $newQty = $_POST['new_qty'];

        // Check if the book is available in the cart
        $checkCartQuery = "SELECT * FROM `tbl_cart` WHERE `buyer_id` = '$userid' AND `book_id` = '$bookid'";
        $checkCartResult = $conn->query($checkCartQuery);

        if ($checkCartResult->num_rows > 0) {
            $cartRow = $checkCartResult->fetch_assoc();
            $cartQty = $cartRow['cart_qty'];

            // Check if the requested quantity is available
            $checkBookQtyQuery = "SELECT `book_qty` FROM `tbl_books` WHERE `book_id` = '$bookid'";
            $checkBookQtyResult = $conn->query($checkBookQtyQuery);

            if ($checkBookQtyResult->num_rows > 0) {
                $bookQtyRow = $checkBookQtyResult->fetch_assoc();
                $bookQty = $bookQtyRow['book_qty'];

                // Check if there is sufficient quantity to update
                if ($newQty <= $bookQty) {
                    // Perform the update operation
                    $updateCartQuery = "UPDATE `tbl_cart` SET `cart_qty`='$newQty' WHERE `buyer_id`='$userid' AND `book_id`='$bookid'";
                    $conn->query($updateCartQuery);

                    $response = array('status' => 'success', 'data' => null);
                    sendJsonResponse($response);
                } else {
                    // Not enough quantity available
                    $response = array('status' => 'failed', 'data' => 'Insufficient quantity available');
                    sendJsonResponse($response);
                }
            } else {
                // Book not found in tbl_books
                $response = array('status' => 'failed', 'data' => 'Book not found');
                sendJsonResponse($response);
            }
        } else {
            // Book not found in tbl_cart
            $response = array('status' => 'failed', 'data' => 'Book not found in the cart');
            sendJsonResponse($response);
        }
    }

    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
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
