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
    "message" => "Starting photo upload process",
    "data" => null,
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
    
    // Check if request contains required fields
    if ($data && isset($data['username']) && isset($data['caption'])) {
        $username = $con->real_escape_string($data['username']);
        $caption = $con->real_escape_string($data['caption']);
        $rating = isset($data['rating']) ? floatval($data['rating']) : 5.0;
        $image_path = isset($data['image_name']) ? $con->real_escape_string($data['image_name']) : 'default_image.jpg';
        $date_time = date('Y-m-d H:i:s'); // Current server time
        
        $response["debug"][] = "Data validated";
        
        // Create photos table if it doesn't exist
        $create_table_query = "CREATE TABLE IF NOT EXISTS user_photos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(255) NOT NULL,
            caption TEXT NOT NULL,
            rating FLOAT DEFAULT 5.0,
            image_path VARCHAR(255),
            likes INT DEFAULT 0,
            date_time DATETIME NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )";
        
        if (!$con->query($create_table_query)) {
            throw new Exception("Failed to create table: " . $con->error);
        }
        
        $response["debug"][] = "Table checked/created";
        
        // Insert photo data
        $insert_query = "INSERT INTO user_photos (username, caption, rating, image_path, date_time) 
                         VALUES ('$username', '$caption', $rating, '$image_path', '$date_time')";
        
        if ($con->query($insert_query)) {
            $photo_id = $con->insert_id;
            $response["success"] = true;
            $response["message"] = "Photo shared successfully";
            $response["data"] = array(
                "id" => $photo_id,
                "username" => $username,
                "caption" => $caption,
                "rating" => $rating,
                "image_path" => $image_path,
                "date_time" => $date_time
            );
            $response["debug"][] = "Photo record created successfully";
        } else {
            $response["message"] = "Database error: " . $con->error;
            $response["debug"][] = "Query failed: " . $con->error;
        }
    } else {
        $response["message"] = "Missing required fields";
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

// Send response back to client
echo json_encode($response);
?>