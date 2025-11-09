-- Create replication user
CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED BY 'replicator';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';

-- Create application user with full privileges
GRANT ALL PRIVILEGES ON *.* TO 'myapp'@'%';

FLUSH PRIVILEGES;
