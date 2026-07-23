module.exports = {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: '.',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': [
      'ts-jest',
      {
        tsconfig: 'tsconfig.base.json',
      },
    ],
  },
  modulePathIgnorePatterns: ['<rootDir>/dist/'],
  collectCoverageFrom: ['{apps,packages}/**/*.ts', '!**/node_modules/**', '!**/dist/**'],
  coverageDirectory: './coverage',
  testEnvironment: 'node',
  moduleNameMapper: {
    '^@pauti-pustak/backend-config$': '<rootDir>/packages/backend-config/src/index.ts',
    '^@pauti-pustak/backend-contracts$': '<rootDir>/packages/backend-contracts/src/index.ts',
    '^@pauti-pustak/backend-database$': '<rootDir>/packages/backend-database/src/index.ts',
    '^@pauti-pustak/backend-observability$': '<rootDir>/packages/backend-observability/src/index.ts',
    '^@pauti-pustak/backend-security$': '<rootDir>/packages/backend-security/src/index.ts',
    '^@pauti-pustak/backend-testing$': '<rootDir>/packages/backend-testing/src/index.ts',
    '^@pauti-pustak/backend-shared-kernel$': '<rootDir>/packages/backend-shared-kernel/src/index.ts',
  },
};
