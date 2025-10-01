/*
  This script runs once on boot (invoked by cloud-init). It attempts to connect to the DB,
  creates the 'users' table if missing, and then starts the server (server.js).
*/
const mysql = require('mysql2/promise');
const { exec } = require('child_process');

const DB_HOST = process.env.DB_HOST || '127.0.0.1';
const DB_USER = process.env.DB_USER || 'admin';
const DB_PASS = process.env.DB_PASS || 'pass';
const DB_NAME = 'demodb';

async function migrate() {
  let conn;
  for (let i=0;i<10;i++) {
    try {
      conn = await mysql.createConnection({ host: DB_HOST, user: DB_USER, password: DB_PASS });
      await conn.query(`CREATE DATABASE IF NOT EXISTS \\`${DB_NAME}\\``);
      await conn.query(`USE \\`${DB_NAME}\\``);
      await conn.query(`CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), email VARCHAR(150))`);
      await conn.end();
      console.log('Migration complete');
      return true;
    } catch (e) {
      console.log('Migration attempt failed, retrying...', e.message);
      await new Promise(r => setTimeout(r, 5000));
    }
  }
  return false;
}

migrate().then(ok => {
  if (!ok) process.exit(1);
  // start node server in background
  exec('node /opt/demo-node-app/server.js', (err, stdout, stderr) => {
    if (err) console.error('server failed', err);
  });
});
