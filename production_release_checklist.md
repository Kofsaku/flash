# 本番リリースチェックリスト - 瞬間英作文アプリ

## 📱 アプリ概要
- **アプリ名**: 瞬間英作文アプリ (Flash Composition App)
- **機能**: 日本語から英語への即座の翻訳練習を支援する言語学習アプリ
- **対象プラットフォーム**: iOS & Android
- **現在のバージョン**: 1.0.0+1

## 🚨 緊急対応が必要な項目

### 1. パッケージID/バンドルIDの変更
- [ ] **Android**: `com.example.flash_composition_app` を独自のIDに変更
  - `android/app/build.gradle.kts` の `applicationId` を更新
  - 推奨形式: `com.yourcompany.flashcomposition`
- [ ] **iOS**: `com.example.flashCompositionApp` を独自のIDに変更
  - Xcodeでプロジェクト設定を開き、Bundle Identifierを更新

### 2. アプリ署名の設定

#### Android署名
- [ ] リリース用キーストアの作成:
  ```bash
  keytool -genkey -v -keystore ~/flash-composition-release.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias release
  ```
- [ ] `android/key.properties` ファイルの作成:
  ```properties
  storePassword=<パスワード>
  keyPassword=<パスワード>
  keyAlias=release
  storeFile=<キーストアファイルへのパス>
  ```
- [ ] `android/app/build.gradle.kts` でリリース署名設定を追加
- [ ] `.gitignore` に `key.properties` と `.jks` ファイルを追加

#### iOS署名
- [ ] Apple Developer Programへの登録
- [ ] App IDの作成
- [ ] Provisioning Profileの作成
- [ ] Xcodeで署名設定を構成

### 3. セキュリティ対策

#### APIキーの保護
- [ ] `firebase_options.dart` の "TO_BE_REPLACED" を実際のAPIキーに置換
- [ ] 本番用と開発用の環境を分離
- [ ] 環境変数または安全なストレージを使用してAPIキーを管理
- [ ] Gitリポジトリからハードコードされたキーを削除

#### コード保護
- [ ] ProGuardルールの作成 (`android/app/proguard-rules.pro`):
  ```proguard
  -keep class io.flutter.** { *; }
  -keep class com.google.firebase.** { *; }
  -keepattributes *Annotation*
  ```
- [ ] `build.gradle.kts` でminifyEnabledを有効化

## 📋 リリース前の必須項目

### アプリメタデータの更新
- [ ] **アプリ名の設定**:
  - Android: `android/app/src/main/AndroidManifest.xml` の `android:label`
  - iOS: `ios/Runner/Info.plist` の `CFBundleDisplayName`
- [ ] **バージョン番号の更新**: `pubspec.yaml` の `version` を適切に設定
- [ ] **パッケージ名の修正**: `pubspec.yaml` の `name` を `flash_composition` などに変更

### アプリアイコンとスプラッシュ画面
- [ ] カスタムアプリアイコンの作成（全サイズ）:
  - Android: mipmap-hdpi, mipmap-mdpi, mipmap-xhdpi, mipmap-xxhdpi, mipmap-xxxhdpi
  - iOS: 20pt, 29pt, 40pt, 60pt の各サイズ（@2x, @3x含む）
- [ ] flutter_launcher_icons パッケージの使用を検討
- [ ] カスタムスプラッシュ画面の実装

### パーミッション設定
- [ ] **iOS** (`ios/Runner/Info.plist`):
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>プロフィール写真の撮影に使用します</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>プロフィール写真の選択に使用します</string>
  ```
- [ ] **Android**: 必要に応じて `AndroidManifest.xml` にパーミッションを追加

### ビルド最適化
- [ ] リリースビルドの最適化設定
- [ ] 不要な依存関係の削除
- [ ] アセットの最適化（画像圧縮など）

## 🏪 ストア申請準備

### 共通
- [ ] プライバシーポリシーのURL準備（既存ファイルをウェブで公開）
- [ ] 利用規約のURL準備
- [ ] サポート連絡先情報
- [ ] アプリカテゴリの選択（教育）

### Google Play Store
- [ ] アプリアイコン（512x512px）
- [ ] フィーチャーグラフィック（1024x500px）
- [ ] スクリーンショット（最低2枚、推奨8枚）
- [ ] 短い説明文（80文字以内）
- [ ] 詳細な説明文（4000文字以内）
- [ ] コンテンツレーティングアンケートの回答

### Apple App Store
- [ ] アプリアイコン（1024x1024px）
- [ ] スクリーンショット（各デバイスサイズ用）
- [ ] アプリプレビュー動画（オプション）
- [ ] キーワード（100文字以内）
- [ ] アプリ説明文
- [ ] 年齢制限の設定

## 🔧 技術的な改善項目

### パフォーマンス
- [ ] 初回起動時間の最適化
- [ ] メモリ使用量の確認と最適化
- [ ] ネットワーク通信の最適化

### テスト
- [ ] 単体テストの実行と修正
- [ ] 統合テストの作成
- [ ] 実機での動作確認（複数のデバイスサイズ）
- [ ] オフライン時の動作確認

### CI/CD設定（推奨）
- [ ] GitHub ActionsまたはCodemagicの設定
- [ ] 自動ビルドとテストの設定
- [ ] Fastlaneの導入検討

## 📊 モニタリングと分析

### Firebase設定
- [ ] Firebase Crashlyticsの有効化
- [ ] Firebase Analyticsの設定
- [ ] Performance Monitoringの有効化

### その他の分析ツール（オプション）
- [ ] A/Bテストの準備
- [ ] ユーザーフィードバック収集機能

## 🚀 リリース手順

### 1. 最終確認
- [ ] すべてのTODOコメントの削除
- [ ] デバッグログの削除
- [ ] ハードコードされたテストデータの削除

### 2. ビルド作成
```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

### 3. 内部テスト
- [ ] 社内テスターでのベータテスト
- [ ] Google Play Internal Testing
- [ ] TestFlight でのベータテスト

### 4. 段階的リリース
- [ ] 限定的なユーザーへのリリース（5-10%）
- [ ] フィードバックの収集と修正
- [ ] 全ユーザーへの展開

## 📝 注意事項

1. **セキュリティ**: APIキーや証明書は絶対にGitリポジトリにコミットしない
2. **バックアップ**: キーストアファイルとパスワードは安全な場所に保管
3. **テスト**: 本番リリース前に必ず複数のデバイスでテスト
4. **法的要件**: プライバシーポリシーと利用規約は必須

## 🎯 推定スケジュール

- 緊急対応項目: 1-2日
- アセット作成: 2-3日
- テストとバグ修正: 3-5日
- ストア申請と承認: 1-2週間

合計: 約3-4週間でリリース可能

---

このチェックリストを順番に進めることで、安全で品質の高いアプリをリリースできます。不明な点があれば、各プラットフォームの公式ドキュメントを参照してください。