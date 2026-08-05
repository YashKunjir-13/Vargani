# Service Dependency Graph

```mermaid
graph LR
    Gateway[API Gateway] --> Auth[auth-service]
    Gateway --> Tenant[tenant-service]
    Gateway --> User[user-service]
    Gateway --> Donor[customer-service]
    Gateway --> Event[service-service]
    Gateway --> Order[order-service]
    Gateway --> Bill[expense-service]
    Gateway --> Payment[payment-service]
    Gateway --> Receipt[receipt-service]
    Gateway --> Finance[finance-service]
    Gateway --> Notif[notification-service]
    Gateway --> Report[report-service]

    Auth --> SharedSecurity[@pauti-pustak/backend-security]
    Tenant --> SharedDB[@pauti-pustak/backend-database]
    Payment --> EventBus[Redis/BullMQ Event Bus]
    Order --> EventBus
    EventBus --> Worker[Worker Services]
```
