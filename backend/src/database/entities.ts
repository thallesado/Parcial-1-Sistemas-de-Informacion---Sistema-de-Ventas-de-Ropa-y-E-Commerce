import { Column, CreateDateColumn, Entity, Index, JoinColumn, ManyToOne, OneToMany, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

@Entity('roles')
export class Role {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ unique: true, length: 50 }) name: string;
  @Column({ nullable: true, length: 255 }) description?: string;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
  @OneToMany(() => User, (user) => user.role) users: User[];
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ unique: true, length: 160 }) email: string;
  @Column({ name: 'password_hash', length: 255 }) passwordHash: string;
  @Column({ name: 'full_name', length: 160 }) fullName: string;
  @Column({ length: 20, default: 'ACTIVE' }) status: string;
  @Column({ name: 'role_id', type: 'uuid' }) roleId: string;
  @ManyToOne(() => Role, (role) => role.users) @JoinColumn({ name: 'role_id' }) role: Role;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
  @UpdateDateColumn({ name: 'updated_at' }) updatedAt: Date;
}

@Entity('branches')
export class Branch {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ unique: true, length: 30 }) code: string;
  @Column({ length: 120 }) name: string;
  @Column({ length: 100 }) city: string;
  @Column({ length: 20, default: 'ACTIVE' }) status: string;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}

@Entity('categories')
export class Category {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ length: 120 }) name: string;
  @Column({ unique: true, length: 140 }) slug: string;
  @Column({ name: 'parent_id', type: 'uuid', nullable: true }) parentId?: string;
  @Column({ length: 20, default: 'ACTIVE' }) status: string;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
  @OneToMany(() => Product, (product) => product.category) products: Product[];
}

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'category_id', type: 'uuid' }) categoryId: string;
  @ManyToOne(() => Category, (category) => category.products) @JoinColumn({ name: 'category_id' }) category: Category;
  @Column({ length: 180 }) name: string;
  @Column({ unique: true, length: 200 }) slug: string;
  @Column({ type: 'text', nullable: true }) description?: string;
  @Column({ nullable: true, length: 100 }) material?: string;
  @Column({ name: 'fit', nullable: true, length: 80 }) fit?: string;
  @Column({ length: 20, default: 'ACTIVE' }) status: string;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
  @UpdateDateColumn({ name: 'updated_at' }) updatedAt: Date;
  @OneToMany(() => ProductVariant, (variant) => variant.product) variants: ProductVariant[];
}

@Entity('product_variants')
@Index(['productId'])
export class ProductVariant {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'product_id', type: 'uuid' }) productId: string;
  @ManyToOne(() => Product, (product) => product.variants, { onDelete: 'CASCADE' }) @JoinColumn({ name: 'product_id' }) product: Product;
  @Column({ unique: true, length: 80 }) sku: string;
  @Column({ length: 80 }) color: string;
  @Column({ length: 30 }) size: string;
  @Column({ type: 'numeric', precision: 12, scale: 2 }) price: number;
  @Column({ unique: true, nullable: true, length: 80 }) barcode?: string;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}

@Entity('customers')
export class Customer {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ unique: true, nullable: true, length: 160 }) email?: string;
  @Column({ name: 'full_name', length: 160 }) fullName: string;
  @Column({ nullable: true, length: 40 }) phone?: string;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}

@Entity('inventory_balances')
@Index(['branchId', 'variantId'], { unique: true })
export class InventoryBalance {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'branch_id', type: 'uuid' }) branchId: string;
  @Column({ name: 'variant_id', type: 'uuid' }) variantId: string;
  @Column({ name: 'available_quantity', default: 0 }) availableQuantity: number;
  @Column({ name: 'reserved_quantity', default: 0 }) reservedQuantity: number;
  @Column({ name: 'minimum_quantity', default: 0 }) minimumQuantity: number;
  @UpdateDateColumn({ name: 'updated_at' }) updatedAt: Date;
}

@Entity('sales')
@Index(['branchId', 'createdAt'])
export class Sale {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'operation_id', type: 'uuid', unique: true }) operationId: string;
  @Column({ name: 'branch_id', type: 'uuid' }) branchId: string;
  @Column({ name: 'customer_id', type: 'uuid', nullable: true }) customerId?: string;
  @Column({ name: 'user_id', type: 'uuid', nullable: true }) userId?: string;
  @Column({ length: 20 }) channel: string;
  @Column({ length: 20, default: 'CONFIRMED' }) status: string;
  @Column({ type: 'numeric', precision: 14, scale: 2 }) total: number;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
  @OneToMany(() => SaleItem, (item) => item.sale) items: SaleItem[];
}

@Entity('sale_items')
export class SaleItem {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'sale_id', type: 'uuid' }) saleId: string;
  @ManyToOne(() => Sale, (sale) => sale.items, { onDelete: 'CASCADE' }) @JoinColumn({ name: 'sale_id' }) sale: Sale;
  @Column({ name: 'variant_id', type: 'uuid' }) variantId: string;
  @Column() quantity: number;
  @Column({ name: 'unit_price', type: 'numeric', precision: 12, scale: 2 }) unitPrice: number;
}

@Entity('inventory_movements')
@Index(['variantId', 'createdAt'])
export class InventoryMovement {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column({ name: 'branch_id', type: 'uuid' }) branchId: string;
  @Column({ name: 'variant_id', type: 'uuid' }) variantId: string;
  @Column({ name: 'movement_type', length: 30 }) movementType: string;
  @Column() quantity: number;
  @Column({ name: 'reference_id', type: 'uuid', nullable: true }) referenceId?: string;
  @Column({ name: 'created_by', type: 'uuid', nullable: true }) createdBy?: string;
  @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}
