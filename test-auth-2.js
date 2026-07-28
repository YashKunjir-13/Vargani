const http = require('http');

const request = (path, method, body) => {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: `/api/v1/auth${path}`,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data)
      }
    };
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(body || '{}') }));
    });
    req.on('error', e => resolve({ error: e.message }));
    req.write(data);
    req.end();
  });
};

async function run() {
  const phone = `987654${Math.floor(Math.random() * 10000)}`;
  console.log(`Using phone number: ${phone}`);

  console.log('\n--- 1. Register ONLY Trust ---');
  const regTrust = await request('/register/trust', 'POST', {
    mandalTrustName: "Test Mandal Only",
    phoneNumber: phone,
    password: "password123",
    preferredLanguage: "EN",
    city: "Pune",
    state: "Maharashtra",
    postalCode: "411001",
    presidentHeadName: "Test President",
    festivalYear: 2026
  });
  console.log(regTrust.status);

  console.log('\n--- 2. Login As Donor (Should Fail) ---');
  const loginDonor = await request('/login', 'POST', {
    phoneNumber: phone,
    password: "password123",
    role: "DONOR"
  });
  console.log(loginDonor);
}

run();
