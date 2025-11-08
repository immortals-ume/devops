-- Create application database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'myapp')
BEGIN
    CREATE DATABASE myapp;
END
GO

USE myapp;
GO

-- Create sample table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'users')
BEGIN
    CREATE TABLE users (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(255) NOT NULL,
        email NVARCHAR(255) NOT NULL,
        created_at DATETIME2 DEFAULT GETDATE()
    );
END
GO

-- Insert sample data
INSERT INTO users (name, email) VALUES 
    ('John Doe', 'john@example.com'),
    ('Jane Smith', 'jane@example.com');
GO
