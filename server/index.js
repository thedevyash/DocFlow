const express =require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const cors = require("cors");
const http=require("http");
const documentRouter = require("./routes/document");
const Document = require("./models/document");
const PORT=process.env.PORT | 3001;
const app =express();

var server =http.createServer(app);

var io=require("socket.io")(server);

app.use(cors());
//har file ko lake index.js mei bhi dalo app.use() ka use kro
//middleware hai ye dono...data ko server jne se pehle hi manipulate krte
//data ko json format mei krke bhejo server pe
app.use(express.json());
//middleware hai ye...bar bar req bnane se ach hai ek alg file bna lo sari routes ke liye aur unko index file mei import krlo app.use() use krke
app.use(authRouter);
app.use(documentRouter);



const DB="mongodb+srv://thedevyash:AxauyufrrI2wmJ7I@cluster0.yrgf5bl.mongodb.net/?retryWrites=true&w=majority";


mongoose.connect(DB).then(()=>{
    console.log("connection succesful");
}).catch((err)=>{
    console.log(err);
});

io.on("connection", (socket) => {
    socket.on("join", (documentId) => {
      socket.join(documentId);
    });
  
    socket.on("typing", (data) => {
      socket.broadcast.to(data.room).emit("changes", data);
    });
  
    socket.on("save", (data) => {
      saveData(data);
    });
  });

  const saveData = async (data) => {
    let document = await Document.findById(data.room);
    document.content = data.delta;
    document = await document.save();
  };

  
server.listen(PORT,"0.0.0.0",()=>

{console.log(`connected at port ${PORT}`);
});