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
  createBaby,
  getUserBabies,
  deleteBaby,
  getUserBaby,
  getUserNotifications, 
  createNotification,
  markAsRead, 
  scheduleNotification, 
  deleteNotification,
  getAllSleepSessions, 
  changePassword,  
  getTodayStats,
};
