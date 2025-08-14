# app/models/whitelist.py
from sqlalchemy import Column, String
from app.db import Base
class Whitelist(Base):
    __tablename__="whitelist"
    email = Column(String(200), primary_key=True)
