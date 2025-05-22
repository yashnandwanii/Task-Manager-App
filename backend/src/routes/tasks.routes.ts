import { Router } from "express";
import { auth, AuthRequest } from "../middlewares.ts/auth.middlewares";
import { NewTask, tasks } from "../db/schema";
import {db} from "../db/index";
import { eq } from "drizzle-orm";

const taskRouter = Router();
taskRouter.post("/", auth, async (req: AuthRequest, res) => {
  try {
    const newTask: NewTask = {
      ...req.body,
      dueAt: new Date(req.body.dueAt),
      dueTime: new Date(req.body.dueTime), 
      uid: req.user!,
    };

    const [task] = await db.insert(tasks).values(newTask).returning();
    res.status(201).json(task);
  } catch (e) {
    console.error("❌ Error creating task:", e);
    res.status(500).json({ error: e instanceof Error ? e.message : "Error creating task" });
  }
});


taskRouter.get("/", auth, async(req: AuthRequest, res)=>{
    try {
        const allTasks = await db.select().from(tasks).where(eq(tasks.uid, req.user!));
        res.json(allTasks);        
    } catch (e) {
        res.status(500).json({error: "Error fetching tasks"});  
    }
})


taskRouter.delete("/", auth, async(req: AuthRequest, res)=>{
    try {
        const {taskId}:{taskId: string} = req.body;
        await db.delete(tasks).where(eq(tasks.id, taskId));   
        
        res.json(true);
    } catch (e) {
        res.status(500).json({error: "Error deleting task"});
    }
})

export default taskRouter;
