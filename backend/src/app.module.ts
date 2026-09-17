import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthController } from './auth/auth.controller';
import { AuthService } from './auth/auth.service';
import { BranchesController, BranchesService } from './branches/branches';
import { CatalogController, CatalogService } from './catalog/catalog';
import { CustomersController, CustomersService } from './customers/customers';
import { InventoryController, InventoryService } from './inventory/inventory';
import { SalesController, SalesService } from './sales/sales';
import { Branch, Category, Customer, InventoryBalance, InventoryMovement, Product, ProductVariant, Role, Sale, SaleItem, User } from './database/entities';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres', host: process.env.DATABASE_HOST ?? 'localhost', port: Number(process.env.DATABASE_PORT ?? 5432),
      database: process.env.DATABASE_NAME ?? 'vesta', username: process.env.DATABASE_USER ?? 'postgres', password: process.env.DATABASE_PASSWORD ?? 'postgres',
      entities: [Role, User, Branch, Category, Product, ProductVariant, Customer, InventoryBalance, Sale, SaleItem, InventoryMovement], synchronize: false,
    }),
    TypeOrmModule.forFeature([Role, User, Branch, Category, Product, ProductVariant, Customer, InventoryBalance, InventoryMovement, Sale, SaleItem]),
  ],
  controllers: [AuthController, CatalogController, BranchesController, CustomersController, InventoryController, SalesController],
  providers: [AuthService, CatalogService, BranchesService, CustomersService, InventoryService, SalesService],
})
export class AppModule {}
