const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  type: {
    type: String,
    required: true,
    enum: ['feeding', 'update', 'appointment', 'health', 'custom']
  },
  title: {
    type: String,
    required: true
  },
  message: {
    type: String,
    required: true
  },
  baby: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Baby',
    required: true
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  isRead: {
    type: Boolean,
    default: false
  },
  scheduledTime: {
    type: Date
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Notification', notificationSchema);