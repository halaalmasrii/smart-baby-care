const Appointment = require("../models/appointment");
const { sendNotification, scheduleTestNotification } = require("../services/notificationService");

const sendVaccineReminder = async (req, res) => {
  try {
    const appointment = await Appointment.findById(req.params.appointmentId).populate("user");

    if (!appointment || !appointment.user?.email) {
      return res.status(404).json({ message: "Appointment or user email not found" });
    }

    await sendNotification({
      recipient: appointment.user.email,
      subject: "🩺 Vaccine Reminder",
      message: `Don't forget your vaccine appointment "${appointment.title}" scheduled on ${appointment.date} at ${appointment.time}.`,
    });

    return res.status(200).json({ message: "Email sent successfully" });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const sendDoctorReminder = async (req, res) => {
  try {
    const appointment = await Appointment.findById(req.params.appointmentId).populate("user");

    if (!appointment || !appointment.user?.email) {
      return res.status(404).json({ message: "Appointment or user email not found" });
    }

    await sendNotification({
      recipient: appointment.user.email,
      subject: "👩‍⚕️ Doctor Visit Reminder",
      message: `Reminder for your doctor appointment "${appointment.title}" on ${appointment.date} at ${appointment.time}.`,
    });

    return res.status(200).json({ message: "Email sent successfully" });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const sendMedicineReminder = async (req, res) => {
  try {
    const appointment = await Appointment.findById(req.params.appointmentId).populate("user");

    if (!appointment || !appointment.user?.email) {
      return res.status(404).json({ message: "Appointment or user email not found" });
    }

    await sendNotification({
      recipient: appointment.user.email,
      subject: "💊 Medicine Reminder",
      message: `Reminder to take your medicine for "${appointment.title}" at ${appointment.time} on ${appointment.date}.`,
    });

    return res.status(200).json({ message: "Email sent successfully" });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// دالة جدولة اشعار اختبارية بعد دقيقة
const testScheduleNotification = (req, res) => {
  const testEmail = "hala.almasri.s.2002@gmail.com"; // غيّرها للإيميل اللي بدك تجرب عليه
  scheduleTestNotification(testEmail);
  res.send("Test notification scheduled to be sent in 1 minute.");
};

module.exports = {
  sendVaccineReminder,
  sendDoctorReminder,
  sendMedicineReminder,
  testScheduleNotification,
};
