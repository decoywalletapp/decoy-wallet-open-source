import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const expectedStagingProjectRef = "dxsihfandgbrkreeokkm";

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

export class HttpError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

export type AuthContext = {
  authorization: string;
  user: { id: string; email?: string };
  admin: ReturnType<typeof createClient>;
};

export function jsonResponse(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

export function optionsResponse() {
  return new Response("ok", { headers: corsHeaders });
}

export function errorResponse(error: unknown) {
  if (error instanceof HttpError) {
    return jsonResponse(error.status, { ok: false, error: error.message });
  }

  return jsonResponse(500, {
    ok: false,
    error: error instanceof Error ? error.message : "Unexpected staging error",
  });
}

export async function readJson(req: Request): Promise<Record<string, unknown>> {
  try {
    const body = await req.json();
    return body && typeof body === "object" && !Array.isArray(body)
      ? body as Record<string, unknown>
      : {};
  } catch (_) {
    return {};
  }
}

export function cleanString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

export function boolValue(value: unknown): boolean {
  return value === true || value === "true";
}

export function base64FromBytes(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary);
}

export function bytesFromBase64(value: string): Uint8Array {
  return Uint8Array.from(atob(value), (char) => char.charCodeAt(0));
}

export function randomBase64(byteLength: number): string {
  const bytes = new Uint8Array(byteLength);
  crypto.getRandomValues(bytes);
  return base64FromBytes(bytes);
}

export async function sha256Hex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

export async function hashPin(
  pin: string,
  saltB64: string,
): Promise<string> {
  const keyMaterial = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(pin),
    "PBKDF2",
    false,
    ["deriveBits"],
  );
  const bits = await crypto.subtle.deriveBits(
    {
      name: "PBKDF2",
      salt: bytesFromBase64(saltB64),
      iterations: 100000,
      hash: "SHA-256",
    },
    keyMaterial,
    256,
  );
  return base64FromBytes(new Uint8Array(bits));
}

export function addDaysIso(days: number): string {
  const date = new Date();
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString();
}

export function getSupabaseConfig() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    throw new HttpError(
      500,
      "Staging backend is missing required Supabase environment values",
    );
  }

  if (!supabaseUrl.includes(expectedStagingProjectRef)) {
    throw new HttpError(
      500,
      "Staging helper refused to run outside the Decoy staging project",
    );
  }

  return { supabaseUrl, anonKey, serviceRoleKey };
}

export function createAdminClient() {
  const { supabaseUrl, serviceRoleKey } = getSupabaseConfig();
  return createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });
}

export async function requireUser(req: Request): Promise<AuthContext> {
  const { supabaseUrl, anonKey } = getSupabaseConfig();
  const authorization = req.headers.get("Authorization") ?? "";

  if (!authorization.startsWith("Bearer ")) {
    throw new HttpError(401, "Missing user authorization");
  }

  const authClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  });

  const { data, error } = await authClient.auth.getUser();
  const user = data?.user;
  if (error || !user) {
    throw new HttpError(401, "Invalid user authorization");
  }

  return {
    authorization,
    user: { id: user.id, email: user.email ?? undefined },
    admin: createAdminClient(),
  };
}

export function normalizeSlot(value: unknown): number | null {
  const slot =
    typeof value === "number" ? value : Number.parseInt(cleanString(value), 10);
  return Number.isInteger(slot) && slot >= 1 && slot <= 5 ? slot : null;
}

export function stagingUrl(path: string): string {
  return `https://staging.decoywalletapp.example${path}`;
}
