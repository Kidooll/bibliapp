import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../styles/styles.dart';

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}

class HighlightColorTween extends Tween<Color?> {
  HighlightColorTween({Color? begin, Color? end})
      : super(begin: begin, end: end);

  @override
  Color? lerp(double t) => Color.lerp(begin, end, t);
}

// Adicione esta função RPC no seu banco de dados Supabase:
/*
create or replace function get_highlights_for_verse(p_verse_id bigint, p_user_id uuid)
returns json as $$
  select json_agg(t) from (
    select * 
    from bookmarks 
    where 
      user_id = p_user_id 
      and bookmark_type = 'highlight'
      and verse_ids @> array[p_verse_id]::bigint[]
  ) t;
$$ language sql;
*/

class VerseActionsModal extends StatefulWidget {
  final int verseId;
  final String text;
  final String? highlightColor;
  final VoidCallback onRefresh;

  const VerseActionsModal({
    super.key,
    required this.verseId,
    required this.text,
    required this.highlightColor,
    required this.onRefresh,
  });

  @override
  State<VerseActionsModal> createState() => _VerseActionsModalState();
}

class _VerseActionsModalState extends State<VerseActionsModal>
    with TickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _currentHighlightColor;
  String? _lastSelectedColor;
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;
  
  // Cores disponíveis para destaque
  static const List<String> colors = [
    '#FFF9C4', // amarelo
    '#FFE0E0', // vermelho
    '#C8E6C9', // verde
    '#BBDEFB', // azul
    '#E1BEE7', // roxo
    '#F8BBD0', // rosa
  ];

  // Cache local para destaques
  static final Map<String, Map<String, dynamic>> _highlightCache = {};
  static bool _isCacheInitialized = false;
  
  // Chave para o cache do usuário atual
  String? get _cacheKey {
    final user = supabase.auth.currentUser;
    return user?.id;
  }
  final _colorTween = HighlightColorTween();

  @override
  void initState() {
    super.initState();
    _currentHighlightColor = widget.highlightColor;
    _lastSelectedColor = widget.highlightColor;

    _colorController = AnimationController(
      vsync: this,
      duration: Duration.zero, // Animação instantânea
      reverseDuration: Duration.zero,
    )..addStatusListener(_handleAnimationStatus);

    _updateColorTween();
    
    // Garante que a cor atual está atualizada com o cache
    _updateHighlightFromCache();
    
    // Inicializa o cache apenas se o widget estiver montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeCache().then((_) {
          if (mounted) {
            _updateHighlightFromCache();
          }
        });
      }
    });
  }
  
  void _updateHighlightFromCache() {
    if (_cacheKey == null) return;
    
    final cacheKey = '${_cacheKey}_${widget.verseId}';
    final cachedHighlight = _highlightCache[cacheKey];
    
    if (cachedHighlight != null && mounted) {
      setState(() {
        _currentHighlightColor = cachedHighlight['highlight_color'];
        _lastSelectedColor = _currentHighlightColor;
        _colorController.value = 1.0; // Garante que a animação está no estado final
      });
    }
  }
  
  Future<void> _initializeCache() async {
    if (_isCacheInitialized || _cacheKey == null) return;
    
    try {
      final response = await supabase
          .from('bookmarks')
          .select()
          .eq('user_id', _cacheKey!)
          .eq('bookmark_type', 'highlight');
          
      if (response != null) {
        final highlights = List<Map<String, dynamic>>.from(response);
        for (var highlight in highlights) {
          final verseIds = List<int>.from(highlight['verse_ids'] ?? []);
          for (var verseId in verseIds) {
            _highlightCache['${_cacheKey}_$verseId'] = Map<String, dynamic>.from(highlight);
          }
        }
        _isCacheInitialized = true;
      }
    } catch (e) {
      debugPrint('Erro ao inicializar cache: $e');
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) {
        setState(() {
          _lastSelectedColor = _currentHighlightColor;
        });
      }
    }
  }

  void _updateColorTween() {
    _colorTween
      ..begin = _getColorFromHex(_lastSelectedColor)
      ..end = _getColorFromHex(_currentHighlightColor);
    _colorAnimation = _colorTween.animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeOutQuad,
    ));
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  Color? _getColorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) {
        buffer.write('ff');
        buffer.write(hex.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing color: $e');
      return null;
    }
  }

  Future<void> _removeHighlight() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final scaffold = ScaffoldMessenger.of(context);

      // Anima a remoção
      await _animateColorTransition(null);

      // Busca o highlight existente para este versículo
      final response = await supabase.rpc('get_highlights_for_verse',
          params: {'p_verse_id': widget.verseId, 'p_user_id': user.id});

      final existingHighlights = (response as List?) ?? [];

      if (existingHighlights.isNotEmpty) {
        await supabase
            .from('bookmarks')
            .delete()
            .eq('id', (existingHighlights[0] as Map)['id'] as int);
      }

      // Atualiza o estado local
      if (mounted) {
        setState(() {
          _currentHighlightColor = null;
          _isLoading = false;
        });
      }

      // Atualiza a UI
      widget.onRefresh();

      // Mostra mensagem de sucesso
      if (mounted) {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Destaque removido'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao remover destaque'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _animateColorTransition(String? newColor) async {
    if (_lastSelectedColor == newColor) return;

    // Atualiza imediatamente sem animação
    _lastSelectedColor = _currentHighlightColor;
    _updateColorTween();
    _colorController.value = 1.0; // Define o valor final imediatamente
  }

  Future<void> _setHighlight(String hex) async {
    if (_isLoading) return;
    _isLoading = true;

    // Salva o estado anterior para possível rollback
    final previousColor = _currentHighlightColor;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final scaffold = ScaffoldMessenger.of(context);

      // Se clicou na mesma cor, remove o highlight
      if (hex == _currentHighlightColor) {
        await _removeHighlight();
        return;
      }

      // Atualiza a UI imediatamente
      if (mounted) {
        setState(() {
          _currentHighlightColor = hex;
          _lastSelectedColor = hex;
          _colorController.value = 1.0;
        });
      }

      // Executa operações de rede em segundo plano sem bloquear a UI
      _processHighlightUpdate(hex, user.id, scaffold).catchError((e) {
        // Se der erro, reverte a cor
        if (mounted) {
          setState(() {
            _currentHighlightColor = previousColor;
            _lastSelectedColor = previousColor;
            _colorController.value = 1.0;
          });
          _showError('Erro ao destacar versículo: $e');
        }
      });
    } catch (e) {
      // Em caso de erro, reverte para a cor anterior
      if (mounted) {
        setState(() {
          _currentHighlightColor = previousColor;
          _lastSelectedColor = previousColor;
          _colorController.value = 1.0;
        });
        _showError('Erro ao destacar versículo: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performDatabaseUpdate(
      String hex, String userId, dynamic existingHighlightId) async {
    try {
      // Se existe um highlight, atualiza. Senão, cria um novo.
      if (existingHighlightId != null) {
        await supabase
            .from('bookmarks')
            .update({
              'highlight_color': hex,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingHighlightId);
      } else {
        await supabase.from('bookmarks').insert({
          'user_id': userId,
          'verse_ids': [widget.verseId],
          'bookmark_type': 'highlight',
          'highlight_color': hex,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Erro ao atualizar banco de dados: $e');
      rethrow; // Propaga o erro para ser tratado pelo chamador
    }
  }

  Future<void> _processHighlightUpdate(
      String hex, String userId, ScaffoldMessengerState scaffold) async {
    if (_cacheKey == null) return;
      
    final cacheKey = '${_cacheKey}_${widget.verseId}';
    final now = DateTime.now().toIso8601String();
    
    try {
      // Verifica se já existe um highlight para este versículo
      final existingHighlight = _highlightCache[cacheKey];
      final existingHighlightId = existingHighlight?['id'] as int?;
      
      // Atualiza o cache local imediatamente para feedback visual
      if (mounted) {
        setState(() {
          _highlightCache[cacheKey] = {
            'id': existingHighlightId,
            'user_id': userId,
            'verse_ids': [widget.verseId],
            'bookmark_type': 'highlight',
            'highlight_color': hex,
            'created_at': existingHighlight?['created_at'] ?? now,
            'updated_at': now,
          };
        });
      }
      
      // Executa a operação no banco de dados em segundo plano
      await _performDatabaseUpdate(hex, userId, existingHighlightId);

      // Atualiza a UI
      if (mounted) {
        widget.onRefresh();
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Versículo destacado'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro ao processar destaque: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.text));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Texto copiado')),
      );
    }
  }

  void _shareVerse() {
    Share.share(widget.text);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildColorPalette() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((hex) {
        final isSelected = hex == _currentHighlightColor;
        final isAnimating =
            _colorController.status == AnimationStatus.forward &&
                _colorAnimation.status == AnimationStatus.forward &&
                _lastSelectedColor != _currentHighlightColor &&
                _lastSelectedColor == hex;

        return GestureDetector(
          onTap: () => _setHighlight(hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 36 : 34,
            height: isSelected ? 36 : 34,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 36 : 34,
                  height: isSelected ? 36 : 34,
                  decoration: BoxDecoration(
                    color: _colorAnimation.status == AnimationStatus.forward &&
                            _colorAnimation.value == _getColorFromHex(hex)
                        ? _colorAnimation.value
                        : _getColorFromHex(hex),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black38, width: 2)
                        : null,
                  ),
                ),
                if (isSelected || isAnimating)
                  const Icon(Icons.check, color: Colors.black87, size: 20),
                if (_isLoading && isAnimating)
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ações do Versículo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.copy,
            title: 'Copiar versículo',
            onTap: _copyToClipboard,
          ),
          _buildActionTile(
            icon: Icons.share,
            title: 'Compartilhar',
            onTap: _shareVerse,
          ),
          if (_currentHighlightColor != null)
            _buildActionTile(
              icon: Icons.highlight_off,
              title: 'Remover destaque',
              onTap: _removeHighlight,
            ),
          const Divider(),
          const Text('Cores de destaque:'),
          const SizedBox(height: 8),
          _buildColorPalette(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
