const { DataTypes } = require('sequelize');
const sequelize = require('../db/sequelize-instance'); // Import the sequelize instance

const Post = sequelize.define('posts', {
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
});



module.exports = Post;
