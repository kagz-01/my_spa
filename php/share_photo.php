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
    "message" => "Starting unified photo process",
    "data" => null,
    "debug" => [],
    "actions" => [],
    "errors" => []
];

try {
    // Connect to database
    require 'connect.php';
    $response["debug"][] = "Database connection established";

    // === PHASE 1: Ensure user_photos table exists ===
    $create_table_query = "CREATE TABLE IF NOT EXISTS user_photos (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NULL,
        username VARCHAR(255) NOT NULL,
        caption TEXT NOT NULL,
        rating FLOAT DEFAULT 5.0,
        image_path VARCHAR(255),
        likes INT DEFAULT 0,
        date_time DATETIME NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )";

    if ($con->query($create_table_query)) {
        $response["actions"][] = "user_photos table created or already exists";
    } else {
        throw new Exception("Failed to create user_photos table: " . $con->error);
    }

    // === PHASE 2: Add user_id column if missing and populate ===
    $check_column = "SHOW COLUMNS FROM user_photos LIKE 'user_id'";
    $column_exists = $con->query($check_column);

    if ($column_exists && $column_exists->num_rows == 0) {
        $add_column = "ALTER TABLE user_photos ADD COLUMN user_id INT NULL AFTER id";
        if ($con->query($add_column)) {
            $response["actions"][] = "Added user_id column to user_photos";

            $users = $con->query("SELECT user_id, username FROM users");
            if ($users && $users->num_rows > 0) {
                $usermap = [];
                while ($user = $users->fetch_assoc()) {
                    $usermap[$user['username']] = $user['user_id'];
                }

                $update_count = 0;
                foreach ($usermap as $username => $userid) {
                    $update_query = "UPDATE user_photos SET user_id = $userid WHERE username = '$username'";
                    if ($con->query($update_query)) {
                        $affected = $con->affected_rows;
                        if ($affected > 0) $update_count += $affected;
                    }
                }

                $response["actions"][] = "Updated $update_count existing records with user_id";

                $null_check = $con->query("SELECT COUNT(*) as count FROM user_photos WHERE user_id IS NULL");
                $null_count = $null_check->fetch_assoc()['count'];
                if ($null_count == 0) {
                    $make_not_null = "ALTER TABLE user_photos MODIFY COLUMN user_id INT NOT NULL";
                    if ($con->query($make_not_null)) {
                        $response["actions"][] = "user_id column changed to NOT NULL";
                    } else {
                        $response["errors"][] = "Failed to enforce NOT NULL: " . $con->error;
                    }
                } else {
                    $response["actions"][] = "$null_count records still have NULL user_id";
                }
            } else {
                $response["errors"][] = "No users found to map for user_id update";
            }
        } else {
            $response["errors"][] = "Error adding user_id column: " . $con->error;
        }
    } else {
        $response["actions"][] = "user_id column already exists";
    }

    // === PHASE 3: Add foreign key constraint (optional) ===
    $add_fk = "ALTER TABLE user_photos 
               ADD CONSTRAINT fk_user_photos_users
               FOREIGN KEY (user_id) REFERENCES users(user_id)
               ON DELETE CASCADE ON UPDATE CASCADE";
    if ($con->query($add_fk)) {
        $response["actions"][] = "Foreign key constraint added to user_photos";
    } else {
        $response["errors"][] = "Foreign key might already exist or failed: " . $con->error;
    }

    // === PHASE 4: Handle upload request ===
    $input = file_get_contents('php://input');
    $response["debug"][] = "Raw input: $input";

    $data = json_decode($input, true);
    $response["debug"][] = "Parsed input: " . json_encode($data);

    if ($data && isset($data['caption']) && isset($data['user_id'])) {
        $username = isset($data['username']) && !empty($data['username']) ? 
            $con->real_escape_string($data['username']) : 'User';
        $user_id = intval($data['user_id']);
        $caption = $con->real_escape_string($data['caption']);
        $rating = isset($data['rating']) ? floatval($data['rating']) : 5.0;
        $image_path = isset($data['image_name']) ? $con->real_escape_string($data['image_name']) : 'default_image.jpg';
        $date_time = date('Y-m-d H:i:s');

        $insert_query = "INSERT INTO user_photos (user_id, username, caption, rating, image_path, date_time)
                         VALUES ($user_id, '$username', '$caption', $rating, '$image_path', '$date_time')";

        if ($con->query($insert_query)) {
            $response["success"] = true;
            $response["message"] = "Photo shared successfully";
            $response["data"] = [
                "id" => $con->insert_id,
                "user_id" => $user_id,
                "username" => $username,
                "caption" => $caption,
                "rating" => $rating,
                "image_path" => $image_path,
                "date_time" => $date_time
            ];
        } else {
            $response["message"] = "Failed to insert photo: " . $con->error;
            $response["debug"][] = "Query error: " . $con->error;
        }
    } else {
        $response["message"] = "Missing required fields: caption and user_id";
        $response["debug"][] = "Input validation failed";
    }

} catch (Exception $e) {
    $response["success"] = false;
    $response["message"] = "Exception occurred: " . $e->getMessage();
    $response["errors"][] = $e->getMessage();
}

// Handle unexpected output
$output = ob_get_clean();
if (!empty($output)) {
    $response["debug"][] = "Unexpected output: " . $output;
}

// Send final JSON response
echo json_encode($response, JSON_PRETTY_PRINT);
?>
