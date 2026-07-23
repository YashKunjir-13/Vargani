import { Injectable, NestMiddleware } from "@nestjs/common";
import { NextFunction, Request, Response } from "express";
import { v4 as uuidv4 } from "uuid";

export const CORRELATION_HEADER = "x-correlation-id";
export const REQUEST_ID_HEADER = "x-request-id";

@Injectable()
export class CorrelationMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const correlationId = (req.headers[CORRELATION_HEADER] as string) || uuidv4();
    const requestId = (req.headers[REQUEST_ID_HEADER] as string) || uuidv4();

    req.headers[CORRELATION_HEADER] = correlationId;
    req.headers[REQUEST_ID_HEADER] = requestId;

    res.setHeader(CORRELATION_HEADER, correlationId);
    res.setHeader(REQUEST_ID_HEADER, requestId);

    next();
  }
}
