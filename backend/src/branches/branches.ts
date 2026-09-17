import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsOptional, IsString } from 'class-validator';
import { Repository } from 'typeorm';
import { Branch } from '../database/entities';

export class CreateBranchDto { @IsString() code: string; @IsString() name: string; @IsString() city: string; }
export class UpdateBranchDto { @IsOptional() @IsString() name?: string; @IsOptional() @IsString() city?: string; @IsOptional() @IsString() status?: string; }

@Injectable()
export class BranchesService {
  constructor(@InjectRepository(Branch) private readonly repository: Repository<Branch>) {}
  list() { return this.repository.find({ order: { name: 'ASC' } }); }
  create(dto: CreateBranchDto) { return this.repository.save(this.repository.create(dto)); }
  async update(id: string, dto: UpdateBranchDto) { const entity = await this.repository.preload({ id, ...dto }); if (!entity) throw new NotFoundException('Sucursal no encontrada'); return this.repository.save(entity); }
  async remove(id: string) { const result = await this.repository.delete(id); if (!result.affected) throw new NotFoundException('Sucursal no encontrada'); return { deleted: true }; }
}

import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
@Controller('branches')
export class BranchesController {
  constructor(private readonly service: BranchesService) {}
  @Get() list() { return this.service.list(); }
  @Post() create(@Body() dto: CreateBranchDto) { return this.service.create(dto); }
  @Patch(':id') update(@Param('id') id: string, @Body() dto: UpdateBranchDto) { return this.service.update(id, dto); }
  @Delete(':id') remove(@Param('id') id: string) { return this.service.remove(id); }
}
