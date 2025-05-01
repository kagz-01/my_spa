<?php
// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// JSON response header
header('Content-Type: application/json');

// Start output buffering
ob_start();

// Initialize response
$response = [
    "success" => false,
    "message" => "Starting photo sharing process",
    "data" => null,
    "debug" => []
];

try {
    // Connect to database
    require 'connect.php';
    $response["debug"][] = "Database connection included";

    // Create photos table if it doesn't exist
    $create_table_query = "CREATE TABLE IF NOT EXISTS user_photos (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
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

    // Process the request based on content type
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Get server document root path for absolute paths
        $server_path = dirname(dirname($_SERVER['SCRIPT_FILENAME']));
        $response["debug"][] = "Server path: $server_path";

        // Handle multipart form data upload
        if (!empty($_FILES) && isset($_FILES['image'])) {
            $response["debug"][] = "Processing multipart form data";
            $response["debug"][] = "Files data: " . json_encode($_FILES);
            $response["debug"][] = "Post data: " . json_encode($_POST);
            
            // Get form data
            $username = isset($_POST['username']) ? $con->real_escape_string($_POST['username']) : '';
            $user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
            $caption = isset($_POST['caption']) ? $con->real_escape_string($_POST['caption']) : '';
            $rating = isset($_POST['rating']) ? floatval($_POST['rating']) : 5.0;
            
            $response["debug"][] = "Form data: username=$username, user_id=$user_id, caption=$caption, rating=$rating";
            
            // Validate required fields
            if (empty($username) || empty($caption) || $user_id <= 0) {
                throw new Exception("Invalid input data. Required fields: username, caption, user_id");
            }
            
            // Handle file upload
            if ($_FILES['image']['error'] === UPLOAD_ERR_OK) {
                // Use absolute path for uploads directory
                $upload_dir = $server_path . '/uploads/photos/';
                if (!is_dir($upload_dir)) {
                    // Try to create directory with proper permissions
                    if (!@mkdir($upload_dir, 0777, true)) {
                        $response["debug"][] = "Failed to create directory: $upload_dir";
                        // Fall back to using existing directory
                        $upload_dir = $server_path . '/uploads/';
                        if (!is_dir($upload_dir)) {
                            if (!@mkdir($upload_dir, 0777, true)) {
                                throw new Exception("Cannot create upload directory. Please create it manually.");
                            }
                        }
                    }
                }
                
                // Generate unique filename
                $file_extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
                $filename = 'photo_' . time() . '_' . uniqid() . '.' . $file_extension;
                $file_path = $upload_dir . $filename;
                
                // Move the uploaded file
                if (move_uploaded_file($_FILES['image']['tmp_name'], $file_path)) {
                    $response["debug"][] = "File uploaded successfully to $file_path";
                    // Store path relative to web root for database
                    $db_image_path = 'uploads/photos/' . $filename;
                } else {
                    $error = error_get_last();
                    $response["debug"][] = "Error: " . ($error ? json_encode($error) : "Unknown error");
                    throw new Exception("Failed to move uploaded file. Error: " . ($error ? $error['message'] : "Unknown"));
                }
            } else {
                throw new Exception("File upload error: " . $_FILES['image']['error']);
            }
        } 
        // Handle JSON request
        else {
            $input = file_get_contents('php://input');
            $response["debug"][] = "Raw input: $input";
            
            $data = json_decode($input, true);
            $response["debug"][] = "Parsed input: " . json_encode($data);
            
            if (!$data) {
                throw new Exception("Invalid input data. Required fields: username, caption, user_id");
            }
            
            // Extract data from JSON
            $username = isset($data['username']) ? $con->real_escape_string($data['username']) : '';
            $user_id = isset($data['user_id']) ? intval($data['user_id']) : 0;
            $caption = isset($data['caption']) ? $con->real_escape_string($data['caption']) : '';
            $rating = isset($data['rating']) ? floatval($data['rating']) : 5.0;
            
            // For backward compatibility, if image_name is provided
            if (isset($data['image_name'])) {
                $db_image_path = $con->real_escape_string($data['image_name']);
            } else {
                $db_image_path = 'default_image.jpg';
            }
        }
        
        $response["debug"][] = "Data validated";
        
        // Insert photo data into the database
        $date_time = date('Y-m-d H:i:s');
        $insert_query = "INSERT INTO user_photos (user_id, username, caption, rating, image_path, date_time) 
                        VALUES ($user_id, '$username', '$caption', $rating, '$db_image_path', '$date_time')";
        
        if ($con->query($insert_query)) {
            $response["debug"][] = "Photo record created successfully";
            $response["success"] = true;
            $response["message"] = "Photo shared successfully";
            $response["data"] = [
                "id" => $con->insert_id,
                "user_id" => $user_id,
                "username" => $username,
                "caption" => $caption,
                "rating" => $rating,
                "image_path" => $db_image_path,
                "date_time" => $date_time
            ];
        } else {
            throw new Exception("Database error: " . $con->error);
        }
    } else {
        throw new Exception("Invalid request method. Use POST to share photos.");
    }
} catch (Exception $e) {
    $response["success"] = false;
    $response["message"] = $e->getMessage();
    $response["debug"][] = "Exception: " . $e->getMessage();
}

// Capture any unexpected output
$output = ob_get_clean();
if (!empty($output)) {
    $response["debug"][] = "Unexpected output: " . $output;
}

// Send the JSON response
echo json_encode($response);
?>
