# frontend

Next.js 16 (App Router) + Auth.js v5 + Cognito Hosted UI のサンプル。

## セットアップ

```sh
cp .env.local.example .env.local
# .env.local の値を埋める:
#   AUTH_SECRET=$(openssl rand -base64 32)
#   AUTH_COGNITO_ID / AUTH_COGNITO_SECRET / AUTH_COGNITO_ISSUER は
#   terraform -chdir=../terraform/environment/dev/cognito output から取得
npm install
npm run dev
```

`http://localhost:3000` を開く。Sign in → Cognito Hosted UI → 戻ると email が表示される。`/protected` は proxy.ts で session 必須に設定されており、ログイン済みなら session.user の中身を表示する。

## 構成

- `auth.ts` — NextAuth v5 + Cognito provider。
- `app/api/auth/[...nextauth]/route.ts` — Auth.js のエンドポイント。コールバック URL は `/api/auth/callback/cognito`。
- `proxy.ts` — `/protected/*` を session 必須に (Next.js 16 で middleware → proxy にリネーム)。
- `app/page.tsx` — Server Action で signIn/signOut。
- `app/protected/page.tsx` — Server Component で session.user を表示。
