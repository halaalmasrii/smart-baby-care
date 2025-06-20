const mongoose = require('mongoose');

const vaccineSchema = new mongoose.Schema({
  babyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Baby',
    required: true
  },
  name: {
    type: String,
    required: true
  },
  date: {
    type: Date,
    required: true
  },

  description: {
    type: String
  },
  administered: {
    type: Boolean,
    default: false
  }
});

module.exports = mongoose.model('Vaccine', vaccineSchema);