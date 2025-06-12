const express = require("express");
const router = express.Router();
const adminController = require('../controller/adminController');
const isAuth = require("../middlewares/authMiddleware");


router.post('/login', adminController.loginAdmin);

router.get("/user/:id", adminController.getUserById);

router.patch("/users/block/:id", adminController.blockUser);

router.get('/users' , adminController.getUsers
)
module.exports = router;
