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
    "message" => "Starting login process",
    "data" => null
);

try {
    // Include database connection
    require 'connect.php';
    
    // Check if request method is POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Get raw input and both POST and JSON formats
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        // Check both POST and JSON input
        $email = "";
        $password = "";
        
        if (isset($_POST['email']) && isset($_POST['password'])) {
            // Form data
            $email = $con->real_escape_string($_POST['email']);
            $password = $_POST['password'];
        } elseif ($data && isset($data['email']) && isset($data['password'])) {
            // JSON data
            $email = $con->real_escape_string($data['email']);
            $password = $data['password'];
        }
        
        // Basic validation
        if (empty($email) || empty($password)) {
            $response["message"] = "Email and password are required";
        } else {
            // Query the database
            $query = "SELECT * FROM users WHERE email = '$email' LIMIT 1";
            $result = $con->query($query);
            
            if ($result && $result->num_rows > 0) {
                $user = $result->fetch_assoc();
                
                // Verify password
                if (password_verify($password, $user['password'])) {
                    // Password matches
                    $response["success"] = true;
                    $response["message"] = "Login successful";
                    
                    // Remove password from data sent to client
                    unset($user['password']);
                    $response["data"] = $user;
                } else {
                    $response["message"] = "Invalid email or password";
                }
            } else {
                $response["message"] = "User not found";
            }
        }
    }
} catch (Exception $e) {
    $response["message"] = "Server error: " . $e->getMessage();
}

// Capture any unexpected output
$output = ob_get_clean();
if (!empty($output)) {
    $response["debug"] = "Unexpected output: " . $output;
}

// Send response back to client
echo json_encode($response);
?>