import { Injectable, UnauthorizedException, Inject } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Pool } from 'pg';
import * as bcrypt from 'bcrypt';
import { DATABASE_POOL } from '../common/database.module';
@Injectable()
export class AuthService {
  constructor(
    @Inject(DATABASE_POOL) private readonly db: Pool,
    private jwtService: JwtService,
  ) {}
  async validateUser(email: string, password: string): Promise<any> {
    const result = await this.db.query(
      'SELECT * FROM users WHERE email = $1 AND is_active = true',
      [email]
    );
    const user = result.rows[0];
    if (!user) throw new UnauthorizedException('E-Mail oder Passwort falsch');
    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) throw new UnauthorizedException('E-Mail oder Passwort falsch');
    const { password_hash, ...rest } = user;
    return rest;
  }
  async login(email: string, password: string, ipAddress?: string, userAgent?: string) {
    const user = await this.validateUser(email, password);
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      name: user.display_name,
      tenant_id: user.tenant_id,
    };

    // Audit-Log Eintrag
    try {
      await this.db.query(
        `INSERT INTO audit_log
           (tenant_id, user_id, user_email, event_type, entity_type, entity_id,
            old_value, new_value, ip_address, user_agent)
         VALUES ($1, $2, $3, 'USER_LOGIN', 'user', $2,
                 NULL,
                 $5::jsonb,
                 $4::inet, $6)`,
        [
          user.tenant_id,
          user.id,
          user.email,
          ipAddress || null,
          JSON.stringify({
            email: user.email,
            role:  user.role,
            name:  user.display_name || user.email,
          }),
          userAgent || null,
        ]
      );
    } catch (e) {
      console.warn('Audit-Log Fehler:', e.message);
    }

    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        name: user.display_name,
        email: user.email,
        role: user.role,
        tenant_id: user.tenant_id,
      },
    };
  }
  async getProfile(userId: string) {
    const result = await this.db.query(
      'SELECT id, display_name AS name, email, role, tenant_id, is_active FROM users WHERE id = $1',
      [userId]
    );
    if (!result.rows[0]) throw new UnauthorizedException();
    return result.rows[0];
  }
}
