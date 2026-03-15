# Stage 1: Base image
FROM node:18-alpine AS base

# Stage 2: Install dependencies
FROM base AS deps
WORKDIR /app

# Copy package.json và package-lock.json (dùng npm)
COPY package.json package-lock.json ./

# Cài dependencies
RUN npm ci

# Stage 3: Build application
FROM base AS builder
WORKDIR /app

# Copy node_modules từ stage deps
COPY --from=deps /app/node_modules ./node_modules

# Copy toàn bộ source code
COPY . .

# Build Next.js
RUN npm run build

# Stage 4: Production server
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copy build output từ stage builder
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Expose port
EXPOSE 3000

# Command chạy server
CMD ["node", "server.js"]
