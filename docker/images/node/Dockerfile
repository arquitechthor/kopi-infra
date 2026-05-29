FROM node:22-alpine

# Create non-root user
RUN addgroup -S kopi && adduser -S kopi -G kopi

USER kopi
WORKDIR /app
