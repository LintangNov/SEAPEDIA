# ⚙️ Seapedia Backend — NestJS Engine

This is the core REST API engine for the Seapedia application, built using the progressive Node.js framework [NestJS](https://nestjs.com), [Prisma ORM](https://prisma.io), and backed by a [PostgreSQL](https://postgresql.org) database.

---

## 🚀 Getting Started

### 1. Prerequisite Installations
Ensure you have **Node.js (v22+)** and **npm** installed globally. You must also have a running **PostgreSQL** instance.

### 2. Local Installation
Navigate to this folder and install all local dependencies:
```bash
cd backend
npm install
```

---

## 🔒 Environment Variables

Duplicate the template to define your environment configurations. Create a `.env` file in the root of the `/backend` directory:

```bash
cp .env.example .env
```

Define the following environment variables inside `.env`:

| Key | Description | Example / Recommended Value |
| :--- | :--- | :--- |
| `DATABASE_URL` | Connection string pointing to your PostgreSQL database. | `postgresql://postgres:password@localhost:5432/seapedia_db?schema=public` |
| `JWT_SECRET` | Secret token signing string for security and session tokens. | `kcgkejedukbelalangsembah` *(Use a strong, unique secret key)* |
| `PORT` | Optional. Defines what port the NestJS server binds to (default: `3000`). | `3000` |

---

## 🗄️ Database Management (Prisma)

Prisma ORM is utilized for database modeling, migrations, and querying.

### 🔌 Synchronizing Database Schema
Synchronize the PostgreSQL database with the model design described in `prisma/schema.prisma`:
```bash
npx prisma db push
```

### 🧬 Generating Prisma Client
Generate the client engine assets after changing any database models in `schema.prisma`:
```bash
npx prisma generate
```

### 📈 Database Migrations
To track database versions and execute database schema upgrades:
```bash
npx prisma migrate dev --name init
```

### 🌱 Seeding Mock/Initial Data
Seed the database with default roles (`ADMIN`, `SELLER`, `BUYER`, `DRIVER`) and a default `superadmin` profile:
```bash
npx prisma db seed
```
> [!IMPORTANT]
> The seed script sets up a default admin profile with:
> *   **Username**: `superadmin`
> *   **Password**: `adminpassword123`

---

## 💻 Running the Server

Run the development, debugging, or production build server using npm scripts:

```bash
# Development (with auto-reload/watch mode)
npm run start:dev

# Debugging mode (with Chrome DevTools attachment)
npm run start:debug

# Production build compilation
npm run build

# Running the production bundle
npm run start:prod
```

---

## 🧪 Testing Suite

Execute tests inside the engine:
```bash
# Run unit tests
npm run test

# Run end-to-end integration tests
npm run test:e2e

# Run test coverage checks
npm run test:cov
```

---

## 📖 API Documentation (Swagger)

By default, the API route documentation is exposed at:
🔗 **[http://localhost:3000/api](http://localhost:3000/api)** *(or the custom port specified in your `.env`)*

> [!NOTE]
> If Swagger is not yet loaded in your environment, follow this simple snippet to enable it:
>
> 1. Install Swagger package:
>    ```bash
>    npm install --save @nestjs/swagger
>    ```
> 2. Add setup to `src/main.ts`:
>    ```typescript
>    import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
> 
>    const config = new DocumentBuilder()
>      .setTitle('Seapedia API')
>      .setDescription('Seapedia Multi-Role Marketplace API Documentation')
>      .setVersion('1.0')
>      .addBearerAuth()
>      .build();
>    const document = SwaggerModule.createDocument(app, config);
>    SwaggerModule.setup('api', app, document);
>    ```
