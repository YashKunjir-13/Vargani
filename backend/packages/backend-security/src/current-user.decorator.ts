import { createParamDecorator, ExecutionContext } from "@nestjs/common";
import { AuthenticatedUser } from "./auth.interfaces";

/**
 * Extracts `request.user`, populated by the auth layer after JWT
 * verification (see AuthenticatedUser). Never trust any other source for
 * the current user's identity/permissions.
 */
export const CurrentUser = createParamDecorator(
  (_data: unknown, context: ExecutionContext): AuthenticatedUser => {
    const request = context.switchToHttp().getRequest();
    return request.user;
  },
);
