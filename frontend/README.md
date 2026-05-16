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

`http://localhost:3000` を開く。Sign in → Cognito Hosted UI → 戻ると email が表示される。`/protected` を開くと backend `/api/me` を Bearer トークン付きで叩いてレスポンスを表示。

## 構成

- `auth.ts` — NextAuth v5 + Cognito provider。`callbacks.jwt` で access_token を JWT 内に取り込み、`callbacks.session` で session に詰める。
- `app/api/auth/[...nextauth]/route.ts` — Auth.js のエンドポイント。コールバック URL は `/api/auth/callback/cognito`。
- `proxy.ts` — `/protected/*` を session 必須に (Next.js 16 で middleware → proxy にリネーム)。
- `app/page.tsx` — Server Action で signIn/signOut。
- `app/protected/page.tsx` — Server Component から backend `/api/me` を fetch。
- `types/next-auth.d.ts` — Session.accessToken の型拡張。
