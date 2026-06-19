import psycopg2
from psycopg2.extras import RealDictCursor

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "user": "postgres",
    "password": "040922",
    "database": "rhythm_site"
}

try:
    print("Testing connection with RealDictCursor...")
    conn = psycopg2.connect(**DB_CONFIG)
    print("Success!")
    conn.close()
except Exception as e:
    print("Failed:")
    import traceback
    traceback.print_exc()
