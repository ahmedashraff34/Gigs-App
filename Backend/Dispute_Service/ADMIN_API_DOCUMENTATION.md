# Admin Dispute Management API Documentation

## Overview
This document describes the admin functionality for managing disputes in the Gigs platform. Admins can view all disputes, filter by various criteria, and resolve disputes by either releasing payments to runners or refunding payments to task posters.

## Gateway Configuration
The admin dispute endpoints are routed through Spring Cloud Gateway:

```java
.route("admin-dispute-service", r -> r
    .path("/api/admin/disputes/**")
    .uri("lb://dispute-service"))
```

## Base URL
```
http://your-gateway-host:port/api/admin/disputes
```

**Example:** `http://localhost:8080/api/admin/disputes`

## Authentication
*Note: This implementation assumes admin authentication will be handled at the gateway level or through additional security layers.*

## API Endpoints

### 1. Get All Disputes
**GET** `/api/admin/disputes`

Returns all disputes in the system with detailed information.

**Response:**
```json
[
  {
    "disputeId": 1,
    "taskId": 123,
    "raisedBy": 456,
    "complainantName": "John Doe",
    "defendantId": 789,
    "defendantName": "Jane Smith",
    "reason": "Task not completed as agreed",
    "status": "PENDING",
    "evidenceUrls": ["https://example.com/evidence1.jpg"],
    "createdAt": "2024-01-15T10:30:00",
    "adminNotes": null
  }
]
```

### 2. Get Pending Disputes
**GET** `/api/admin/disputes/pending`

Returns only disputes that are pending and require admin attention.

**Response:** Same format as above, but only PENDING disputes.

### 3. Get Disputes by User
**GET** `/api/admin/disputes/user/{userId}/raised`

Returns all disputes raised by a specific user.

**GET** `/api/admin/disputes/user/{userId}/against`

Returns all disputes where a specific user is the defendant.

### 4. Get Dispute Details
**GET** `/api/admin/disputes/{disputeId}`

Returns detailed information about a specific dispute.

### 5. Resolve Dispute with Payment Action
/////**PUT** `/api/admin/disputes/{disputeId}/resolve`

Resolves a dispute by either releasing payment to the runner or refunding payment to the task poster.

**Request Body:**
```json
{
  "resolutionType": "RELEASE",  // or "REFUND"
  "adminNotes": "Evidence shows task was completed satisfactorily",
  "recipientId": 789  // Required only for RELEASE resolution
}
```

**Resolution Types:**
- `RELEASE`: Releases the escrow payment to the runner (requires recipientId)
- `REFUND`: Refunds the payment back to the task poster

**Response:**
```json
{
  "message": "Dispute resolved successfully with payment action: RELEASE",
  "disputeId": 1,
  "resolutionType": "RELEASE",
  "adminNotes": "Evidence shows task was completed satisfactorily"
}
```

### 6. Get Dispute Statistics
**GET** `/api/admin/disputes/statistics`

Returns statistics about disputes for admin dashboard.

**Response:**
```json
{
  "totalDisputes": 50,
  "pendingDisputes": 15,
  "resolvedDisputes": 30,
  "closedDisputes": 5
}
```

## Alternative Endpoints (DisputeController)

The following endpoints are also available in the main DisputeController:

- `GET /api/disputes/admin/all` - Get all disputes for admin
- `GET /api/disputes/admin/pending` - Get pending disputes for admin
- `GET /api/disputes/admin/user/{userId}/raised` - Get disputes raised by user
- `GET /api/disputes/admin/user/{userId}/against` - Get disputes against user
- `PUT /api/disputes/admin/{disputeId}/resolve-with-payment` - Resolve dispute with payment
- `GET /api/disputes/admin/{disputeId}` - Get dispute for admin

## Business Logic

### Dispute Resolution Flow
1. Admin reviews dispute details and evidence
2. Admin decides whether to:
   - **RELEASE**: Payment goes to runner (task was completed satisfactorily)
   - **REFUND**: Payment goes back to task poster (task was not completed or issues found)
3. System automatically:
   - Calls Payment Service to process the payment action
   - Updates dispute status to RESOLVED
   - Stores admin notes for audit trail

### Payment Integration
- **RELEASE**: Calls `POST /api/payments/release/{taskId}?recipient={recipientId}`
- **REFUND**: Calls `POST /api/payments/refund/{taskId}`

### Validation Rules
- Only PENDING disputes can be resolved
- RELEASE resolution requires recipientId
- Admin notes are stored for audit purposes
- Payment actions are atomic - if payment fails, dispute remains PENDING

## Error Handling

**Common Error Responses:**

```json
{
  "error": "Can only resolve disputes that are in PENDING status",
  "disputeId": 1
}
```

```json
{
  "error": "Recipient ID is required for RELEASE resolution",
  "disputeId": 1
}
```

```json
{
  "error": "Payment action failed",
  "disputeId": 1
}
```

## Example Usage with Gateway

### Scenario: Admin resolves dispute in favor of runner
```bash
curl -X PUT http://localhost:8080/api/admin/disputes/1/resolve \
  -H "Content-Type: application/json" \
  -d '{
    "resolutionType": "RELEASE",
    "adminNotes": "Evidence shows task was completed as agreed. Runner provided photos and video proof.",
    "recipientId": 789
  }'
```

### Scenario: Admin resolves dispute in favor of task poster
```bash
curl -X PUT http://localhost:8080/api/admin/disputes/2/resolve \
  -H "Content-Type: application/json" \
  -d '{
    "resolutionType": "REFUND",
    "adminNotes": "Runner did not complete the task as specified. Evidence shows incomplete work."
  }'
```

### Scenario: Admin views pending disputes
```bash
curl -X GET http://localhost:8080/api/admin/disputes/pending
```

### Scenario: Admin gets dispute statistics
```bash
curl -X GET http://localhost:8080/api/admin/disputes/statistics
```

## Database Changes

The following field was added to the Dispute entity:
- `adminNotes` (LONGTEXT): Stores admin resolution notes for audit trail

## Integration Points

1. **Payment Service**: For processing payment releases and refunds
2. **Task Service**: For validating task existence and status
3. **User Service**: For validating user existence

## Security Considerations

- Admin endpoints should be protected with proper authentication and authorization
- Consider implementing audit logging for all admin actions
- Validate admin permissions before allowing dispute resolution
- Consider rate limiting for admin endpoints
- Gateway-level security filters can be added for additional protection 