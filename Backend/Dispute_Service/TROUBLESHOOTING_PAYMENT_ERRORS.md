# Troubleshooting Payment Action Errors

## Error: "500 INTERNAL_SERVER_ERROR Payment action failed"

This error occurs when the Dispute Service cannot successfully communicate with the Payment Service to process payment actions (release or refund).

## Step-by-Step Debugging

### 1. Check Payment Service Status

First, verify that the Payment Service is running and accessible:

```bash
# Check if payment service is running
curl -X GET http://localhost:8087/actuator/health

# Expected response:
{
  "status": "UP"
}
```

### 2. Test Payment Service Connection

Use the debug endpoint to test the connection:

```bash
# Test payment service connection
curl -X GET http://localhost:8090/api/admin/disputes/debug/payment-test
```

**Expected Response:**
```json
{
  "message": "Payment service connection test completed",
  "refundTest": {
    "status": "200 OK",
    "body": "Payment refunded successfully."
  },
  "releaseTest": {
    "status": "200 OK", 
    "body": "Payment released successfully."
  },
  "timestamp": "2024-01-15T10:30:00"
}
```

### 3. Check Service Discovery

Verify that the Payment Service is registered with Eureka:

```bash
# Check Eureka registry
curl -X GET http://localhost:8761/eureka/apps/payment-service
```

### 4. Check Network Connectivity

Test direct communication with Payment Service:

```bash
# Test direct payment service endpoints
curl -X POST http://localhost:8087/api/payments/refund/999
curl -X POST http://localhost:8087/api/payments/release/999?recipient=1
```

## Common Issues and Solutions

### Issue 1: Payment Service Not Running
**Symptoms:**
- Connection refused errors
- Timeout errors
- Service not found in Eureka

**Solution:**
```bash
# Start payment service
cd payment_service
mvn spring-boot:run
```

### Issue 2: Payment Service Not Registered with Eureka
**Symptoms:**
- "Service not found" errors
- Load balancer errors

**Solution:**
1. Check payment service application.properties:
```properties
eureka.client.service-url.defaultZone=http://localhost:8761/eureka
spring.application.name=payment-service
```

2. Restart payment service

### Issue 3: Payment Not Found in Database
**Symptoms:**
- Payment service returns 404 or error for specific task ID
- "No payment found" errors

**Solution:**
1. Check if payment exists for the task:
```bash
# Check payment service logs
tail -f payment_service/logs/application.log
```

2. Verify task ID is correct in dispute

### Issue 4: Database Connection Issues
**Symptoms:**
- Database connection errors
- Transaction rollback errors

**Solution:**
1. Check database connectivity:
```bash
# Test MySQL connection
mysql -h localhost -P 3311 -u root -p gigs_payment
```

2. Verify database schema:
```sql
-- Check if payments table exists
SHOW TABLES;

-- Check if payment exists for task
SELECT * FROM payment WHERE task_id = YOUR_TASK_ID;
```

### Issue 5: Feign Client Configuration Issues
**Symptoms:**
- Feign client errors
- Circuit breaker errors

**Solution:**
1. Check Feign client configuration in application.properties:
```properties
feign.client.config.default.connectTimeout=5000
feign.client.config.default.readTimeout=5000
```

2. Add circuit breaker configuration:
```properties
spring.cloud.circuit.breaker.enabled=true
spring.cloud.circuit.breaker.resilience4j.enabled=true
```

## Debugging with Logs

### 1. Enable Debug Logging

Add to `application.properties`:
```properties
# Enable debug logging for payment client
logging.level.com.example.Dispute_Service.Client.PaymentClient=DEBUG
logging.level.org.springframework.cloud.openfeign=DEBUG

# Enable debug logging for dispute service
logging.level.com.example.Dispute_Service.Service.DisputeService=DEBUG
```

### 2. Check Logs for Specific Errors

```bash
# Check dispute service logs
tail -f Dispute_Service/logs/application.log | grep -i payment

# Check payment service logs  
tail -f payment_service/logs/application.log | grep -i "release\|refund"
```

### 3. Common Log Patterns

**Successful Payment:**
```
INFO  - Successfully released payment for task ID: 123 to recipient ID: 789
INFO  - Payment release response status: 200 OK
INFO  - Payment release response body: Payment released successfully.
```

**Failed Payment:**
```
ERROR - Payment release failed for task ID: 123 to recipient ID: 789. Status: 404 NOT_FOUND, Body: No payment found for task ID: 123
ERROR - Exception occurred while releasing payment for task ID: 123 and recipient ID: 789
```

## Testing Payment Actions

### 1. Create Test Payment

First, create a test payment in the payment service:

```bash
# Create a test payment
curl -X POST http://localhost:8087/api/payments/process \
  -H "Content-Type: application/json" \
  -d '{
    "payer": 456,
    "recipient": 789,
    "taskId": 123,
    "amount": 100
  }'
```

### 2. Test Dispute Resolution

Then test the dispute resolution:

```bash
# Test dispute resolution with release
curl -X PUT http://localhost:8080/api/admin/disputes/1/resolve \
  -H "Content-Type: application/json" \
  -d '{
    "resolutionType": "RELEASE",
    "adminNotes": "Test resolution",
    "recipientId": 789
  }'
```

## Monitoring and Alerts

### 1. Health Checks

Add health check endpoints:

```bash
# Check dispute service health
curl -X GET http://localhost:8090/actuator/health

# Check payment service health
curl -X GET http://localhost:8087/actuator/health
```

### 2. Metrics

Monitor key metrics:
- Payment success rate
- Payment processing time
- Error rates by payment type

## Emergency Procedures

### 1. Manual Payment Processing

If automated payment processing fails, you can manually process payments:

```bash
# Manual payment release
curl -X POST http://localhost:8087/api/payments/release/123?recipient=789

# Manual payment refund
curl -X POST http://localhost:8087/api/payments/refund/123
```

### 2. Database Recovery

If database issues occur:

```sql
-- Check payment status
SELECT * FROM payment WHERE task_id = 123;

-- Update payment status manually if needed
UPDATE payment SET status = 'COMPLETED' WHERE task_id = 123 AND recipient = 789;
```

## Contact Information

For additional support:
- Check application logs for detailed error messages
- Verify all services are running and healthy
- Test network connectivity between services
- Review database connectivity and schema 