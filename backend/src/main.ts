import { NestFactory } from '@nestjs/core';
import { Logger, ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';
import { Response } from 'express';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // CORS
  const env = process.env.NODE_ENV ?? 'development';
  const allowedOrigins = (process.env.CORS_ORIGINS ?? '')
    .split(',')
    .map((item) => item.trim())
    .filter((item) => item.length > 0);

  const corsOrigin: boolean | string[] =
    allowedOrigins.length > 0
      ? allowedOrigins
      : env == 'production'
        ? false
        : true;

  if (env == 'production' && allowedOrigins.length == 0) {
    logger.warn(
      'CORS_ORIGINS is empty in production. Cross-origin requests are denied.',
    );
  }

  app.enableCors({
    origin: corsOrigin,
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

  await app.listen(process.env.PORT ?? 3000);
}

bootstrap();
