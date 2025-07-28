import uvicorn
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
  return {"message": "Welcome to the AIS API!"}


uvicorn.run('main:app', host="localhost", port=8000)
