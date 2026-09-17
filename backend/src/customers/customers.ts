import { Body, Controller, Delete, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsEmail, IsOptional, IsString } from 'class-validator';
import { Repository } from 'typeorm';
import { Customer } from '../database/entities';

export class CreateCustomerDto { @IsString() fullName: string; @IsOptional() @IsEmail() email?: string; @IsOptional() @IsString() phone?: string; }
export class UpdateCustomerDto { @IsOptional() @IsString() fullName?: string; @IsOptional() @IsEmail() email?: string; @IsOptional() @IsString() phone?: string; }
@Injectable()
export class CustomersService {
  constructor(@InjectRepository(Customer) private readonly repository: Repository<Customer>) {}
  list(query?: string) { const qb = this.repository.createQueryBuilder('customer').orderBy('customer.fullName', 'ASC'); if (query) qb.where('LOWER(customer.fullName) LIKE LOWER(:query) OR LOWER(customer.email) LIKE LOWER(:query)', { query: `%${query}%` }); return qb.getMany(); }
  create(dto: CreateCustomerDto) { return this.repository.save(this.repository.create(dto)); }
  async update(id: string, dto: UpdateCustomerDto) { const entity = await this.repository.preload({ id, ...dto }); if (!entity) throw new NotFoundException('Cliente no encontrado'); return this.repository.save(entity); }
  async remove(id: string) { const result = await this.repository.delete(id); if (!result.affected) throw new NotFoundException('Cliente no encontrado'); return { deleted: true }; }
}
@Controller('customers')
export class CustomersController {
  constructor(private readonly service: CustomersService) {}
  @Get() list(@Query('q') query?: string) { return this.service.list(query); }
  @Post() create(@Body() dto: CreateCustomerDto) { return this.service.create(dto); }
  @Patch(':id') update(@Param('id') id: string, @Body() dto: UpdateCustomerDto) { return this.service.update(id, dto); }
  @Delete(':id') remove(@Param('id') id: string) { return this.service.remove(id); }
}
