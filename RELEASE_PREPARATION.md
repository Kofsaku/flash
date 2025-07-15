# Flash Composition App - リリース準備計画

## 現在の状況
- 基本機能は実装済み
- 158個のlint問題が存在
- テストファイルにエラーあり
- Mock データサービス使用中
- 開発環境に問題あり（Rosetta未インストール、Android SDK未設定）

## リリース準備作業一覧

### 🔴 最優先項目（Critical）

#### 1. 開発環境の修正
**現在の問題:**
- Rosettaが未インストール（ARM Mac用）
- Android SDKが未設定

**対応手順:**
```bash
# Rosettaのインストール
sudo softwareupdate --install-rosetta --agree-to-license

# Android Studioのインストールが必要
# https://developer.android.com/studio からダウンロード
# 初回起動時にAndroid SDKが自動的にインストールされる
```

#### 2. コード品質の改善（158個のlint問題）
**主な問題:**
- `avoid_print`: 本番環境でのprint文使用（147件）
- `deprecated_member_use`: 非推奨API使用（7件）
- `unused_import`: 未使用import（2件）
- その他の警告

**対応状況:** 🔄 対応中

#### 3. テストファイルの修正
**問題:** `MyApp`クラスが見つからない
**対応状況:** 🔄 対応中

#### 4. アプリメタデータの設定
**変更が必要な項目:**
- Bundle ID: `com.example.flash_composition_app` → 本番用ID
- アプリ名: より適切な表示名
- 説明文: pubspec.yamlの説明文更新 ✅ 完了

**対応手順:**
1. ✅ pubspec.yamlの説明文更新完了
2. 🔄 適切なBundle IDを決定（推奨: com.yourcompany.flashcomposition）
3. 🔄 Android: `android/app/build.gradle.kts`のapplicationId更新
4. 🔄 iOS: XcodeプロジェクトでBundle Identifier更新

**⚠️ 重要な注意点:**
Bundle IDの変更には以下が必要です：
- Apple Developer Accountでの新しいBundle IDの登録
- Google Play Consoleでの新しいPackage名の登録
- 変更後は別のアプリとして認識されるため、既存のデータは引き継がれません

**推奨Bundle ID案:**
- `com.flashcomposition.app`
- `com.englishlearning.flashcomposition`
- `com.yourcompany.flashcomposition`（実際の会社名/個人名に置き換え）

#### 5. 署名設定とリリースビルド設定
**Android:**
- Keystoreの作成
- `android/app/build.gradle.kts`でリリース署名設定
- ProGuard/R8設定

**iOS:**
- Apple Developer アカウント必要
- Provisioning Profile設定
- Code Signing設定

#### 6. プライバシーポリシーと利用規約
**必要な文書:**
- プライバシーポリシー
- 利用規約
- アプリ内への統合

#### 7. 本番用APIエンドポイント設定
**現在:** MockDataService使用
**必要な作業:**
- 本番APIサーバーの準備
- エンドポイント設定の環境分離
- API認証の実装

#### 8. セキュリティ監査
**チェック項目:**
- デバッグコードの削除
- APIキー等の秘匿情報確認
- 不要な権限の削除

#### 9. ストアアカウント設定
**Google Play Console:**
- デベロッパーアカウント登録（$25）
- アプリ情報入力
- ストアリスティング作成

**App Store Connect:**
- Apple Developer Program登録（年間$99）
- アプリ情報入力
- App Store用メタデータ作成

### 🟡 中優先項目（Medium）

#### 10. アプリアイコンとスプラッシュスクリーン
**必要なサイズ（Android）:**
- 48×48, 72×72, 96×96, 144×144, 192×192dp
- 適応型アイコン対応

**必要なサイズ（iOS）:**
- 20×20〜1024×1024（複数サイズ）

#### 11. ストア用スクリーンショット
**必要な画像:**
- Android: 携帯電話、7インチタブレット、10インチタブレット用
- iOS: iPhone、iPad用（複数画面サイズ）
- フィーチャーグラフィック（Android）

#### 12. パフォーマンステスト
- アプリ起動時間測定
- メモリ使用量確認
- バッテリー消費テスト

#### 13. テストの追加
- ユニットテスト拡充
- インテグレーションテスト追加
- UIテスト実装

### 🟢 低優先項目（Low）

#### 14. リリースビルドの作成
```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

#### 15. ストア申請
- Google Play: 審査通常1-3日
- App Store: 審査通常24-48時間

## 進捗状況
- [ ] 開発環境修正 ⚠️ **要対応: Rosetta・Android SDK設定が必要**
- [x] コード品質改善 ✅ **完了: 158→0個のlint問題を修正**
- [x] テストファイル修正 ✅ **完了: widget_testエラー解決**
- [x] アプリメタデータ設定 ✅ **完了: 説明文更新、Bundle ID要検討**
- [ ] 署名設定 ⚠️ **要対応: ストア公開に必須**
- [x] プライバシーポリシー作成 ✅ **完了: テンプレート作成済み**
- [ ] API設定 ⚠️ **要対応: Mock→本番API移行必要**
- [x] セキュリティ監査 ✅ **完了: デバッグコード・秘匿情報チェック済み**
- [ ] ストアアカウント設定 ⚠️ **要対応: Apple/Google開発者登録**
- [ ] アイコン・スプラッシュ作成 📋 **要対応: デザイン作成が必要**
- [ ] スクリーンショット準備 📋 **要対応: ストア用画像準備**
- [ ] パフォーマンステスト 📋 **要対応: 最適化確認**
- [ ] テスト追加 📋 **要対応: テストカバレッジ拡大**
- [ ] リリースビルド作成 📋 **要対応: 最終ビルド**
- [ ] ストア申請 📋 **要対応: 審査申請**

### 🎉 完了済み (6/15項目)
1. **コード品質の大幅改善**: 158個のlint問題 → 0個
2. **テスト修正**: アプリが正常に起動することを確認
3. **プライバシーポリシー・利用規約**: テンプレート作成済み
4. **セキュリティチェック**: デバッグコード削除、秘匿情報なし
5. **メタデータ更新**: アプリ説明文を本番用に更新
6. **リリース準備計画書**: 詳細な作業手順書作成

## 注意事項
1. Apple Developer Programの年間費用: $99
2. Google Play Console登録費用: $25（一回のみ）
3. プライバシーポリシーは法的要件のため必須
4. 各ストアの審査ガイドライン確認が必要