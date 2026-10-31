# Brightloop Subscription Management ERP

Brightloop ERP is a full-stack subscription billing and customer management application built with React, Tailwind CSS, Node.js, Express, and MySQL.

## Demo Credentials

The password for every seeded account is:

```text
Admin123!
```

| Role | Email Address | Access |
|---|---|---|
| Super Admin | `admin@brightloop.local` | Complete ERP administration |
| Admin | `manager@brightloop.local` | Business and operational management |
| Staff | `staff@brightloop.local` | Billing and customer operations |
| Customer | `aarav@example.com` | Customer portal |

## Application URLs

| Service | URL |
|---|---|
| Frontend | `http://localhost:5173` |
| Backend API | `http://localhost:5000/api` |
| API health check | `http://localhost:5000/api/test/test` |

## Working Flow

1. Start MySQL and initialize the database.
2. Start the backend API.
3. Start the frontend application.
4. Sign in using one of the demo accounts.
5. Super Admin and Admin users manage catalog, customers, plans, quotations, subscriptions, billing, finance, and reports.
6. Staff users process approved billing and finance operations.
7. Customers view only their own subscriptions, invoices, quotations, and payments.
8. Create a quotation, confirm the subscription, and attach a recurring plan.
9. Run billing manually through the workflow API or wait for the scheduled recurring billing job.
10. Generate invoices and PDF documents.
11. Record payments and allocate them to customer invoices.
12. Process eligible refunds.
13. Review revenue and operational reports from the dashboard.

## Requirements

- Node.js 20 or newer
- npm
- MySQL 8
- Gmail account with 2-Step Verification enabled for email delivery

## Installation

### 1. Clone or open the project

```powershell
cd E:\subscription_management_system
```

### 2. Configure and initialize MySQL

Create the database by running the supplied initializer:

```powershell
cd server
npm install
Copy-Item .env.example .env
npm run db:init
```

Update `server/.env` for the local MySQL account before running initialization.

### 3. Start the backend

```powershell
npm start
```

The backend performs a database connection check before opening port 5000.

### 4. Start the frontend

Open a second terminal:

```powershell
cd E:\subscription_management_system\client
npm install
npm run dev
```

## Database Configuration

Example `server/.env` database settings:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=subscription_management
```

## Gmail Configuration

1. Sign in to the Gmail account configured in `server/.env`.
2. Enable Google 2-Step Verification.
3. Open Google Account > Security > 2-Step Verification > App passwords.
4. Create an app password named `Brightloop ERP`.
5. Paste the generated 16-character password into `SMTP_PASS`.
6. Restart the backend.

Example:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=sanjayravichandran600@gmail.com
SMTP_PASS=your_generated_app_password
SMTP_FROM=Brightloop ERP <sanjayravichandran600@gmail.com>
```

Do not place the normal Gmail password or spaces from the app password in `SMTP_PASS`.

## Email Workflow

- Select **Forgot password** on the login screen.
- Enter a registered user email address.
- Brightloop sends a one-hour reset link through Gmail SMTP.
- Open the reset link and choose a strong new password.
- Existing refresh tokens are revoked after a successful reset.

## Core Modules

- Dashboard and subscription metrics
- Customer management
- Product, category, and variant catalog
- Subscription plans
- Quotations and PDF quotations
- Subscription lifecycle management
- Automated recurring billing
- Billing runs and invoice generation
- Invoice lifecycle and PDF invoices
- Payments and transaction-safe allocations
- Refund processing
- Taxes and discounts
- Users, roles, and permissions
- Notifications and audit records
- Revenue and operational reports
- Customer-specific portal isolation

## Important API Endpoints

| Purpose | Endpoint |
|---|---|
| Login | `POST /api/auth/login` |
| Register customer | `POST /api/auth/register` |
| Refresh JWT | `POST /api/auth/refresh` |
| Forgot password | `POST /api/auth/forgot-password` |
| Reset password | `POST /api/auth/reset-password` |
| Health check | `GET /api/test/test` |
| Dashboard | `GET /api/dashboard` |
| Subscription action | `POST /api/workflows/subscriptions/:id/:action` |
| Run billing | `POST /api/workflows/billing/run` |
| Quotation PDF | `GET /api/quotations/:id/pdf` |
| Invoice PDF | `GET /api/invoices/:id/pdf` |

Supported subscription actions:

```text
activate
pause
cancel
renew
expire
```

## Verification Commands

Backend tests:

```powershell
cd server
npm test
```

Frontend production build:

```powershell
cd client
npm run build
```

## Demo Script

1. Open the login screen.
2. Sign in as Super Admin.
3. Show the dashboard metrics and revenue report.
4. Open Customers and add or edit a customer.
5. Open Products and create a subscription product.
6. Open Subscription Plans and show the recurring plan configuration.
7. Open Quotations and download a quotation PDF.
8. Open Subscriptions and demonstrate activate, pause, renew, or cancel.
9. Open Billing Runs and run a billing workflow.
10. Open Invoices and confirm, cancel, or download an invoice.
11. Record a payment and review the resulting invoice allocation.
12. Sign out and log in as the Customer account to demonstrate data isolation.
13. Test Forgot Password using a registered email address.

## Security Notes

- Passwords are stored as bcrypt hashes.
- Access uses JWT authentication.
- Refresh tokens are stored as hashes and support rotation/revocation.
- Password reset tokens expire after one hour.
- Customer resources are filtered by the linked customer account.
- Administrative user operations are restricted to Admin and Super Admin roles.
- API database access uses parameterized MySQL queries.

## Troubleshooting

- If the API does not start, confirm MySQL is running and database credentials are correct.
- If the frontend shows API errors, confirm the backend is running on port 5000.
- If Gmail delivery fails, verify 2-Step Verification and generate a new App Password.
- If Vite reports a port conflict, use the alternate URL printed in the terminal.
