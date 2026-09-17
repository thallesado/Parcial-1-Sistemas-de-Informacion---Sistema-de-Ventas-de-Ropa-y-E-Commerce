import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { IsArray, IsIn, IsInt, IsOptional, IsString, IsUUID, Min, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { DataSource } from 'typeorm';
import { InventoryBalance, InventoryMovement, ProductVariant, Sale, SaleItem } from '../database/entities';

export class SaleItemDto { @IsUUID() variantId: string; @IsInt() @Min(1) quantity: number; }
export class CreateSaleDto { @IsUUID() operationId: string; @IsUUID() branchId: string; @IsOptional() @IsUUID() customerId?: string; @IsOptional() @IsUUID() userId?: string; @IsIn(['POS', 'ONLINE']) channel: string; @IsArray() @ValidateNested({ each: true }) @Type(() => SaleItemDto) items: SaleItemDto[]; }
@Injectable()
export class SalesService {
  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}
  async create(dto: CreateSaleDto) {
    return this.dataSource.transaction(async (manager) => {
      const sales = manager.getRepository(Sale); const existing = await sales.findOne({ where: { operationId: dto.operationId }, relations: ['items'] });
      if (existing) return { ...existing, duplicated: true };
      let total = 0; const prepared: { variantId: string; quantity: number; unitPrice: number }[] = [];
      for (const item of dto.items) {
        const variant = await manager.getRepository(ProductVariant).findOneBy({ id: item.variantId });
        if (!variant) throw new NotFoundException(`Variante ${item.variantId} no encontrada`);
        const balance = await manager.getRepository(InventoryBalance).findOne({ where: { branchId: dto.branchId, variantId: item.variantId }, lock: { mode: 'pessimistic_write' } });
        if (!balance || balance.availableQuantity < item.quantity) throw new ConflictException(`Stock insuficiente para ${variant.sku}`);
        balance.availableQuantity -= item.quantity; await manager.getRepository(InventoryBalance).save(balance);
        total += Number(variant.price) * item.quantity; prepared.push({ variantId: item.variantId, quantity: item.quantity, unitPrice: Number(variant.price) });
      }
      const sale = await sales.save(sales.create({ operationId: dto.operationId, branchId: dto.branchId, customerId: dto.customerId, userId: dto.userId, channel: dto.channel, total, status: 'CONFIRMED' }));
      await manager.getRepository(SaleItem).save(prepared.map((item) => manager.getRepository(SaleItem).create({ ...item, saleId: sale.id })));
      await manager.getRepository(InventoryMovement).save(prepared.map((item) => manager.getRepository(InventoryMovement).create({ branchId: dto.branchId, variantId: item.variantId, movementType: 'SALE', quantity: -item.quantity, referenceId: sale.id, createdBy: dto.userId })));
      return sales.findOne({ where: { id: sale.id }, relations: ['items'] });
    });
  }
  list(branchId?: string) { const repo = this.dataSource.getRepository(Sale); const qb = repo.createQueryBuilder('sale').leftJoinAndSelect('sale.items', 'item').orderBy('sale.createdAt', 'DESC'); if (branchId) qb.where('sale.branchId = :branchId', { branchId }); return qb.getMany(); }
  async get(id: string) { const sale = await this.dataSource.getRepository(Sale).findOne({ where: { id }, relations: ['items'] }); if (!sale) throw new NotFoundException('Venta no encontrada'); return sale; }
}
@Controller('sales')
export class SalesController {
  constructor(private readonly service: SalesService) {}
  @Post() create(@Body() dto: CreateSaleDto) { return this.service.create(dto); }
  @Get() list(@Query('branchId') branchId?: string) { return this.service.list(branchId); }
  @Get(':id') get(@Param('id') id: string) { return this.service.get(id); }
}
