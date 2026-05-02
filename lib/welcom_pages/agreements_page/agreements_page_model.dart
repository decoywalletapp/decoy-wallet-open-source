import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'agreements_page_widget.dart' show AgreementsPageWidget;
import 'package:flutter/material.dart';

class AgreementsPageModel extends FlutterFlowModel<AgreementsPageWidget> {
  ///  Local state fields for this page.

  bool boxesSelected = false;

  int agreementPageIndex = 0;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? agreementsUpd;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
