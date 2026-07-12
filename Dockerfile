# Stage 1: Build SheepShaver to WebAssembly with Emscripten
FROM trzeci/emscripten AS builder

# Copy all local code into the container
WORKDIR /src
COPY . .

# Build flags: output single .js file and configure for WebSockify
RUN em++ -O2 main.cpp -o sheepshaver.js \
    -s WASM=1 \
    -s WEBSOCKET_URL="ws://localhost:8080" \
    -s WEBSOCKET_SUBPROTOCOL="binary"

# Stage 2: Serve the compiled files using Python 3
FROM python:3

WORKDIR /app
# Copy the generated assets from the builder stage
COPY --from=builder /src/sheepshaver.js /app/
COPY --from=builder /src/sheepshaver.wasm /app/
# Ensure any other required static files are also copied if they exist
COPY --from=builder /src/index.html /app/

# Expose the web server port
EXPOSE 8000

# Serve the files using Python's HTTP server
ENTRYPOINT ["python3", "-m", "http.server", "8000"]
