
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from langchain.chains import SimpleSequentialChain
from langchain.llms import HuggingFacePipeline
from transformers import pipeline
from sqlalchemy import create_engine, Column, Integer, String, Float, ForeignKey, Text
from sqlalchemy.orm import sessionmaker, declarative_base, relationship

# Database Configuration
DATABASE_URL = "postgresql://username:password@localhost/chatbotdb"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# FastAPI App
app = FastAPI()

# Define Models
class Supplier(Base):
    __tablename__ = "suppliers"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    contact_info = Column(Text)
    product_categories = Column(Text)
    products = relationship("Product", back_populates="supplier")


class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    brand = Column(String)
    price = Column(Float)
    category = Column(String)
    description = Column(Text)
    supplier_id = Column(Integer, ForeignKey("suppliers.id"))
    supplier = relationship("Supplier", back_populates="products")


# Create Tables
Base.metadata.create_all(bind=engine)

# Input Model
class Query(BaseModel):
    query: str

# Load LLM
llm_pipeline = pipeline("text-generation", model="gpt2")
llm = HuggingFacePipeline(pipeline=llm_pipeline)

@app.post("/query")
async def process_query(query: Query):
    session = SessionLocal()

    try:
        # Basic Query Handling
        if "products under brand" in query.query.lower():
            brand = query.query.split("brand")[-1].strip()
            products = session.query(Product).filter(Product.brand.ilike(f"%{brand}%")).all()
            return {"response": [f"{p.name} (${p.price})" for p in products]}

        elif "suppliers provide" in query.query.lower():
            category = query.query.split("provide")[-1].strip()
            suppliers = session.query(Supplier).filter(Supplier.product_categories.ilike(f"%{category}%")).all()
            
            # Summarize Suppliers
            supplier_text = " ".join([f"{s.name}: {s.contact_info}" for s in suppliers])
            summary = llm(supplier_text)[0]["generated_text"]
            return {"response": summary}

        elif "details of product" in query.query.lower():
            product_name = query.query.split("product")[-1].strip()
            product = session.query(Product).filter(Product.name.ilike(f"%{product_name}%")).first()
            if product:
                return {
                    "response": {
                        "name": product.name,
                        "brand": product.brand,
                        "price": product.price,
                        "category": product.category,
                        "description": product.description,
                    }
                }
            else:
                return {"response": "Product not found."}

        else:
            return {"response": "I couldn't understand your query. Please try again."}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        session.close()
