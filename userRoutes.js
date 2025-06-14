const express = require('express');
const userController= require('../controller/userController');
const { body } = require('express-validator');
const isAuth = require("../middlewares/authMiddleware");
const multer = require('multer');
//const upload = require('../middlewares/uploadMiddleware'); 
const router = express.Router();


// إعداد Multer لرفع الصور
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname);
  }
});
const upload = multer({ storage });


router.post('/register', [
  body('username').notEmpty(),
  body('email').isEmail().withMessage('Please enter a valid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('userType').isIn(['Mother', 'Father', 'Other']).withMessage('Invalid user type')
], userController.createUser);

router.post('/login', userController.loginUser);
//router.get('/user/:id',isAuth , userController.getUserById);
router.put('/:id' , isAuth , userController.updateUserProfile);
router.put('/image/:id', isAuth , userController.updateUserImage);
router.get('/check-auth', isAuth, userController.checkAuth);
router.post('/baby', isAuth, upload.single('image'), userController.createBaby);
router.get('/babies', isAuth, userController.getUserBabies);
router.delete('/baby/:id', isAuth, userController.deleteBaby);
router.get('/baby', isAuth, userController.getUserBaby);
router.get('/notifications', isAuth, userController.getUserNotifications);
router.post('/notifications', isAuth, userController.createNotification);
router.put('/notifications/:id/read', isAuth, userController.markAsRead);
router.post('/notifications/schedule', isAuth, userController.scheduleNotification);
router.delete('/notifications/:id', isAuth, userController.deleteNotification);
router.get('/sleep', isAuth, userController.getAllSleepSessions);
router.get('/status/today', isAuth, userController.getTodayStats);

module.exports = router;


//16 routes