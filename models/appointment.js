const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  type: {
    type: String, // 'vaccine', 'doctor', 'medicine'
    required: true
  },
  date: {
    type: Date,
    required: false
  },
time: {
  type: String,
  required: true,
},

  repeat: {
    type: String, // قيم محتملة: null, 'daily', 'weekly', 'monthly', إلخ
    default: null
  },
  durationDays: {
    type: Number, // عدد الأيام للمواعيد المتكررة أو العلاجات
    default: null
  },
  notifyAtTime: {
    type: Boolean,
    default: false
  },
  notifyOneDayBefore: {
    type: Boolean,
    default: false
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  babyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Baby',
    required: true
  }
});

module.exports = mongoose.model('Appointment', appointmentSchema);