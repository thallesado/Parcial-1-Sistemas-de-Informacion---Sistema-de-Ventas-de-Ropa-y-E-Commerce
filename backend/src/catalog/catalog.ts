import { BadRequestException, Body, Controller, Delete, Get, Injectable, NotFoundException, Param, Patch, Post, Query } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsArray, IsNumber, IsOptional, IsString, Min, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { Repository } from 'typeorm';
import { Category, Product, ProductVariant } from '../database/entities';

export class CreateCategoryDto { @IsString() name: string; @IsString() slug: string; @IsOptional() @IsString() parentId?: string; }
export class UpdateCategoryDto { @IsOptional() @IsString() name?: string; @IsOptional() @IsString() slug?: string; @IsOptional() @IsString() parentId?: string; @IsOptional() @IsString() status?: string; }
export class VariantDto { @IsString() sku: string; @IsString() color: string; @IsString() size: string; @IsNumber() @Min(0) price: number; @IsOptional() @IsString() barcode?: string; }
export class CreateProductDto { @IsString() categoryId: string; @IsString() name: string; @IsString() slug: string; @IsOptional() @IsString() description?: string; @IsOptional() @IsString() material?: string; @IsOptional() @IsString() fit?: string; @IsArray() @ValidateNested({ each: true }) @Type(() => VariantDto) variants: VariantDto[]; }
export class UpdateProductDto { @IsOptional() @IsString() categoryId?: string; @IsOptional() @IsString() name?: string; @IsOptional() @IsString() slug?: string; @IsOptional() @IsString() description?: string; @IsOptional() @IsString() material?: string; @IsOptional() @IsString() fit?: string; @IsOptional() @IsString() status?: string; }

@Injectable()
export class CatalogService {
  constructor(@InjectRepository(Category) private readonly categories: Repository<Category>, @InjectRepository(Product) private readonly products: Repository<Product>, @InjectRepository(ProductVariant) private readonly variants: Repository<ProductVariant>) {}
  listCategories() { return this.categories.find({ order: { name: 'ASC' } }); }
  createCategory(dto: CreateCategoryDto) { return this.categories.save(this.categories.create(dto)); }
  async updateCategory(id: string, dto: UpdateCategoryDto) { const entity = await this.categories.preload({ id, ...dto }); if (!entity) throw new NotFoundException('Categoría no encontrada'); return this.categories.save(entity); }
  async deleteCategory(id: string) { const result = await this.categories.delete(id); if (!result.affected) throw new NotFoundException('Categoría no encontrada'); return { deleted: true }; }
  listProducts(query?: string) { const builder = this.products.createQueryBuilder('product').leftJoinAndSelect('product.category', 'category').leftJoinAndSelect('product.variants', 'variant').orderBy('product.name', 'ASC'); if (query) builder.where('LOWER(product.name) LIKE LOWER(:query) OR LOWER(variant.sku) LIKE LOWER(:query)', { query: `%${query}%` }); return builder.getMany(); }
  async getProduct(id: string) { const product = await this.products.findOne({ where: { id }, relations: ['category', 'variants'] }); if (!product) throw new NotFoundException('Producto no encontrado'); return product; }
  async createProduct(dto: CreateProductDto) { const category = await this.categories.findOneBy({ id: dto.categoryId }); if (!category) throw new BadRequestException('La categoría no existe'); const product = await this.products.save(this.products.create({ ...dto, variants: undefined })); if (dto.variants?.length) await this.variants.save(dto.variants.map((variant) => this.variants.create({ ...variant, productId: product.id }))); return this.getProduct(product.id); }
  async updateProduct(id: string, dto: UpdateProductDto) { const entity = await this.products.preload({ id, ...dto }); if (!entity) throw new NotFoundException('Producto no encontrado'); return this.products.save(entity); }
  async deleteProduct(id: string) { const result = await this.products.delete(id); if (!result.affected) throw new NotFoundException('Producto no encontrado'); return { deleted: true }; }
  async createVariant(productId: string, dto: VariantDto) { await this.getProduct(productId); return this.variants.save(this.variants.create({ ...dto, productId })); }
  async updateVariant(id: string, dto: Partial<VariantDto>) { const entity = await this.variants.preload({ id, ...dto }); if (!entity) throw new NotFoundException('Variante no encontrada'); return this.variants.save(entity); }
  async deleteVariant(id: string) { const result = await this.variants.delete(id); if (!result.affected) throw new NotFoundException('Variante no encontrada'); return { deleted: true }; }
}

@Injectable()
@Controller()
export class CatalogController {
  constructor(private readonly service: CatalogService) {}
  @Get('categories') listCategories() { return this.service.listCategories(); }
  @Post('categories') createCategory(@Body() dto: CreateCategoryDto) { return this.service.createCategory(dto); }
  @Patch('categories/:id') updateCategory(@Param('id') id: string, @Body() dto: UpdateCategoryDto) { return this.service.updateCategory(id, dto); }
  @Delete('categories/:id') deleteCategory(@Param('id') id: string) { return this.service.deleteCategory(id); }
  @Get('products') listProducts(@Query('q') query?: string) { return this.service.listProducts(query); }
  @Get('products/:id') getProduct(@Param('id') id: string) { return this.service.getProduct(id); }
  @Post('products') createProduct(@Body() dto: CreateProductDto) { return this.service.createProduct(dto); }
  @Patch('products/:id') updateProduct(@Param('id') id: string, @Body() dto: UpdateProductDto) { return this.service.updateProduct(id, dto); }
  @Delete('products/:id') deleteProduct(@Param('id') id: string) { return this.service.deleteProduct(id); }
  @Post('products/:productId/variants') createVariant(@Param('productId') productId: string, @Body() dto: VariantDto) { return this.service.createVariant(productId, dto); }
  @Patch('variants/:id') updateVariant(@Param('id') id: string, @Body() dto: Partial<VariantDto>) { return this.service.updateVariant(id, dto); }
  @Delete('variants/:id') deleteVariant(@Param('id') id: string) { return this.service.deleteVariant(id); }
}
