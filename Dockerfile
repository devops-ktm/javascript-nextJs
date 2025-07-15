# ---------- Build stage ----------
FROM node:20-alpine AS builder

WORKDIR /app

# Ignore unnecessary files
COPY package.json package-lock.json ./
RUN npm install --no-audit --no-fund

# Copy specific configuration files
COPY next.config.ts ./

# Copy the rest of the application code
COPY . .

# Build the Next.js app
RUN npm run build

# ---------- Production stage ----------
FROM node:20-alpine AS runner

WORKDIR /app

# Set non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Change ownership and copy package files
COPY --chown=nextjs:nodejs package.json package-lock.json ./

# Set network timeout and buildkit
ENV DOCKER_BUILDKIT=1
ENV BUILDKIT_INLINE_CACHE=1
ENV NPM_CONFIG_NETWORK_TIMEOUT=100000

# Install only production dependencies
RUN npm install --omit=dev --no-audit --no-fund

# Copy built assets from builder stage with ownership change
COPY --chown=nextjs:nodejs --from=builder /app/.next ./.next
COPY --chown=nextjs:nodejs --from=builder /app/public ./public
COPY --chown=nextjs:nodejs --from=builder /app/next.config.ts ./
COPY --chown=nextjs:nodejs --from=builder /app/package.json ./
COPY --chown=nextjs:nodejs --from=builder /app/src ./src

# Switch to non-root user
USER nextjs

# Expose the port
EXPOSE 3000

# Start the Next.js app
CMD ["npx", "next", "start", "-p", "3000"]