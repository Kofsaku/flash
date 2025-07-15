# Flash Composition App - データ移行実行手順

## 🎯 このガイドについて

このガイドは、作業者がFlash Composition Appの既存データをFirestoreに移行する際の実際の手順を説明します。

## ⚠️ 事前準備

### 1. バックアップの作成
```bash
# 現在のプロジェクトをバックアップ
cp -r /Users/kt/flash_composition/flash_composition_app /Users/kt/flash_composition/flash_composition_app_backup

# Gitでコミット
cd /Users/kt/flash_composition/flash_composition_app
git add .
git commit -m "データ移行前のバックアップ"
```

### 2. Firebase環境の確認
- Firebase Console でプロジェクトが作成済みであること
- Authentication（Email/Password）が有効であること
- Firestore Database が作成済みであること
- セキュリティルールが設定済みであること

## 🚀 実行手順

### Step 1: 移行用画面の追加

1. **一時的にルートに移行画面を追加**

`lib/router.dart` に以下を追加：

```dart
import 'screens/admin/migration_admin_screen.dart';

// routes配列に追加
GoRoute(
  path: '/admin/migration',
  name: 'migration',
  builder: (context, state) => const MigrationAdminScreen(),
),
```

2. **アプリを起動して移行画面にアクセス**

```bash
cd /Users/kt/flash_composition/flash_composition_app
flutter run
```

アプリが起動したら、ブラウザまたはアプリ内で `/admin/migration` にアクセス

### Step 2: データ移行の実行

1. **移行画面で現在の状況を確認**
   - レベル数: 0 → 移行が必要
   - カテゴリー数: 0 → 移行が必要
   - 例文数: 0 → 移行が必要
   - 設定: ❌ → 移行が必要

2. **「🚀 データ移行を実行」ボタンをクリック**
   
   以下のような進行が表示されます：
   ```
   🚀 データ移行を開始します...
   📚 既存データを読み込み中...
   📖 学習コンテンツを移行中...
   📚 レベル "中学レベル" を移行中... (1/1)
     📁 カテゴリー "be動詞" を移行中... (1/2)
       ✅ カテゴリー "be動詞" の全例文移行完了 (10件)
     📁 カテゴリー "一般動詞" を移行中... (2/2)
       ✅ カテゴリー "一般動詞" の全例文移行完了 (10件)
   ⚙️ アプリ設定を移行中...
   ✅ アプリ設定の移行完了
   ✅ データ整合性を確認中...
   📊 データ統計:
     - レベル: 1/1
     - カテゴリー: 2/2
     - 例文: 20/20
   ✅ データ整合性チェック完了 - すべて正常です
   🎉 データ移行が完了しました！
   ```

3. **移行結果の確認**
   - 「📊 現在のFirestoreデータ状況」セクションで数値が更新される
   - Firebase Console のFirestore Database でデータを目視確認

### Step 3: Firebase Console での確認

1. **Firebase Console にアクセス**
   - https://console.firebase.google.com/
   - プロジェクト選択 → Firestore Database

2. **データ構造の確認**
   ```
   📁 levels
   └── 📄 junior_high
       ├── 📁 categories
       │   ├── 📄 be_verb
       │   │   └── 📁 examples
       │   │       ├── 📄 be_001
       │   │       ├── 📄 be_002
       │   │       └── ...
       │   └── 📄 general_verb
       │       └── 📁 examples
       │           ├── 📄 general_001
       │           └── ...
   
   📁 app_content
   └── 📄 settings
   ```

3. **レコード数の確認**
   - levels: 1件
   - categories: 2件（be_verb, general_verb）
   - examples: 約20件（レベルに応じて）
   - app_content/settings: 1件

### Step 4: アプリでの動作確認

1. **認証のテスト**
   ```
   新規登録 → プロフィール設定 → ホーム画面表示
   ```

2. **学習機能のテスト**
   ```
   ホーム → レベル選択 → カテゴリー選択 → 例文一覧 → 学習実行
   ```

3. **データ永続化のテスト**
   ```
   例文完了 → アプリ再起動 → 進捗が保持されているか確認
   ```

### Step 5: 移行画面の削除

**重要: 本番リリース前に必ず実行**

1. **移行関連ファイルの削除**
   ```bash
   # 移行画面ファイルの削除
   rm lib/screens/admin/migration_admin_screen.dart
   rm lib/services/data_migration_script.dart
   
   # adminディレクトリが空になった場合は削除
   rmdir lib/screens/admin
   ```

2. **ルーターから移行画面の削除**
   
   `lib/router.dart` から以下を削除：
   ```dart
   import 'screens/admin/migration_admin_screen.dart'; // この行を削除
   
   // routes配列から以下を削除
   GoRoute(
     path: '/admin/migration',
     name: 'migration',
     builder: (context, state) => const MigrationAdminScreen(),
   ),
   ```

3. **動作確認**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 🔍 トラブルシューティング

### よくある問題

#### 1. 「permission-denied」エラー
**原因**: Firestoreセキュリティルールが正しく設定されていない
**解決**: Firebase Console → Firestore → ルール で以下を確認
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### 2. 移行中にタイムアウト
**原因**: データサイズが大きすぎる
**解決**: バッチサイズを小さくする（`data_migration_script.dart` の `batchSize` を250に変更）

#### 3. データ不整合エラー
**原因**: 既存のFirestoreデータが破損している
**解決**: 「全削除」ボタンで一度クリアしてから再実行

#### 4. アプリが起動しない
**原因**: Firebase設定が不完全
**解決**: 
```bash
# Firebase設定を再実行
flutter pub add firebase_core firebase_auth cloud_firestore
flutterfire configure
```

### 緊急時の復旧手順

#### 移行に失敗した場合
1. **バックアップからの復元**
   ```bash
   # 元のファイルを復元
   rm -rf /Users/kt/flash_composition/flash_composition_app
   cp -r /Users/kt/flash_composition/flash_composition_app_backup /Users/kt/flash_composition/flash_composition_app
   ```

2. **Firestoreデータの削除**
   - 移行画面の「全削除」ボタンを使用
   - または Firebase Console で手動削除

#### Firestore接続ができない場合
1. **MockDataServiceに一時復帰**
   ```dart
   // AppProviderで一時的にMockDataServiceを使用
   // FirestoreServiceの呼び出しをコメントアウト
   ```

## 📊 移行完了チェックリスト

移行が正常に完了したことを確認するためのチェックリスト：

### ✅ データ移行
- [ ] レベルデータが移行されている（1件以上）
- [ ] カテゴリーデータが移行されている（2件以上）
- [ ] 例文データが移行されている（20件以上）
- [ ] アプリ設定が移行されている（1件）

### ✅ 機能テスト
- [ ] 新規登録ができる
- [ ] ログインができる
- [ ] プロフィール設定ができる
- [ ] レベル選択ができる
- [ ] カテゴリー選択ができる
- [ ] 例文学習ができる
- [ ] 進捗が保存される
- [ ] お気に入り機能が動作する

### ✅ セキュリティ
- [ ] 未認証ユーザーがデータにアクセスできない
- [ ] 他のユーザーのデータにアクセスできない
- [ ] セキュリティルールが適切に設定されている

### ✅ パフォーマンス
- [ ] 初期ローディングが3秒以内
- [ ] 画面遷移が1秒以内
- [ ] オフライン時も基本機能が動作する

### ✅ クリーンアップ
- [ ] 移行用ファイルが削除されている
- [ ] 移行用ルートが削除されている
- [ ] 不要なデバッグコードが削除されている

## 📈 移行後の監視項目

移行完了後、以下の項目を継続的に監視：

1. **Firebase Console での確認項目**
   - Authentication: 新規登録数、エラー率
   - Firestore: 読み書き回数、レスポンス時間
   - Performance: アプリ起動時間、クラッシュ率

2. **コスト監視**
   - 月次使用量の確認
   - 予算アラートの設定

3. **ユーザーフィードバック**
   - ローディング時間の苦情
   - データ同期の問題
   - 機能不具合の報告

移行作業が完了したら、本番運用に向けたモニタリング体制の構築を行ってください。