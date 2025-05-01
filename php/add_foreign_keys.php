<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set content type
header('Content-Type: application/json');

// Initialize response
$response = array(
    "success" => false,
    "message" => "Starting database constraints update",
    "actions" => [],
    "errors" => []
);

try {
    // Include database connection
    require 'connect.php';
    $response["actions"][] = "Database connection established";
    
    // Function to check if constraint already exists
    function constraintExists($con, $tableName, $constraintName) {
        $query = "SELECT COUNT(*) as count FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE CONSTRAINT_SCHEMA = DATABASE() 
                  AND TABLE_NAME = '$tableName' 
                  AND CONSTRAINT_NAME = '$constraintName'";
        $result = $con->query($query);
        if ($result && $result->num_rows > 0) {
            return $result->fetch_assoc()['count'] > 0;
        }
        return false;
    }
    
    // Step 1: Check if users table has user_id as primary key
    $check_users_query = "SHOW KEYS FROM users WHERE Key_name = 'PRIMARY'";
    $result = $con->query($check_users_query);
    
    if ($result) {
        $row = $result->fetch_assoc();
        if ($row && $row['Column_name'] === 'user_id') {
            $response["actions"][] = "Confirmed users table has user_id as primary key";
        } else {
            // If primary key is not user_id, we need to rename it
            $response["actions"][] = "Users table does not have user_id as primary key. Will attempt to rename.";
            
            // Dropping existing foreign keys if they exist (to avoid constraint issues)
            $con->query("ALTER TABLE bookings DROP FOREIGN KEY IF EXISTS fk_bookings_users");
            $con->query("ALTER TABLE cart_items DROP FOREIGN KEY IF EXISTS fk_cart_items_users");
            $con->query("ALTER TABLE orders DROP FOREIGN KEY IF EXISTS fk_orders_users");
            $con->query("ALTER TABLE user_photos DROP FOREIGN KEY IF EXISTS fk_user_photos_users");
            $response["actions"][] = "Dropped any existing foreign key constraints";
            
            // Rename primary key column from id to user_id if needed
            $check_id_exists = "SHOW COLUMNS FROM users LIKE 'id'";
            $id_result = $con->query($check_id_exists);
            
            if ($id_result && $id_result->num_rows > 0) {
                // id column exists, rename it to user_id
                $rename_query = "ALTER TABLE users CHANGE COLUMN id user_id INT AUTO_INCREMENT";
                
                if ($con->query($rename_query)) {
                    $response["actions"][] = "Renamed 'id' column to 'user_id' in users table";
                } else {
                    throw new Exception("Failed to rename id column: " . $con->error);
                }
            }
        }
    } else {
        throw new Exception("Error checking users table primary key: " . $con->error);
    }
    
    // Step 2: Add foreign key constraint to bookings table
    if (!constraintExists($con, 'bookings', 'fk_bookings_users')) {
        $alter_bookings_query = "ALTER TABLE bookings
                                ADD CONSTRAINT fk_bookings_users
                                FOREIGN KEY (user_id) 
                                REFERENCES users(user_id)
                                ON DELETE RESTRICT
                                ON UPDATE CASCADE";
        
        if ($con->query($alter_bookings_query)) {
            $response["actions"][] = "Added foreign key constraint to bookings table";
        } else {
            $response["errors"][] = "Failed to add constraint to bookings table: " . $con->error;
        }
    } else {
        $response["actions"][] = "Foreign key constraint already exists on bookings table";
    }
    
    // Step 3: Add foreign key constraint to cart_items table
    if (!constraintExists($con, 'cart_items', 'fk_cart_items_users')) {
        $alter_cart_query = "ALTER TABLE cart_items
                            ADD CONSTRAINT fk_cart_items_users
                            FOREIGN KEY (user_id) 
                            REFERENCES users(user_id)
                            ON DELETE RESTRICT
                            ON UPDATE CASCADE";
        
        if ($con->query($alter_cart_query)) {
            $response["actions"][] = "Added foreign key constraint to cart_items table";
        } else {
            $response["errors"][] = "Failed to add constraint to cart_items table: " . $con->error;
        }
    } else {
        $response["actions"][] = "Foreign key constraint already exists on cart_items table";
    }
    
    // Step 4: Add foreign key constraint to orders table
    if (!constraintExists($con, 'orders', 'fk_orders_users')) {
        $alter_orders_query = "ALTER TABLE orders
                              ADD CONSTRAINT fk_orders_users
                              FOREIGN KEY (user_id) 
                              REFERENCES users(user_id)
                              ON DELETE RESTRICT
                              ON UPDATE CASCADE";
        
        if ($con->query($alter_orders_query)) {
            $response["actions"][] = "Added foreign key constraint to orders table";
        } else {
            $response["errors"][] = "Failed to add constraint to orders table: " . $con->error;
        }
    } else {
        $response["actions"][] = "Foreign key constraint already exists on orders table";
    }
    
    // Step 5: Add foreign key constraint to order_items table to reference orders
    if (!constraintExists($con, 'order_items', 'fk_order_items_orders')) {
        $alter_order_items_query = "ALTER TABLE order_items
                                   ADD CONSTRAINT fk_order_items_orders
                                   FOREIGN KEY (order_id) 
                                   REFERENCES orders(id)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE";
        
        if ($con->query($alter_order_items_query)) {
            $response["actions"][] = "Added foreign key constraint to order_items table";
        } else {
            $response["errors"][] = "Failed to add constraint to order_items table: " . $con->error;
        }
    } else {
        $response["actions"][] = "Foreign key constraint already exists on order_items table";
    }
    
    // Step 6: Check if user_photos table exists and add constraint if needed
    $check_photos_table = "SHOW TABLES LIKE 'user_photos'";
    $photos_table_result = $con->query($check_photos_table);
    
    if ($photos_table_result && $photos_table_result->num_rows > 0) {
        if (!constraintExists($con, 'user_photos', 'fk_user_photos_users')) {
            $alter_photos_query = "ALTER TABLE user_photos
                                  ADD CONSTRAINT fk_user_photos_users
                                  FOREIGN KEY (user_id) 
                                  REFERENCES users(user_id)
                                  ON DELETE CASCADE
                                  ON UPDATE CASCADE";
            
            if ($con->query($alter_photos_query)) {
                $response["actions"][] = "Added foreign key constraint to user_photos table";
            } else {
                $response["errors"][] = "Failed to add constraint to user_photos table: " . $con->error;
            }
        } else {
            $response["actions"][] = "Foreign key constraint already exists on user_photos table";
        }
    } else {
        $response["actions"][] = "user_photos table not found, skipping constraint";
    }
    
    // Check if there were any errors during constraint creation
    if (empty($response["errors"])) {
        $response["success"] = true;
        $response["message"] = "Foreign key constraints added or verified successfully";
    } else {
        $response["message"] = "Some errors occurred during constraint creation";
    }
    
} catch (Exception $e) {
    $response["success"] = false;
    $response["message"] = "Error: " . $e->getMessage();
    $response["errors"][] = $e->getMessage();
}

// Output the response
echo json_encode($response, JSON_PRETTY_PRINT);
?>