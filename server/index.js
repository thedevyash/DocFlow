const express =require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const cors = require("cors");
const PORT=process.env.PORT | 3001;
const app =express();

app.use(cors());
//har file ko lake index.js mei bhi dalo app.use() ka use kro
//middleware hai ye dono...data ko server jne se pehle hi manipulate krte
//data ko json format mei krke bhejo server pe
app.use(express.json());
//middleware hai ye...bar bar req bnane se ach hai ek alg file bna lo sari routes ke liye aur unko index file mei import krlo app.use() use krke
app.use(authRouter);



const DB="mongodb+srv://thedevyash:AxauyufrrI2wmJ7I@cluster0.yrgf5bl.mongodb.net/?retryWrites=true&w=majority";


mongoose.connect(DB).then(()=>{
    console.log("connection succesful");
}).catch((err)=>{
    console.log(err);
});

app.listen(PORT,"0.0.0.0",()=>

{console.log(`connected at port ${PORT}`);
});