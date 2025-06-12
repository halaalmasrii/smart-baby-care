const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const cors = require("cors");
const multer = require('multer');
const path = require('path');
const routes = require('./routes/routes');


dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;


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
     origin: "http://localhost:3001",
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


