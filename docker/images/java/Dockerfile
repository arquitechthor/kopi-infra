FROM eclipse-temurin:21-jre-alpine

# Create non-root user
RUN addgroup -S kopi && adduser -S kopi -G kopi

USER kopi
WORKDIR /app
