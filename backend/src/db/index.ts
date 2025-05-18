import { Pool } from "pg";
import { drizzle } from "drizzle-orm/node-postgres";

const pool = new Pool(
    {
        connectionString: "postgresql://postgres:test123@db:5432/mydatabase",
    }
);

export const db = drizzle(pool);

