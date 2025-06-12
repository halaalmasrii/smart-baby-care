const express = require('express');
const router = express.Router();
const userRoutes = require('./userRoutes');
const babyRoutes = require('./babyRoutes');
const adminRoutes = require('./adminRoutes');


router.use('/users', userRoutes);
router.use('/babies', userRoutes);
router.use('/admin', adminRoutes);

module.exports = router;
