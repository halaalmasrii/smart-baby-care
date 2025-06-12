const mongoose = require('mongoose');

const dangerAlertSchema = new mongoose.Schema({
  babyId: {
   type: mongoose.Schema.Types.ObjectId,
    ref: 'Baby',
    required: true
  },
  type: {
    type: String,
    required: true,
    enum: ['Movement', 'Fall', 'Abnormal Crying', 'Temperature Alert']
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  description: {
    type: String,
    default: 'Dangerous movement detected'
  },
  resolved: {
    type: Boolean,
    default: false
  },
});

module.exports = mongoose.model('DangerAlert', dangerAlertSchema);