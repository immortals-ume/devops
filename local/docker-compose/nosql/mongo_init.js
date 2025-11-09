// MongoDB Initialization Script
db = db.getSiblingDB('myapp');

// Create application user
db.createUser({
  user: 'appuser',
  pwd: 'apppassword',
  roles: [
    { role: 'readWrite', db: 'myapp' },
    { role: 'dbAdmin', db: 'myapp' }
  ]
});

// Create sample collection
db.createCollection('users');

// Insert sample data
db.users.insertMany([
  { name: 'John Doe', email: 'john@example.com', created_at: new Date() },
  { name: 'Jane Smith', email: 'jane@example.com', created_at: new Date() }
]);

print('MongoDB initialization completed');
