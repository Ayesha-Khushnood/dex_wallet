# DEX Wallet

<div align="center">

![DEX Wallet](https://img.shields.io/badge/Flutter-3.9.0-blue?style=for-the-badge&logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey?style=for-the-badge)

**A modern, secure, and feature-rich decentralized exchange (DEX) wallet built with Flutter**

[Features](#-features) • [Installation](#-installation) • [Configuration](#-configuration) • [Usage](#-usage) • [Contributing](#-contributing)

</div>

---

## 📖 About

DEX Wallet is a comprehensive cryptocurrency wallet application that provides users with a secure and intuitive interface to manage their digital assets across multiple blockchain networks. Built with Flutter, it offers seamless integration with decentralized applications (dApps), token swapping, NFT management, and much more.

### Key Highlights

- 🔐 **Secure**: Private keys stored securely using Flutter Secure Storage
- 🌐 **Multi-Chain**: Support for Ethereum, BSC, Polygon, Arbitrum, and Optimism
- 🔄 **dApp Integration**: Seamless connection with Web3 dApps via ReownWalletKit
- 💱 **Token Swapping**: Built-in DEX integration for token exchanges
- 📱 **Cross-Platform**: Works on Android, iOS, Web, Linux, macOS, and Windows
- 🎨 **Modern UI**: Beautiful, responsive design with dark theme support

---

## ✨ Features

### 🔐 Security & Authentication
- **PIN Protection**: Secure PIN-based authentication
- **Biometric Authentication**: Face ID / Fingerprint support via Local Auth
- **Secure Storage**: Private keys encrypted and stored securely
- **Email Verification**: Account verification system
- **Password Management**: Forgot password and reset functionality

### 💰 Wallet Management
- **Multi-Wallet Support**: Create and manage multiple wallets
- **Wallet Import/Export**: Import existing wallets or export for backup
- **Address Management**: Generate and manage wallet addresses
- **Balance Tracking**: Real-time balance updates across all supported chains
- **Transaction History**: Complete transaction history with details

### 🌐 Multi-Chain Support
- **Ethereum** (Mainnet & Sepolia Testnet)
- **Binance Smart Chain** (Mainnet & Testnet)
- **Polygon** (Mainnet & Mumbai Testnet)
- **Arbitrum** (Mainnet & Sepolia Testnet)
- **Optimism** (Mainnet & Sepolia Testnet)

### 💸 Transactions
- **Send Crypto**: Send tokens to any address with QR code scanning
- **Receive Crypto**: Generate QR codes for receiving payments
- **Transaction Review**: Review transactions before confirmation
- **Gas Estimation**: Automatic gas price estimation
- **Transaction Status**: Real-time transaction status tracking

### 🔄 DeFi Features
- **Token Swapping**: Swap tokens directly within the app
- **dApp Browser**: Built-in browser for interacting with Web3 dApps
- **Popular dApps**: Quick access to popular DeFi platforms
  - Uniswap
  - OpenSea
  - Compound
  - Aave
  - Curve
  - And more...

### 📊 Market & Analytics
- **Market Data**: Real-time cryptocurrency market prices
- **Portfolio Overview**: Track your total portfolio value
- **Price Charts**: View price history and trends
- **Token Information**: Detailed token information and metadata

### 🖼️ NFT Support
- **NFT Display**: View your NFT collection
- **NFT Marketplace**: Access to NFT marketplaces like OpenSea
- **NFT Details**: View detailed NFT information

### 🎨 User Experience
- **Dark Theme**: Beautiful dark theme interface
- **Responsive Design**: Optimized for all screen sizes
- **Smooth Animations**: Fluid transitions and animations
- **Custom Fonts**: Inter, Quicksand, and Rubik fonts
- **Intuitive Navigation**: Easy-to-use bottom navigation

---

## 🛠️ Tech Stack

### Core Technologies
- **Flutter** `^3.9.0` - Cross-platform UI framework
- **Dart** `^3.9.0` - Programming language

### Key Dependencies
- **web3dart** `^2.7.3` - Ethereum blockchain interaction
- **reown_walletkit** `^1.3.5` - Web3 wallet connectivity
- **flutter_secure_storage** `^9.0.0` - Secure key storage
- **local_auth** `^2.1.7` - Biometric authentication
- **provider** `^6.0.5` - State management
- **dio** `^5.3.2` - HTTP client
- **mobile_scanner** `^5.0.0` - QR code scanning
- **qr_flutter** `^4.1.0` - QR code generation
- **flutter_inappwebview** `^6.0.0` - In-app browser
- **crypto** `^3.0.3` - Cryptographic functions
- **http** `^1.1.0` - HTTP requests

### Development Tools
- **flutter_lints** `^5.0.0` - Linting rules
- **chucker_flutter** `^1.8.5` - API debugging

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.9.0 or higher)
- **Dart SDK** (3.9.0 or higher)
- **Android Studio** / **Xcode** (for mobile development)
- **Git**
- **ReownWalletKit Project ID** (for dApp connectivity)

### Flutter Installation

If you haven't installed Flutter yet, follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install).

Verify your installation:
```bash
flutter doctor
```

---

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/dex-wallet.git
   cd dex-wallet
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   **Important**: Copy `.env.example` to `.env` and fill in your actual API keys:
   ```bash
   cp .env.example .env
   ```
   
   Then edit `.env` and replace the placeholder values:
   ```env
   # Reown WalletKit Project ID for dApp connectivity
   # Get your Project ID from: https://cloud.reown.com
   WALLETKIT_PROJECT_ID=your_reown_walletkit_project_id_here
   
   # Infura Project ID for blockchain RPC endpoints
   # Get your Project ID from: https://www.infura.io/
   INFURA_PROJECT_ID=your_infura_project_id_here
   
   # Backend API Base URL
   API_BASE_URL=https://your-backend-api-url.com/api/
   ```
   
   ⚠️ **Never commit the `.env` file to version control!** It's already in `.gitignore`.

4. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21
- Target SDK: 34
- Ensure Android Studio is properly configured

#### iOS
- Minimum iOS version: 12.0
- Ensure Xcode is properly configured
- Run `pod install` in the `ios` directory if needed

#### Web
```bash
flutter run -d chrome
```

---

## ⚙️ Configuration

### Environment Variables Configuration

The app uses environment variables for sensitive configuration. All sensitive values are loaded from the `.env` file:

- **WALLETKIT_PROJECT_ID**: Your Reown WalletKit Project ID (get from [Reown Cloud](https://cloud.reown.com))
- **INFURA_PROJECT_ID**: Your Infura Project ID (get from [Infura](https://www.infura.io/))
- **API_BASE_URL**: Your backend API base URL

The app will automatically load these values from `.env` on startup. If the `.env` file is missing, the app will use default placeholder values (which won't work for production).

### WalletKit Configuration

The WalletKit Project ID is automatically loaded from your `.env` file. Just make sure you've set `WALLETKIT_PROJECT_ID` in your `.env` file.

### Network Configuration

Network settings can be configured in `lib/config/blockchain_config.dart`:

```dart
// Set network type (mainnet or testnet)
BlockchainConfig.setNetworkType(WalletNetworkType.testnet);

// Set chain type
BlockchainConfig.setChainType(ChainType.ethereum);
```

### RPC Endpoints

The app uses Infura RPC endpoints by default. To use custom RPC endpoints, update the configuration in `lib/config/blockchain_config.dart`.

---

## 📱 Usage

### First Time Setup

1. **Launch the app** - You'll see the splash screen
2. **Create an account** - Sign up with your email
3. **Verify email** - Check your inbox for verification
4. **Set PIN** - Create a secure 6-digit PIN
5. **Create wallet** - Generate your first crypto wallet

### Creating a Wallet

1. Navigate to **Wallet** tab
2. Tap **"Create a new wallet"**
3. Enter your PIN to confirm
4. Your wallet address will be generated
5. **Important**: Save your recovery phrase securely!

### Sending Crypto

1. Go to **Wallet** tab
2. Tap **"Send"** button
3. Scan QR code or enter recipient address
4. Enter amount
5. Review transaction details
6. Confirm with PIN

### Receiving Crypto

1. Go to **Wallet** tab
2. Tap **"Receive"** button
3. Share your QR code or wallet address
4. Wait for incoming transaction

### Connecting to dApps

1. Navigate to **Explore** tab
2. Browse popular dApps
3. Tap on a dApp to open in browser
4. Approve connection when prompted
5. Interact with the dApp

### Swapping Tokens

1. Go to **Swap** tab
2. Select tokens to swap
3. Enter amount
4. Review swap details
5. Confirm transaction

---

## 📁 Project Structure

```
lib/
├── config/              # App configuration
│   ├── blockchain_config.dart
│   ├── generate_routes.dart
│   ├── page_transitions.dart
│   └── wallet_config.dart
├── data/                # Data layer
│   ├── data_sources/    # API clients
│   ├── model/           # Data models
│   └── repos/           # Repositories
├── helper/              # Helper utilities
├── providers/           # State providers
├── services/            # Business logic services
│   ├── auth_service.dart
│   ├── blockchain_service.dart
│   ├── dapp_service.dart
│   ├── transaction_service.dart
│   ├── wallet_service.dart
│   └── web3_provider_service.dart
├── theme/               # Theme configuration
├── util/                # Utility functions
├── view/                # UI screens
│   ├── bottomNav/
│   ├── common/
│   ├── start/           # Authentication screens
│   └── tabs/            # Main app tabs
│       ├── explore/
│       ├── main_wallet/
│       ├── market/
│       ├── settings/
│       └── swap/
└── widgets/             # Reusable widgets
└── main.dart            # App entry point
```

---

## 🔒 Security

### Security Features

- **Encrypted Storage**: All private keys are encrypted using Flutter Secure Storage
- **PIN Protection**: All sensitive operations require PIN verification
- **Biometric Auth**: Optional biometric authentication for quick access
- **No Key Logging**: Private keys never leave the device
- **Secure Communication**: All API calls use HTTPS

### Best Practices

- ⚠️ **Never share your private keys or recovery phrase**
- ⚠️ **Always verify transaction details before confirming**
- ⚠️ **Keep your PIN secure and don't share it**
- ⚠️ **Use testnet for testing before using mainnet**
- ⚠️ **Regularly backup your wallet**

---

## 🧪 Testing

Run tests with:
```bash
flutter test
```

For integration tests:
```bash
flutter test integration_test/
```

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: App crashes on launch
- **Solution**: Ensure all dependencies are installed (`flutter pub get`)
- **Solution**: Check Flutter version compatibility

**Issue**: Cannot connect to blockchain
- **Solution**: Verify internet connection
- **Solution**: Check RPC endpoint configuration
- **Solution**: Ensure you're using correct network (mainnet/testnet)

**Issue**: dApp connection fails
- **Solution**: Verify WalletKit Project ID is correctly configured
- **Solution**: Check network connectivity

**Issue**: Transaction fails
- **Solution**: Ensure sufficient balance for gas fees
- **Solution**: Check network congestion
- **Solution**: Verify recipient address is correct

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### Contribution Guidelines

- Follow the existing code style
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - Amazing cross-platform framework
- [web3dart](https://pub.dev/packages/web3dart) - Ethereum integration
- [ReownWalletKit](https://reown.com/) - Web3 wallet connectivity
- [Infura](https://www.infura.io/) - Blockchain infrastructure
- All the open-source contributors and packages used in this project

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/dex-wallet/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/dex-wallet/discussions)
- **Email**: support@dex-wallet.com

---

## 🗺️ Roadmap

- [ ] Hardware wallet support (Ledger, Trezor)
- [ ] Additional blockchain networks (Solana, Avalanche)
- [ ] Staking functionality
- [ ] Advanced portfolio analytics
- [ ] Multi-language support
- [ ] Social recovery features
- [ ] Gas optimization features
- [ ] Transaction batching

---

## ⚠️ Disclaimer

This software is provided "as is" without warranty of any kind. Users are responsible for the security of their private keys and funds. Always test with small amounts first and use testnet for development.

**Use at your own risk. The developers are not responsible for any loss of funds.**

---

<div align="center">

**Made with ❤️ using Flutter**

⭐ Star this repo if you find it helpful!

</div>
#
