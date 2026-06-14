import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../features/agreements/data/agreement_models.dart';
import '../../features/disputes/data/dispute_models.dart';
import '../../l10n/app_localizations.dart';

String formatLocalizedDate(BuildContext context, DateTime? value) {
  if (value == null) return contextL10n(context).notSpecified;
  return DateFormat('dd.MM.yyyy', contextL10n(context).localeName).format(value);
}

String formatLocalizedMoney(BuildContext context, int? amount) {
  if (amount == null) return contextL10n(context).notSpecified;
  final formatter = NumberFormat.decimalPattern(contextL10n(context).localeName);
  return '${formatter.format(amount)} KZT';
}

AppLocalizations contextL10n(BuildContext context) => AppLocalizations.of(context)!;

extension AgreementStatusL10nX on AgreementStatus {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      AgreementStatus.draft => l10n.agreementStatusDraft,
      AgreementStatus.waitingSecondParty => l10n.agreementStatusWaitingSecondParty,
      AgreementStatus.pendingConfirmation => l10n.agreementStatusPendingConfirmation,
      AgreementStatus.active => l10n.agreementStatusActive,
      AgreementStatus.cancelled => l10n.agreementStatusCancelled,
      AgreementStatus.completed => l10n.agreementStatusCompleted,
      AgreementStatus.rejected => l10n.agreementStatusRejected,
    };
  }
}

String agreementUtilitySplitLabelL10n(AppLocalizations l10n, String? value) {
  return switch ((value ?? '').toUpperCase()) {
    'EQUAL' => l10n.agreementUtilityEqual,
    'PERCENTAGE' => l10n.agreementUtilityPercentage,
    'CUSTOM' => l10n.agreementUtilityCustom,
    _ => l10n.notSpecified,
  };
}

extension DisputeStatusL10nX on DisputeStatus {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      DisputeStatus.open => l10n.disputeStatusOpen,
      DisputeStatus.inReview => l10n.disputeStatusInReview,
      DisputeStatus.resolved => l10n.disputeStatusResolved,
      DisputeStatus.rejected => l10n.disputeStatusRejected,
      DisputeStatus.closed => l10n.disputeStatusClosed,
    };
  }
}

extension DisputeDecisionL10nX on DisputeDecision {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      DisputeDecision.none => l10n.disputeDecisionNone,
      DisputeDecision.accepted => l10n.disputeDecisionAccepted,
      DisputeDecision.rejected => l10n.disputeDecisionRejected,
      DisputeDecision.needMoreInfo => l10n.disputeDecisionNeedMoreInfo,
    };
  }
}

extension DisputeActionL10nX on DisputeAction {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      DisputeAction.none => l10n.disputeActionNone,
      DisputeAction.warning => l10n.disputeActionWarning,
      DisputeAction.temporaryRestriction => l10n.disputeActionTemporaryRestriction,
      DisputeAction.accountBan => l10n.disputeActionAccountBan,
      DisputeAction.agreementCancelled => l10n.disputeActionAgreementCancelled,
      DisputeAction.paymentRequired => l10n.disputeActionPaymentRequired,
      DisputeAction.profileFlagged => l10n.disputeActionProfileFlagged,
    };
  }
}

extension DisputeReasonL10nX on DisputeReason {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      DisputeReason.paymentNotPaid => l10n.disputeReasonPaymentNotPaid,
      DisputeReason.agreementViolation => l10n.disputeReasonAgreementViolation,
      DisputeReason.propertyDamage => l10n.disputeReasonPropertyDamage,
      DisputeReason.fakeInformation => l10n.disputeReasonFakeInformation,
      DisputeReason.rudeBehavior => l10n.disputeReasonRudeBehavior,
      DisputeReason.safetyConcern => l10n.disputeReasonSafetyConcern,
      DisputeReason.other => l10n.disputeReasonOther,
    };
  }
}

extension DisputeDirectionL10nX on DisputeDirection {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      DisputeDirection.outgoing => l10n.disputeDirectionOutgoing,
      DisputeDirection.incoming => l10n.disputeDirectionIncoming,
    };
  }
}

String localizeDisputeDirectionTitle(
  BuildContext context,
  DisputeItem dispute,
) {
  final l10n = contextL10n(context);
  return dispute.directionLabel ??
      dispute.direction?.localizedLabel(l10n) ??
      l10n.disputeDirectionDefault;
}

String localizeDisputeCounterpartySubtitle(
  BuildContext context,
  DisputeItem dispute,
) {
  final l10n = contextL10n(context);
  final userName = dispute.counterparty?.displayName ?? l10n.userFallback;
  if (dispute.direction == DisputeDirection.incoming) {
    return l10n.disputeFromUser(userName);
  }
  return l10n.disputeAgainstUser(userName);
}

String? localizeDisputeSummary(
  BuildContext context,
  DisputeItem dispute,
) {
  final viewerText = (dispute.viewerResultText ?? '').trim();
  if (viewerText.isNotEmpty) return viewerText;

  final baseText = (dispute.resultText ?? '').trim();
  if (baseText.isNotEmpty) return baseText;

  final l10n = contextL10n(context);
  if (dispute.decision == DisputeDecision.rejected) {
    return l10n.disputeRejectedSummary;
  }
  if (dispute.decision == DisputeDecision.needMoreInfo) {
    return l10n.disputeNeedMoreInfo;
  }
  return null;
}
