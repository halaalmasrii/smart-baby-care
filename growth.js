const mongoose = require('mongoose');

const growthSchema = new mongoose.Schema({
  babyId: {
       type: mongoose.Schema.Types.ObjectId,
        ref: 'Baby',
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
  date: {
    type: Date,
    default: Date.now
  },
  user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
});

module.exports = mongoose.model('Growth', growthSchema);