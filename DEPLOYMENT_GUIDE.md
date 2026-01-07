# ReFi Platform - Deployment Guide

## Frontend Setup (refiFrontend)

### Prerequisites
- Node.js 18+
- npm or yarn

### Installation

```bash
cd refiFrontend
npm install
```

### Environment Variables

Create a `.env.local` file in the refiFrontend directory:

```env
# Contract Addresses on Mantle Sepolia
NEXT_PUBLIC_ORACLE_ADDRESS=0xaCB5D04cfda744e6F81Df82cF2771CE8c6B55CCB
NEXT_PUBLIC_FACTORY_ADDRESS=0xB9C6fceD595295edc49FaF58D61ce7916E1D4299
NEXT_PUBLIC_USDC_ADDRESS=0x53248C753AA91bec5D486cBfaEb1ABbeF2f5B1D2

# Network
NEXT_PUBLIC_CHAIN_ID=5003
NEXT_PUBLIC_RPC_URL=https://rpc.sepolia.mantle.xyz

# Admin Wallet - All investment payments go here
NEXT_PUBLIC_ADMIN_ADDRESS=0x56EDAf354806e0c25Ff7aDC4AF5C35ef802C319b

# Database (Neon PostgreSQL)
DATABASE_URL=postgresql://neondb_owner:npg_noHKLC6AO1ND@ep-patient-field-a1db7o95-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

### Running Development Server

```bash
cd refiFrontend
npm run dev
```

The application will be available at `http://localhost:3000`

### Building for Production

```bash
cd refiFrontend
npm run build
npm start
```

## Features

### Landing Page
- Dual portal system (Investor & Admin)
- Wallet connection via RainbowKit
- Property browsing and investment capability
- Admin access with fixed wallet address

### Admin Dashboard
- View platform statistics
- Manage properties and vaults
- Create new properties
- Update oracle data
- Back navigation to home

### Payment System
- Direct USDC transfers to admin wallet
- Fixed admin address: `0x56EDAf354806e0c25Ff7aDC4AF5C35ef802C319b`
- All investor payments go directly to admin

## Database

The application uses PostgreSQL (Neon) for data storage:

- Properties
- Investments
- Transactions
- Oracle data

## Important Notes

### Node Modules
The `node_modules` folder is intentionally not included in git due to size constraints. Always run `npm install` after cloning.

### .env.local
The `.env.local` file contains sensitive information and is not committed. Create it locally with appropriate values for your deployment.

### .next / Build artifacts
Build artifacts are also excluded from git. Run `npm run build` to generate them.

## Support

For issues or questions, refer to the documentation files in the root directory:
- ARCHITECTURE.md - System design
- ADMIN_SETUP.md - Admin configuration
- PROJECT_STATUS.md - Current status
