# Google認証クラッシュ解決手順

## 現在の状況
- URL Scheme は正しく設定済み
- アプリは「Google サインイン開始」まで実行
- その後クラッシュ

## 解決手順

### 1. Firebase Console での Google認証設定

**必須：以下を必ず実行してください**

1. **Firebase Console を開く**
   - https://console.firebase.google.com
   - プロジェクト「flash-4523a」を選択

2. **Authentication設定**
   - 左メニュー「Authentication」をクリック
   - 「Sign-in method」タブをクリック

3. **Google認証を有効化**
   - 「Google」を見つけてクリック
   - 「有効にする」をONにする
   - **プロジェクトのサポートメール**を入力（必須）
   - 「保存」をクリック

### 2. iOS設定の確認

**SHA-1フィンガープリントの追加（重要）**

1. **開発用SHA-1の取得**
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

2. **Firebase Console での設定**
   - プロジェクト設定 → iOS アプリ
   - 「SHA証明書フィンガープリント」を追加

### 3. Info.plist の追加設定

**CFBundleURLName の追加**

1. **Xcode で Info.plist を開く**
   - Runner → Info → Custom iOS Target Properties

2. **URL Types の設定を完全にする**
   ```
   CFBundleURLTypes
   └── Item 0
       ├── CFBundleURLName = GoogleSignIn
       └── CFBundleURLSchemes
           └── Item 0 = com.googleusercontent.apps.368459758861-ihj6rsljptc6a1hsdnot686q9irv3umk
   ```

### 4. Bundle IDの確認

**重要：Bundle IDが一致しているか確認**

1. **Xcode での Bundle ID**
   - Runner → General → Identity → Bundle Identifier
   - `com.example.flashCompositionApp` になっているか確認

2. **Firebase Console での Bundle ID**
   - プロジェクト設定 → iOS アプリ
   - Bundle ID が一致しているか確認

### 5. Google認証のテスト環境設定

**テスト用Googleアカウントの追加**

1. **Firebase Console**
   - Authentication → Users → Add user
   - テスト用のGoogleアカウントを追加

2. **または**
   - Authentication → Sign-in method → Google → テストモード

### 6. 詳細なエラーログの確認

**Xcode コンソールでエラーを確認**

1. **Xcode を開く**
   - View → Debug Area → Show Debug Area

2. **アプリを実行**
   - Google認証をタップ
   - コンソールのエラーメッセージを確認

**よくあるエラーと対処法：**

- `DEVELOPER_ERROR` → OAuth設定の問題
- `SIGN_IN_REQUIRED` → Firebase Console設定の問題
- `NETWORK_ERROR` → インターネット接続の問題

### 7. 最後の手段：設定ファイルの再作成

**GoogleService-Info.plist の再ダウンロード**

1. **Firebase Console**
   - プロジェクト設定 → iOS アプリ
   - 「GoogleService-Info.plist をダウンロード」

2. **古いファイルを置き換え**
   - `/Users/kt/flash_composition/flash_composition_app/ios/Runner/GoogleService-Info.plist`

3. **Xcode で再追加**
   - Runner フォルダに再追加
   - Target membership を確認

## 最優先で実行すべき項目

1. **Firebase Console で Google認証を有効化**（最重要）
2. **サポートメールアドレスの設定**
3. **Bundle ID の一致確認**
4. **Xcode コンソールでエラーメッセージを確認**

これらを実行後、再度テストしてください。