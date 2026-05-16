import Link from "next/link";

import { auth } from "@/auth";

export const dynamic = "force-dynamic";

export default async function Protected() {
  const session = await auth();
  const accessToken = session?.accessToken;
  const backend = process.env.NEXT_PUBLIC_BACKEND_BASE ?? "http://localhost:8080";

  let body: unknown;
  if (!accessToken) {
    body = { error: "no access token in session" };
  } else {
    const res = await fetch(`${backend}/api/me`, {
      headers: { Authorization: `Bearer ${accessToken}` },
      cache: "no-store",
    });
    body = res.ok ? await res.json() : { error: `status=${res.status}` };
  }

  return (
    <main className="min-h-screen p-8 font-sans">
      <h1 className="mb-4 text-2xl font-bold">/api/me (via Spring Boot)</h1>
      <pre className="rounded bg-gray-100 p-4 text-sm">
        {JSON.stringify(body, null, 2)}
      </pre>
      <p className="mt-6">
        <Link className="text-blue-600 underline" href="/">
          back to /
        </Link>
      </p>
    </main>
  );
}
