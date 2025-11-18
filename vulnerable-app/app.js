javascript
const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();
const PORT = 3000;

// Hardcoded secret (security issue for demonstration)
const SECRET_KEY = "super-secret-key-12345";

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ 
    message: 'Vulnerable Demo API',
    version: '1.0.0',
    status: 'running'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.post('/login', (req, res) => {
  const { username, password } = req.body;
  
  // Weak authentication (demo purposes)
  if (username && password) {
    const token = jwt.sign({ username }, SECRET_KEY, { expiresIn: '1h' });
    res.json({ token });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

app.get('/data', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    res.json({ 
      message: 'Protected data',
      user: decoded.username 
    });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
