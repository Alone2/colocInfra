FROM alpine:latest AS base

# Spliit version and repo
ARG VERSION="1.15.0"
ARG REPOSITORY="https://github.com/spliit-app/spliit"

# Env varlables
ARG NEXT_TELEMETRY_DISABLED=1

# db
ENV POSTGRES_PASSWORD=1234
ENV POSTGRES_PRISMA_URL=postgresql://postgres:${POSTGRES_PASSWORD}@db
ENV POSTGRES_URL_NON_POOLING=postgresql://postgres:${POSTGRES_PASSWORD}@db
# app-minio
ENV SPLIIT_NEXT_PUBLIC_ENABLE_EXPENSE_DOCUMENTS=false
ENV SPLIIT_S3_UPLOAD_KEY=AAAAAAAAAAAAAAAAAAAA
ENV SPLIIT_S3_UPLOAD_SECRET=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ENV SPLIIT_S3_UPLOAD_BUCKET=spliit
ENV SPLIIT_S3_UPLOAD_REGION=eu-north-1
ENV SPLIIT_S3_UPLOAD_ENDPOINT=s3://minio.example.com
# app-openai
ENV SPLIIT_NEXT_PUBLIC_ENABLE_RECEIPT_EXTRACT=false
ENV SPLIIT_OPENAI_API_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXX
ENV SPLIIT_NEXT_PUBLIC_ENABLE_CATEGORY_EXTRACT=false

# Install dependencies
RUN apk add --update --no-cache bash \
                                git \
                                ca-certificates \
                                npm \
                                nodejs-current \
                                openssl

# Workdir for source
WORKDIR /src

# Clone Repo
RUN git clone ${REPOSITORY} && \
    cd spliit && \
    git checkout ${VERSION}

# Workdir for split
WORKDIR /src/spliit

# Build image
RUN npm ci --ignore-scripts && \
    npx prisma generate && \ 
    cp scripts/build.env .env && \
    npm run build

# Remove cache
RUN rm -r .next/cache

# Runtime
FROM alpine:latest AS runner

# Install dependencies
RUN apk add --update --no-cache npm \
                                nodejs-current

# Workdir for spliit
WORKDIR /split

# Copy compiled data
COPY --from=base /src/spliit/package.json \
                 /src/spliit/package-lock.json \
                 /src/spliit/next.config.mjs    ./
COPY --from=base /src/spliit/node_modules       ./node_modules
COPY --from=base /src/spliit/public             ./public
COPY --from=base /src/spliit/scripts            ./scripts
COPY --from=base /src/spliit/prisma             ./prisma
COPY --from=base /src/spliit/.next              ./.next

COPY ./entrypoint.sh ./entrypoint.sh

# Ports
EXPOSE 3000/tcp

# entrypoint
ENTRYPOINT ["/bin/sh", "/split/entrypoint.sh"]

