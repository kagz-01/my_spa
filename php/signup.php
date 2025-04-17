<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set content type
header('Content-Type: application/json');

// Capture any output before intended JSON response
ob_start();

// Initialize response
$response = array(
    "success" => false,
    "message" => "Starting signup process",
    "debug" => []
);

try {
    // Include database connection
    require 'connect.php';
    $response["debug"][] = "Database connection included";
    
    // Get the request body data
    $input = file_get_contents('php://input');
    $response["debug"][] = "Raw input: " . $input;
    
    // Decode JSON input
    $data = json_decode($input, true);
    $response["debug"][] = "Parsed input: " . json_encode($data);
    
    // Check if request contains valid data
    if ($data && isset($data['username']) && isset($data['email']) && isset($data['password'])) {
        $username = $con->real_escape_string($data['username']);
        $email = $con->real_escape_string($data['email']);
        $password = $data['password'];
        
        $response["debug"][] = "Data validated";
        
        // Basic validation
        if (empty($username) || empty($email) || empty($password)) {
            $response["message"] = "All fields are required";
        } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $response["message"] = "Invalid email format";
        } else {
            $response["debug"][] = "Input validation passed";
            
            // Check if email already exists
            $check_query = "SELECT * FROM users WHERE email = '$email' LIMIT 1";
            $check_result = $con->query($check_query);
            
            if ($check_result && $check_result->num_rows > 0) {
                $response["message"] = "Email already registered";
                $response["debug"][] = "Email exists in database";
            } else {
                $response["debug"][] = "Email is unique";
                
                // Hash the password
                $hashed_password = password_hash($password, PASSWORD_DEFAULT);
                
                // Insert new user
                $insert_query = "INSERT INTO users (username, email, password, created_at) 
                                 VALUES ('$username', '$email', '$hashed_password', NOW())";
                
                if ($con->query($insert_query)) {
                    $response["success"] = true;
                    $response["message"] = "Registration successful";
                    $response["user_id"] = $con->insert_id;
                    $response["debug"][] = "User created successfully";
                } else {
                    $response["message"] = "Database error: " . $con->error;
                    $response["debug"][] = "Query failed: " . $con->error;
                }
            }
        }
    } else {
        $response["message"] = "Missing required fields or invalid JSON";
        $response["debug"][] = "Invalid input data";
    }
} catch (Exception $e) {
    $response["message"] = "Server error: " . $e->getMessage();
    $response["debug"][] = "Exception: " . $e->getMessage();
}

// Capture any unexpected output
$output = ob_get_clean();
if (!empty($output)) {
    $response["debug"][] = "Unexpected output: " . $output;
}

// Send response
echo json_encode($response);
?>