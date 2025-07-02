
#  Product CRUD App

A full-stack CRUD application built with:

- **Backend:** Node.js + Express + SQL Server
- **Frontend:** Flutter + Provider

---

##  Folder Structure

```
├── backend/          # Node.js + Express API
│   ├── controllers/  # Controller logic
│   ├── routes/       # Express routes
│   ├── sql/          # SQL script for table and sample data
│   ├── .env          # Your environment variables (DO NOT COMMIT)
│   ├── .env.example  # Template env file for setup
│   ├── db.js         # DB connection setup (MSSQL)
│   └── index.js      # Entry point
└── frontend/         # Flutter app
```

---

##  How to Run the Project

### 🛠 Backend Setup

1. Install dependencies:
   ```bash
   cd backend
   npm install
   ```

2. Create a `.env` file using `.env.example`:
   ```env
   DB_USER=sa
   DB_PASSWORD=Masterly123!
   DB_SERVER=localhost
   DB_DATABASE=ProductDB
   DB_PORT=1433
   ```

3. Start your SQL Server (Docker, TablePlus, etc.)

4. Run SQL script to create table:
   ```sql
   -- backend/sql/product_table.sql
   ```

5. Start the server:
   ```bash
   node index.js
   ```

>  API is served at: `http://localhost:3000`

---

###  Frontend Setup

1. Go to the Flutter app:
   ```bash
   cd frontend
   ```

2. Install packages:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

> Ensure backend is running at `http://localhost:3000`  
> If testing on mobile/emulator, update base URL accordingly

---

##  Features

###  Backend (Node.js + Express + SQL Server)
- REST API for full product CRUD
- Safe input validation
- Full product returned on Create/Update (`OUTPUT INSERTED.*`)
- CORS enabled for frontend
- Environment-based DB config

###  Frontend (Flutter + Provider)
- Product list with lazy load & pull-to-refresh
- Add/Edit/Delete with form validation
- Realtime search (with debounce)
- Sort by price or stock
- Export to PDF/CSV
- Share CSV file
- Toast notifications + loading indicators

---

---

##  Author

- **Sok Masterly** (ITC Cambodia)

---


