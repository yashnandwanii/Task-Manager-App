import {Router , Request, Response} from 'express';
import { db } from '../db'; // Assuming you have a db module to handle database operations
import {NewUser, users} from "../db/schema"; // Assuming you have a schema module to define your database schema
import { eq } from "drizzle-orm";
import bcryptjs from 'bcryptjs';

const authRouter = Router();

interface SignUpBody{
    name: string;
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

        if(existingUser) {
            res.status(400).json({
                message: "User already exists"
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
            updatedAt: new Date(),
            lastLogin: new Date()
        }
        const [user] =  await db.insert(users).values(newUser).returning();
        res.status(201).json(user);
        
    } catch (error) {
        res.status(500).json({
            error:error
        });
}
});

authRouter.get("/", (req,res)=>{
    res.send("Welcome to the auth route");
});

export default authRouter;