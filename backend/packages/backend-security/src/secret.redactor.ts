const SENSITIVE_KEYS = [
  "password",
  "secret",
  "token",
  "authorization",
  "apiKey",
  "privateKey",
  "razorpayKeySecret",
  "cookie",
];

export function redactSecrets<T extends Record<string, any>>(obj: T): T {
  if (!obj || typeof obj !== "object") {
    return obj;
  }

  const redacted = Array.isArray(obj) ? [...obj] : { ...obj };

  for (const key of Object.keys(redacted)) {
    if (SENSITIVE_KEYS.some((k) => key.toLowerCase().includes(k.toLowerCase()))) {
      (redacted as any)[key] = "[REDACTED]";
    } else if (typeof (redacted as any)[key] === "object") {
      (redacted as any)[key] = redactSecrets((redacted as any)[key]);
    }
  }

  return redacted as T;
}
