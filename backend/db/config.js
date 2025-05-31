module.exports = {
    database: process.env.DB_NAME || 'database',
    username: process.env.DB_USER || 'root',     
    password: process.env.DB_PASSWORD || '123456',
    host: process.env.DB_HOST || 'mysql',        
    dialect: 'mysql',
};