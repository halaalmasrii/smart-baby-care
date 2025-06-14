const express = require('express');
const babyController= require('../controller/babyController');
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


router.get('/test', (req, res) => {
  res.send('Route is working');
});


router.put('/info/:babyId', isAuth, babyController.updateBabyInfo);
router.post('/appointments', isAuth, babyController.createAppointment);
router.post('/babies/appointments/:babyId', isAuth, babyController.createAppointmentForBaby);
router.get('/babies/appointments/:babyId', isAuth, babyController.getAppointments);
router.get('/appointments/:id', isAuth, babyController.getAppointments);
//router.post('/appointments/:id', isAuth, babyController.createAppointment);
router.post('/analysis/:babyId', isAuth, babyController.createAnalysis);
router.get('/analysis', isAuth, babyController.getUserAnalysis);
router.get('/vaccine', isAuth, babyController.getUserVaccines);
router.post('/feeding', isAuth, babyController.addFeeding);
router.get('/feeding', isAuth, babyController.getUserFeedings);
router.get('/feedings/:babyId', isAuth, babyController.getFeedingsByBaby);
router.delete('/feeding/:id', isAuth, babyController.deleteFeeding);
router.post('/alert', isAuth, babyController.createDangerAlert);
router.get('/alerts', isAuth, babyController.getUserAlerts);
router.get('/notifications', isAuth, babyController.getUserNotifications);
router.post('/notifications', isAuth, babyController.createNotification);
router.put('/notifications/:id/read', isAuth, babyController.markAsRead);
router.post('/notifications/schedule', isAuth, babyController.scheduleNotification);
router.delete('/notifications/:id', isAuth, babyController.deleteNotification);
router.get('/reports/growth', isAuth,babyController.getGrowthReports);
router.get('/reports/feeding', isAuth,babyController.getFeedingReports);
router.get('/reports/sleep', isAuth, babyController.getSleepReports);
router.get('/reports/vaccines', isAuth, babyController.getVaccineReports);
router.get('/reports/danger', isAuth, babyController.getDangerReports);
router.post('/sleep', isAuth, babyController.startSleep);
router.put('/sleep/:id/end', isAuth, babyController.endSleep);
router.get('/sleep/baby/:babyId', isAuth, babyController.getSleepSessionsByBaby);
router.delete('/sleep/:id', isAuth, babyController.deleteSleepSession);
router.get('/status/growth', isAuth, babyController.getGrowthData);
router.get('/status/sleep', isAuth, babyController.getSleepStats);
router.get('/status/feeding', isAuth, babyController.getFeedingStats);
router.get('/status/crying', isAuth, babyController.getCryingStats);
router.get('/status/today', isAuth, babyController.getTodayStats);
router.post('/vaccines', isAuth, babyController.addVaccine);
router.get('/vaccines', isAuth, babyController.getAllVaccines);
router.get('/vaccines/:id', isAuth, babyController.getVaccineById);
router.put('/vaccines/:id', isAuth, babyController.updateVaccine);
router.delete('/vaccines/:id', isAuth, babyController.deleteVaccine);

module.exports = router;

//35 routes