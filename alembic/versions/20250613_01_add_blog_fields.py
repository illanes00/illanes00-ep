"""add author_email views likes to blog_posts

Revision ID: 20250613_01
Revises: ddc03213bc39
Create Date: 2025-06-13 15:10:00

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '20250613_01'
down_revision = 'ddc03213bc39'
branch_labels = None
depends_on = None


def upgrade() -> None:
    with op.batch_alter_table("blog_posts") as batch:
        batch.add_column(sa.Column("author_email", sa.String(200), nullable=True))
        batch.add_column(sa.Column("views", sa.Integer(), nullable=False, server_default="0"))
        batch.add_column(sa.Column("likes", sa.Integer(), nullable=False, server_default="0"))


def downgrade() -> None:
    with op.batch_alter_table("blog_posts") as batch:
        batch.drop_column("likes")
        batch.drop_column("views")
        batch.drop_column("author_email")
