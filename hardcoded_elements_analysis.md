# アプリ内ハードコーディング要素分析

## 概要
現在のflash_composition_appにおいて、例文以外のハードコーディングされている要素を調査した結果をまとめます。これらの要素を動的に処理できるようにするための課題と改善案を提示します。

## 1. アプリケーション設定・メタデータ

### アプリケーション名・説明
- **main.dart:45** - アプリタイトル: `'瞬間英作文'`
- **pubspec.yaml:2** - アプリ説明: `"瞬間英作文アプリ - 英語学習を効率的にサポートする学習アプリ"`
- **pubspec.yaml:1** - パッケージ名: `flash_composition_app`

### Android設定
- **android/app/build.gradle.kts** - アプリケーションID: `"com.example.flash_composition_app"`
- **android/app/build.gradle.kts** - 名前空間: `"com.example.flash_composition_app"`

### バージョン情報
- **pubspec.yaml:19** - バージョン: `1.0.0+1`

## 2. テーマ・UI設定

### カラーテーマ
- **main.dart:47-80** - テーマカラー設定（全てBlue系で固定）
  - `seedColor: Colors.blue`
  - `backgroundColor: Colors.blue[600]`
  - `borderSide: BorderSide(color: Colors.blue[600]!)`

### アセットパス
- **pubspec.yaml:78-80** - アセットディレクトリ
  - `assets/images/`
  - `assets/fonts/`

## 3. ナビゲーション・ルーティング

### ルートパス（router.dart:31-51）
```dart
static const String splash = '/';
static const String login = '/login';
static const String profileSetup = '/profile-setup';
static const String profileStep1 = '/profile/step1';
static const String profileStep2 = '/profile/step2';
static const String profileStep3 = '/profile/step3';
static const String profileStep4 = '/profile/step4';
static const String profileStep5 = '/profile/step5';
static const String quickStart = '/profile/quick-start';
static const String loading = '/loading';
static const String home = '/home';
static const String category = '/category';
static const String exampleList = '/examples';
static const String study = '/study';
static const String favorites = '/favorites';
static const String profile = '/profile';
static const String profileEdit = '/profile/edit';
static const String dailyGoalSetting = '/settings/daily-goal';
static const String categoryManagement = '/category-management';
static const String error = '/error';
```

## 4. UI表示テキスト（日本語）

### スプラッシュ画面（splash_screen.dart）
- `'瞬間英作文'` - アプリタイトル
- `'Flash Composition'` - 英語タイトル
- `'アプリを起動しています...'` - ローディングメッセージ

### ホーム画面（home_screen.dart）
- `'瞬間英作文'` - アプリバータイトル
- `'メニュー'` - ツールチップ
- `'検索'` - ツールチップ
- `'エラーが発生しました'` - エラーメッセージ
- `'再試行'` - ボタンテキスト
- `'レベルを選択'` - セクションタイトル
- `'こんにちは、${user?.name ?? 'ゲスト'}さん！'` - 挨拶メッセージ
- `'あなたに合わせた例文で英作文を練習しましょう'` - 説明文
- `'パーソナライズされた学習体験'` - キャッチフレーズ
- `'進捗'` - ラベル
- `'${level.completedExamples}/${level.totalExamples}'` - 進捗表示
- `'${(level.progress * 100).toInt()}%'` - パーセンテージ表示
- `'${level.categories.length}カテゴリー'` - カテゴリー数表示
- `'🎯 総合力テスト'` - テスト名
- `'全レベルからランダム出題'` - 説明文

### ナビゲーション（main_layout.dart）
- `'ホーム'` - タブラベル
- `'学習'` - タブラベル
- `'お気に入り'` - タブラベル
- `'プロフィール'` - タブラベル

### ローディング画面（loading_screen.dart）
- `'あなた専用の例文を生成中'` - メインメッセージ
- `'プロフィール情報を基に\nパーソナライズされた例文を作成しています'` - 説明文
- `'${(_progressAnimation.value * 100).toInt()}%'` - 進捗表示
- プログレスメッセージ配列:
  - `'プロフィール情報を分析中...'`
  - `'例文パターンを選択中...'`
  - `'パーソナライズされた例文を生成中...'`
  - `'学習データを準備中...'`
- `'あなたの興味・関心に基づいて、より効果的な学習例文を作成しています'` - 説明文

### カテゴリー管理画面（category_management_screen.dart）
- `'カテゴリー管理'` - 画面タイトル
- `'ホームに戻る'` - ツールチップ
- `'カテゴリーを検索...'` - 検索ヒント
- `'レベル'` - フィルターラベル
- `'すべてのレベル'` - 選択肢
- `'完了状態'` - フィルターラベル
- `'すべて'` - 選択肢
- `'完了済み'` - 選択肢
- `'未完了'` - 選択肢
- `'最近学習したカテゴリー'` - セクションタイトル
- `'お気に入りのあるカテゴリー'` - セクションタイトル
- `'カテゴリー一覧 (${categories.length})'` - リストタイトル
- `'クリア'` - ボタンテキスト
- `'条件に一致するカテゴリーが見つかりませんでした'` - エラーメッセージ
- `'検索条件やフィルターを変更してみてください'` - 説明文

### プロフィール登録画面（register_profile_screen.dart）
長大な選択肢リストとラベル（年齢層、職業、英語レベル、趣味、業界、学習目標など）が全てハードコーディング

## 5. クエリパラメータ・URL生成

### 動的URL生成
- `context.go('${AppRouter.category}?levelId=${level.id}');`
- `context.go('${AppRouter.study}?allLevels=true');`
- `context.go('${AppRouter.exampleList}?categoryId=${category.id}');`

### クエリパラメータキー
- `'levelId'`
- `'categoryId'` 
- `'mixed'`
- `'allLevels'`
- `'index'`
- `'tab'`

## 6. 設定値・定数

### デフォルト値
- **router.dart:248** - デフォルトタブインデックス: `'study'`
- **main_layout.dart** - デフォルトレベルID: `'junior_high'`

### 進捗計算
- パーセンテージ計算: `(level.progress * 100).toInt()`
- 進捗表示フォーマット: `'${completed}/${total}'`

## 7. 問題となる箇所

### 国際化対応不備
- 全ての日本語テキストがハードコーディング
- 多言語対応が困難

### テーマ固定化
- カラーテーマが完全に固定
- ダークモード等の対応不可

### 設定の柔軟性不足
- アプリ名やメタデータの動的変更不可
- 選択肢の動的追加・削除不可

### URL構造の固定化
- ルートパスが全て固定
- 将来的なURL変更が困難

## 影響度評価

### 高影響度
1. **UI表示テキスト** - ユーザー体験に直結
2. **選択肢データ** - 機能拡張の阻害
3. **テーマ設定** - カスタマイズ性の欠如

### 中影響度
1. **ルーティング** - 保守性の問題
2. **アプリケーション設定** - ブランディング変更時の問題

### 低影響度
1. **アセットパス** - 変更頻度が低い
2. **バージョン情報** - 通常の開発プロセスで管理

---

# 動的化のためのTODOリスト

## フェーズ1: 基盤整備（高優先度）

### 1. 国際化対応の実装
- [ ] **flutter_localizations パッケージを追加**
  - pubspec.yaml に flutter_localizations を追加
  - MaterialApp に localizationsDelegates と supportedLocales を設定

- [ ] **多言語リソースファイルの作成**
  - `lib/l10n/` ディレクトリを作成
  - `app_ja.arb` (日本語) ファイルを作成
  - `app_en.arb` (英語) ファイルを作成
  - 現在ハードコーディングされている全ての日本語テキストを移行

- [ ] **AppLocalizations クラスの生成設定**
  - `l10n.yaml` 設定ファイルを作成
  - `flutter gen-l10n` コマンドでローカライゼーションクラスを生成

### 2. テーマシステムの動的化
- [ ] **カスタムテーマプロバイダーの作成**
  - `ThemeProvider` クラスを作成
  - ライト/ダークテーマの切り替え機能
  - カラーカスタマイズ機能

- [ ] **テーマ設定の永続化**
  - SharedPreferences でテーマ設定を保存
  - アプリ起動時にテーマ設定を復元

- [ ] **main.dart のテーマ設定を動的化**
  - ハードコーディングされたテーマ設定を ThemeProvider から取得するよう変更

### 3. 設定管理システムの構築
- [ ] **AppConfig クラスの作成**
  - アプリ名、説明、バージョン情報の管理
  - 環境別設定（開発、本番）の対応

- [ ] **設定ファイルの作成**
  - `assets/config/app_config.json` の作成
  - 環境変数からの設定読み込み機能

## フェーズ2: データ構造の動的化（中優先度）

### 4. 選択肢データの外部化
- [ ] **選択肢データのJSON化**
  - プロフィール設定の全選択肢を JSON ファイルに移行
  - `assets/data/profile_options.json` の作成

- [ ] **動的選択肢読み込み機能の実装**
  - JSON ファイルから選択肢を読み込むサービスクラス
  - 選択肢の動的追加・削除機能

- [ ] **レベル・カテゴリデータの外部化**
  - 現在 mock_data_service.dart にあるデータを JSON に移行
  - データ構造の正規化

### 5. ルーティング設定の動的化
- [ ] **ルート設定の外部化**
  - `assets/config/routes.json` の作成
  - 動的ルート生成機能の実装

- [ ] **URL構造のカスタマイズ機能**
  - 管理画面からのURL変更機能
  - SEO対応のためのURL構造最適化

## フェーズ3: 管理機能の実装（中優先度）

### 6. 管理画面の構築
- [ ] **設定管理画面の作成**
  - アプリ設定の変更機能
  - テーマカスタマイズ画面

- [ ] **コンテンツ管理画面の作成**
  - 選択肢データの管理機能
  - 例文テンプレートの管理機能

### 7. データ管理機能の強化
- [ ] **データエクスポート/インポート機能**
  - 設定データのバックアップ機能
  - 他環境への設定移行機能

- [ ] **バージョン管理機能**
  - 設定変更履歴の記録
  - ロールバック機能

## フェーズ4: 高度な機能（低優先度）

### 8. リモート設定対応
- [ ] **Firebase Remote Config の導入**
  - サーバーサイドからの設定配信
  - A/Bテスト機能

- [ ] **動的コンテンツ更新**
  - アプリ更新なしでのコンテンツ変更
  - リアルタイム設定反映

### 9. パフォーマンス最適化
- [ ] **設定キャッシュ機能**
  - 頻繁にアクセスされる設定のメモリキャッシュ
  - 非同期読み込み機能

- [ ] **遅延読み込み機能**
  - 必要時のみ設定を読み込む機能
  - アプリ起動時間の短縮

## 実装優先度

### 最優先（フェーズ1）
1. 国際化対応の実装
2. テーマシステムの動的化
3. 設定管理システムの構築

### 次優先（フェーズ2）
4. 選択肢データの外部化
5. ルーティング設定の動的化

### その後（フェーズ3-4）
6. 管理機能の実装
7. 高度な機能の追加

## 期待される効果

### 短期的効果
- 多言語対応によるユーザーベース拡大
- テーマカスタマイズによるユーザビリティ向上
- 設定変更の容易化

### 長期的効果
- 保守性の大幅改善
- 機能拡張の迅速化
- A/Bテスト等の高度な機能への対応

### 開発効率向上
- ハードコーディング箇所の削減
- 設定変更のためのコード変更不要
- テストケースの簡素化