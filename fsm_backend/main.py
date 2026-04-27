from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
import jwt
from datetime import datetime, timedelta

app = FastAPI()

SECRET_KEY = "mysecretkey"
security = HTTPBearer()

# Dummy user
USER = {
    "email": "test@mail.com",
    "password": "123456"
}

# Models
class LoginRequest(BaseModel):
    email: str
    password: str

class Job(BaseModel):
    id: int
    title: str
    location: str

# Dummy job data
jobs = [
    {"id": 1, "title": "AC Repair", "location": "Chennai"},
    {"id": 2, "title": "Fridge Service", "location": "Madurai"},
]

# 🔐 Create Token
def create_token(data: dict):
    payload = data.copy()
    payload["exp"] = datetime.utcnow() + timedelta(hours=1)
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")

# 🔐 Verify Token
def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return True
    except:
        raise HTTPException(status_code=401, detail="Invalid token")

# 🔐 LOGIN API
@app.post("/login")
def login(data: LoginRequest):
    if data.email == USER["email"] and data.password == USER["password"]:
        token = create_token({"email": data.email})
        return {
            "access_token": token,
            "token_type": "bearer"
        }
    raise HTTPException(status_code=401, detail="Invalid credentials")

# 📋 GET JOBS (Protected)
@app.get("/jobs")
def get_jobs(auth=Depends(verify_token)):
    return jobs

# ➕ CREATE JOB
@app.post("/jobs")
def create_job(job: Job, auth=Depends(verify_token)):
    jobs.append(job.dict())
    return {"message": "Job created"}