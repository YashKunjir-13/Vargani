export interface ApiResponseEnvelope<T> {
  success: boolean;
  statusCode: number;
  data: T;
  message?: string;
  meta?: {
    requestId?: string;
    correlationId?: string;
    tenantId?: string;
    timestamp: string;
    page?: number;
    limit?: number;
    totalCount?: number;
  };
  errors?: Array<{
    field?: string;
    message: string;
    code?: string;
  }>;
}

export function createApiResponse<T>(
  data: T,
  statusCode = 200,
  message?: string,
  meta?: Partial<Omit<ApiResponseEnvelope<T>['meta'], 'timestamp'>>,
): ApiResponseEnvelope<T> {
  return {
    success: statusCode >= 200 && statusCode < 300,
    statusCode,
    data,
    message,
    meta: {
      timestamp: new Date().toISOString(),
      ...meta,
    },
  };
}
