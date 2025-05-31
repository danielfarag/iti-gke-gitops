var express = require('express');
var router = express.Router();


router.get('/health', async (req, res) => {
  res.status(200).json({}); 
});



router.get('/custom', async (req, res) => {
  res.status(200).json({
    res: "message "
  }); 
});


module.exports = router;
