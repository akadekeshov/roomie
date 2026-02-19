import { IsEmail, IsString, ValidateIf, IsNotEmpty, Validate } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { registerDecorator, ValidationOptions, ValidationArguments } from 'class-validator';

function IsEmailOrPhone(validationOptions?: ValidationOptions) {
  return function (object: Object, propertyName: string) {
    registerDecorator({
      name: 'isEmailOrPhone',
      target: object.constructor,
      propertyName: propertyName,
      options: validationOptions,
      validator: {
        validate(value: any, args: ValidationArguments) {
          const obj = args.object as LoginDto;
          const hasEmail = !!obj.email;
          const hasPhone = !!obj.phone;
          return hasEmail !== hasPhone; // Exactly one must be present
        },
        defaultMessage(args: ValidationArguments) {
          return 'Exactly one of email or phone must be provided';
        },
      },
    });
  };
}

export class LoginDto {
  @ApiPropertyOptional({ example: 'user@example.com' })
  @ValidateIf((o) => !o.phone)
  @IsNotEmpty({ message: 'Either email or phone must be provided' })
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ example: '+77767767676' })
  @ValidateIf((o) => !o.email)
  @IsNotEmpty({ message: 'Either email or phone must be provided' })
  @IsString()
  phone?: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @IsNotEmpty()
  password: string;
}
