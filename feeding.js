const mongoose = require('mongoose');

const feedingSchema = new mongoose.Schema({
  babyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Baby',
    required: true
  },
  title: {
    type: String,
    default: "Feeding Reminder"
  },
  time: {
    type: Date,
    default: Date.now
  },
  recurrence: {
    type: String,
    default: 'every_3_hours'
  },
  notifyAtTime: {
    type: Boolean,
    default: true
  },
  lastFeeding: {
    type: Date,
    default: null
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
});

const Feeding = mongoose.model('Feeding', feedingSchema);
module.exports = Feeding;