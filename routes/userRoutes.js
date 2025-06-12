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
  body('phoneNumber').isMobilePhone(),
  body('userType').isIn(['Mother', 'Father', 'Other']).withMessage('Invalid user type')
], userController.createUser);

router.post('/login', userController.loginUser);
//router.get('/user/:id',isAuth , userController.getUserById);
router.put('/user/:id' , isAuth , userController.updateUserProfile);
router.put('/user/image/:id', isAuth , userController.updateUserImage);
//router.put('/user/cv/:id' , isAuth , userController.updateCv);
router.put('/user/:id/change-password', isAuth, userController.changePassword);
router.get('/check-auth', isAuth, userController.checkAuth);
router.get('/user/:id/appointments', isAuth, userController.getAppointments);
router.post('/user/:id/appointments', isAuth, userController.createAppointment);
router.post('/analysis', isAuth, userController.createAnalysis);
router.get('/analysis', isAuth, userController.getUserAnalysis);
router.post('/baby', isAuth, upload.single('image'), userController.createBaby);
router.get('/babies', isAuth, userController.getUserBabies);
router.delete('/baby/:id', isAuth, userController.deleteBaby);
router.get('/baby', isAuth, userController.getUserBaby);
router.put('/baby/:id/update-baby-info', isAuth, userController.updateChildInfo);
router.get('/vaccine', isAuth, userController.getUserVaccines);
router.post('/feeding', isAuth, userController.addFeeding);
router.get('/feeding', isAuth, userController.getUserFeedings);
router.get('/feedings/:babyId', isAuth, userController.getFeedingsByBaby);
router.delete('/feeding/:id', isAuth, userController.deleteFeeding);
router.post('/alert', isAuth, userController.createDangerAlert);
router.get('/alerts', isAuth, userController.getUserAlerts);
router.get('/notifications', isAuth, userController.getUserNotifications);
router.post('/notifications', isAuth, userController.createNotification);
router.put('/notifications/:id/read', isAuth, userController.markAsRead);
router.post('/notifications/schedule', isAuth, userController.scheduleNotification);
router.delete('/notifications/:id', isAuth, userController.deleteNotification);
router.get('/reports/growth', isAuth,userController.getGrowthReports);
router.get('/reports/feeding', isAuth,userController.getFeedingReports);
router.get('/reports/sleep', isAuth, userController.getSleepReports);
router.get('/reports/vaccines', isAuth, userController.getVaccineReports);
router.get('/reports/danger', isAuth, userController.getDangerReports);
router.post('/sleep', isAuth, userController.startSleep);
router.put('/sleep/:id/end', isAuth, userController.endSleep);
router.get('/sleep', isAuth, userController.getAllSleepSessions);
router.get('/sleep/baby/:babyId', isAuth, userController.getSleepSessionsByBaby);
router.delete('/sleep/:id', isAuth, userController.deleteSleepSession);
router.get('/status/growth', isAuth, userController.getGrowthData);
router.get('/status/sleep', isAuth, userController.getSleepStats);
router.get('/status/feeding', isAuth, userController.getFeedingStats);
router.get('/status/crying', isAuth, userController.getCryingStats);
router.get('/status/today', isAuth, userController.getTodayStats);
router.post('/vaccines', isAuth, userController.addVaccine);
router.get('/vaccines', isAuth, userController.getAllVaccines);
router.get('/vaccines/:id', isAuth, userController.getVaccineById);
router.put('/vaccines/:id', isAuth, userController.updateVaccine);
router.delete('/vaccines/:id', isAuth, userController.deleteVaccine);

module.exports = router;