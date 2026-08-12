export declare class PanEncryptionService {
    private readonly key;
    constructor();
    encrypt(plainText: string): string;
    decrypt(payload: string): string;
}
