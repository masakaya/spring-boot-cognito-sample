import Link from "next/link";

import { auth, signIn, signOut } from "@/auth";

export default async function Home() {
  const session = await auth();

  return (
    <main className="min-h-screen p-8 font-sans">
      <h1 className="mb-6 text-2xl font-bold">Cognito Hosted UI Sample</h1>

      {session?.user ? (
        <div className="space-y-4">
          <p>
            Signed in as <strong>{session.user.email ?? session.user.name}</strong>
          </p>
          <form
            action={async () => {
              "use server";
              await signOut({ redirectTo: "/" });
            }}
          >
            <button
              type="submit"
              className="rounded bg-gray-800 px-4 py-2 text-white hover:bg-gray-700"
            >
              Sign out
            </button>
          </form>
          <Link className="text-blue-600 underline" href="/protected">
            /protected を開く
          </Link>
        </div>
      ) : (
        <form
          action={async () => {
            "use server";
            await signIn("cognito");
          }}
        >
          <button
            type="submit"
            className="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-500"
          >
            Sign in with Cognito
          </button>
        </form>
      )}
    </main>
  );
}
