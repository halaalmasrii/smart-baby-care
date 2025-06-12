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
//const FavoriteList = require("../models/favoriteList");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const fs = require("fs");

const createUser = async (req, res) => {
  const { username, email, password, phoneNumber, userType } = req.body;

  if (
    !username ||
    !email ||
    !password ||
    !phoneNumber 
    /*
    || !req.files.cv ||
    !req.files.image
    */
  ) {
    return res
      .status(400)
      .json({ message: "Please provide all required fields" });
  }

  try {
    console.log('inside');
    
    const existUser = await User.findOne({ email: email });
    if (existUser) {
      return res.status(400).json({ message: "User already exist" });
    }
    /*
    let image;
    let cv;
    if (req.files) {
      image = req.files.image[0].path;
      cv = req.files.cv[0].path;
    }
    console.log(image);
    console.log(cv);
    */
    const hashedPassword = await bcrypt.hash(password, 12);

    const newUser = new User({
      username: username,
      email: email,
      password: hashedPassword,
      phoneNumber: phoneNumber,
      userType: userType || 'Mother'
      //profileImage: image,
      //cv: cv,
    });

    await newUser.save();
console.log(newUser);
    const token = jwt.sign(
      { email: newUser.email },
      process.env.ACCESS_TOKEN_SECRET
    );

    return res
      .status(201)
      .json({ message: "User created successfully", user: newUser },token);
  } catch (error) {
    return res
      .status(500)
      .json({ message:  error.message });
  }
};
//////////

const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email: email });

    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }
    const isEqual = await bcrypt.compare(password, user.password);
    if (!isEqual) {
      return res.status(400).json({ message: "Invalid password" });
    }
    const token = jwt.sign(
      { email: user.email },
      process.env.ACCESS_TOKEN_SECRET
    );

    res.cookie('token', token, { httpOnly: true, secure: false }); // secure: true في الإنتاج

    return res.status(200).json({ message: "Login successful", user, token });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Failed to login", error: error.message });
  }
};

//////////

const getUserById = async (req, res) => {
  const id = req.params.id;
  const user = await User.findById(id);

  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }
  const image = await fs.promises.readFile(
    `${process.cwd()}\\${user.profileImage}`
  );
  /*
  const base64Image = Buffer.from(image, "binary").toJSON();
  console.log(base64Image);
  const cv = await fs.promises.readFile(`${process.cwd()}\\${user.cv}`);
  const base64Cv = Buffer.from(cv, "binary").toJSON();
  const jsonUser = user.toJSON();
  delete jsonUser.password;
  jsonUser.profileImage = base64Image;
  jsonUser.cv = base64Cv;
  */
  console.log(jsonUser);
  return res.status(200).json(jsonUser);
};

////////

const updateUserProfile = async (req, res) => {
  const userId = req.params.id;
  const username = req.body.username;
  const phoneNumber = req.body.phoneNumber;
  let user = await User.findById(userId);
  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }
  if (username) {
    user.username = username;
  }
  if (phoneNumber) {
    user.phoneNumber = phoneNumber;
  }
  user = await user.save();
  return res.status(200).json({
    message: "Profile updated successfully", 
    user,
  });
};

const changePassword = async (req, res) => {
  const userId = req.params.id;
  const { oldPassword, newPassword } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    // التحقق من كلمة المرور القديمة
    const isValid = await bcrypt.compare(oldPassword, user.password);
    if (!isValid) return res.status(400).json({ message: "Invalid password" });

    // تشفير كلمة المرور الجديدة
    const hashedPassword = await bcrypt.hash(newPassword, 12);
    user.password = hashedPassword;
    await user.save();

    return res.status(200).json({
    message: "Password changed successfully" });
  } catch (error) {
    return res.status(500).json({
    message: error.message });
  }
};

const updateChildInfo = async (req, res) => {
  const userId = req.params.id;
  const { babyName, babyGender } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    // افترض أن عندك نموذج Baby مرتبط بالمستخدم
    const baby = await Baby.findOne({ user: userId });
    if (!baby) return res.status(404).json({ message: "Baby not found" });

    if (babyName) baby.name = babyName;
    if (babyGender) baby.gender = babyGender;
    await baby.save();

    return res.status(200).json({ message: "Child info updated successfully", baby });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};



const checkAuth = async (req, res) => {
  try {
    const user = req.user; // من middleware isAuth
    return res.status(200).json({ isAuthenticated: true, user });
  } catch (error) {
    return res.status(401).json({ isAuthenticated: false, error: 'Not authenticated' });
  }
};


//////////

const updateUserImage = async (req, res) => {
  try {
    const userId = req.params.id;
    const profileImagePath = req.files.image[0].path;
    const user = await User.findById(userId);
    console.log(user);
    fs.unlink(`${process.cwd()}\\${user.profileImage}`, (err) => {
      console.log(err);
    });
    user.profileImage = profileImagePath;
    await user.save();

    return res.json(user);
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }
};

//////


const getAppointments = async (req, res) => {
  const { userId } = req.params;

  try {
    const appointments = await Appointment.find({ user: userId }).sort({ date: -1 });
    return res.status(200).json({ appointments });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const createAppointment = async (req, res) => {
  const { userId } = req.params;
  const { title, date, time } = req.body;

  try {
    const newAppointment = new Appointment({
      title,
      date,
      time,
      user: userId
    });

    await newAppointment.save();
    return res.status(201).json({ message: 'Appointment created successfully', appointment: newAppointment });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const createAnalysis = async (req, res) => {
  const { reason } = req.body;
  const userId = req.user._id; 

  try {
    const newAnalysis = new CryAnalysis({
      reason,
      user: userId
    });

    await newAnalysis.save();
    return res.status(201).json({ message: 'Analysis created successfully', analysis: newAnalysis });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getUserAnalysis = async (req, res) => {
  const userId = req.user._id;

  try {
    const analyses = await CryAnalysis.find({ user: userId }).sort({ timestamp: -1 });
    return res.status(200).json({ analyses });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const createBaby = async (req, res) => {
  const { name, birthDate, gender, height, weight } = req.body;
  const userId = req.user._id;
  const imageUrl = req.file ? req.file.path : null;

  try {
    const newBaby = new Baby({
      name,
      birthDate,
      gender,
      height,
      weight,
      imageUrl,
      user: userId
    });

    await newBaby.save();
    return res.status(201).json({ message: 'Baby added successfully', baby: newBaby });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getUserBabies = async (req, res) => {
  const userId = req.user._id;

  try {
    const babies = await Baby.find({ user: userId });
    return res.status(200).json({ babies });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const deleteBaby = async (req, res) => {
  const babyId = req.params.id;

  try {
    const baby = await Baby.findByIdAndDelete(babyId);
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    if (baby.imageUrl) {
      fs.unlinkSync(baby.imageUrl); // حذف الصورة من النظام
    }

    return res.status(200).json({ message: 'Baby deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getUserBaby = async (req, res) => {
  const userId = req.user._id;

  try {
    const baby = await Baby.findOne({ user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    return res.status(200).json({ baby });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getUserVaccines = async (req, res) => {
  const userId = req.user._id;
  try {
    const vaccines = await Vaccine.find({ user: userId });
    return res.status(200).json({ vaccines });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const addFeeding = async (req, res) => {
  const { babyId, amount, unit } = req.body;
  const userId = req.user._id;

  try {
    // التأكد من أن الطفل يعود للمستخدم
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const newFeeding = new Feeding({
      babyId,
      amount,
      unit: unit || 'ml',
      note,
    });

    await newFeeding.save();
    return res.status(201).json({ message: 'Feeding added successfully', feeding: newFeeding });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getUserFeedings = async (req, res) => {
  const userId = req.user._id;

  try {
    const feedings = await Feeding.find({ babyId: { $in: await Baby.distinct('_id', { user: userId }) } })
      .populate('babyId', 'name')
      .sort({ time: -1 });

    return res.status(200).json({ feedings });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getFeedingsByBaby = async (req, res) => {
  const userId = req.user._id;
  const babyId = req.params.babyId;

  try {
    // التأكد من أن الطفل يعود للمستخدم
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const feedings = await Feeding.find({ baby: babyId }).sort({ time: -1 });
    return res.status(200).json({ feedings });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const deleteFeeding = async (req, res) => {
  const feedingId = req.params.id;

  try {
    const feeding = await Feeding.findByIdAndDelete(feedingId);
    if (!feeding) return res.status(404).json({ message: 'Feeding not found' });

    return res.status(200).json({ message: 'Feeding deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const createDangerAlert = async (req, res) => {
  const { type, babyId } = req.body;
  const userId = req.user._id;

  try {
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const newAlert = new DangerAlert({
      type,
      baby: babyId,
      description: `${type} detected`,
    });

    await newAlert.save();
    return res.status(201).json({ message: 'Danger alert created successfully', alert: newAlert });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getUserAlerts = async (req, res) => {
  const userId = req.user._id;

  try {
    const alerts = await DangerAlert.find({
      baby: { 
        $in: await Baby.distinct('_id', { user: userId }) 
      }
    })
    .populate('baby', 'name')
    .sort({ timestamp: -1 });

    return res.status(200).json({ alerts });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const getUserNotifications = async (req, res) => {
  const userId = req.user._id;

  try {
    const notifications = await Notification.find({ user: userId })
      .populate('baby', 'name')
      .sort({ createdAt: -1 });
    
    return res.status(200).json({ notifications });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const createNotification = async (req, res) => {
  const { type, title, message, babyId } = req.body;
  const userId = req.user._id;

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

const scheduleNotification = async (req, res) => {
  const { type, title, message, babyId, scheduledTime } = req.body;
  const userId = req.user._id;

  try {
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const newNotification = new Notification({
      type,
      title,
      message,
      baby: babyId,
      user: userId,
      scheduledTime
    });

    await newNotification.save();
    return res.status(201).json({ 
      message: 'Notification scheduled successfully',
      notification: newNotification 
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

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
const getGrowthReports = async (req, res) => {
  const userId = req.user._id;

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    const growthData = await Baby.find({ _id: { $in: babyIds } })
      .select('name birthDate weight height')
      .sort({ birthDate: -1 });
    
    return res.status(200).json({ growthData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getFeedingReports = async (req, res) => {
  const userId = req.user._id;

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    const feedingData = await Feeding.find({ baby: { $in: babyIds } })
      .populate('baby', 'name')
      .sort({ time: -1 });
    
    return res.status(200).json({ feedingData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const startSleep = async (req, res) => {
  const { babyId } = req.body;
  const userId = req.user._id;

  try {
    // التأكد من أن الطفل يعود للمستخدم
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const newSleep = new Sleep({
      baby: babyId,
      startTime: new Date(),
    });

    await newSleep.save();
    return res.status(201).json({ 
      message: 'Sleep session started successfully', 
      sleep: newSleep 
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const endSleep = async (req, res) => {
  const sleepId = req.params.id;
  const endTime = new Date();

  try {
    const sleep = await Sleep.findById(sleepId);
    if (!sleep) return res.status(404).json({ message: 'Sleep session not found' });

    sleep.endTime = endTime;
    sleep.duration = Math.floor((endTime - sleep.startTime) / 1000); // بالثواني
    await sleep.save();

    return res.status(200).json({ 
      message: 'Sleep session ended successfully', 
      sleep 
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getAllSleepSessions = async (req, res) => {
  const userId = req.user._id;

  try {
    const sleepSessions = await Sleep.find({
      baby: { 
        $in: await Baby.distinct('_id', { user: userId }) 
      }
    })
    .populate('baby', 'name')
    .sort({ startTime: -1 });

    return res.status(200).json({ sleepSessions });
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

    const sleepSessions = await Sleep.find({ baby: babyId }).sort({ startTime: -1 });
    return res.status(200).json({ sleepSessions });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const deleteSleepSession = async (req, res) => {
  const sleepId = req.params.id;

  try {
    const sleep = await Sleep.findByIdAndDelete(sleepId);
    if (!sleep) return res.status(404).json({ message: 'Sleep session not found' });

    return res.status(200).json({ message: 'Sleep session deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getSleepReports = async (req, res) => {
  const userId = req.user._id;

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    const sleepData = await Sleep.find({ baby: { $in: babyIds } })
      .populate('baby', 'name')
      .sort({ startTime: -1 });
    
    return res.status(200).json({ sleepData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


const getVaccineReports = async (req, res) => {
  const userId = req.user._id;

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    const vaccineData = await Vaccine.find({ baby: { $in: babyIds } })
      .populate('baby', 'name')
      .sort({ date: -1 });
    
    return res.status(200).json({ vaccineData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const addVaccine = async (req, res) => {
  const { babyId, name, date } = req.body;
  const userId = req.user._id;

  try {
    // التأكد من أن الطفل يعود للمستخدم
    const baby = await Baby.findOne({ _id: babyId, user: userId });
    if (!baby) return res.status(404).json({ message: 'Baby not found' });

    const newVaccine = new Vaccine({
      name,
      date,
      baby: babyId
    });
    await newVaccine.save();
    return res.status(201).json({ 
      message: 'Vaccine added successfully', 
      vaccine: newVaccine 
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getAllVaccines = async (req, res) => {
  const userId = req.user._id;

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    const vaccines = await Vaccine.find({ baby: { $in: babyIds } })
      .populate('baby', 'name')
      .sort({ date: -1 });
    
    return res.status(200).json({ vaccines });
  } catch (error) {  
     return res.status(500).json({ message: error.message });
  }
};


const getVaccineById = async (req, res) => {
  const vaccineId = req.params.id;
  const userId = req.user._id;

  try {
    const vaccine = await Vaccine.findById(vaccineId).populate('baby');
    if (!vaccine) return res.status(404).json({ message: 'Vaccine not found' });

    // التأكد من أن التطعيم يعود لمستخدم مسجل
    const baby = await Baby.findById(vaccine.baby._id);
    if (baby.user.toString() !== userId.toString()) {
      return res.status(403).json({ message: 'Access denied' });
    }
    return res.status(200).json({ vaccine });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const updateVaccine = async (req, res) => {
  const vaccineId = req.params.id;
  const { name, date, administered } = req.body;

  try {
    const vaccine = await Vaccine.findById(vaccineId).populate('baby');
    if (!vaccine) return res.status(404).json({ message: 'Vaccine not found' });

    // التأكد من أن المستخدم مخول
    if (vaccine.baby.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Access denied' });
    }

    if (name) vaccine.name = name;
    if (date) vaccine.date = date;
    if (administered != null) vaccine.administered = administered;

    await vaccine.save();
    return res.status(200).json({ 
      message: 'Vaccine updated successfully', 
      vaccine 
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// حذف تطعيم
const deleteVaccine = async (req, res) => {
  const vaccineId = req.params.id;

  try {
    const vaccine = await Vaccine.findById(vaccineId).populate('baby');
    if (!vaccine) return res.status(404).json({ message: 'Vaccine not found' });

    // التأكد من أن المستخدم مخول
    if (vaccine.baby.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Access denied' });
    }

    await Vaccine.findByIdAndDelete(vaccineId);
    return res.status(200).json({ message: 'Vaccine deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getDangerReports = async (req, res) => {
  const userId = req.user._id;

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    const dangerData = await DangerAlert.find({ baby: { $in: babyIds } })
      .populate('baby', 'name')
      .sort({ timestamp: -1 });
    
    return res.status(200).json({ dangerData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getGrowthData = async (req, res) => {
  const userId = req.user._id;

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    const growthData = await Growth.find({ baby: { $in: babyIds } })
      .populate('baby', 'name')
      .sort({ date: -1 });
    
    return res.status(200).json({ growthData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getSleepStats = async (req, res) => {
  const userId = req.user._id;
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    const sleepData = await Sleep.find({ 
      baby: { $in: babyIds },
      startTime: { $gte: today }
    }).sort({ startTime: -1 });
    
    return res.status(200).json({ sleepData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getFeedingStats = async (req, res) => {
  const userId = req.user._id;
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    const feedingData = await Feeding.find({ 
      baby: { $in: babyIds },
      time: { $gte: today }
    }).sort({ time: -1 });
    
    return res.status(200).json({ feedingData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getCryingStats = async (req, res) => {
  const userId = req.user._id;
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    const cryingData = await CryAnalysis.find({ 
      baby: { $in: babyIds },
      timestamp: { $gte: today }
    }).sort({ timestamp: -1 });
    
    return res.status(200).json({ cryingData });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getTodayStats = async (req, res) => {
  const userId = req.user._id;
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  try {
    const babies = await Baby.find({ user: userId });
    const babyIds = babies.map(baby => baby._id);
    
    // إحصائيات النوم
    const sleepData = await Sleep.find({ 
      baby: { $in: babyIds },
      startTime: { $gte: today }
    });
    
    const totalSleep = sleepData.reduce((sum, session) => sum + (session.duration || 0), 0);
     // إحصائيات التغذية
    const feedingData = await Feeding.find({ 
      baby: { $in: babyIds },
      time: { $gte: today }
    });
    
    const totalFeedings = feedingData.length;
    const totalAmount = feedingData.reduce((sum, feed) => sum + feed.amount, 0);
    
    // إحصائيات البكاء
    const cryingData = await CryAnalysis.find({ 
      baby: { $in: babyIds },
      timestamp: { $gte: today }
    });
    
    const cryingCount = cryingData.length;
       
    return res.status(200).json({ 
      sleep: {
        totalSleep: totalSleep,
        sessions: sleepData.length
      },
      feeding: {
        totalFeedings: totalFeedings,
        totalAmount: totalAmount
      },
      crying: {
        cryingCount: cryingCount
      }
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};


module.exports = {
  createUser,
  loginUser,
  getUserById,
  updateUserProfile,
  checkAuth,
  updateUserImage,
  getAppointments,
  createAppointment,
  createAnalysis,
  getUserAnalysis,
  createBaby,
  getUserBabies,
  deleteBaby,
  getUserBaby,
  getUserVaccines,
  addFeeding,
  getUserFeedings,
  getFeedingsByBaby, 
  deleteFeeding,
  createDangerAlert,
  getUserAlerts,
  getUserNotifications, 
  createNotification,
  markAsRead, 
  scheduleNotification, 
  deleteNotification,
  getGrowthReports, 
  getFeedingReports, 
  getSleepReports,
  startSleep, 
  endSleep, 
  getAllSleepSessions, 
  getSleepSessionsByBaby, 
  deleteSleepSession, 
  getVaccineReports, 
  getDangerReports,
  changePassword, 
  updateChildInfo,
  getGrowthData, 
  getSleepStats, 
  getFeedingStats, 
  getCryingStats, 
  getTodayStats,
  addVaccine, 
  getAllVaccines, 
  getVaccineById, 
  updateVaccine, 
  deleteVaccine,
 // updateCv,
};
