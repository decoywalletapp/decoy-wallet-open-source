# Use a small Node image
FROM node:22-alpine

# Create app directory
WORKDIR /usr/src/app

# Install dependencies first (for better layer caching)
COPY package.json package-lock.json ./
RUN npm install --omit=dev

# Copy the rest of the source
COPY . .

# Environment
ENV NODE_ENV=production

# Cloud Run will set PORT; our code uses process.env.PORT || 8081
# EXPOSE is mostly documentation, but we can set it:
EXPOSE 8081

# Start the watcher
CMD ["node", "index.js"]
