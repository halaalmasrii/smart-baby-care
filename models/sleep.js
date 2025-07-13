const mongoose = require('mongoose');

const sleepSchema = new mongoose.Schema({
  babyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Baby',
    required: true
  },
  startTime: {
    type: Date,
    required: true
  },
  endTime: {
    type: Date,
    required: false // بينضاف عند إنهاء النوم
  },
  duration: {
    type: Number, // بالدقائق
    required: false
  },
  notes: {
    type: String,
    default: ''
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  isSleeping: {
    type: Boolean,
    default: true // أول ما يبدأ النوم بيكون نايم
  }
});

module.exports = mongoose.model('Sleep', sleepSchema);
