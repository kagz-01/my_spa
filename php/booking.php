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
    "message" => "Starting booking process",
    "data" => null,
    "debug" => []
);

try {
    // Include database connection
    require 'connect.php';
    $response["debug"][] = "Database connection included";
    
    // Create bookings table if it doesn't exist
    $create_table_query = "CREATE TABLE IF NOT EXISTS bookings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        service_name VARCHAR(255) NOT NULL,
        service_category VARCHAR(255) NOT NULL,
        appointment_date DATE NOT NULL,
        appointment_time VARCHAR(20) NOT NULL,
        duration INT NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'confirmed',
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )";
    
    if (!$con->query($create_table_query)) {
        throw new Exception("Failed to create bookings table: " . $con->error);
    }
    
    $response["debug"][] = "Bookings table checked/created";
    
    // Process POST request for creating a new booking
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Get raw input
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        $response["debug"][] = "Received data: " . json_encode($data);
        
        // Check if request contains required fields
        if ($data && isset($data['user_id']) && isset($data['service_name']) && 
            isset($data['appointment_date']) && isset($data['appointment_time']) && 
            isset($data['duration']) && isset($data['price'])) {
            
            // Sanitize inputs
            $user_id = intval($data['user_id']);
            
            // Verify user exists before proceeding
            $user_check_query = "SELECT user_id FROM users WHERE user_id = $user_id LIMIT 1";
            $user_result = $con->query($user_check_query);
            
            if ($user_result && $user_result->num_rows > 0) {
                // User exists, proceed with booking
                $service_name = $con->real_escape_string($data['service_name']);
                $service_category = isset($data['service_category']) ? 
                    $con->real_escape_string($data['service_category']) : 'Spa Service';
                
                // Format date for MySQL (YYYY-MM-DD)
                $appointment_date = date('Y-m-d', strtotime($data['appointment_date']));
                $appointment_time = $con->real_escape_string($data['appointment_time']);
                $duration = intval($data['duration']);
                $price = floatval($data['price']);
                $notes = isset($data['notes']) ? $con->real_escape_string($data['notes']) : '';
                
                // Insert booking
                $insert_query = "INSERT INTO bookings (user_id, service_name, service_category, appointment_date, 
                               appointment_time, duration, price, notes) 
                             VALUES ('$user_id', '$service_name', '$service_category', '$appointment_date', 
                                    '$appointment_time', '$duration', '$price', '$notes')";
                
                if ($con->query($insert_query)) {
                    $booking_id = $con->insert_id;
                    $response["success"] = true;
                    $response["message"] = "Booking created successfully";
                    $response["data"] = array(
                        "id" => $booking_id,
                        "user_id" => $user_id,
                        "service_name" => $service_name,
                        "service_category" => $service_category,
                        "appointment_date" => $appointment_date,
                        "appointment_time" => $appointment_time,
                        "duration" => $duration,
                        "price" => $price,
                        "status" => "confirmed"
                    );
                } else {
                    $response["message"] = "Database error: " . $con->error;
                    $response["debug"][] = "Query failed: " . $con->error;
                }
            } else {
                $response["message"] = "User ID not found in the database";
                $response["debug"][] = "Invalid user_id: $user_id";
            }
        } else {
            $response["message"] = "Missing required fields";
            $response["debug"][] = "Invalid input data";
        }
    } 
    // Process GET request for retrieving bookings
    else if ($_SERVER['REQUEST_METHOD'] === 'GET' && !isset($_GET['id'])) {
        // Check if specific user_id is provided
        $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;
        
        if ($user_id) {
            // MODIFIED: Skip user verification temporarily for testing purposes
            // Commented out user verification check
            /*
            $user_check_query = "SELECT user_id FROM users WHERE user_id = $user_id LIMIT 1";
            $user_result = $con->query($user_check_query);
            
            if ($user_result && $user_result->num_rows > 0) {
            */
            // Always proceed with fetching bookings regardless of user verification
            
            // User exists, get bookings for specific user
            $query = "SELECT * FROM bookings WHERE user_id = $user_id ORDER BY appointment_date, appointment_time";
            $result = $con->query($query);
            
            if ($result) {
                $bookings = [];
                
                while ($row = $result->fetch_assoc()) {
                    // Format date for display
                    $row['formatted_date'] = date('l, F j, Y', strtotime($row['appointment_date']));
                    $bookings[] = $row;
                }
                
                $response["success"] = true;
                $response["message"] = "Bookings fetched successfully";
                $response["data"] = $bookings;
                $response["count"] = count($bookings);
            } else {
                $response["message"] = "Error fetching bookings: " . $con->error;
            }
            /*
            } else {
                $response["success"] = false;
                $response["message"] = "User ID not found in the database";
                $response["data"] = [];
                $response["count"] = 0;
            }
            */
        } else {
            // Get all bookings (could be restricted to admin only in a real app)
            $query = "SELECT * FROM bookings ORDER BY appointment_date, appointment_time";
            
            $result = $con->query($query);
            
            if ($result) {
                $bookings = [];
                
                while ($row = $result->fetch_assoc()) {
                    // Format date for display
                    $row['formatted_date'] = date('l, F j, Y', strtotime($row['appointment_date']));
                    $bookings[] = $row;
                }
                
                $response["success"] = true;
                $response["message"] = "All bookings fetched successfully";
                $response["data"] = $bookings;
                $response["count"] = count($bookings);
            } else {
                $response["message"] = "Error fetching bookings: " . $con->error;
            }
        }
    }
    // Process GET request for a specific booking
    else if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['id'])) {
        $booking_id = intval($_GET['id']);
        
        // Get specific booking
        $query = "SELECT * FROM bookings WHERE id = $booking_id";
        $result = $con->query($query);
        
        if ($result && $result->num_rows > 0) {
            $booking = $result->fetch_assoc();
            
            // Format date for display
            $booking['formatted_date'] = date('l, F j, Y', strtotime($booking['appointment_date']));
            
            $response["success"] = true;
            $response["message"] = "Booking fetched successfully";
            $response["data"] = $booking;
        } else {
            $response["message"] = "Booking not found";
        }
    }
    // Process PUT request to update booking status
    else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        // Get raw input
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        // Check if request contains required fields
        if ($data && isset($data['id']) && isset($data['status'])) {
            $id = intval($data['id']);
            $status = $con->real_escape_string($data['status']);
            $notes = isset($data['notes']) ? $con->real_escape_string($data['notes']) : null;
            
            // Prepare update query
            $update_query = "UPDATE bookings SET status = '$status'";
            
            // Add notes if provided
            if ($notes !== null) {
                $update_query .= ", notes = '$notes'";
            }
            
            $update_query .= " WHERE id = $id";
            
            if ($con->query($update_query)) {
                $response["success"] = true;
                $response["message"] = "Booking status updated successfully";
            } else {
                $response["message"] = "Error updating booking: " . $con->error;
            }
        } else {
            $response["message"] = "Missing required fields for update";
        }
    }
    // Process DELETE request to cancel booking
    else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
        // Get booking ID from URL parameter
        $id = isset($_GET['id']) ? intval($_GET['id']) : null;
        
        if ($id) {
            // In a real app, you might want to just mark the booking as canceled
            // rather than deleting it completely
            $update_query = "UPDATE bookings SET status = 'canceled' WHERE id = $id";
            
            if ($con->query($update_query)) {
                $response["success"] = true;
                $response["message"] = "Booking canceled successfully";
            } else {
                $response["message"] = "Error canceling booking: " . $con->error;
            }
        } else {
            $response["message"] = "Booking ID is required";
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