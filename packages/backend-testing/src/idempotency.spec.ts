import { createApiResponse } from '@pauti-pustak/backend-contracts';

describe('IdempotencyContract', () => {
  it('should format idempotent response envelopes consistently', () => {
    const response = createApiResponse({ orderId: 'ord-123' }, 200, 'Success', {
      requestId: 'req-001',
      correlationId: 'corr-001',
    });

    expect(response.success).toBe(true);
    expect(response.statusCode).toBe(200);
    expect(response.data.orderId).toBe('ord-123');
    expect(response.meta?.requestId).toBe('req-001');
    expect(response.meta?.correlationId).toBe('corr-001');
  });
});
