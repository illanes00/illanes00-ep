import datetime
from sqlalchemy import Column, Integer, Text, DateTime, ForeignKey, String
from app.db import Base
from sqlalchemy.orm import relationship

class Comment(Base):
    __tablename__ = "comments"

    id        = Column(Integer, primary_key=True)
    post_id   = Column(Integer, ForeignKey("blog_posts.id", ondelete="CASCADE"))
    author_email = Column(String(200))
    content   = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
