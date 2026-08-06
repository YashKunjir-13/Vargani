import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from "@nestjs/common";
import { Response } from "express";

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    console.error("=== API EXCEPTION CAUGHT ===");
    console.error(exception);
    if (exception instanceof Error) {
      console.error(exception.stack);
    }

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? exception.getResponse()
        : { statusCode: status, message: (exception as Error)?.message || "Internal server error" };

    response.status(status).json(message);
  }
}
