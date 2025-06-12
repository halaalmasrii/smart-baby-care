const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  type: {
    type: String,
    required: true
  },

  title: {
    type: String,
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  time: {
    type: String,
  },
  repeat: {
    type: String,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
});

module.exports = mongoose.model('Appointment', appointmentSchema);