import { Router } from "express";
import { auth, AuthRequest } from "../middlewares.ts/auth.middlewares";
import { NewTask, tasks } from "../db/schema";
import {db} from "../db/index";
import { eq } from "drizzle-orm";
import { d } from "drizzle-kit/index-BAUrj6Ib";

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

taskRouter.post("/sync", auth, async(req: AuthRequest, res)=>{
    try {
        // const {taskId, ...rest} = req.body;
        // await db.update(tasks).set(rest).where(eq(tasks.id, taskId));   
        const taskList = req.body;
        console.log("taskList", taskList);

        const filteredTasks: NewTask[] = [];

        for(let t of taskList){
          t = {...t, dueAt: new Date(t.dueAt),
             dueTime: new Date(t.dueTime),
             createdAt: new Date(t.createdAt),
              updatedAt: new Date(t.updatedAt),
              uid:req.user};
          filteredTasks.push(t);  
        }
        console.log("filteredTasks", filteredTasks);
        
        const pushedTasks = await db.insert(tasks).values(filteredTasks).returning(); 


        res.status(201).json(pushedTasks);
    } catch (e) {
        res.status(500).json({error: "Error updating task"});
    }
})

export default taskRouter;
