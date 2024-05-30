<?php
include "dbinfo.inc.php"; 
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Employee Details</title>
    <!-- Bootstrap CSS -->
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h1 class="text-center mb-4">Employee Details</h1>
    <?php
    // Enable error reporting
    error_reporting(E_ALL);
    ini_set('display_errors', 1);

    // Connect to MySQL and select the database
    $connection = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD);

    if (mysqli_connect_errno()) {
        echo "<div class='alert alert-danger'>Failed to connect to MySQL: " . mysqli_connect_error() . "</div>";
        exit();
    }

    $database = mysqli_select_db($connection, DB_DATABASE);

    if (!$database) {
        echo "<div class='alert alert-danger'>Failed to select database: " . mysqli_error($connection) . "</div>";
        exit();
    }

    // Ensure that the EMPLOYEES table exists
    verifyEmployeesTable($connection, DB_DATABASE);

    // If input fields are populated, add a row to the EMPLOYEES table
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $employee_name = htmlentities($_POST['NAME']);
        $employee_address = htmlentities($_POST['ADDRESS']);

        if (strlen($employee_name) || strlen($employee_address)) {
            addEmployee($connection, $employee_name, $employee_address);
        }
    }
    ?>

    <!-- Input form -->
    <form action="<?php echo htmlspecialchars($_SERVER['PHP_SELF']); ?>" method="POST" class="mb-5">
        <div class="form-row">
            <div class="form-group col-md-6">
                <label for="name">Name</label>
                <input type="text" class="form-control" id="name" name="NAME" maxlength="45" required>
            </div>
            <div class="form-group col-md-6">
                <label for="address">Address</label>
                <input type="text" class="form-control" id="address" name="ADDRESS" maxlength="90" required>
            </div>
        </div>
        <button type="submit" class="btn btn-primary">Add Data</button>
    </form>

    <!-- Display table data -->
    <table class="table table-striped table-bordered">
        <thead class="thead-dark">
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Address</th>
            </tr>
        </thead>
        <tbody>
        <?php
        $result = mysqli_query($connection, "SELECT * FROM EMPLOYEES");

        if (!$result) {
            echo "<div class='alert alert-danger'>Error fetching data: " . mysqli_error($connection) . "</div>";
        } else {
            while ($query_data = mysqli_fetch_row($result)) {
                echo "<tr>";
                echo "<td>", $query_data[0], "</td>",
                     "<td>", $query_data[1], "</td>",
                     "<td>", $query_data[2], "</td>";
                echo "</tr>";
            }
        }
        ?>
        </tbody>
    </table>

    <?php
    // Clean up
    mysqli_free_result($result);
    mysqli_close($connection);
    ?>
</div>

<!-- Bootstrap JS and dependencies -->
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.2/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>

<?php
// Function to add an employee to the table
function addEmployee($connection, $name, $address) {
    $n = mysqli_real_escape_string($connection, $name);
    $a = mysqli_real_escape_string($connection, $address);

    $query = "INSERT INTO EMPLOYEES (NAME, ADDRESS) VALUES ('$n', '$a');";

    if (!mysqli_query($connection, $query)) {
        echo "<div class='alert alert-danger'>Error adding employee data: " . mysqli_error($connection) . "</div>";
    } else {
        echo "<div class='alert alert-success'>Employee added successfully.</div>";
    }
}

// Function to check whether the table exists and, if not, create it
function verifyEmployeesTable($connection, $dbName) {
    if (!tableExists("EMPLOYEES", $connection, $dbName)) {
        $query = "CREATE TABLE EMPLOYEES (
            ID int(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            NAME VARCHAR(45) NOT NULL,
            ADDRESS VARCHAR(90) NOT NULL
        )";

        if (!mysqli_query($connection, $query)) {
            echo "<div class='alert alert-danger'>Error creating table: " . mysqli_error($connection) . "</div>";
        }
    }
}

// Function to check for the existence of a table
function tableExists($tableName, $connection, $dbName) {
    $t = mysqli_real_escape_string($connection, $tableName);
    $d = mysqli_real_escape_string($connection, $dbName);

    $checkTable = mysqli_query($connection,
        "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_NAME = '$t' AND TABLE_SCHEMA = '$d'");

    if (mysqli_num_rows($checkTable) > 0) {
        return true;
    }

    return false;
}
?>
