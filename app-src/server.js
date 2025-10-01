const express = require('express');
const mysql = require('mysql2/promise');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const DB_HOST = process.env.DB_HOST || '127.0.0.1';
const DB_USER = process.env.DB_USER || 'admin';
const DB_PASS = process.env.DB_PASS || 'pass';
const DB_NAME = 'demodb';

let pool;

async function initPool() {
  pool = mysql.createPool({ host: DB_HOST, user: DB_USER, password: DB_PASS, database: DB_NAME, waitForConnections: true, connectionLimit: 5 });
}

app.get('/health', (req, res) => res.send('ok'));

app.get('/', (req, res) => res.send({ msg: 'Hello from demo-node-app', db: DB_HOST }));

app.get('/users', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, name, email FROM users');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/users', async (req, res) => {
  try {
    const { name, email } = req.body;
    const [result] = await pool.execute('INSERT INTO users (name, email) VALUES (?, ?)', [name, email]);
    res.json({ id: result.insertId, name, email });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

initPool().then(() => {
  app.listen(PORT, () => console.log('Server listening on', PORT));
}).catch(err => {
  console.error('Failed to initialize DB pool', err);
  process.exit(1);
});
