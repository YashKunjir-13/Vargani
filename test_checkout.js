const axios = require('axios');
async function test() {
  try {
    const res = await axios.post('http://localhost:3000/api/v1/donor/payments/checkout', {
      organizationId: '8093db5e-7a2e-4de8-bd4a-67a8427f7f02', // Dummy UUID for format validation
      amountPaise: '100000',
      mode: 'UPI',
      paymentReference: 'Testing purpose'
    });
    console.log("Success:", res.data);
  } catch (err) {
    console.log("Error status:", err.response ? err.response.status : err.message);
    console.log("Error data:", err.response ? err.response.data : '');
  }
}
test();
