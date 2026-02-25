import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
<<<<<<< HEAD
import { join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // ✅ uploads сыртқа беру
  app.useStaticAssets(join(process.cwd(), 'uploads'), {
    prefix: '/uploads',
=======

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.enableCors({
    origin: true,
    credentials: true,
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
  });

  app.setGlobalPrefix('api');

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
<<<<<<< HEAD
      transformOptions: { enableImplicitConversion: true },
=======
      transformOptions: {
        enableImplicitConversion: true,
      },
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
    }),
  );

  const config = new DocumentBuilder()
    .setTitle('Roomie API')
    .setDescription('Roommate app backend API')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  await app.listen(process.env.PORT ?? 3000);
}
<<<<<<< HEAD
bootstrap();
=======
bootstrap();
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
