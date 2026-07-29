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

  console.log('\n--- 1. Register Trust ---');
  const regTrust = await request('/register/trust', 'POST', {
    mandalTrustName: "Test Mandal",
    phoneNumber: phone,
    password: "password123",
    preferredLanguage: "EN",
    city: "Pune",
    state: "Maharashtra",
    postalCode: "411001",
    presidentHeadName: "Test President",
    festivalYear: 2026
  });
  console.log(regTrust);

  console.log('\n--- 2. Register Donor (Same Phone) ---');
  const regDonor = await request('/register/donor', 'POST', {
    fullName: "Test Donor",
    phoneNumber: phone,
    email: `test${phone}@example.com`,
    password: "password123",
    preferredLanguage: "EN",
    city: "Pune",
    postalCode: "411001"
  });
  console.log(regDonor);

  console.log('\n--- 3. Register Duplicate Trust ---');
  const dupTrust = await request('/register/trust', 'POST', {
    mandalTrustName: "Test Mandal 2",
    phoneNumber: phone,
    password: "password123",
    preferredLanguage: "EN",
    city: "Pune",
    state: "Maharashtra",
    postalCode: "411001",
    presidentHeadName: "Test President",
    festivalYear: 2026
  });
  console.log(dupTrust);

  console.log('\n--- 4. Register Duplicate Donor ---');
  const dupDonor = await request('/register/donor', 'POST', {
    fullName: "Test Donor 2",
    phoneNumber: phone,
    email: `test${phone}2@example.com`,
    password: "password123",
    preferredLanguage: "EN",
    city: "Pune",
    postalCode: "411001"
  });
  console.log(dupDonor);

  console.log('\n--- 5. Login As Trust ---');
  const loginTrust = await request('/login', 'POST', {
    phoneNumber: phone,
    password: "password123",
    role: "MANDAL"
  });
  console.log(loginTrust);

  console.log('\n--- 6. Login As Donor ---');
  const loginDonor = await request('/login', 'POST', {
    phoneNumber: phone,
    password: "password123",
    role: "DONOR"
  });
  console.log(loginDonor);

  console.log('\n--- 7. Login Wrong Role (Trust, wrong phone) ---');
  const loginWrong = await request('/login', 'POST', {
    phoneNumber: "9999999999", // assuming not registered
    password: "password123",
    role: "MANDAL"
  });
  console.log(loginWrong);
}

run();
