const mongoose = require('mongoose');

const cryAnalysisSchema = new mongoose.Schema({
  reason: {
    type: String,
    required: true,
    enum: ['Hungry', 'Colic', 'Tired', 'Needs Burping', 'Discomfort', 'Wet Diaper'] // الأسباب الثابتة من الواجهة
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
});

module.exports = mongoose.model('CryAnalysis', cryAnalysisSchema);