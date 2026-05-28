---
name: verify-endpoints
description: Boots a local dev server, listens to logs, runs curl/HTTP validation requests, checks status codes, and debugs failures automatically.
---
# Automated Endpoint Verification Playbook

This skill instructs the agent to run and test local development servers and verify the responsiveness, response format, and stability of endpoints after any change.

## Target Triggers
- `/verify-endpoints`
- `/loop-debug`
- `"verify endpoint works on dev server"`

## Action Plan

### 1. Identify Server Start Commands
- Find how the server is booted locally (e.g. `npm run dev`, `python main.py`, `flask run`, `uvicorn main:app`, `go run main.go`, `rails s`).
- Determine the port and host configuration (typically `http://localhost:3000` or `http://127.0.0.1:8000`).

### 2. Launch Local Dev Server in Background
- Run the server boot command as a background task using `run_command` with an asynchronous wait time or separate terminal output.
- Wait a few seconds for the database/server connections to initialize.
- Monitor log files or stdout/stderr logs to ensure the server starts without compilation/boot errors.

### 3. Probe and Verify Endpoints
- Execute target curl/HTTP requests representing standard usage:
  - Check the health check endpoint (e.g. `/health`, `/`).
  - Perform GET, POST, or PUT actions with test payloads on modified routes.
  - Review the HTTP response headers and status codes (e.g. `200 OK`, `201 Created`).
  - Parse the JSON body to verify schema correctness.

### 4. Handle Failures & Loop Debug
- If a request returns `500 Internal Server Error`, `404 Not Found`, or fails to connect:
  - Inspect server stdout/stderr logs for traces, exceptions, database errors, or syntax issues.
  - Fix the code matching the traceback.
  - Re-run curl tests until everything passes cleanly.

### 5. Cleanup
- Terminate the background server task once testing is complete using `manage_task` with action `kill`.
- Clean up any temporary or mock database states created during manual probes.
