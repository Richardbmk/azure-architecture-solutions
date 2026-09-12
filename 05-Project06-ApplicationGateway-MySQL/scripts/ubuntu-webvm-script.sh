#!/bin/sh
# Update package list
sudo apt-get update -y

# Stop Firewall and Disable it (Ubuntu uses ufw instead of firewalld)
sudo systemctl stop ufw
sudo systemctl disable ufw

# Install Apache, PHP, PostgreSQL Client and PHP PostgreSQL extension
sudo apt-get install -y apache2 php libapache2-mod-php php-pgsql postgresql-client wget

sudo systemctl enable apache2
sudo systemctl start apache2

sudo chmod -R 777 /var/www/html

# Create App1 status page for AppGateway probe
sudo mkdir -p /var/www/html/app1
sudo echo "Welcome to MyFitness - WebVM App1 - App Status Page" > /var/www/html/app1/status.html
sudo echo "Welcome to MyFitness - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/app1/hostname.html

# Create Index Page
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(210, 230, 250);"> <h1>Welcome to MyFitness - WebVM APP-1 (PostgreSQL)</h1> <p>Application Version: V1</p> <p><a href="/app1/dbtest.php">Test PostgreSQL Connection</a></p> </body></html>' | sudo tee /var/www/html/app1/index.html

# Create DB test page
cat <<'EOF' | sudo tee /var/www/html/app1/dbtest.php
<?php
$host = "${db_hostname}";
$db   = "${db_name}";
$user = "${db_username}";
$pass = "${db_password}";

$conn_string = "host=$host port=5432 dbname=$db user=$user password=$pass sslmode=require";
$dbconn = @pg_connect($conn_string);

echo "<!DOCTYPE html><html><head><title>PostgreSQL Connection Test</title></head><body style='font-family: sans-serif; padding: 20px;'>";
echo " baseline <h2>PostgreSQL Connection Test</h2>";

if ($dbconn) {
    echo "<p style='color: green; font-weight: bold;'>Successfully connected to PostgreSQL Database!</p>";
    echo "<ul>";
    echo "<li><strong>Host:</strong> " . htmlspecialchars($host) . "</li>";
    echo "<li><strong>Database:</strong> " . htmlspecialchars($db) . "</li>";
    echo "<li><strong>User:</strong> " . htmlspecialchars($user) . "</li>";
    echo "<li><strong>Server Hostname:</strong> " . gethostname() . "</li>";
    echo "</ul>";

    // Create a dummy table and insert a row if it doesn't exist
    @pg_query($dbconn, "CREATE TABLE IF NOT EXISTS visits (id SERIAL PRIMARY KEY, visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);");
    @pg_query($dbconn, "INSERT INTO visits DEFAULT VALUES;");
    $result = @pg_query($dbconn, "SELECT COUNT(*) FROM visits;");
    if ($result) {
        $row = pg_fetch_row($result);
        echo "<p>Total database visits recorded: <strong>" . $row[0] . "</strong></p>";
    }
    pg_close($dbconn);
} else {
    echo "<p style='color: red; font-weight: bold;'>Failed to connect to PostgreSQL Database.</p>";
    echo "<p>Check server host, credentials, and network/DNS settings.</p>";
}
echo "</body></html>";
?>
EOF

sudo systemctl restart apache2