# Build
FROM python:3.10-slim AS build

WORKDIR /app

COPY app-files .


# Run
FROM python:3.10-alpine

RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup --home /home/appuser appuser

WORKDIR /app

COPY --from=build /app /app

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

CMD ["python3", "-m", "http.server", "3000"]