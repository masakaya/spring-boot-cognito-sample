import Link from "next/link";

import { auth } from "@/auth";

export default async function Protected() {
  const session = await auth();

  return (
    <main className="min-h-screen p-8 font-sans">
      <h1 className="mb-4 text-2xl font-bold">Protected page</h1>
      <p className="mb-4 text-sm text-gray-600">
        proxy.ts によって session が無いと到達できないルート。
      </p>
      <pre className="rounded bg-gray-100 p-4 text-sm">
        {JSON.stringify(session?.user, null, 2)}
      </pre>
      <p className="mt-6">
        <Link className="text-blue-600 underline" href="/">
          back to /
        </Link>
      </p>
    </main>
  );
}
