# 瞬間英作文アプリ Flutter開発TODOリスト

## 概要
仕様書に基づいて瞬間英作文アプリのFlutter版を開発します。まずはダミーデータを使用して画面遷移を確認可能なプロトタイプを作成します。

## 開発タスク一覧

### Phase 1: プロジェクトセットアップ（優先度：高）

#### 1. Flutterプロジェクトの初期セットアップ
- [ ] `flutter create flash_composition`コマンドでプロジェクト作成
- [ ] プロジェクトの基本設定（アプリ名、パッケージ名等）

#### 2. 基本的なプロジェクト構造の作成
- [ ] `lib/`ディレクトリ構造の整理
  - [ ] `lib/screens/` - 画面用ディレクトリ
  - [ ] `lib/models/` - データモデル用ディレクトリ
  - [ ] `lib/services/` - サービス層用ディレクトリ
  - [ ] `lib/widgets/` - 共通ウィジェット用ディレクトリ
  - [ ] `lib/utils/` - ユーティリティ用ディレクトリ
- [ ] `assets/`ディレクトリの作成
  - [ ] `assets/images/` - 画像用
  - [ ] `assets/fonts/` - フォント用
- [ ] `test/`ディレクトリの構造整理

#### 3. 必要なパッケージの追加
- [ ] `pubspec.yaml`への依存関係追加
  - [ ] `go_router: ^14.0.0` - ルーティング
  - [ ] `provider: ^6.1.0` - 状態管理
  - [ ] `shared_preferences: ^2.2.0` - ローカルストレージ
  - [ ] `flutter_svg: ^2.0.0` - SVG表示用
- [ ] `flutter pub get`の実行

#### 4. ダミーデータモデルの作成
- [ ] `lib/models/user.dart` - ユーザーモデル
- [ ] `lib/models/profile.dart` - プロフィールモデル（4ステップ分の情報）
- [ ] `lib/models/level.dart` - レベルモデル（中学、高校1-3年）
- [ ] `lib/models/category.dart` - カテゴリーモデル（文法カテゴリー）
- [ ] `lib/models/example.dart` - 例文モデル（日本語・英語ペア）

#### 14. 画面遷移の実装（go_routerでのナビゲーション設定）
- [ ] `lib/router.dart`の作成
- [ ] ルート定義（全画面分）
- [ ] 認証状態による遷移制御

#### 15. ダミーデータサービスの作成
- [ ] `lib/services/mock_data_service.dart`の作成
- [ ] ダミーユーザーデータの生成
- [ ] ダミープロフィールデータの生成
- [ ] ダミー例文データの生成（各レベル・カテゴリー別）

### Phase 2: 画面実装（優先度：中）

#### 5. スプラッシュ画面の実装
- [ ] `lib/screens/splash_screen.dart`の作成
- [ ] アプリロゴの表示
- [ ] ローディングアニメーション
- [ ] 自動遷移ロジック（チュートリアル or トップ画面）

#### 6. 認証画面の実装
- [ ] `lib/screens/auth/register_screen.dart` - 会員登録画面
  - [ ] メールアドレス入力フィールド
  - [ ] パスワード入力フィールド
  - [ ] 登録ボタン
- [ ] `lib/screens/auth/login_screen.dart` - ログイン画面
  - [ ] メールアドレス入力フィールド
  - [ ] パスワード入力フィールド
  - [ ] ログインボタン
  - [ ] 会員登録画面への遷移リンク

#### 7. プロフィール設定画面の実装（Step 1-4）
- [ ] `lib/screens/profile/profile_step1_screen.dart` - 基本情報
  - [ ] 年齢層選択（ラジオボタン）
  - [ ] 職業カテゴリー選択（ドロップダウン）
  - [ ] 英語学習歴選択（ラジオボタン）
- [ ] `lib/screens/profile/profile_step2_screen.dart` - 興味・関心
  - [ ] 趣味・娯楽（チェックボックス、複数選択）
  - [ ] 仕事・業界（ラジオボタン）
  - [ ] ライフスタイル（チェックボックス、複数選択）
- [ ] `lib/screens/profile/profile_step3_screen.dart` - 学習環境・目標
  - [ ] 学習目標（ラジオボタン）
  - [ ] 学習時間帯（チェックボックス、複数選択）
  - [ ] 1日の目標学習時間（ラジオボタン）
  - [ ] 学習継続の課題（チェックボックス、複数選択）
- [ ] `lib/screens/profile/profile_step4_screen.dart` - 個人的背景
  - [ ] 居住地域（ドロップダウン、任意）
  - [ ] 家族構成（ラジオボタン、任意）
  - [ ] 英語使用場面（チェックボックス、複数選択）
  - [ ] 興味のあるトピック（テキスト入力、任意）
- [ ] ステップインジケーターウィジェットの作成

#### 8. 例文生成中画面の実装
- [ ] `lib/screens/loading_screen.dart`の作成
- [ ] プログレスバー表示
- [ ] 生成中メッセージ表示
- [ ] アニメーション実装

#### 9. トップ画面の実装（レベル選択）
- [ ] `lib/screens/home_screen.dart`の作成
- [ ] レベルカード表示（中学、高校1-3年）
- [ ] 各レベルの進捗表示
- [ ] 設定アイコン（右上）
- [ ] ユーザー情報表示

#### 10. カテゴリー選択画面の実装
- [ ] `lib/screens/category_screen.dart`の作成
- [ ] カテゴリーグリッド表示
- [ ] 各カテゴリーの例文数表示
- [ ] 完了状況アイコン表示

#### 11. 例文一覧画面の実装
- [ ] `lib/screens/example_list_screen.dart`の作成
- [ ] 例文リスト表示（10件）
- [ ] 番号表示
- [ ] 完了状況チェック表示

#### 12. 学習画面の実装（メイン機能）
- [ ] `lib/screens/study_screen.dart`の作成
- [ ] 日本語例文表示（大きなフォント）
- [ ] タップで英語表示切り替え
- [ ] 前へ/次へボタン
- [ ] 進捗表示（例：3/10）
- [ ] スワイプジェスチャー対応

### Phase 3: エラー処理（優先度：低）

#### 13. エラー画面の実装
- [ ] `lib/screens/error_screen.dart`の作成
- [ ] エラーメッセージ表示
- [ ] リトライボタン
- [ ] ホームへ戻るボタン

### Phase 4: 共通コンポーネント

#### 共通ウィジェットの作成
- [ ] `lib/widgets/custom_button.dart` - カスタムボタン
- [ ] `lib/widgets/custom_text_field.dart` - カスタムテキストフィールド
- [ ] `lib/widgets/loading_indicator.dart` - ローディングインジケーター
- [ ] `lib/widgets/progress_bar.dart` - プログレスバー

### Phase 5: テーマ・スタイリング

#### アプリテーマの設定
- [ ] `lib/theme/app_theme.dart`の作成
- [ ] カラーパレットの定義
- [ ] テキストスタイルの定義
- [ ] ボタンスタイルの定義

## ダミーデータ仕様

### ユーザーデータ
```dart
{
  "id": "user_001",
  "email": "test@example.com",
  "name": "テストユーザー"
}
```

### プロフィールデータ
```dart
{
  "userId": "user_001",
  "ageGroup": "20代社会人",
  "occupation": "会社員",
  "englishLevel": "初級（1-3年）",
  "hobbies": ["映画・ドラマ鑑賞", "料理・グルメ"],
  "industry": "IT・エンジニア",
  "lifestyle": ["健康・フィットネス"],
  "learningGoal": "仕事で英語を使いたい",
  "studyTime": ["夜（19-22時）"],
  "targetStudyMinutes": "10-20分",
  "challenges": ["時間がない", "モチベーション維持"]
}
```

### 例文データ
```dart
{
  "id": "example_001",
  "levelId": "junior_high",
  "categoryId": "be_verb",
  "japanese": "私は学生です。",
  "english": "I am a student.",
  "isCompleted": false
}
```

## 実装順序

1. プロジェクトセットアップ（タスク1-4, 14-15）
2. スプラッシュ画面 → 認証画面
3. プロフィール設定画面（Step 1-4）
4. 例文生成中画面
5. トップ画面 → カテゴリー選択画面
6. 例文一覧画面 → 学習画面
7. エラー画面
8. 画面遷移の接続・テスト

## 注意事項

- 全てダミーデータで動作確認できるようにする
- 実際のAPI通信やデータベース接続は行わない
- 画面遷移が正しく動作することを優先
- UIは基本的なMaterial Designで実装
- レスポンシブ対応は後回し（iPhone/Android標準サイズで確認）

## 完了条件

- [ ] 全13画面が実装されている
- [ ] 画面遷移が仕様書通りに動作する
- [ ] ダミーデータで全機能が確認できる
- [ ] エラーなくビルド・実行できる