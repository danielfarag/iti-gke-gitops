var express = require('express');
var path = require('path');
var logger = require('morgan');
const sequelize = require('./db/sequelize-instance');
const cors = require('cors'); 

var postsRouter = require('./routes/posts');
var indexRouter = require('./routes/index');

var app = express();

sequelize
  .authenticate()
  .then(() => {
    return sequelize.sync({ alter: true });
  })
  .then(() => {
    console.log('Database synchronized. ');
  })
  .catch((err) => {
    throw new Error('Connection Failed');
  });

  

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));


app.use('/', indexRouter);
app.use('/posts', postsRouter);

module.exports = app;
