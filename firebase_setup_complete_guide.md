# Firebase Google認証 完全設定ガイド

## 概要
このガイドでは、Flutter アプリに Firebase Google認証を完全に設定する手順を説明します。

---

## 1. Firebase Console での設定

### 1.1 Google認証プロバイダーの有効化

1. **Firebase Console を開く**
   - https://console.firebase.google.com にアクセス
   - プロジェクト「flash-4523a」を選択

2. **認証設定**
   - 左メニューから「Authentication」をクリック
   - 「Sign-in method」タブをクリック
   - 「Google」を見つけて「有効にする」をクリック

3. **プロジェクトサポートメールの設定**
   - Google認証を有効にする際、サポートメールアドレスを入力
   - 通常は開発者のメールアドレス

4. **保存**
   - 設定を保存

### 1.2 iOS アプリの Bundle ID 確認

1. **プロジェクト設定を開く**
   - Firebase Console で歯車マーク → 「プロジェクトの設定」

2. **iOS アプリの確認**
   - 「マイアプリ」セクションでiOSアプリを確認
   - Bundle ID が `com.example.flashCompositionApp` になっているか確認

---

## 2. REVERSED_CLIENT_ID の確認

### 2.1 GoogleService-Info.plist から値を取得

1. **Xcode でプロジェクトを開く**
   - `/Users/kt/flash_composition/flash_composition_app/ios/Runner.xcworkspace` を開く

2. **GoogleService-Info.plist を開く**
   - 左側ナビゲーションで「Runner」フォルダを展開
   - 「GoogleService-Info.plist」をクリック

3. **REVERSED_CLIENT_ID をコピー**
   - `REVERSED_CLIENT_ID` の値をコピー
   - 例: `com.googleusercontent.apps.368459758861-xxxxxxxxxxxxxxxx`

---

## 3. Xcode での URL Scheme 設定

### 3.1 Info.plist の編集

1. **Runnerターゲットを選択**
   - 左側ナビゲーションで「Runner」プロジェクトをクリック
   - 「TARGETS」の「Runner」を選択

2. **Infoタブを選択**
   - 上部タブから「Info」をクリック

3. **URL Types セクションを展開**
   - 「URL Types (0)」の横にある「▶」をクリックして展開

4. **新しい URL Type を追加**
   - 「URL Types」セクションの「+」ボタンをクリック
   - 「Item 0」が追加される

5. **URL Type の設定**
   - **「Item 0」を展開**
   - **「+」ボタンをクリックして以下を追加:**
     
     a) **URL identifier を追加**
     - Key: `URL identifier`
     - Type: `String`
     - Value: `GoogleSignIn`

     b) **URL Schemes を追加**
     - Key: `URL Schemes`
     - Type: `Array`
     - 「URL Schemes」を展開して「+」ボタンをクリック
     - 「Item 0」に手順2.1でコピーした `REVERSED_CLIENT_ID` の値を入力

### 3.2 設定の確認

最終的に以下のような構造になります：

```
URL Types (Array)
└── Item 0 (Dictionary)
    ├── URL identifier (String) = GoogleSignIn
    └── URL Schemes (Array)
        └── Item 0 (String) = com.googleusercontent.apps.368459758861-xxxxxxxxxxxxxxxx
```

---

## 4. アプリのテスト

### 4.1 アプリの再起動

1. **アプリを停止**
   - Xcode で停止ボタンをクリック

2. **アプリを再起動**
   - 再生ボタンをクリック

### 4.2 Google認証のテスト

1. **ログイン画面を開く**
   - アプリが起動したらログイン画面に移動

2. **Google認証をテスト**
   - 「Googleでサインイン」ボタンをタップ
   - Googleの認証画面が表示されるか確認
   - 認証が完了するか確認

---

## 5. トラブルシューティング

### 5.1 よくある問題と解決策

**問題: アプリがクラッシュする**
- **原因**: URL Scheme が正しく設定されていない
- **解決**: 手順3を再度確認し、REVERSED_CLIENT_ID が正しく設定されているか確認

**問題: Google認証画面が表示されない**
- **原因**: Firebase Console でGoogle認証が有効になっていない
- **解決**: 手順1.1を再度実行

**問題: 認証後にアプリに戻らない**
- **原因**: URL Scheme の値が間違っている
- **解決**: GoogleService-Info.plist の REVERSED_CLIENT_ID を再度確認

### 5.2 ログの確認

**Xcode コンソールでエラーログを確認:**
1. Xcode で「View」→「Debug Area」→「Show Debug Area」
2. 下部のコンソールでエラーメッセージを確認

**よくあるエラーメッセージ:**
- `URL scheme not found`: URL Scheme が設定されていない
- `Bundle ID mismatch`: Bundle ID が Firebase Console と一致しない

---

## 6. 設定完了後の確認事項

### 6.1 チェックリスト

- [ ] Firebase Console で Google認証が有効
- [ ] GoogleService-Info.plist がプロジェクトに追加済み
- [ ] REVERSED_CLIENT_ID が Info.plist の URL Schemes に設定済み
- [ ] アプリが正常に起動する
- [ ] Google認証ボタンをタップしてもクラッシュしない
- [ ] Google認証画面が表示される
- [ ] 認証後にアプリに戻る

### 6.2 最終テスト

1. **アプリを完全に停止**
2. **デバイスからアプリを削除**
3. **Xcode から再インストール**
4. **Google認証をテスト**

---

## 7. 次のステップ

### 7.1 Android サポート（必要に応じて）

現在はiOSのみの設定ですが、Android サポートが必要な場合：

1. **google-services.json の追加**
   - Firebase Console からダウンロード
   - `android/app/` フォルダに配置

2. **Android の設定**
   - SHA-1 フィンガープリントの設定
   - `android/build.gradle` の確認

### 7.2 他の認証方法

- Email/Password認証は既に実装済み
- 他の認証プロバイダー（Twitter、Facebook等）の追加

---

## 8. サポート情報

**設定で問題が発生した場合:**

1. **エラーログをXcodeで確認**
2. **Firebase Console の設定を再確認**
3. **GoogleService-Info.plist の内容を確認**
4. **Bundle ID の一致を確認**

**重要なファイル:**
- `ios/Runner/GoogleService-Info.plist`
- `ios/Runner/Info.plist`
- `lib/firebase_options.dart`

この手順で Google認証が正常に動作するはずです。