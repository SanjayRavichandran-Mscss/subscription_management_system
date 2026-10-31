# Brightloop ERP

## Requirements
- Node.js 20 or newer
- MySQL 8
- Gmail account with 2-Step Verification enabled

## Start the backend
1. Copy `.env.example` to `.env`.
2. Configure MySQL credentials and SMTP settings.
3. Run `npm install`.
4. Run `npm run db:init`.
5. Run `npm start`.
   The API will not start if MySQL cannot be reached.

## Start the frontend
1. Run `npm install`.
2. Run `npm run dev`.

## Gmail App Password
Do not use your normal Gmail password.
1. Sign in to the Google account `sanjayravichandran600@gmail.com`.
2. Enable 2-Step Verification.
3. Open Google Account > Security > 2-Step Verification > App passwords.
4. Create an app named `Brightloop ERP`.
5. Copy the generated 16-character password into `SMTP_PASS`.
6. Restart the API server after changing `.env`.
