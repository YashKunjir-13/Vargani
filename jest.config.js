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
  collectCoverageFrom: ['backend/{apps,packages}/**/*.ts', '!**/node_modules/**', '!**/dist/**'],
  coverageDirectory: './coverage',
  testEnvironment: 'node',
  moduleNameMapper: {
    '^@pauti-pustak/backend-config$': '<rootDir>/backend/packages/backend-config/src/index.ts',
    '^@pauti-pustak/backend-contracts$': '<rootDir>/backend/packages/backend-contracts/src/index.ts',
    '^@pauti-pustak/backend-database$': '<rootDir>/backend/packages/backend-database/src/index.ts',
    '^@pauti-pustak/backend-observability$': '<rootDir>/backend/packages/backend-observability/src/index.ts',
    '^@pauti-pustak/backend-security$': '<rootDir>/backend/packages/backend-security/src/index.ts',
    '^@pauti-pustak/backend-testing$': '<rootDir>/backend/packages/backend-testing/src/index.ts',
    '^@pauti-pustak/backend-shared-kernel$': '<rootDir>/backend/packages/backend-shared-kernel/src/index.ts',
  },
};
