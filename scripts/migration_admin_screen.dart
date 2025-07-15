import 'package:flutter/material.dart';
import '../../services/data_migration_script.dart';

/// データ移行を実行するための管理画面
/// 注意: 本番リリース前に必ずこのファイルを削除すること
class MigrationAdminScreen extends StatefulWidget {
  const MigrationAdminScreen({super.key});

  @override
  State<MigrationAdminScreen> createState() => _MigrationAdminScreenState();
}

class _MigrationAdminScreenState extends State<MigrationAdminScreen> {
  final DataMigrationScript _migrationScript = DataMigrationScript();
  final List<String> _logs = [];
  bool _isRunning = false;
  Map<String, dynamic>? _migrationStatus;

  @override
  void initState() {
    super.initState();
    _loadMigrationStatus();
  }

  void _loadMigrationStatus() async {
    final status = await _migrationScript.getMigrationStatus();
    setState(() {
      _migrationStatus = status;
    });
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $message');
    });
    
    // 自動スクロール
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 データ移行管理画面'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMigrationStatus,
            tooltip: '状況を更新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 警告バナー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red[100],
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ 管理者専用画面：本番リリース前に必ずこのファイルを削除してください',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 現在の状況
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildStatusCard(),
          ),
          
          // 操作ボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildActionButtons(),
          ),
          
          // ログ表示
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildLogArea(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 現在のFirestoreデータ状況',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_migrationStatus == null)
              const Center(child: CircularProgressIndicator())
            else if (_migrationStatus!.containsKey('error'))
              Text(
                'エラー: ${_migrationStatus!['error']}',
                style: TextStyle(color: Colors.red[600]),
              )
            else
              Column(
                children: [
                  _buildStatusRow('レベル数', _migrationStatus!['levels'], Icons.school),
                  _buildStatusRow('カテゴリー数', _migrationStatus!['categories'], Icons.category),
                  _buildStatusRow('例文数', _migrationStatus!['examples'], Icons.text_fields),
                  _buildStatusRow('設定', _migrationStatus!['settings'] ? '✅' : '❌', Icons.settings),
                  if (_migrationStatus!['lastMigration'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '最終更新: ${_migrationStatus!['lastMigration'].toDate().toString().substring(0, 19)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              color: value == 0 || value == '❌' ? Colors.red[600] : Colors.green[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isRunning ? null : _runMigration,
            icon: Icon(_isRunning ? Icons.hourglass_empty : Icons.upload),
            label: Text(_isRunning ? '移行実行中...' : '🚀 データ移行を実行'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isRunning ? null : _runOverwriteMigration,
                icon: const Icon(Icons.warning),
                label: const Text('上書き移行'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange[600],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isRunning ? null : _clearAllData,
                icon: const Icon(Icons.delete_forever),
                label: const Text('全削除'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logs.isEmpty ? null : _clearLogs,
            icon: const Icon(Icons.clear_all),
            label: const Text('ログをクリア'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogArea() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '📝 実行ログ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _logs.isEmpty
                  ? Center(
                      child: Text(
                        'ログがありません\n移行を実行するとここにログが表示されます',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          Color textColor = Colors.white;
                          
                          if (log.contains('❌') || log.contains('エラー')) {
                            textColor = Colors.red[300]!;
                          } else if (log.contains('✅') || log.contains('完了')) {
                            textColor = Colors.green[300]!;
                          } else if (log.contains('⚠️') || log.contains('警告')) {
                            textColor = Colors.orange[300]!;
                          } else if (log.contains('🚀') || log.contains('開始')) {
                            textColor = Colors.blue[300]!;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Text(
                              log,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _runMigration() async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
      _logs.clear();
    });

    _addLog('📋 通常の移行を開始します（既存データは保持）');
    
    final success = await _migrationScript.runFullMigration(
      overwriteExisting: false,
      onProgress: _addLog,
    );

    setState(() {
      _isRunning = false;
    });

    if (success) {
      _addLog('🎉 移行が正常に完了しました！');
      _loadMigrationStatus();
    } else {
      _addLog('💥 移行に失敗しました。ログを確認してください。');
    }
  }

  void _runOverwriteMigration() async {
    if (_isRunning) return;

    // 確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 上書き移行の確認'),
        content: const Text(
          '既存のFirestoreデータを上書きします。\n'
          'この操作は元に戻せません。\n'
          '続行しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('上書き実行'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRunning = true;
      _logs.clear();
    });

    _addLog('⚠️ 上書き移行を開始します（既存データを上書き）');
    
    final success = await _migrationScript.runFullMigration(
      overwriteExisting: true,
      onProgress: _addLog,
    );

    setState(() {
      _isRunning = false;
    });

    if (success) {
      _addLog('🎉 上書き移行が正常に完了しました！');
      _loadMigrationStatus();
    } else {
      _addLog('💥 上書き移行に失敗しました。ログを確認してください。');
    }
  }

  void _clearAllData() async {
    if (_isRunning) return;

    // 確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 全データ削除の確認'),
        content: const Text(
          'Firestoreの全データを削除します。\n'
          'この操作は元に戻せません。\n'
          '本当に実行しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除実行'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRunning = true;
      _logs.clear();
    });

    try {
      _addLog('🗑️ 全データ削除を開始します');
      await _migrationScript.clearAllData();
      _addLog('✅ 全データ削除が完了しました');
      _loadMigrationStatus();
    } catch (e) {
      _addLog('❌ 削除エラー: $e');
    }

    setState(() {
      _isRunning = false;
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}