const express = require('express');
const router = express.Router();
const userRoutes = require('./userRoutes');
const babyRoutes = require('./babyRoutes');
const adminRoutes = require('./adminRoutes');

const notificationRoutes = require("./notificationRoutes");
router.use("/notifications", notificationRoutes);

router.use('/users', userRoutes);
router.use('/babies', babyRoutes);
router.use('/admin', adminRoutes);

module.exports = router;
