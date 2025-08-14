PY=python3
UVICORN=uvicorn

.PHONY: run dev fmt lint

run:
	$(UVICORN) asgi:app --host $${HOST-127.0.0.1} --port $${PORT-8000}

dev:
	$(UVICORN) asgi:app --reload --host $${HOST-127.0.0.1} --port $${PORT-8000}

