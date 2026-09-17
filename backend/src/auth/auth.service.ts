import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { Repository } from 'typeorm';
import { Role, User } from '../database/entities';

@Injectable()
export class AuthService {
  constructor(@InjectRepository(User) private readonly users: Repository<User>, @InjectRepository(Role) private readonly roles: Repository<Role>) {}

  async register(email: string, password: string, fullName: string, roleName = 'SELLER') {
    if (await this.users.findOneBy({ email })) throw new ConflictException('El correo ya está registrado');
    let role = await this.roles.findOneBy({ name: roleName });
    if (!role) role = await this.roles.save(this.roles.create({ name: roleName, description: `Rol ${roleName}` }));
    const user = await this.users.save(this.users.create({ email, fullName, roleId: role.id, passwordHash: await bcrypt.hash(password, 12) }));
    return { id: user.id, email: user.email, fullName: user.fullName, role: role.name };
  }

  async login(email: string, password: string) {
    const user = await this.users.findOne({ where: { email }, relations: ['role'] });
    if (!user || user.status !== 'ACTIVE' || !(await bcrypt.compare(password, user.passwordHash))) throw new UnauthorizedException('Credenciales inválidas');
    return { id: user.id, email: user.email, fullName: user.fullName, role: user.role.name };
  }
}
