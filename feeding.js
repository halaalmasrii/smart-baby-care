const mongoose = require('mongoose');

const feedingSchema = new mongoose.Schema({
  babyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Baby',
    required: true
  },
  amount: {
    type: Number,
    required: true
  },
  unit: {
    type: String,
    enum: ['ml', 'oz'],
    default: 'ml'
  },
  time: {
    type: Date,
    default: Date.now
  },
  note: {
    type: String,
    default: ''
  },
  user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
});

module.exports = mongoose.model('Feeding', feedingSchema);