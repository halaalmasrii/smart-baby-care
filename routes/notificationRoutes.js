const express = require("express");
const router = express.Router();
const notificationController = require("../controller/notificationController");
const isAuth = require("../middlewares/authMiddleware");

router.get("/vaccine/:appointmentId", isAuth, notificationController.sendVaccineReminder);
router.get("/doctor/:appointmentId", isAuth, notificationController.sendDoctorReminder);
router.get("/medicine/:appointmentId", isAuth, notificationController.sendMedicineReminder);
router.get("/test-schedule", notificationController.testScheduleNotification);


module.exports = router;
