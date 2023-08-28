FROM node:18-slim

WORKDIR /app

COPY package*.json ./

RUN npm install --only=production
COPY . .

EXPOSE 3000
# NOTE! using OpenTelemetry to propagete trace context.
# https://istio.io/latest/docs/tasks/observability/distributed-tracing/overview/
CMD [ "node", "-r", "./tracing.js", "index.js" ]