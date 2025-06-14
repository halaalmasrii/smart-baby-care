const express = require('express');
const router = express.Router();
const userRoutes = require('./userRoutes');
const babyRoutes = require('./babyRoutes');
const adminRoutes = require('./adminRoutes');


router.use('/users', userRoutes);
router.use('/babies', babyRoutes);
router.use('/admin', adminRoutes);

module.exports = router;
