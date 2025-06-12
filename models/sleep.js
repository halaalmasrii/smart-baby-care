const mongoose = require('mongoose');

const sleepSchema = new mongoose.Schema({
  baby: {
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
    required: true
  },
  duration: {
    type: Number, // مدة النوم بالدقائق
    required: true
  },
  notes: {
    type: String,
    default: ''
  }
});

module.exports = mongoose.model('Sleep', sleepSchema);