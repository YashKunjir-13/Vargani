import { NestMiddleware } from "@nestjs/common";
import { NextFunction, Request, Response } from "express";
export declare const CORRELATION_HEADER = "x-correlation-id";
export declare const REQUEST_ID_HEADER = "x-request-id";
export declare class CorrelationMiddleware implements NestMiddleware {
    use(req: Request, res: Response, next: NextFunction): void;
}
