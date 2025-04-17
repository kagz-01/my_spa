<?php
// Enable error reporting for debugging - can be removed in production
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database credentials
$host = "localhost";
$user = "root"; 
$password = ""; 
$db = "my_spa";

// Create connection
$con = new mysqli($host, $user, $password, $db);

// Check connection
if ($con->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Connection failed: " . $con->connect_error
    ]));
}

// Simple connection test file
header('Content-Type: application/json');

// Initialize response
$response = array(
    "success" => true,
    "message" => "Connection successful",
    "timestamp" => date('Y-m-d H:i:s')
);

// Send response
echo json_encode($response);
?>