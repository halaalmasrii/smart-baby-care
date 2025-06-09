const express = require("express");
const router = express.Router();
const adminController = require('../controller/adminController');
const isAuth = require("../middlewares/authMiddleware");


router.post('/login', adminController.loginAdmin);

router.get("/user/:id", adminController.getUserById);

router.patch("/users/block/:id", adminController.blockUser);

//router.get("/opportunities", adminController.getOpportunity);

//router.get('/:opportunityid' , isAuth, adminController.getOpportunityById);

//router.get("/opportunities/:role", adminController.getOpportunity);

//router.delete("/opportunities/:id", adminController.softDeleteOpportunity);

//router.get("/opportunity/:userId", isAuth, adminController.getOpportunityByUser);

router.get('/users' , adminController.getUsers
)
module.exports = router;
