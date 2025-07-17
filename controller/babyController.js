const User = require("../models/user");
const Appointment = require('../models/appointment');
const CryAnalysis = require('../models/cryAnalysis');
const Baby = require("../models/baby");
const Feeding = require('../models/feeding');
const DangerAlert = require('../models/dangerAlert');
const Notification = require('../models/notification');
const Sleep = require('../models/sleep');
const Vaccine = require('../models/vaccine');
const Growth = require('../models/growth');
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const fs = require("fs");
const mongoose = require('mongoose');





const updateBabyInfo = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;
  const { babyName, babyGender } = req.body;

  try {
    const baby = await Baby.findById({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: "baby not found" });

    // جلب المستخدم من بيانات الطفل مباشرة
    const user = await User.findById(baby.user);
    if (!user) return res.status(404).json({ message: "user not found" });

    if (babyName) baby.name = babyName;
    if (babyGender) baby.gender = babyGender;
    await baby.save();

    return res.status(200).json({ message: "Child info updated successfully", baby });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};




const { scheduleAppointmentNotification } = require("../services/notificationService"); // استيراد دالة الجدولة

const createAppointment = async (req, res) => {
  const {
    title,
    type,
    date,
    time,
    repeat,
    durationDays,
    notifyOneDayBefore,
    notifyAtTime
  } = req.body;
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    // التأكد من أن الطفل يعود للمستخدم
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const newAppointment = new Appointment({
      title,
      type,
      date,
      time,
      repeat,
      durationDays,
      notifyOneDayBefore,
      notifyAtTime,
      user: userId,
      babyId
    });

    // حفظ الموعد أولاً
    await newAppointment.save();

    // تحميل بيانات المستخدم (populate)
    await newAppointment.populate('user');

    // استدعاء جدولة الإشعار مع بيانات المستخدم كاملة
    scheduleAppointmentNotification(newAppointment);

    return res.status(201).json({ message: 'Appointment created successfully', appointment: newAppointment });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};




const getAppointments = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    const appointments = await Appointment.find({
      babyId: babyId,
      user: userId
    }).sort({ date: -1 });

    return res.status(200).json({ appointments });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};



const deleteAppointment = async (req, res) => {
  const appointmentId = req.params.id;
  const userId = req.user._id;

  try {
    const deleted = await Appointment.findOneAndDelete({
      _id: appointmentId,
      user: userId
    });

    if (!deleted) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    return res.status(200).json({ message: "Appointment deleted successfully" });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const updateAppointment = async (req, res) => {
  const appointmentId = req.params.id;
  const userId = req.user._id;

  const updateData = {};
  const allowedFields = [
    'title',
    'type',
    'date',
    'time',
    'repeat',
    'durationDays',
    'notifyOneDayBefore',
    'notifyAtTime'
  ];

  // نسخ الحقول المسموحة فقط
  Object.keys(req.body).forEach((key) => {
    if (allowedFields.includes(key)) {
      updateData[key] = req.body[key];
    }
  });

  try {
    const updated = await Appointment.findOneAndUpdate(
      { _id: appointmentId, user: userId },
      updateData,
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    return res.status(200).json({
      message: "Appointment updated",
      appointment: updated
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const createAnalysis = async (req, res) => {
  const { reason } = req.body;
  const babyId = req.params.babyId;
  const userId = req.user?._id;

  if (!reason || !babyId) {
    return res.status(400).json({ message: 'reason  are required' });
  }

  try {
    const newAnalysis = new CryAnalysis({
      reason,
      babyId,
      user: userId
    });

    await newAnalysis.save();
    return res.status(201).json({ message: 'Analysis created successfully', analysis: newAnalysis });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};



const getBabyAnalysis = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
const analyses = await CryAnalysis.find({ user: userId, babyId }).sort({ timestamp: -1 });
    return res.status(200).json({ analyses });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};







const addFeeding = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const now = new Date();

    const newFeeding = new Feeding({
      babyId,
      user: userId,
      time: now,
      recurrence: 'every_3_hours',
      notifyAtTime: true,
      lastFeeding: now,
    });

    await newFeeding.save();
    return res.status(201).json({ message: 'Feeding added successfully', feeding: newFeeding });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};



const getFeedingsByBaby = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    // تحقق من ملكية الطفل
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    // الاستعلام الصحيح
    const feedings = await Feeding.find({
      babyId: babyId,   // أو baby: babyId ← حسب الـ Schema
      user:   userId
    }).sort({ time: -1 });

    return res.status(200).json({ feedings });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};



const deleteFeeding = async (req, res) => {
  const feedingId = req.params.id;
  const userId = req.user._id;

  try {
    const feeding = await Feeding.findByIdAndDelete({_id:feedingId, user: userId});
    if (!feeding) return res.status(404).json({ message: 'Feeding not found' });

    return res.status(200).json({ message: 'Feeding deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const createDangerAlert = async (req, res) => {
  const { type } = req.body;
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const newAlert = new DangerAlert({
      type,
      description: `${type} detected`,
      baby: babyId,
      user: userId
    });

    await newAlert.save();
    return res.status(201).json({ message: 'Danger alert created successfully', alert: newAlert });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};




const getUserAlerts = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const alerts = await DangerAlert.find({ baby: babyId })
      .populate('baby', 'name')
      .sort({ timestamp: -1 });

    return res.status(200).json({ alerts });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};




const getBabyNotifications = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  // تأكد أن الطفل تابع للمستخدم
  const baby = await Baby.findOne({ _id: babyId, user: userId });
  if (!baby) {
    return res.status(404).json({ message: "Baby not found or not yours" });
  }

  try {
    const notifications = await Notification.find({ user: userId, baby: babyId })
      .populate('baby', 'name')
      .sort({ createdAt: -1 });

    return res.status(200).json({ notifications });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const createNotification = async (req, res) => {
  const { type, title, message } = req.body;
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const newNotification = new Notification({
      type,
      title,
      message,
      baby: babyId,
      user: userId
    });

    await newNotification.save();
    return res.status(201).json({ 
      message: 'Notification created successfully', 
      notification: newNotification 
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const markAsRead = async (req, res) => {
  const notificationId = req.params.id;

  try {
    const notification = await Notification.findByIdAndUpdate(
      notificationId,
      { isRead: true },
      { new: true }
    );

    if (!notification) return res.status(404).json({ message: 'Notification not found' });

    return res.status(200).json({ 
      message: 'Notification marked as read',
      notification
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// const scheduleNotification = async (req, res) => {
//   const { type, title, message, scheduledTime } = req.body;
//   const userId = req.user._id;
//   const babyId = req.params.babyId;

//   try {
//     const baby = await Baby.findOne({ _id: babyId, user: userId });
//     if (!baby) return res.status(404).json({ message: 'Baby not found' });

//     const newNotification = new Notification({
//       type,
//       title,
//       message,
//       baby: babyId,
//       user: userId,
//       scheduledTime
//     });

//     await newNotification.save();
//     return res.status(201).json({ 
//       message: 'Notification scheduled successfully',
//       notification: newNotification 
//     });
//   } catch (error) {
//     return res.status(500).json({ message: error.message });
//   }
// };


const deleteNotification = async (req, res) => {
  const notificationId = req.params.id;

  try {
    const notification = await Notification.findByIdAndDelete(notificationId);
    if (!notification) return res.status(404).json({ message: 'Notification not found' });

    return res.status(200).json({ message: 'Notification deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};



const getGrowthData = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    /* 1️⃣ التحقق من ملكية الطفل */
    const baby = await Baby.findOne({ _id: babyId, user: userId })
                           .select('birthDate height weight'); // نحتاج birthDate للحساب فقط
    if (!baby) {
      return res.status(404).json({ message: 'Baby not found' });
    }

    /* 2️⃣ حساب عمر الطفل بالأشهر */
    const today = new Date();
    const birth = new Date(baby.birthDate);

    // (عدد سنوات الفرق * 12) + فرق الشهور
    let ageMonths = (today.getFullYear() - birth.getFullYear()) * 12 +
                    (today.getMonth() - birth.getMonth());

    // لو يوم الشهر الحالي أصغر من يوم الميلاد → أطرح شهر واحد
    if (today.getDate() < birth.getDate()) {
      ageMonths -= 1;
    }

    /* 3️⃣ تجهيز الاستجابة بدون تاريخ الميلاد */
    return res.status(200).json({
      weight: baby.weight,   // الوزن (مثلاً بالكيلوغرام)
      height: baby.height,   // الطول (مثلاً بالسنتمتر)
      ageMonths             // العمر بالأشهر
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};




const getFeedingStats = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    // تحقق من ملكية الطفل
    const baby = await Baby.findOne({ _id: babyId, user: userId }).lean();
    if (!baby) {
      return res.status(404).json({ message: 'Baby not found' });
    }

    // جلب بيانات الرضاعة لهذا الطفل
    const feedingData = await Feeding.find({
      babyId: babyId,
      user: userId
    })
      .sort({ time: -1 })
      .lean();

    return res.status(200).json({ feedingData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};





const startSleep = async (req, res) => {
  const babyId = req.params.babyId;
  const userId = req.user._id;

  console.log("🔎 babyId:", babyId);
  console.log("👤 userId:", userId);

  try {
    // أول شي تأكدي إنو babyId شكله صحيح
    if (!mongoose.Types.ObjectId.isValid(babyId)) {
      return res.status(400).json({ message: "Invalid baby ID" });
    }

    const baby = await Baby.findById(babyId);

    // إذا البيبي مو موجود أصلاً
    if (!baby) {
      return res.status(404).json({ message: "Baby not found (doesn't exist)" });
    }

    // إذا البيبي مو تابع لهاليوزر
    if (baby.user.toString() !== userId.toString()) {
      return res.status(403).json({ message: "You are not authorized to access this baby" });
    }

    // ✔️ لو كلشي تمام، بلش جلسة النوم
    const newSleep = new Sleep({
      babyId: babyId,
      user: userId,
      startTime: new Date(),
    });

    await newSleep.save();

    return res.status(201).json({
      message: "Sleep session started successfully",
      sleep: newSleep,
    });
  } catch (error) {
    console.error("🔥 Error in startSleep:", error);
    return res.status(500).json({ message: error.message });
  }
};


const endSleep = async (req, res) => {
  const sleepId = req.params.sleepId;
  const endTime = new Date();

  try {
    const sleep = await Sleep.findById(sleepId);
    if (!sleep) return res.status(404).json({ message: 'Sleep session not found' });

    if (sleep.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "You are not authorized to end this sleep session." });
    }

    if (!sleep.isSleeping || sleep.endTime) {
      return res.status(400).json({ message: 'Sleep session has already ended' });
    }

    sleep.endTime = endTime;
    sleep.duration = Math.floor((endTime - sleep.startTime) / (1000 * 60)); // بالدقائق
    sleep.isSleeping = false;

    await sleep.save();

    return res.status(200).json({ 
      message: 'Sleep session ended successfully', 
      sleep 
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};



const getSleepSessionsByBaby = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    // التأكد من أن الطفل يعود للمستخدم
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    // ✅ الاستعلام الصحيح
    const sleepSessions = await Sleep.find({ babyId: babyId, user: userId }).sort({ startTime: -1 });

    return res.status(200).json({ sleepSessions });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};



const deleteSleepSession = async (req, res) => {
  const userId = req.user._id;      // جلب معرّف المستخدم من التوكن
  const sleepId = req.params.id;

  try {
    const sleep = await Sleep.findOneAndDelete({
      _id: sleepId,
      user: userId                // التقييد بمالك السجل
    });

    if (!sleep) {
      return res.status(404).json({ message: 'Sleep session not found or not yours' });
    }

    return res.status(200).json({ message: 'Sleep session deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const getSleepStats = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    const baby = await Baby.findOne({ _id: babyId, user: userId }).lean();
    if (!baby) {
      return res.status(404).json({ message: 'Baby not found' });
    }

    const sleepData = await Sleep.find({
      babyId: babyId,  // ← استخدم اسم الحقل الصحيح
      user: userId
    })
      .sort({ startTime: -1 })
      .lean();

    return res.status(200).json({ sleepData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};




// const getVaccineReports = async (req, res) => {
//   const userId = req.user._id;
//   const babyId = req.params.babyId;

//   try {
//     const baby = await Baby.findOne({ _id: babyId, user: userId });
//     if (!baby) return res.status(404).json({ message: 'Baby not found' });

//     const vaccineData = await Vaccine.find({ baby: babyId })
//       .populate('baby', 'name')
//       .sort({ date: -1 });

//     return res.status(200).json({ vaccineData });
//   } catch (error) {
//     return res.status(500).json({ message: error.message });
//   }
// };



// const addVaccine = async (req, res) => {
//   const { name, date } = req.body;
//   const userId = req.user._id;
//   const babyId = req.params.babyId;

//   try {
//     const baby = await Baby.findOne({ _id: babyId, user: userId });
//     if (!baby) return res.status(404).json({ message: 'Baby not found' });

//     const newVaccine = new Vaccine({
//       name,
//       date,
//       baby: babyId,
//       user: userId
//     });

//     await newVaccine.save();
//     return res.status(201).json({
//       message: 'Vaccine added successfully',
//       vaccine: newVaccine
//     });
//   } catch (error) {
//     return res.status(500).json({ message: error.message });
//   }
// };




// const getAllVaccines = async (req, res) => {
//   const userId = req.user._id;
//   const babyId = req.params.babyId;

//   try {
//     const baby = await Baby.findOne({ _id: babyId, user: userId });
//     if (!baby) return res.status(404).json({ message: 'Baby not found' });

//     const vaccines = await Vaccine.find({ baby: babyId })
//       .populate('baby', 'name')
//       .sort({ date: -1 });

//     return res.status(200).json({ vaccines });
//   } catch (error) {
//     return res.status(500).json({ message: error.message });
//   }
// };




// const getVaccineById = async (req, res) => {
//   const vaccineId = req.params.id;
//   const userId = req.user._id;

//   try {
//     const vaccine = await Vaccine.findById(vaccineId).populate('baby');
//     if (!vaccine) return res.status(404).json({ message: 'Vaccine not found' });

//     if (vaccine.baby.user.toString() !== userId.toString()) {
//       return res.status(403).json({ message: 'Access denied' });
//     }

//     return res.status(200).json({ vaccine });
//   } catch (error) {
//     return res.status(500).json({ message: error.message });
//   }
// };



// const updateVaccine = async (req, res) => {
//   const vaccineId = req.params.id;
//   const { name, date, administered, description } = req.body;
//   const userId = req.user._id;

//   try {
//     const vaccine = await Vaccine.findById(vaccineId).populate('baby');
//     if (!vaccine) return res.status(404).json({ message: 'Vaccine not found' });

//     if (vaccine.baby.user.toString() !== userId.toString()) {
//       return res.status(403).json({ message: 'Access denied' });
//     }

//     if (name) vaccine.name = name;
//     if (date) vaccine.date = date;
//     if (description) vaccine.description = description;
//     if (administered != null) vaccine.administered = administered;

//     await vaccine.save();
//     return res.status(200).json({
//       message: 'Vaccine updated successfully',
//       vaccine
//     });
//   } catch (error) {
//     return res.status(500).json({ message: error.message });
//   }
// };



// const deleteVaccine = async (req, res) => {
//   const vaccineId = req.params.id;
//   const userId = req.user._id;

//   try {
//     const vaccine = await Vaccine.findById(vaccineId).populate('baby');
//     if (!vaccine) return res.status(404).json({ message: 'Vaccine not found' });

//     if (vaccine.baby.user.toString() !== userId.toString()) {
//       return res.status(403).json({ message: 'Access denied' });
//     }

//     await Vaccine.findByIdAndDelete(vaccineId);
//     return res.status(200).json({ message: 'Vaccine deleted successfully' });
//   } catch (error) {
//     return res.status(500).json({ message: error.message });
//   }
// };




// const getDangerReports = async (req, res) => {
//   const userId = req.user._id;
//   const babyId = req.params.babyId;

//   try {
//     const baby = await Baby.findOne({ _id: babyId, user: userId });
//     if (!baby) return res.status(404).json({ message: 'Baby not found' });

//     const dangerData = await DangerAlert.find({ baby: babyId })
//       .populate('baby', 'name')
//       .sort({ timestamp: -1 });

//     return res.status(200).json({ dangerData });
//   } catch (error) {
//     return res.status(500).json({ message: error.message });
//   }
// };







// const getCryingStats = async (req, res) => {
//   const userId = req.user._id;
//   const babyId = req.params.babyId; // إذا موجود
//   const today = new Date();
//   today.setHours(0, 0, 0, 0);

//   try {
//     let babyIds;

//     if (babyId) {
//       const baby = await Baby.findOne({ _id: babyId, user: userId });
//       if (!baby) {
//         return res.status(404).json({ message: "Baby not found or not yours" });
//       }
//       babyIds = [babyId];
//     } else {
//       const babies = await Baby.find({ user: userId });
//       babyIds = babies.map(b => b._id);
//     }

//     const cryingData = await CryAnalysis.find({
//       baby: { $in: babyIds },
//       timestamp: { $gte: today }
//     }).sort({ timestamp: -1 });

//     return res.status(200).json({ cryingData });
//   } catch (error) {
//     return res.status(500).json({ message: error.message });
//   }
// };



const getCryingStats = async (req, res) => {
  try {
    const userId = req.user._id;        // من الـ JWT
    const { babyId } = req.params;      // من الـ URL

    /* 1️⃣ تحقُّق أن babyId موجود في المسار */
    if (!babyId) {
      return res.status(400).json({ message: 'Missing babyId in params' });
    }

    /* 2️⃣ تأكُّد أن الطفل تابع للمستخدم */
    const baby = await Baby.findOne({ _id: babyId, user: userId }).lean();
    if (!baby) {
      return res.status(404).json({ message: 'Baby not found or not yours' });
    }

    /* 3️⃣ حدِّد بداية اليوم (00:00) */
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    /* 4️⃣ جلب بيانات البكاء لهذا الطفل فقط */
    const cryingData = await CryAnalysis.find({
      baby: babyId,
      timestamp: { $gte: today }
    }).sort({ timestamp: -1 });

    /* 5️⃣ إرجاع النتيجة */
    return res.status(200).json({ cryingData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};



// const getTodayStats = async (req, res) => {
//   try {
//     const userId = req.user._id;
//     const babyId = req.params.babyId;

//     // 1️⃣ تحقق من وجود babyId
//     if (!babyId) {
//       return res.status(400).json({ message: 'Missing babyId in params' });
//     }

//     // 2️⃣ تحقق أن الطفل فعلاً تابع للمستخدم
//     const baby = await Baby.findOne({ _id: babyId, user: userId }).lean();
//     if (!baby) {
//       return res.status(404).json({ message: 'Baby not found or not yours' });
//     }

//     // 3️⃣ بداية اليوم
//     const today = new Date();
//     today.setHours(0, 0, 0, 0);

//     // 4️⃣ إحصائيات النوم
//     const sleepData = await Sleep.find({
//       baby: babyId,
//       startTime: { $gte: today }
//     });

//     const totalSleep = sleepData.reduce((sum, session) => sum + (session.duration || 0), 0);

//     // 5️⃣ إحصائيات التغذية
//     const feedingData = await Feeding.find({
//       baby: babyId,
//       time: { $gte: today }
//     });

//     const totalFeedings = feedingData.length;
//     const totalAmount = feedingData.reduce((sum, feed) => sum + feed.amount, 0);

//     // 6️⃣ إحصائيات البكاء
//     const cryingData = await CryAnalysis.find({
//       baby: babyId,
//       timestamp: { $gte: today }
//     });

//     const cryingCount = cryingData.length;

//     // 7️⃣ النتيجة النهائية
//     return res.status(200).json({
//       baby: {
//         _id: baby._id,
//         name: baby.name
//       },
//       sleep: {
//         totalSleep,
//         sessions: sleepData.length
//       },
//       feeding: {
//         totalFeedings,
//         totalAmount
//       },
//       crying: {
//         cryingCount
//       }
//     });
//   } catch (error) {
//     return res.status(500).json({ message: error.message });
//   }
// };




module.exports = {
  getAppointments,
  createAppointment,
  deleteAppointment,
  updateAppointment,
  createAnalysis,
  getBabyAnalysis,
  //getUserVaccines,
  addFeeding,
  getFeedingsByBaby, 
  deleteFeeding,
  createDangerAlert,
  getUserAlerts,
  getBabyNotifications, 
  createNotification,
  markAsRead, 
  //scheduleNotification, 
  deleteNotification,
  startSleep, 
  endSleep, 
  getSleepSessionsByBaby, 
  deleteSleepSession, 
  //getVaccineReports, 
  //getDangerReports,
  updateBabyInfo,
  getGrowthData, 
  getSleepStats, 
  getFeedingStats, 
  getCryingStats, 
  //getTodayStats,
  // addVaccine, 
  // getAllVaccines, 
  // getVaccineById, 
  // updateVaccine, 
  // deleteVaccine,
};


//38-12
