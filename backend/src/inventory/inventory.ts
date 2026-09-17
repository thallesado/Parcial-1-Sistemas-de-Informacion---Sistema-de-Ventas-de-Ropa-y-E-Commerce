import { Body, Controller, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsInt, IsOptional, IsString, Min } from 'class-validator';
import { Repository } from 'typeorm';
import { InventoryBalance, InventoryMovement } from '../database/entities';

export class CreateInventoryDto { @IsString() branchId: string; @IsString() variantId: string; @IsInt() @Min(0) availableQuantity: number; @IsOptional() @IsInt() @Min(0) minimumQuantity?: number; }
export class UpdateInventoryDto { @IsOptional() @IsInt() @Min(0) availableQuantity?: number; @IsOptional() @IsInt() @Min(0) reservedQuantity?: number; @IsOptional() @IsInt() @Min(0) minimumQuantity?: number; }
@Injectable()
export class InventoryService {
  constructor(@InjectRepository(InventoryBalance) private readonly balances: Repository<InventoryBalance>, @InjectRepository(InventoryMovement) private readonly movements: Repository<InventoryMovement>) {}
  list(branchId?: string, variantId?: string) { const qb = this.balances.createQueryBuilder('balance').orderBy('balance.updatedAt', 'DESC'); if (branchId) qb.andWhere('balance.branchId = :branchId', { branchId }); if (variantId) qb.andWhere('balance.variantId = :variantId', { variantId }); return qb.getMany(); }
  async create(dto: CreateInventoryDto) { const existing = await this.balances.findOneBy({ branchId: dto.branchId, variantId: dto.variantId }); if (existing) throw new BadRequestException('Ya existe saldo para esa sucursal y variante'); const balance = await this.balances.save(this.balances.create(dto)); if (dto.availableQuantity) await this.movements.save(this.movements.create({ branchId: dto.branchId, variantId: dto.variantId, movementType: 'PURCHASE', quantity: dto.availableQuantity })); return balance; }
  async update(id: string, dto: UpdateInventoryDto) { const balance = await this.balances.findOneBy({ id }); if (!balance) throw new NotFoundException('Saldo de inventario no encontrado'); const previous = balance.availableQuantity; Object.assign(balance, dto); const saved = await this.balances.save(balance); if (dto.availableQuantity !== undefined && dto.availableQuantity !== previous) await this.movements.save(this.movements.create({ branchId: balance.branchId, variantId: balance.variantId, movementType: 'ADJUSTMENT', quantity: dto.availableQuantity - previous })); return saved; }
  movementsFor(variantId?: string) { return this.movements.find({ where: variantId ? { variantId } : undefined, order: { createdAt: 'DESC' } }); }
}
@Controller('inventory')
export class InventoryController {
  constructor(private readonly service: InventoryService) {}
  @Get() list(@Query('branchId') branchId?: string, @Query('variantId') variantId?: string) { return this.service.list(branchId, variantId); }
  @Post() create(@Body() dto: CreateInventoryDto) { return this.service.create(dto); }
  @Patch(':id') update(@Param('id') id: string, @Body() dto: UpdateInventoryDto) { return this.service.update(id, dto); }
  @Get('movements') movements(@Query('variantId') variantId?: string) { return this.service.movementsFor(variantId); }
}
