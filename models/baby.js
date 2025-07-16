const mongoose = require('mongoose');

const babySchema = new mongoose.Schema({

  name: {
    type: String,
    required: true
  },
  birthDate: {
    type: Date,
    required: true
  },
  gender: {
    type: String,
    enum: ['Male', 'Female'],
    required: true
  },
  height: {
    type: Number,
    required: true
  },
  weight: {
    type: Number,
    required: true
  },
  image: {
    type: String,
    required: false
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
   lastHeightWeightUpdate: { 
    type: Date
   },
  lastFeedingTime: {
    type: Date
  },
    lastSleepSession: {
    type: Date 
  }

});

module.exports = mongoose.model('Baby', babySchema);