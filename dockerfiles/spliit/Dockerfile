FROM alpine:latest AS base

# Spliit version and repo
ARG VERSION="1.15.0"
ARG REPOSITORY="https://github.com/spliit-app/spliit.git"

##ARG REPOSITORY_FEATURE="https://github.com/trandall2/spliit_recurring_expense.git"
##ARG FEATURE_BRANCH="attempt_to_add_recurring_expense_functionality"

# Env varlables
ARG NEXT_TELEMETRY_DISABLED=1

# db
ENV POSTGRES_PASSWORD=1234
ENV POSTGRES_PRISMA_URL=postgresql://postgres:${POSTGRES_PASSWORD}@postgres
ENV POSTGRES_URL_NON_POOLING=postgresql://postgres:${POSTGRES_PASSWORD}@postgres
# app-minio
ENV SPLIT_NEXT_PUBLIC_ENABLE_EXPENSE_DOCUMENTS=false
ENV SPLIT_S3_UPLOAD_KEY=AAAAAAAAAAAAAAAAAAAA
ENV SPLIT_S3_UPLOAD_SECRET=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ENV SPLIT_S3_UPLOAD_BUCKET=spliit
ENV SPLIT_S3_UPLOAD_REGION=eu-north-1
ENV SPLIT_S3_UPLOAD_ENDPOINT=s3://minio.example.com
# app-openai
ENV SPLIT_NEXT_PUBLIC_ENABLE_RECEIPT_EXTRACT=false
ENV SPLIT_OPENAI_API_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXX
ENV SPLIT_NEXT_PUBLIC_ENABLE_CATEGORY_EXTRACT=false

# Install dependencies
RUN apk add --update --no-cache bash \
                                git \
                                ca-certificates \
                                npm \
                                nodejs-current \
                                openssl

# Workdir for source
WORKDIR /src

# Patch
COPY ./patch.txt patch.txt

# Clone Repo
RUN git clone ${REPOSITORY} && \
    cd spliit && \
    git checkout ${VERSION} 
    
### Clone Repo
##RUN git clone ${REPOSITORY} && \
##    cd spliit && \
##    git config --global user.email "split@a1n.ch" && \
##    git config --global user.name "split" && \
##    git checkout ${VERSION} && \
##    git remote add feature ${REPOSITORY_FEATURE} && \
##    git fetch feature && \
##    git rebase feature/${FEATURE_BRANCH} && \
##    git apply ../patch.txt

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
                                nodejs-current \
                                ca-certificates \
                                openssl

# add split user
RUN    addgroup --gid 12346 -S split && \
       adduser --disabled-password --uid 12346 --ingroup split split && \
       mkdir /split && \
       chown -R 12346:12346 /split


# Run as unprivileged user
USER split

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

# Permissions
USER   root
RUN    chown -R 12346:12346 /split
USER   split

# Ports
EXPOSE 3000/tcp

# entrypoint
ENTRYPOINT ["/split/entrypoint.sh"]

