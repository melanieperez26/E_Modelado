import os
from dotenv import load_dotenv

from agno.agent import Agent
from agno.models.openai import OpenAIChat
from agno.playground import Playground
from agno.storage.sqlite import SqliteStorage
from agno.tools.duckduckgo import DuckDuckGoTools
from agno.tools.yfinance import YFinanceTools
from agno.models.groq import Groq

# Cargar variables de entorno
load_dotenv()

# Verificar la existencia de la variable de entorno GROQ_API_KEY
if not os.getenv("GROQ_API_KEY"):
    raise ValueError("ERROR: GROQ_API_KEY no está configurada. Por favor, configúrala en las variables de entorno de Cloud Run.")

# Configurar el directorio temporal
os.makedirs('tmp', exist_ok=True)

# Obtener el puerto desde las variables de entorno
port = int(os.getenv('PORT', 8080))

agent_storage = "tmp/agents.db"

web_agent = Agent(
    name="Melanie Perez",
    model=Groq(id="llama-3.3-70b-versatile"),
    tools=[DuckDuckGoTools()],
    instructions=["Always include sources"],
    storage=SqliteStorage(table_name="web_agent", db_file=agent_storage),
    add_datetime_to_instructions=True,
    add_history_to_messages=True,
    num_history_responses=5,
    markdown=True,
)

finance_agent = Agent(
    name="Finance Agent",
    model=Groq(id="llama-3.3-70b-versatile", api_key=os.getenv("GROQ_API_KEY")),
    tools=[YFinanceTools(stock_price=True, analyst_recommendations=True, company_info=True, company_news=True)],
    instructions=["Always use tables to display data"],
    storage=SqliteStorage(table_name="finance_agent", db_file=agent_storage),
    add_datetime_to_instructions=True,
    add_history_to_messages=True,
    num_history_responses=5,
    markdown=True,
)

# Crear la aplicación
app = Playground(agents=[web_agent, finance_agent]).get_app()

if __name__ == "__main__":
    print(f"Iniciando aplicación en el puerto {port}")
    print(f"GROQ_API_KEY: {'******' if os.getenv('GROQ_API_KEY') else 'NO CONFIGURADA'}")
    print("Para ejecutar localmente, usa:")
    print("python -m uvicorn playground:app --reload --port 8000")
    print("Para Cloud Run, usa Gunicorn como está configurado en el Dockerfile")
