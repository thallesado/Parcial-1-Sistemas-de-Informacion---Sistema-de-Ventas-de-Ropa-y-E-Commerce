import 'dotenv/config';
import { DataSource } from 'typeorm';
import { Branch, Category, Customer, InventoryBalance, InventoryMovement, Product, ProductVariant, Role, Sale, SaleItem, User } from './entities';

export const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DATABASE_HOST ?? 'localhost',
  port: Number(process.env.DATABASE_PORT ?? 5432),
  database: process.env.DATABASE_NAME ?? 'vesta',
  username: process.env.DATABASE_USER ?? 'postgres',
  password: process.env.DATABASE_PASSWORD ?? 'postgres',
  entities: [Role, User, Branch, Category, Product, ProductVariant, Customer, InventoryBalance, Sale, SaleItem, InventoryMovement],
  synchronize: false,
  migrations: [],
});
