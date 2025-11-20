# API Documentation

## Supabase API

### Base URL
```
https://xrkxxqhoglrimiljfnml.supabase.co/functions/v1/make-server-2c3121a9
```

### Authentication
```http
Authorization: Bearer eyJhbGci...
X-API-Key: your-api-key
```

---

### 1. Get Pending Events

**Endpoint:** `GET /admin/events/pending`

**Query Params:**
- `limit` (optional): Max events to return (default: 100)

**Response:**
```json
{
  "success": true,
  "events": [
    {
      "id": "evt_123",
      "type": "worker.created",
      "timestamp": "2025-11-20T18:32:12.077Z",
      "workers": [
        {
          "workerId": "uuid",
          "nationalIdNumber": "1234567890",
          "fullName": "Ahmed Ali",
          "phoneNumber": "0551234567",
          "facePhoto": "https://...",
          "nationalIdImage": "https://...",
          "status": "pending"
        }
      ]
    }
  ],
  "count": 1,
  "totalPending": 0
}
```

**Event Types:**
- `worker.created` - New worker added
- `worker.blocked` - Worker blocked
- `worker.deleted` - Worker deleted
- `worker.unblocked` - Worker unblocked
- `workers.bulk_created` - Multiple workers added
- `unit.workers_blocked` - All unit workers blocked
- `unit.workers_unblocked` - All unit workers unblocked

---

### 2. Update Worker Status

**Endpoint:** `POST /admin/workers/update-status`

**Body:**
```json
{
  "workerId": "uuid",
  "status": "approved",
  "externalId": "HK-12345",
  "blockedReason": "optional reason"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Worker status updated"
}
```

---

### 3. Download Image

**Endpoint:** `GET <signed_url>`

Pre-signed URL from event data. Just download directly.

---

## HikCentral API

### Base URL
```
https://10.127.0.2/artemis
```

### Authentication

Uses digest authentication with app key/secret.

**Headers:**
```http
Content-Type: application/json
X-Ca-Key: {APP_KEY}
X-Ca-Signature: {SIGNATURE}
X-Ca-Timestamp: {TIMESTAMP}
```

---

### 1. Add Person

**Endpoint:** `POST /api/resource/v1/person/single/add`

**Body:**
```json
{
  "personCode": "1234567890",
  "personFamilyName": "Ali",
  "personGivenName": "Ahmed",
  "gender": 1,
  "phoneNo": "0551234567",
  "email": "",
  "beginTime": "2025-11-20T00:00:00+02:00",
  "endTime": "2035-11-20T00:00:00+02:00",
  "orgIndexCode": "1",
  "faces": [
    {
      "faceData": "base64_encoded_image",
      "faceType": 1
    }
  ]
}
```

**Response:**
```json
{
  "code": "0",
  "msg": "success",
  "data": {
    "personId": "HK-12345"
  }
}
```

---

### 2. Add to Privilege Group

**Endpoint:** `POST /api/acs/v1/privilege/group/single/addPersons`

**Body:**
```json
{
  "privilegeGroupId": "3",
  "list": [
    {
      "id": "HK-12345"
    }
  ]
}
```

**Response:**
```json
{
  "code": "0",
  "msg": "success"
}
```

---

### 3. Remove from Privilege Group

**Endpoint:** `POST /api/acs/v1/privilege/group/single/deletePersons`

**Body:**
```json
{
  "privilegeGroupId": "3",
  "list": [
    {
      "id": "HK-12345"
    }
  ]
}
```

---

### 4. Delete Person

**Endpoint:** `POST /api/resource/v1/person/single/delete`

**Body:**
```json
{
  "personId": "HK-12345"
}
```

---

## Error Codes

### Supabase
- `401` - Unauthorized (check Bearer token & API key)
- `404` - Not found
- `500` - Server error

### HikCentral
- `"0"` - Success
- `"10001"` - Invalid parameter
- `"20001"` - Person already exists
- `"20002"` - Person not found
- `"30001"` - Authentication failed

---

## Rate Limits

- **Supabase**: No strict limit, but respect 60s polling interval
- **HikCentral**: ~10 requests/second recommended

---

## Notes

1. All times use ISO 8601 format
2. National ID numbers are sanitized in logs
3. Images must be JPEG/PNG, max 2MB
4. Face images should be clear, front-facing, 300x300px minimum
5. Privilege Group ID `3` is default access group
