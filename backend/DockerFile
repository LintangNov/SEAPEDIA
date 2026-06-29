FROM node:20-alpine

# Set working directory
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npx prisma generate
RUN npm run build

EXPOSE 7860
ENV PORT=7860

RUN chown -R 1000:1000 /app
USER 1000

CMD ["npm", "run", "start:prod"]