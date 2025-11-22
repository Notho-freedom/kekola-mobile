
# Importe types SQLAlchemy.
from sqlalchemy import Column, Integer, String, Float, ForeignKey, UniqueConstraint
# Importe relationship.
from sqlalchemy.orm import relationship
# Importe Base.
from .database import Base

# Classe DailyMetric - table pour saisies journalières (section 9 specs).
class DailyMetric(Base):
    __tablename__ = "daily_metrics"
    
    # Colonne id - clé primaire.
    id = Column(Integer, primary_key=True, index=True)
    # Colonne date - format ISO (e.g., 2025-08-03).
    date = Column(String)
    # Colonne sales - ventes en float (XOF).
    sales = Column(Float)
    # Colonne cash - cash en float.
    cash = Column(Float)
    # Colonne user_id - lie à un user (clé étrangère).
    user_id = Column(Integer, ForeignKey("users.id"))
    # Colonne source - source de la saisie (e.g., "APP").
    source = Column(String, default="APP")
    
    # Relation inverse avec User.
    user = relationship("User", back_populates="metrics")

    # Contrainte d'unicité sur date et user_id
    __table_args__ = (UniqueConstraint('date', 'user_id', name='uix_date_user_id'),)