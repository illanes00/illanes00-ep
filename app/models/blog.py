# app/models/blog.py
import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime
from app.db import Base
from sqlalchemy.orm import relationship

class BlogPost(Base):
    __tablename__ = "blog_posts"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    content = Column(Text, nullable=False)

    author_email = Column(String(200), default="martin.illanes@espaciopublico.cl")
    tag    = Column(String(120), nullable=True)   # ✔ nuevo campo

    views  = Column(Integer, default=0)
    likes  = Column(Integer, default=0)
    project_id = Column(Integer)     # enlaza con projects.id  (opcional)
    comments = relationship("Comment", backref="post", cascade="all, delete-orphan")

    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(
        DateTime,
        default=datetime.datetime.utcnow,
        onupdate=datetime.datetime.utcnow,
    )

    @property
    def month_key(self) -> str:
        """Devuelve 'YYYY-MM' para agrupar en Jinja."""
        return self.created_at.strftime("%Y-%m")