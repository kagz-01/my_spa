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
    "message" => "Starting fetching photos",
    "data" => [],
    "debug" => []
);

try {
    // Include database connection
    require 'connect.php';
    $response["debug"][] = "Database connection included";
    
    // Create photos table if it doesn't exist - prevents errors on first run
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
    
    // Get photos from the database, newest first
    $query = "SELECT * FROM user_photos ORDER BY date_time DESC LIMIT 20";
    $result = $con->query($query);
    
    if ($result) {
        $photos = [];
        
        while ($row = $result->fetch_assoc()) {
            // Calculate time ago
            $date_time = new DateTime($row['date_time']);
            $now = new DateTime();
            $interval = $now->diff($date_time);
            
            $time_ago = '';
            if ($interval->y > 0) {
                $time_ago = $interval->y . 'y ago';
            } elseif ($interval->m > 0) {
                $time_ago = $interval->m . 'm ago';
            } elseif ($interval->d > 0) {
                $time_ago = $interval->d . 'd ago';
            } elseif ($interval->h > 0) {
                $time_ago = $interval->h . 'h ago';
            } elseif ($interval->i > 0) {
                $time_ago = $interval->i . 'min ago';
            } else {
                $time_ago = 'Just now';
            }
            
            // Format the photo data
            $photos[] = array(
                'id' => $row['id'],
                'username' => $row['username'],
                'caption' => $row['caption'],
                'rating' => floatval($row['rating']),
                'image' => $row['image_path'],
                'likes' => intval($row['likes']),
                'timeAgo' => $time_ago,
                'date_time' => $row['date_time']
            );
        }
        
        $response["success"] = true;
        $response["message"] = "Photos fetched successfully";
        $response["data"] = $photos;
        $response["count"] = count($photos);
    } else {
        $response["message"] = "Error fetching photos: " . $con->error;
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