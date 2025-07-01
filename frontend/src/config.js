// Configuration file for API endpoints
// This file will be automatically updated during deployment

const API_CONFIG = {
  // Local development
  development: 'http://localhost:5000/api',
  
  // Production - this will be automatically replaced during deployment
  production: 'https://kp8upawavi.execute-api.us-east-1.amazonaws.com/',
  
  // Get the current environment's API URL
  getApiUrl: () => {
    const isProd = import.meta.env.PROD || (import.meta.env.MODE === 'production');
    return isProd ? API_CONFIG.production : API_CONFIG.development;
  }
};

export default API_CONFIG;
