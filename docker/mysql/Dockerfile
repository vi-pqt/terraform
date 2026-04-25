FROM mysql:8.0

# Bake in schema migrations and seed data
# MySQL auto-executes files in /docker-entrypoint-initdb.d/ on first boot
# Files are executed in alphabetical order
COPY db/init.sh /docker-entrypoint-initdb.d/00-init.sh
COPY db/migrations/ /docker-entrypoint-initdb.d/migrations/
COPY db/seed/ /docker-entrypoint-initdb.d/seed/

EXPOSE 3306
