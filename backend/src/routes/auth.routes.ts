import {Router , Request, Response} from "express";
import { db } from '../db'; // Assuming you have a db module to handle database operations
import {NewUser, users} from "../db/schema"; // Assuming you have a schema module to define your database schema
import { eq } from "drizzle-orm";
import bcryptjs from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { auth, AuthRequest } from "../middlewares.ts/auth.middlewares";

const authRouter = Router();

interface SignUpBody{
    name: string;
    email: string;
    password: string;
}

interface LoginBody{
    email: string;
    password: string;
}

authRouter.post("/signup", async(req: Request<{}, {}, SignUpBody> , res: Response)=>{
    try {
        // get request body
        const {name, email, password} = req.body;
        
        

        // check if the user already exists
        const existingUser = await db
        .select()
        .from(users)
        .where(eq(users.email, email))

        if(existingUser.length > 0) {
            res.status(400).json({
                error: "User already exists"
            });
            return;
        }
        //hashed password
        const hashedPassword = await bcryptjs.hash(password, 8);
        
        

        // create a new user and store it in the database
        const newUser:NewUser = {
            name,
            email,
            password: hashedPassword,
            createdAt: new Date(),
            updatedAt: new Date()
        }

        console.log(newUser);
        

        const [user] =  await db.insert(users).values(newUser).returning();
        res.status(201).json(user);
        
    } catch (error) {
        res.status(500).json({
            error:error
        }
    );
}
});

authRouter.post("/login", async(req: Request<{}, {}, LoginBody> , res: Response)=>{
    try {
        // get request body
        const {email, password} = req.body;
        
        // check if the user already exists
        const existingUser = await db
        .select()
        .from(users)
        .where(eq(users.email, email))

        console.log(existingUser);
        
        
        if(!existingUser) {
            res.status(400).json({
                error: "User with this email does not exist"
            });
            return;
        }
        //hashed password
        const isMatched = await bcryptjs.compare(password, existingUser[0].password);
        if(!isMatched) {
            res.status(400).json({
                error: "Password is incorrect"
            });
            return;
        }
        console.log("isMatched",isMatched);
        

        const token = jwt.sign({
            id:existingUser[0].id,
        },"passwordKey");

        console.log(token);
        

        res.status(200).json({token, ...existingUser});
        console.log("routes completed.");
        
    } catch (error) {
        res.status(500).json({
            error:error
        }
    );
}
});

authRouter.post("/tokenIsValid", async(req,res)=>{
    try {
    //get the header
    const token = req.header("x-auth-token");

    if(!token){
        res.json(false);
        return;
    }
    //verify if the token is valid

    const verified = jwt.verify(token, "passwordKey");
    if(!verified){
        res.json(false);
        return;
    }
    //get the user data if the token is valid
    const verifiedToken = verified as { id: string };
    const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id));

    // if no user return false.
    if(!user){
        res.json(false);
        return;
    }
    res.json(true);
} catch (e) {
    res.status(500).json(false) 
}
})

authRouter.get("/", auth, async (req: AuthRequest, res) => {
  try {
    if (!req.user) {
      res.status(401).json({ error: "User not found!" });
      return;
    }

    const [user] = await db.select().from(users).where(eq(users.id, req.user));

    res.json({ ...user, token: req.token });
  } catch (e) {
    res.status(500).json(false);
  }
});

export default authRouter;