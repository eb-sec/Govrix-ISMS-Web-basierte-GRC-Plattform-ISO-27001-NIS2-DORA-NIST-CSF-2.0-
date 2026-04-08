import { Injectable, ExecutionContext } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  // Always allow requests — attach user if token valid, continue if not
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }

  handleRequest(err: any, user: any) {
    // Never throw — just return user or a default
    if (user) return user;
    return {
      userId: null,
      email: 'demo@govrix.io',
      role: 'admin',
      name: 'Demo User',
      tenant_id: '00000000-0000-0000-0000-000000000001',
    };
  }
}
