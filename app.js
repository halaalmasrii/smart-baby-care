const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require("cors");
const multer = require('multer');
const path = require('path');
const routes = require('./routes/routes');


dotenv.config();

const app = express();
const PORT = process.env.PORT || 51974;


// استدعاء sendNotification من ملف الخدمات
const { sendNotification } = require("./services/notificationService");

// مسار اختبار إرسال الإيميل
app.get('/test-email', async (req, res) => {
  try {
    await sendNotification({
      recipient: "hala.almasri.s.2002@gmail.com",  // غيّر هذا للإيميل اللي بدك تجرب عليه
      subject: "Test Email",
      message: "This is a test email to verify sending.",
    });
    res.send("Test email sent!");
  } catch (error) {
    res.status(500).send("Failed to send test email: " + error.message);
  }
});


const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); 
  }
});

app.use(multer({
  storage:storage}).fields(
    [{name:'image'}]
  ));


 app.use( cors({
     origin: '*',
     credentials: true 
   })
 );

 const cookieParser = require('cookie-parser');
app.use(cookieParser());

app.use(express.json());
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('Connected to MongoDB');
}).catch((error) => {
  console.log('MongoDB connection error: ', error);
});


app.use('/api', routes);

process.on("uncaughtException", (err) => {
  console.error("Uncaught Exception:", err);
});

process.on("unhandledRejection", (err) => {
  console.error("Unhandled Rejection:", err);
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});


