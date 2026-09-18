export async function hasActiveDecoyWalletAccess(supabaseAdmin, userId) {
  const { data, error } = await supabaseAdmin.rpc(
    'has_active_decoy_wallet_access',
    { p_user_id: userId },
  );
  if (error) {
    throw new Error(`entitlement lookup failed: ${error.message}`);
  }
  return data === true;
}
