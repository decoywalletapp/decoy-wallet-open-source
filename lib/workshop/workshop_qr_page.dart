import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'workshop_claim_client.dart';

class WorkshopCameraDenied implements Exception {
  const WorkshopCameraDenied();
}

Future<String?> scanWorkshopQr() async {
  if (kIsWeb ||
      (defaultTargetPlatform != TargetPlatform.iOS &&
          defaultTargetPlatform != TargetPlatform.android)) {
    throw UnsupportedError('Native camera required');
  }
  if (!(await Permission.camera.request()).isGranted) {
    throw const WorkshopCameraDenied();
  }
  final value = await FlutterBarcodeScanner.scanBarcode(
      '#C62828', 'Cancel', true, ScanMode.QR);
  return value == '-1' || value.trim().isEmpty ? null : value;
}

enum _Stage { ready, scanning, claiming, granted, preview, error }

class WorkshopQrPage extends StatefulWidget {
  const WorkshopQrPage({
    super.key,
    required this.claim,
    this.scan = scanWorkshopQr,
    this.openSettings = openAppSettings,
  });

  final Future<WorkshopClaimReceipt> Function(String qr) claim;
  final Future<String?> Function() scan;
  final Future<bool> Function() openSettings;

  @override
  State<WorkshopQrPage> createState() => _WorkshopQrPageState();
}

class _WorkshopQrPageState extends State<WorkshopQrPage> {
  _Stage _stage = _Stage.ready;
  String? _retryQr;
  String? _error;
  bool _cameraDenied = false;

  bool get _busy => _stage == _Stage.scanning || _stage == _Stage.claiming;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scan();
    });
  }

  Future<void> _scan() async {
    if (_busy) return;
    setState(() {
      _stage = _Stage.scanning;
      _retryQr = null;
      _error = null;
      _cameraDenied = false;
    });
    try {
      final qr = await widget.scan();
      if (!mounted) return;
      if (qr == null || qr.trim().isEmpty) {
        setState(() => _stage = _Stage.ready);
      } else if (qr.trim() == workshopPreviewQr) {
        setState(() => _stage = _Stage.preview);
      } else {
        parseWorkshopQr(qr);
        await _claim(qr);
      }
    } on WorkshopCameraDenied {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.error;
        _cameraDenied = true;
        _error = 'Camera access is off.';
      });
    } on WorkshopClaimException catch (error) {
      _showClaimError(error);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.error;
        _error = 'The camera could not open.';
      });
    }
  }

  Future<void> _claim(String qr) async {
    if (_stage == _Stage.claiming) return;
    setState(() {
      _stage = _Stage.claiming;
      _retryQr = qr;
      _error = null;
    });
    try {
      await widget.claim(qr);
      if (!mounted) return;
      setState(() {
        _stage = _Stage.granted;
        _retryQr = null;
      });
    } on WorkshopClaimException catch (error) {
      _showClaimError(error);
    } catch (_) {
      _showClaimError(
          const WorkshopClaimException(WorkshopClaimFailure.unavailable));
    }
  }

  void _showClaimError(WorkshopClaimException exception) {
    if (!mounted) return;
    setState(() {
      _stage = _Stage.error;
      _error = switch (exception.failure) {
        WorkshopClaimFailure.invalidQr => 'This is not a valid workshop QR.',
        WorkshopClaimFailure.signedOut => 'Please sign in again.',
        WorkshopClaimFailure.closed => 'Workshop claims are closed.',
        WorkshopClaimFailure.rateLimited =>
          'Too many attempts. Try again later.',
        WorkshopClaimFailure.unavailable =>
          'Access could not be confirmed. Please retry.',
      };
      if (exception.failure != WorkshopClaimFailure.unavailable &&
          exception.failure != WorkshopClaimFailure.rateLimited) {
        _retryQr = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final success = _stage == _Stage.granted;
    final title = switch (_stage) {
      _Stage.ready => 'Workshop QR',
      _Stage.scanning => 'Camera open',
      _Stage.claiming => 'Confirming access',
      _Stage.granted => 'Workshop access activated',
      _Stage.preview => 'Test QR recognized',
      _Stage.error => _error!,
    };
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.info,
        foregroundColor: theme.primaryText,
        title: const Text('Workshop QR'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: _busy
                        ? Center(
                            child:
                                CircularProgressIndicator(color: theme.primary))
                        : Icon(
                            success
                                ? Icons.check_circle_outline
                                : Icons.qr_code_scanner_rounded,
                            size: 72,
                            color: theme.primary,
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText)),
                  if (success || _stage == _Stage.preview) ...[
                    const SizedBox(height: 12),
                    Text(
                      success
                          ? 'Your access is saved to your account.'
                          : 'Preview only. No account access has changed.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, color: theme.secondaryText),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (!_busy)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: theme.info,
                        minimumSize: const Size(250, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: success
                          ? () => Navigator.of(context).pop(true)
                          : _retryQr != null
                              ? () => _claim(_retryQr!)
                              : _scan,
                      icon: Icon(success
                          ? Icons.check
                          : _retryQr != null
                              ? Icons.refresh
                              : Icons.qr_code_scanner_rounded),
                      label: Text(success
                          ? 'Done'
                          : _retryQr != null
                              ? 'Retry'
                              : 'Scan QR'),
                    ),
                  if (_cameraDenied)
                    TextButton(
                      onPressed: () async {
                        await widget.openSettings();
                      },
                      child: const Text('Open Settings'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
