# Dockerfile for decoy-sms-worker
FROM node:22-alpine

WORKDIR /usr/src/app

# Install deps
COPY package*.json ./
RUN npm install --omit=dev

# Copy the rest of the code
COPY . .

# Cloud Run will inject PORT; we default to 8082
ENV PORT=8082

# Start the worker HTTP server (Express)
CMD ["node", "index.js"]
