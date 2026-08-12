export declare class HashingService {
    hashPassword(plainText: string): Promise<string>;
    verifyPassword(plainText: string, hash: string): Promise<boolean>;
}
