# Customer Gift Management App

> ⚠️ **IMPORTANT: TESTING APPLICATION ONLY**
>
> This Flutter application is developed **for testing and requirement for process interview purposes only**.
> It is **NOT intended for production use** and may lack proper error handling, security measures,
> and comprehensive testing that would be required for a production-ready application.

## 🚨 Limitations & Disclaimers

### What This App DOES:
- ✅ Demonstrates Flutter + Laravel API integration
- ✅ requirement based on process interview coding of PT.Tirtakencana Tatawarna

### What This App DOES NOT:
- ❌ **Comprehensive error handling** - May crash on unexpected API responses
- ❌ **Input validation** - Limited form validation
- ❌ **Security measures** - No encryption, authentication, or authorization
- ❌ **Performance optimization** - Not optimized for large datasets
- ❌ **Offline capability** - Requires constant internet connection
- ❌ **Backend error recovery** - May not handle all backend error scenarios
- ❌ **Data persistence** - No local database/cache
- ❌ **Comprehensive testing** - Limited test coverage

### Known Limitations:
- **API Error Handling**: Basic try-catch blocks only
- **Network Issues**: No retry mechanisms for failed requests
- **Data Validation**: Relies on backend validation
- **State Management**: Basic BLoC implementation without advanced patterns
- **UI/UX**: Minimal loading states and user feedback
- **Security**: No token-based authentication
- **Error Messages**: Generic error messages without detailed user guidance

### Flutter Environment

Flutter 3.35.7 • channel stable

Tools • Dart 3.9.2 • DevTools 2.48.0

### WiFi Connection to Laravel Backend

To connect to your Laravel backend running on the same WiFi network:

1. **Find your computer's IP address:**
    - **Windows**: Run `ipconfig` in Command Prompt, look for "IPv4 Address"
    - **Mac/Linux**: Run `ifconfig` or `ip addr`, look for "inet"
    - Example: `192.168.1.100`

2. **Update Base URL in App:**
    - Tap the **Settings icon (⚙️)** in the top-right corner of apps
    - ![img.png](img.png)
    - Change Base URL to: `http://[YOUR_IP_ADDRESS]:8000/api/v1`
    - Example: `http://192.168.1.100:8000/api/v1`
    - Tap **TEST CONNECTION** to verify
    - Tap **SAVE** to apply changes