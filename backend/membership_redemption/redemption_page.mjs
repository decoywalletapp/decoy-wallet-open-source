export function renderRedemptionPage({ apiBaseUrl, sessionToken }) {
  const api = JSON.stringify(apiBaseUrl);
  const session = JSON.stringify(sessionToken);
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Redeem Membership | Decoy Wallet</title>
<style>
body{margin:0;background:#fff;color:#111;font-family:Arial,sans-serif}main{max-width:520px;margin:0 auto;padding:48px 24px}.brand{color:#ff5a00;font-weight:800;letter-spacing:.08em}h1{font-size:34px;margin:56px 0 12px}p{line-height:1.5;color:#59636d}label{display:block;font-weight:700;margin:32px 0 8px}input{box-sizing:border-box;width:100%;padding:18px;border:3px solid #ff5a00;border-radius:8px;font-size:20px;text-transform:uppercase}button,a.button{box-sizing:border-box;display:block;width:100%;margin-top:20px;padding:17px;border:0;border-radius:8px;background:#ff5a00;color:#fff;font-size:20px;font-weight:700;text-align:center;text-decoration:none}.message{min-height:24px;margin-top:18px;font-weight:700}.error{color:#d90429}.success{color:#069c32}</style>
</head><body><main><div class="brand">DECOY WALLET</div><h1>Redeem Membership</h1>
<p>Enter the membership code from your event tag. A valid code adds 365 days of access to your account.</p>
<form id="redeem"><label for="code">Membership code</label><input id="code" autocomplete="off" autocapitalize="characters" placeholder="MWBS-XXXX-XXXX-XXXX" required><button type="submit">Redeem 1 Year</button></form>
<div id="message" class="message" role="status"></div><a id="return" class="button" href="decoywalletapp://paymentreturn" hidden>Return to Decoy Wallet App</a></main>
<script>const api=${api},session=${session},form=document.getElementById('redeem'),msg=document.getElementById('message'),back=document.getElementById('return');form.addEventListener('submit',async(e)=>{e.preventDefault();msg.className='message';msg.textContent='Redeeming...';try{const response=await fetch(api+'/redeem-membership-code',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({session,code:document.getElementById('code').value})});const data=await response.json();if(!response.ok)throw new Error(data.error||'Unable to redeem this code.');msg.className='message success';msg.textContent='Your membership has been extended by 365 days.';form.hidden=true;back.href=data.return_url||back.href;back.hidden=false}catch(error){msg.className='message error';msg.textContent=error.message;}});</script></body></html>`;
}
