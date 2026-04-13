import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';
import { Response } from 'express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // CORS
  app.enableCors({
    origin: true,
    credentials: true,
  });

  // Global prefix
  app.setGlobalPrefix('api');

  // Validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Serve uploads statically
  app.useStaticAssets(join(process.cwd(), 'uploads'), {
    prefix: '/uploads',
  });

  // Serve admin web panel
  app.useStaticAssets(join(process.cwd(), 'admin-web'), {
    prefix: '/admin',
  });

  // Open admin panel by /admin (without explicit /index.html)
  const expressApp = app.getHttpAdapter().getInstance();
  expressApp.get('/admin', (_req: any, res: Response) => {
    res.sendFile(join(process.cwd(), 'admin-web', 'index.html'));
  });
  expressApp.get('/admin/', (_req: any, res: Response) => {
    res.sendFile(join(process.cwd(), 'admin-web', 'index.html'));
  });

  // Swagger
  const config = new DocumentBuilder()
    .setTitle('Roomie API')
    .setDescription('Roommate app backend API')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  await app.listen(process.env.PORT ?? 3001);
}

bootstrap();
