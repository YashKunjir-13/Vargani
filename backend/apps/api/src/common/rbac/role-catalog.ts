export interface PermissionDefinition {
  code: string;
  module: string;
  action: string;
  description: string;
}

/**
 * Illustrative default permission catalog. Every code here is freely
 * editable/extendable later by whoever holds "role.manage" -- this list
 * only seeds the starting set, it is not a hardcoded enum consumed
 * elsewhere in the codebase.
 */
export const PERMISSION_CATALOG: PermissionDefinition[] = [
  {
    code: "payment.create",
    module: "payment",
    action: "create",
    description: "Record a new payment",
  },
  {
    code: "payment.confirmMatch",
    module: "payment",
    action: "confirmMatch",
    description: "Confirm a payment matched to a bill or contribution",
  },
  { code: "payment.view", module: "payment", action: "view", description: "View payment records" },
  {
    code: "receipt.viewAll",
    module: "receipt",
    action: "viewAll",
    description: "View all receipts across the organization",
  },
  {
    code: "receipt.viewOwn",
    module: "receipt",
    action: "viewOwn",
    description: "View only self-issued or self-related receipts",
  },
  { code: "receipt.void", module: "receipt", action: "void", description: "Void an issued receipt" },
  {
    code: "bill.create",
    module: "bill",
    action: "create",
    description: "Create a contribution or expense bill",
  },
  { code: "bill.approve", module: "bill", action: "approve", description: "Approve a bill for payment" },
  {
    code: "bill.pay",
    module: "bill",
    action: "pay",
    description: "Mark a bill as paid / disburse payment",
  },
  {
    code: "contribution.create",
    module: "contribution",
    action: "create",
    description: "Record a new contribution",
  },
  {
    code: "contribution.delete",
    module: "contribution",
    action: "delete",
    description: "Delete a contribution record",
  },
  {
    code: "template.upload",
    module: "template",
    action: "upload",
    description: "Upload a receipt or bill template",
  },
  {
    code: "template.activate",
    module: "template",
    action: "activate",
    description: "Activate a template as the organization's default",
  },
  {
    code: "role.manage",
    module: "role",
    action: "manage",
    description: "Create, edit, and assign organization roles and permissions",
  },
];

export const MANAGE_ROLES_PERMISSION = "role.manage";

export const ALL_PERMISSION_CODES: string[] = PERMISSION_CATALOG.map((p) => p.code);

export const TRUST_PRESIDENT_ROLE_NAME = "Trust President";

export interface DefaultRoleDefinition {
  name: string;
  description: string;
  isSystem: boolean;
  isOwnerRole: boolean;
  permissions: string[];
}

/**
 * Default roles seeded for every newly-created organization. Only the
 * Trust President role is system-protected (isSystem/isOwnerRole); the
 * rest are ordinary, fully editable/deletable starting points.
 */
export const DEFAULT_ROLE_DEFINITIONS: DefaultRoleDefinition[] = [
  {
    name: TRUST_PRESIDENT_ROLE_NAME,
    description:
      "Full authority over the mandal's account. System-protected: cannot be deleted, and always retains full permission scope so the mandal can never lock itself out.",
    isSystem: true,
    isOwnerRole: true,
    permissions: ALL_PERMISSION_CODES,
  },
  {
    name: "Vice President",
    description: "Deputizes for the Trust President across financial and operational approvals.",
    isSystem: false,
    isOwnerRole: false,
    permissions: [
      "payment.create",
      "payment.confirmMatch",
      "payment.view",
      "receipt.viewAll",
      "receipt.void",
      "bill.create",
      "bill.approve",
      "bill.pay",
      "contribution.create",
      "contribution.delete",
      "template.upload",
      "template.activate",
    ],
  },
  {
    name: "Secretary",
    description: "Manages contributor communication, templates, and record-keeping.",
    isSystem: false,
    isOwnerRole: false,
    permissions: [
      "receipt.viewAll",
      "contribution.create",
      "contribution.delete",
      "template.upload",
      "template.activate",
      "bill.create",
    ],
  },
  {
    name: "Treasurer",
    description: "Owns day-to-day financial operations: payments, bills, receipts.",
    isSystem: false,
    isOwnerRole: false,
    permissions: [
      "payment.create",
      "payment.confirmMatch",
      "payment.view",
      "receipt.viewAll",
      "receipt.void",
      "bill.create",
      "bill.approve",
      "bill.pay",
      "contribution.create",
    ],
  },
  {
    name: "Volunteer",
    description: "Field collection role: records payments/contributions and views own receipts.",
    isSystem: false,
    isOwnerRole: false,
    permissions: ["payment.create", "receipt.viewOwn", "contribution.create"],
  },
  {
    name: "Donor",
    description: "External contributor with read-only access to their own receipts.",
    isSystem: false,
    isOwnerRole: false,
    permissions: ["receipt.viewOwn"],
  },
];
