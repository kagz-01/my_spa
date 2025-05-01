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
    "message" => "Starting profile operation",
    "data" => null,
    "debug" => []
);

try {
    // Include database connection
    require 'connect.php';
    $response["debug"][] = "Database connection established";
    
    // Process GET request for retrieving user profile
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Get user ID from request
        $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;
        
        if ($user_id) {
            // Fetch user data
            $query = "SELECT user_id, username, email, phone, bio, profile_image FROM users WHERE user_id = $user_id LIMIT 1";
            $result = $con->query($query);
            
            if ($result && $result->num_rows > 0) {
                $user = $result->fetch_assoc();
                
                $response["success"] = true;
                $response["message"] = "Profile fetched successfully";
                $response["data"] = $user;
            } else {
                $response["message"] = "User not found";
            }
        } else {
            $response["message"] = "User ID is required";
        }
    }
    // Process PUT request for updating user profile
    else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        // Get raw input
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        $response["debug"][] = "Received data: " . json_encode($data);
        
        // Check if request contains required fields
        if ($data && isset($data['user_id'])) {
            // Sanitize inputs
            $user_id = intval($data['user_id']);
            
            // Prepare update query
            $update_query = "UPDATE users SET ";
            $updates = array();
            
            // Update fields that are provided
            if (isset($data['username'])) {
                $username = $con->real_escape_string($data['username']);
                $updates[] = "username = '$username'";
            }
            
            if (isset($data['email'])) {
                $email = $con->real_escape_string($data['email']);
                $updates[] = "email = '$email'";
            }
            
            if (isset($data['phone'])) {
                $phone = $con->real_escape_string($data['phone']);
                $updates[] = "phone = '$phone'";
            }
            
            if (isset($data['bio'])) {
                $bio = $con->real_escape_string($data['bio']);
                $updates[] = "bio = '$bio'";
            }
            
            if (isset($data['profile_image'])) {
                $profile_image = $con->real_escape_string($data['profile_image']);
                $updates[] = "profile_image = '$profile_image'";
            }
            
            // If there are fields to update
            if (count($updates) > 0) {
                $update_query .= implode(", ", $updates);
                $update_query .= " WHERE user_id = $user_id";
                
                if ($con->query($update_query)) {
                    $response["success"] = true;
                    $response["message"] = "Profile updated successfully";
                    
                    // Fetch updated user data
                    $fetch_query = "SELECT user_id, username, email, phone, bio, profile_image FROM users WHERE user_id = $user_id LIMIT 1";
                    $result = $con->query($fetch_query);
                    
                    if ($result && $result->num_rows > 0) {
                        $user = $result->fetch_assoc();
                        $response["data"] = $user;
                    }
                } else {
                    $response["message"] = "Error updating profile: " . $con->error;
                }
            } else {
                $response["message"] = "No fields to update";
            }
        } else {
            $response["message"] = "User ID is required";
        }
    }
    // Process POST request for uploading profile image
    else if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_GET['upload_image'])) {
        // Check if user_id is provided
        $user_id = isset($_POST['user_id']) ? intval($_POST['user_id']) : null;
        
        if ($user_id && isset($_FILES['image'])) {
            $response["debug"][] = "Received profile image upload request for user: " . $user_id;
            $response["debug"][] = "File details: " . json_encode($_FILES['image']);
            
            // Create uploads directory if it doesn't exist
            $upload_dir = '../uploads/profile/';
            if (!file_exists($upload_dir)) {
                if (!mkdir($upload_dir, 0777, true)) {
                    throw new Exception("Failed to create profile upload directory");
                }
                chmod($upload_dir, 0777);
                $response["debug"][] = "Created profile upload directory: $upload_dir";
            }
            
            // Validate file
            if ($_FILES['image']['error'] !== UPLOAD_ERR_OK) {
                throw new Exception("File upload error code: " . $_FILES['image']['error']);
            }
            
            // Generate unique filename
            $file_extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
            $file_name = 'profile_' . $user_id . '_' . time() . '.' . $file_extension;
            $file_path = $upload_dir . $file_name;
            
            // Move uploaded file
            if (move_uploaded_file($_FILES['image']['tmp_name'], $file_path)) {
                $response["debug"][] = "File moved to $file_path";
                
                // Update user profile with new image
                $image_path = 'uploads/profile/' . $file_name;
                $update_query = "UPDATE users SET profile_image = '$image_path' WHERE user_id = $user_id";
                
                if ($con->query($update_query)) {
                    $response["success"] = true;
                    $response["message"] = "Profile image uploaded successfully";
                    $response["data"] = array("profile_image" => $image_path);
                } else {
                    throw new Exception("Error updating profile image in database: " . $con->error);
                }
            } else {
                throw new Exception("Failed to move uploaded file. Check directory permissions.");
            }
        } else {
            $response["message"] = "User ID and image file are required";
            $response["debug"][] = "Missing user_id or image file";
        }
    }
    // Process POST request for changing password
    else if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_GET['change_password'])) {
        // Get raw input
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        // Check if request contains required fields
        if ($data && isset($data['user_id']) && isset($data['current_password']) && isset($data['new_password'])) {
            $user_id = intval($data['user_id']);
            $current_password = $data['current_password'];
            $new_password = $data['new_password'];
            
            // Verify current password
            $query = "SELECT password FROM users WHERE user_id = $user_id LIMIT 1";
            $result = $con->query($query);
            
            if ($result && $result->num_rows > 0) {
                $user = $result->fetch_assoc();
                
                if (password_verify($current_password, $user['password'])) {
                    // Current password is correct, update with new password
                    $hashed_password = password_hash($new_password, PASSWORD_DEFAULT);
                    $update_query = "UPDATE users SET password = '$hashed_password' WHERE user_id = $user_id";
                    
                    if ($con->query($update_query)) {
                        $response["success"] = true;
                        $response["message"] = "Password changed successfully";
                    } else {
                        $response["message"] = "Error updating password: " . $con->error;
                    }
                } else {
                    $response["message"] = "Current password is incorrect";
                }
            } else {
                $response["message"] = "User not found";
            }
        } else {
            $response["message"] = "Missing required fields for password change";
        }
    } else {
        $response["message"] = "Invalid request method";
    }
    
    // Add column to users table if it doesn't exist
    // This ensures older database installations are upgraded
    $columns_to_add = array(
        "phone" => "VARCHAR(20) DEFAULT NULL",
        "bio" => "TEXT DEFAULT NULL",
        "profile_image" => "VARCHAR(255) DEFAULT NULL"
    );
    
    foreach ($columns_to_add as $column => $definition) {
        // Check if column exists
        $check_column = $con->query("SHOW COLUMNS FROM users LIKE '$column'");
        if ($check_column->num_rows == 0) {
            // Add column if it doesn't exist
            $alter_query = "ALTER TABLE users ADD $column $definition";
            $con->query($alter_query);
            $response["debug"][] = "Added column $column to users table";
        }
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