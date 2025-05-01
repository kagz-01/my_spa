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
    "message" => "Starting cart process",
    "data" => null,
    "debug" => []
);

try {
    // Include database connection
    require 'connect.php';
    $response["debug"][] = "Database connection included";
    
    // Create cart_items table if it doesn't exist
    $create_table_query = "CREATE TABLE IF NOT EXISTS cart_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        product_name VARCHAR(255) NOT NULL,
        product_category VARCHAR(255) NOT NULL,
        quantity INT NOT NULL DEFAULT 1,
        price DECIMAL(10,2) NOT NULL,
        image_path VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )";
    
    if (!$con->query($create_table_query)) {
        throw new Exception("Failed to create cart_items table: " . $con->error);
    }
    
    $response["debug"][] = "Cart items table checked/created";
    
    // Process POST request for adding item to cart
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Get raw input
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        $response["debug"][] = "Received data: " . json_encode($data);
        
        // Check if request contains required fields
        if ($data && isset($data['user_id']) && isset($data['product_name']) && 
            isset($data['price']) && isset($data['quantity'])) {
            
            // Sanitize user_id
            $user_id = intval($data['user_id']);
            
            // Verify user exists before proceeding
            $user_check_query = "SELECT user_id FROM users WHERE user_id = $user_id LIMIT 1";
            $user_result = $con->query($user_check_query);
            
            if ($user_result && $user_result->num_rows > 0) {
                // User exists, proceed with cart operations
                $product_name = $con->real_escape_string($data['product_name']);
                $product_category = isset($data['product_category']) ? 
                    $con->real_escape_string($data['product_category']) : 'Spa Product';
                $quantity = intval($data['quantity']);
                $price = floatval($data['price']);
                $image_path = isset($data['image_path']) ? $con->real_escape_string($data['image_path']) : null;
                
                // Check if the product is already in the cart for this user
                $check_query = "SELECT * FROM cart_items WHERE user_id = $user_id AND product_name = '$product_name'";
                $result = $con->query($check_query);
                
                if ($result && $result->num_rows > 0) {
                    // Product already in cart, update quantity
                    $item = $result->fetch_assoc();
                    $new_quantity = $item['quantity'] + $quantity;
                    
                    $update_query = "UPDATE cart_items SET quantity = $new_quantity, updated_at = NOW() WHERE id = {$item['id']}";
                    
                    if ($con->query($update_query)) {
                        $response["success"] = true;
                        $response["message"] = "Cart updated successfully";
                        $response["data"] = array(
                            "id" => $item['id'],
                            "user_id" => $user_id,
                            "product_name" => $product_name,
                            "quantity" => $new_quantity,
                            "price" => $price
                        );
                    } else {
                        $response["message"] = "Error updating cart: " . $con->error;
                    }
                } else {
                    // Product not in cart, add new item
                    $insert_query = "INSERT INTO cart_items (user_id, product_name, product_category, quantity, price, image_path) 
                                  VALUES ($user_id, '$product_name', '$product_category', $quantity, $price, '$image_path')";
                    
                    if ($con->query($insert_query)) {
                        $cart_item_id = $con->insert_id;
                        $response["success"] = true;
                        $response["message"] = "Item added to cart successfully";
                        $response["data"] = array(
                            "id" => $cart_item_id,
                            "user_id" => $user_id,
                            "product_name" => $product_name,
                            "product_category" => $product_category,
                            "quantity" => $quantity,
                            "price" => $price,
                            "image_path" => $image_path
                        );
                    } else {
                        $response["message"] = "Database error: " . $con->error;
                        $response["debug"][] = "Query failed: " . $con->error;
                    }
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
    // Process GET request for retrieving cart items
    else if ($_SERVER['REQUEST_METHOD'] === 'GET' && !isset($_GET['checkout'])) {
        // Check if specific user_id is provided
        $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;
        
        if ($user_id) {
            // First check if the user exists
            $user_check_query = "SELECT user_id FROM users WHERE user_id = $user_id LIMIT 1";
            $user_result = $con->query($user_check_query);
            
            if ($user_result && $user_result->num_rows > 0) {
                // User exists, proceed to get cart items
                $query = "SELECT * FROM cart_items WHERE user_id = $user_id";
                $result = $con->query($query);
                
                if ($result) {
                    $items = [];
                    $total_amount = 0;
                    
                    while ($row = $result->fetch_assoc()) {
                        $items[] = $row;
                        $total_amount += ($row['price'] * $row['quantity']);
                    }
                    
                    $response["success"] = true;
                    $response["message"] = "Cart items fetched successfully";
                    $response["data"] = array(
                        "items" => $items,
                        "count" => count($items),
                        "total_amount" => $total_amount
                    );
                } else {
                    $response["message"] = "Error fetching cart items: " . $con->error;
                }
            } else {
                $response["success"] = false;
                $response["message"] = "User ID not found in the database";
                $response["data"] = array(
                    "items" => [],
                    "count" => 0,
                    "total_amount" => 0
                );
            }
        } else {
            $response["message"] = "User ID is required to fetch cart items";
        }
    }
    // Process PUT request to update cart item quantity
    else if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        // Get raw input
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        // Check if request contains required fields
        if ($data && isset($data['id']) && isset($data['quantity'])) {
            $id = intval($data['id']);
            $quantity = intval($data['quantity']);
            
            if ($quantity > 0) {
                $update_query = "UPDATE cart_items SET quantity = $quantity, updated_at = NOW() WHERE id = $id";
                
                if ($con->query($update_query)) {
                    $response["success"] = true;
                    $response["message"] = "Cart item updated successfully";
                } else {
                    $response["message"] = "Error updating cart item: " . $con->error;
                }
            } else {
                // If quantity is 0 or negative, remove the item
                $delete_query = "DELETE FROM cart_items WHERE id = $id";
                
                if ($con->query($delete_query)) {
                    $response["success"] = true;
                    $response["message"] = "Item removed from cart successfully";
                } else {
                    $response["message"] = "Error removing cart item: " . $con->error;
                }
            }
        } else {
            $response["message"] = "Missing required fields for update";
        }
    }
    // Process DELETE request to remove item from cart
    else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
        // Get item ID from URL parameter
        $id = isset($_GET['id']) ? intval($_GET['id']) : null;
        
        if ($id) {
            $delete_query = "DELETE FROM cart_items WHERE id = $id";
            
            if ($con->query($delete_query)) {
                $response["success"] = true;
                $response["message"] = "Item removed from cart successfully";
            } else {
                $response["message"] = "Error removing item from cart: " . $con->error;
            }
        } else {
            $response["message"] = "Item ID is required";
        }
    }
    // Process checkout
    else if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['checkout'])) {
        $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;
        
        if ($user_id) {
            // Create orders table if it doesn't exist
            $create_orders_table = "CREATE TABLE IF NOT EXISTS orders (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                total_amount DECIMAL(10,2) NOT NULL,
                status VARCHAR(20) DEFAULT 'pending',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )";
            
            if (!$con->query($create_orders_table)) {
                throw new Exception("Failed to create orders table: " . $con->error);
            }
            
            // Create order_items table if it doesn't exist
            $create_order_items_table = "CREATE TABLE IF NOT EXISTS order_items (
                id INT AUTO_INCREMENT PRIMARY KEY,
                order_id INT NOT NULL,
                product_name VARCHAR(255) NOT NULL,
                product_category VARCHAR(255) NOT NULL,
                quantity INT NOT NULL,
                price DECIMAL(10,2) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )";
            
            if (!$con->query($create_order_items_table)) {
                throw new Exception("Failed to create order_items table: " . $con->error);
            }
            
            // Get cart items for the user
            $query = "SELECT * FROM cart_items WHERE user_id = $user_id";
            $result = $con->query($query);
            
            if ($result && $result->num_rows > 0) {
                $total_amount = 0;
                $cart_items = [];
                
                while ($row = $result->fetch_assoc()) {
                    $cart_items[] = $row;
                    $total_amount += ($row['price'] * $row['quantity']);
                }
                
                // Begin transaction
                $con->begin_transaction();
                
                try {
                    // Create order
                    $create_order = "INSERT INTO orders (user_id, total_amount) VALUES ($user_id, $total_amount)";
                    $con->query($create_order);
                    $order_id = $con->insert_id;
                    
                    // Insert order items
                    foreach ($cart_items as $item) {
                        $product_name = $con->real_escape_string($item['product_name']);
                        $product_category = $con->real_escape_string($item['product_category']);
                        $quantity = intval($item['quantity']);
                        $price = floatval($item['price']);
                        
                        $insert_item = "INSERT INTO order_items (order_id, product_name, product_category, quantity, price) 
                                     VALUES ($order_id, '$product_name', '$product_category', $quantity, $price)";
                        $con->query($insert_item);
                    }
                    
                    // Clear cart
                    $clear_cart = "DELETE FROM cart_items WHERE user_id = $user_id";
                    $con->query($clear_cart);
                    
                    // Commit transaction
                    $con->commit();
                    
                    $response["success"] = true;
                    $response["message"] = "Checkout successful";
                    $response["data"] = array(
                        "order_id" => $order_id,
                        "total_amount" => $total_amount,
                        "items_count" => count($cart_items)
                    );
                    
                } catch (Exception $e) {
                    // Rollback transaction on error
                    $con->rollback();
                    throw $e;
                }
            } else {
                $response["message"] = "Cart is empty";
            }
        } else {
            $response["message"] = "User ID is required for checkout";
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