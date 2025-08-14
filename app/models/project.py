import datetime
from sqlalchemy import Column, Integer, String, Text, Date, DateTime
from app.db import Base

class Project(Base):
    __tablename__ = "projects"

    id          = Column(Integer, primary_key=True)
    name        = Column(String(120), nullable=False, unique=True)
    description = Column(Text)
    owner_email = Column(String(200))
    status      = Column(String(40), default="en progreso")  # abierto / cerrado
    start_date  = Column(Date)
    end_date    = Column(Date)

    created_at  = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at  = Column(DateTime,
                         default=datetime.datetime.utcnow,
                         onupdate=datetime.datetime.utcnow)
