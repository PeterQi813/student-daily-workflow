import {
  CardDef,
  Component,
  FieldDef,
  contains,
  containsMany,
  linksTo,
  field,
} from 'https://cardstack.com/base/card-api';
import StringField from 'https://cardstack.com/base/string';
import NumberField from 'https://cardstack.com/base/number';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { concat, get } from '@ember/helper';
import { eq } from '@cardstack/boxel-ui/helpers';
// Conversation-driven student day workflow with predicate engine

// ── Education Tone Colors ──
// teacher: #2a9d8f (teal)   aide: #7c5fc4 (purple)   therapist: #c08b30 (amber)
// ai: #0aad82 (green)       system: gray italic

// ── Predicate Engine ──
// Schedule blocks auto-complete when predicates match against messages/attachments

function normalizeText(value: unknown): string {
  return String(value ?? '').trim().toLowerCase();
}

function hasText(value: unknown): boolean {
  if (Array.isArray(value)) {
    return value.length > 0;
  }
  return normalizeText(value).length > 0;
}

function matchesText(actual: unknown, expected: unknown): boolean {
  return normalizeText(actual) === normalizeText(expected);
}

function includesText(actual: unknown, expected: unknown): boolean {
  return normalizeText(actual).includes(normalizeText(expected));
}

function compareFieldValue(
  actual: unknown,
  comparator: string,
  expected: unknown,
): boolean {
  if (comparator === 'equals') {
    return matchesText(actual, expected);
  }
  if (comparator === 'contains') {
    return includesText(actual, expected);
  }
  return hasText(actual);
}

// ── Predicate Condition ──

export class PredicateConditionField extends FieldDef {
  static displayName = 'Predicate Condition';
  @field subject = contains(StringField);
  @field attachmentType = contains(StringField);
  @field author = contains(StringField);
  @field tone = contains(StringField);
  @field textContains = contains(StringField);
  @field fieldName = contains(StringField);
  @field comparator = contains(StringField);
  @field value = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    get summary() {
      let parts: string[] = [];
      let m = this.args.model;
      if (hasText(m.textContains)) parts.push(`text includes "${m.textContains}"`);
      if (hasText(m.attachmentType)) parts.push(`type is ${m.attachmentType}`);
      if (hasText(m.fieldName)) parts.push(`${m.fieldName} ${m.comparator ?? 'present'}`);
      let subject = m.subject ?? 'message';
      return parts.length ? `${subject}: ${parts.join(' & ')}` : subject;
    }

    <template>
      <span class='cond-pill'>{{this.summary}}</span>
      <style scoped>
        .cond-pill { font-size: 11px; color: #475569; padding: 2px 8px; background: #f1f5f9; border-radius: 6px; }
      </style>
    </template>
  };
}

// ── Predicate ──

export class PredicateField extends FieldDef {
  static displayName = 'Predicate';
  @field group = contains(StringField);
  @field conditions = containsMany(PredicateConditionField);

  static embedded = class Embedded extends Component<typeof this> {
    get groupLabel() {
      return (this.args.model.group ?? 'all') === 'any' ? 'Any' : 'All';
    }

    get count() {
      return this.args.model.conditions?.length ?? 0;
    }

    <template>
      <span class='pred-badge'>{{this.groupLabel}} of {{this.count}}</span>
      <style scoped>
        .pred-badge { font-size: 10px; font-weight: 700; color: #155e75; background: #ecfeff; padding: 2px 8px; border-radius: 999px; }
      </style>
    </template>
  };
}

// ── Participant ──

export class ParticipantField extends FieldDef {
  static displayName = 'Participant';
  @field initials = contains(StringField);
  @field name = contains(StringField);
  @field role = contains(StringField);
  @field tone = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    <template>
      <div class='p-inline'>
        <span class={{concat 'p-av ' @model.tone}}>{{@model.initials}}</span>
        <span>{{@model.name}}</span>
      </div>
      <style scoped>
        .p-inline { display: flex; align-items: center; gap: 6px; font-size: 13px; }
        .p-av { width: 22px; height: 22px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 8px; font-weight: 800; color: #fff; background: #6b7280; }
        .p-av.teacher { background: #2a9d8f; color: #fff; }
        .p-av.aide { background: #7c5fc4; color: #fff; }
        .p-av.therapist { background: #c08b30; color: #fff; }
        .p-av.ai { background: #0aad82; color: #fff; }
        .p-av.system { background: #94a3b8; color: #fff; }
      </style>
    </template>
  };
}

// ── Attachment ──

export class AttachmentField extends FieldDef {
  static displayName = 'Attachment';
  @field attachmentType = contains(StringField);
  @field typeLabel = contains(StringField);
  @field status = contains(StringField);
  @field ctaLabel = contains(StringField);
  @field messageRef = contains(StringField);
  @field linkedCard = linksTo(CardDef);

  static embedded = class Embedded extends Component<typeof this> {
    <template>
      <div class='att-card'>
        <@fields.linkedCard @format="embedded" />
        {{#if @model.ctaLabel}}
          <button type='button' class='att-cta'>{{@model.ctaLabel}}</button>
        {{/if}}
      </div>
      <style scoped>
        .att-card { border: 1px solid #e4e7ed; border-radius: 8px; overflow: hidden; max-width: 380px; }
        .att-cta { width: 100%; border: none; border-top: 1px solid #e4e7ed; background: #f7f8fa; color: #0aad82; font-size: 12px; font-weight: 700; padding: 8px; cursor: pointer; transition: background 0.15s; }
        .att-cta:hover { background: #0aad82; color: #fff; }
      </style>
    </template>
  };
}

// ── Message ──

export class MessageField extends FieldDef {
  static displayName = 'Message';
  @field initials = contains(StringField);
  @field author = contains(StringField);
  @field sentAt = contains(StringField);
  @field text = contains(StringField);
  @field tone = contains(StringField);
  @field isBot = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    <template>
      <div class='m-inline'>
        <span class={{concat 'm-av ' @model.tone}}>{{@model.initials}}</span>
        <div class='m-copy'>
          <strong>{{@model.author}}</strong>
          <span>{{@model.text}}</span>
        </div>
      </div>
    </template>
  };
}

// ── Step ──

export class StepField extends FieldDef {
  static displayName = 'Step';
  @field label = contains(StringField);
  @field status = contains(StringField);
  @field weight = contains(NumberField);
  @field predicate = contains(PredicateField);

  static embedded = class Embedded extends Component<typeof this> {
    <template>
      <div class={{concat 'step-inline ' @model.status}}>
        {{@model.label}}
      </div>
    </template>
  };
}

// ── Predicate Evaluation Engine ──

interface MessageFact {
  index: number;
  author: string;
  tone: string;
  text: string;
  isBot: boolean;
}

interface AttachmentFact {
  index: number;
  attachmentType: string;
  typeLabel: string;
  status: string;
  messageIndex: number;
  author: string;
  tone: string;
  text: string;
  linkedCard: CardDef | null;
}

interface ResolvedStepView {
  label: string;
  status: string;
  weight: number;
  completed: boolean;
}

interface WorkflowResolution {
  progressPercent: number;
  steps: ResolvedStepView[];
  completedWeight: number;
  totalWeight: number;
}

interface MessageView {
  id: string;
  initials: string;
  author: string;
  sentAt: string;
  text: string;
  tone: string;
  isOwn: boolean;
  isBot: boolean;
  attachmentIndices: number[];
}

function visibleMessageCount(
  model: StudentDayWorkflow,
  limit?: number,
): number {
  let total = model.messages?.length ?? 0;
  if (limit == null || limit < 0) return total;
  return Math.max(0, Math.min(limit, total));
}

function attachmentMessageIndex(attachment: AttachmentField): number | null {
  let parsed = Number.parseInt(attachment.messageRef ?? '', 10);
  return Number.isNaN(parsed) ? null : parsed;
}

function buildMessageFacts(
  model: StudentDayWorkflow,
  limit?: number,
): MessageFact[] {
  let count = visibleMessageCount(model, limit);
  return (model.messages ?? []).slice(0, count).map((message, index) => ({
    index,
    author: message.author ?? '',
    tone: message.tone ?? '',
    text: message.text ?? '',
    isBot: (message.isBot ?? '') === 'true',
  }));
}

function buildAttachmentFacts(
  model: StudentDayWorkflow,
  limit?: number,
): AttachmentFact[] {
  let count = visibleMessageCount(model, limit);
  let messages = model.messages ?? [];
  let facts: AttachmentFact[] = [];

  (model.attachments ?? []).forEach((attachment, index) => {
    let messageIndex = attachmentMessageIndex(attachment);
    if (messageIndex == null || messageIndex < 0 || messageIndex >= count) return;

    let sourceMessage = messages[messageIndex];
    facts.push({
      index,
      attachmentType: attachment.attachmentType ?? '',
      typeLabel: attachment.typeLabel ?? '',
      status: attachment.status ?? '',
      messageIndex,
      author: sourceMessage?.author ?? '',
      tone: sourceMessage?.tone ?? '',
      text: sourceMessage?.text ?? '',
      linkedCard: (attachment as any).linkedCard ?? null,
    });
  });

  return facts;
}

function conditionMatchesMessage(
  condition: PredicateConditionField,
  message: MessageFact,
): boolean {
  if (hasText(condition.author) && !matchesText(message.author, condition.author)) return false;
  if (hasText(condition.tone) && !matchesText(message.tone, condition.tone)) return false;
  if (hasText(condition.textContains) && !includesText(message.text, condition.textContains)) return false;
  return true;
}

function conditionMatchesAttachment(
  condition: PredicateConditionField,
  attachment: AttachmentFact,
): boolean {
  if (hasText(condition.attachmentType) && !matchesText(attachment.attachmentType, condition.attachmentType)) return false;
  if (hasText(condition.author) && !matchesText(attachment.author, condition.author)) return false;
  if (hasText(condition.tone) && !matchesText(attachment.tone, condition.tone)) return false;
  if (hasText(condition.textContains) && !includesText(attachment.text, condition.textContains)) return false;
  return true;
}

function conditionMatchesLinkedCard(
  condition: PredicateConditionField,
  attachment: AttachmentFact,
): boolean {
  if (!attachment.linkedCard) return false;
  if (!conditionMatchesAttachment(condition, attachment)) return false;
  if (!hasText(condition.fieldName)) return true;

  let comparator = condition.comparator ?? 'present';
  let actual = (attachment.linkedCard as any)[condition.fieldName ?? ''];
  return compareFieldValue(actual, comparator, condition.value);
}

function evaluatePredicate(
  predicate: PredicateField | null | undefined,
  messageFacts: MessageFact[],
  attachmentFacts: AttachmentFact[],
): boolean {
  let conditions = predicate?.conditions ?? [];
  if (!conditions.length) return false;

  let group = predicate?.group ?? 'all';
  let results = conditions.map((condition) => {
    let subject = condition.subject ?? 'message';
    if (subject === 'attachment') {
      return attachmentFacts.some((att) => conditionMatchesAttachment(condition, att));
    }
    if (subject === 'linked-card') {
      return attachmentFacts.some((att) => conditionMatchesLinkedCard(condition, att));
    }
    return messageFacts.some((msg) => conditionMatchesMessage(condition, msg));
  });

  return group === 'any' ? results.some(Boolean) : results.every(Boolean);
}

function resolveWorkflowState(
  model: StudentDayWorkflow,
  limit?: number,
  extraMessageFacts?: MessageFact[],
): WorkflowResolution {
  let messageFacts = buildMessageFacts(model, limit);
  if (extraMessageFacts?.length) {
    messageFacts = [...messageFacts, ...extraMessageFacts];
  }
  let attachmentFacts = buildAttachmentFacts(model, limit);
  let steps = model.steps ?? [];
  let resolvedSteps: ResolvedStepView[] = [];
  let totalWeight = 0;
  let completedWeight = 0;

  steps.forEach((step) => {
    let weight = step.weight && step.weight > 0 ? step.weight : 1;
    let completed =
      step.predicate?.conditions?.length
        ? evaluatePredicate(step.predicate, messageFacts, attachmentFacts)
        : (step.status ?? '') === 'completed';

    totalWeight += weight;
    if (completed) completedWeight += weight;

    resolvedSteps.push({
      label: step.label ?? 'Untitled step',
      status: 'upcoming',
      weight,
      completed,
    });
  });

  let currentAssigned = false;
  resolvedSteps = resolvedSteps.map((step) => {
    if (step.completed) return { ...step, status: 'completed' };
    if (!currentAssigned) {
      currentAssigned = true;
      return { ...step, status: 'current' };
    }
    return { ...step, status: 'upcoming' };
  });

  return {
    progressPercent:
      totalWeight > 0
        ? Math.round((completedWeight / totalWeight) * 100)
        : (model.progressPercent ?? 0),
    steps: resolvedSteps,
    completedWeight,
    totalWeight,
  };
}

// ── Main StudentDayWorkflow Card ──

export class StudentDayWorkflow extends CardDef {
  static displayName = 'Student Day Workflow';
  static prefersWideFormat = true;

  @field student = linksTo(CardDef);
  @field studentName = contains(StringField);
  @field studentInitials = contains(StringField);
  @field dateLabel = contains(StringField);
  @field gradeLabel = contains(StringField);
  @field category = contains(StringField);
  @field categoryTone = contains(StringField);
  @field title = contains(StringField);
  @field preview = contains(StringField);
  @field progressPercent = contains(NumberField);
  @field progressTone = contains(StringField);
  @field unreadCount = contains(NumberField);
  @field composerPlaceholder = contains(StringField);
  @field participants = containsMany(ParticipantField);
  @field messages = containsMany(MessageField);
  @field steps = containsMany(StepField);
  @field attachments = containsMany(AttachmentField);
  @field cardTitle = contains(StringField, {
    computeVia: function (this: StudentDayWorkflow) {
      return this.title ?? this.studentName ?? 'Student Workflow';
    },
  });

  // ── Isolated: Conversation + Sidebar ──

  static isolated = class Isolated extends Component<typeof StudentDayWorkflow> {
    @tracked draftMessage = '';
    @tracked localMessages: MessageView[] = [];
    @tracked _messagesVersion = 0;
    @tracked isAtBottom = true;
    @tracked isReplaying = false;
    @tracked replayVisibleCount = -1;
    @tracked showTyping = false;
    @tracked typingAuthor = '';
    @tracked typingInitials = '';
    @tracked typingTone = '';
    _streamEl: HTMLElement | null = null;
    _replayTimer: ReturnType<typeof setTimeout> | null = null;
    _aiTimer: ReturnType<typeof setTimeout> | null = null;
    _streamId = `stream-${Math.random().toString(36).slice(2, 8)}`;
    _scrollInitTimer = setTimeout(() => {
      let el = document.getElementById(this._streamId);
      if (el) {
        this._streamEl = el;
        el.scrollTop = el.scrollHeight;
      }
    }, 300);

    willDestroy() {
      super.willDestroy();
      if (this._replayTimer) clearTimeout(this._replayTimer);
      if (this._aiTimer) clearTimeout(this._aiTimer);
      if (this._scrollInitTimer) clearTimeout(this._scrollInitTimer);
    }

    preventCardOpen = (event: Event) => {
      event.stopPropagation();
    };

    handleStreamScroll = (event: Event) => {
      let el = event.currentTarget as HTMLElement;
      this._streamEl = el;
      if (!this.isReplaying) {
        let threshold = 60;
        this.isAtBottom = el.scrollTop + el.clientHeight >= el.scrollHeight - threshold;
      }
    };

    scrollToBottom = () => {
      requestAnimationFrame(() => {
        let el = this._streamEl;
        if (el) el.scrollTop = el.scrollHeight;
      });
    };

    // ── Replay ──

    startReplay = (event: Event) => {
      event.preventDefault();
      event.stopPropagation();
      if (this.isReplaying) {
        this.stopReplay();
        return;
      }
      this.localMessages = [];
      this.isReplaying = true;
      this.replayVisibleCount = 0;
      this.isAtBottom = true;
      this.showTyping = false;
      this.scrollToBottom();
      this.scheduleNextReplayMessage();
    };

    scheduleNextReplayMessage = () => {
      let messages = this.args.model.messages ?? [];
      let total = messages.length;
      if (this.replayVisibleCount >= total) {
        this.showTyping = false;
        this.isReplaying = false;
        this.replayVisibleCount = -1;
        return;
      }

      let nextMsg = messages[this.replayVisibleCount];
      let isBot = (nextMsg?.isBot ?? '') === 'true';
      let textLen = (nextMsg?.text ?? '').length;
      let tone = nextMsg?.tone ?? 'system';
      let author = nextMsg?.author ?? 'System';
      let initials = nextMsg?.initials ?? '';

      if (isBot) {
        let delay = 300 + Math.random() * 500;
        this._replayTimer = setTimeout(() => {
          this.showTyping = false;
          this.replayVisibleCount = this.replayVisibleCount + 1;
          this.scrollToBottom();
          this.scheduleNextReplayMessage();
        }, delay);
      } else {
        let thinkTime = 700 + Math.random() * 1200;
        let typeTime = Math.min(500 + textLen * 10, 3200);

        this._replayTimer = setTimeout(() => {
          this.typingAuthor = author;
          this.typingInitials = initials;
          this.typingTone = tone;
          this.showTyping = true;
          this.scrollToBottom();

          this._replayTimer = setTimeout(() => {
            this.showTyping = false;
            this.replayVisibleCount = this.replayVisibleCount + 1;
            this.scrollToBottom();
            this.scheduleNextReplayMessage();
          }, typeTime);
        }, thinkTime);
      }
    };

    stopReplay = () => {
      if (this._replayTimer) {
        clearTimeout(this._replayTimer);
        this._replayTimer = null;
      }
      this.showTyping = false;
      this.isReplaying = false;
      this.replayVisibleCount = -1;
    };

    get workflowState(): WorkflowResolution {
      this._messagesVersion;
      if (this.isReplaying) {
        return resolveWorkflowState(this.args.model, this.replayVisibleCount);
      }
      let persistedCount = this.args.model.messages?.length ?? 0;
      let extraFacts: MessageFact[] = this.localMessages.map((msg, i) => ({
        index: persistedCount + i,
        author: msg.author,
        tone: msg.tone,
        text: msg.text,
        isBot: msg.isBot,
      }));
      return resolveWorkflowState(this.args.model, undefined, extraFacts);
    }

    get totalMessageCount(): number {
      return this.args.model.messages?.length ?? 0;
    }

    get replayCompletedLabels(): string[] {
      if (!this.isReplaying || this.replayVisibleCount <= 0) return [];

      let current = this.workflowState;
      let previous = resolveWorkflowState(this.args.model, this.replayVisibleCount - 1);

      return current.steps
        .filter((step, index) =>
          step.status === 'completed' && previous.steps[index]?.status !== 'completed',
        )
        .map((step) => step.label);
    }

    get replayStatusText(): string {
      let completedLabels = this.replayCompletedLabels;
      if (completedLabels.length) return `Checked off: ${completedLabels.join(', ')}`;
      if (this.replayVisibleCount >= this.totalMessageCount) return 'Replay complete';
      return `Replaying ${this.replayVisibleCount}/${this.totalMessageCount}`;
    }

    get activeMessages(): MessageView[] {
      let allAttachments = this.args.model.attachments ?? [];

      let persisted = (this.args.model.messages ?? []).map(
        (message: MessageField, msgIdx: number) => {
          let ref = String(msgIdx);
          let attIndices: number[] = [];
          allAttachments.forEach((att: AttachmentField, idx: number) => {
            if ((att.messageRef ?? '') === ref) attIndices.push(idx);
          });

          return {
            id: `msg-${msgIdx}`,
            initials: message.initials ?? '--',
            author: message.author ?? 'Unknown',
            sentAt: message.sentAt ?? '',
            text: message.text ?? '',
            tone: message.tone ?? 'system',
            isOwn: (message.author ?? '') === '@You',
            isBot: (message.isBot ?? '') === 'true',
            attachmentIndices: attIndices,
          };
        },
      );

      let all = [...persisted, ...this.localMessages];
      if (this.isReplaying && this.replayVisibleCount >= 0) {
        return all.slice(0, this.replayVisibleCount);
      }
      return all;
    }

    get activityLog(): { time: string; text: string }[] {
      let entries: { time: string; text: string }[] = [];
      for (let msg of this.args.model.messages ?? []) {
        if ((msg.isBot ?? '') === 'true') continue;
        let tone = msg.tone ?? '';
        if (tone === 'system') continue;
        let text = msg.text ?? '';
        entries.push({
          time: msg.sentAt ?? '',
          text: text.length > 60 ? text.slice(0, 60) + '...' : text,
        });
      }
      for (let msg of this.localMessages) {
        if (msg.isBot) continue;
        entries.push({
          time: msg.sentAt,
          text: msg.text.length > 60 ? msg.text.slice(0, 60) + '...' : msg.text,
        });
      }
      return entries;
    }

    handleInput = (event: Event) => {
      this.draftMessage = (event.target as HTMLTextAreaElement).value;
    };

    handleKeydown = (event: KeyboardEvent) => {
      if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        this.sendMessage();
      }
    };

    sendMessage = () => {
      let text = this.draftMessage.trim();
      if (!text) return;

      let now = new Date();
      let hours = now.getHours();
      let minutes = now.getMinutes();
      let ampm = hours >= 12 ? 'PM' : 'AM';
      let displayHours = hours % 12 || 12;
      let displayMinutes = minutes < 10 ? `0${minutes}` : String(minutes);
      let timestamp = `${displayHours}:${displayMinutes} ${ampm}`;

      this.localMessages = [
        ...this.localMessages,
        {
          id: `local-${Date.now()}`,
          initials: 'YO',
          author: '@You',
          sentAt: timestamp,
          text,
          tone: 'teacher',
          isOwn: true,
          isBot: false,
          attachmentIndices: [],
        },
      ];
      this._messagesVersion++;

      this.draftMessage = '';
      this.isAtBottom = true;
      this.scrollToBottom();
      this.generateAiResponse(text, timestamp);
    };

    generateAiResponse = (text: string, timestamp: string) => {
      if (this._aiTimer) clearTimeout(this._aiTimer);
      let delay = 600 + Math.random() * 400;

      this._aiTimer = setTimeout(() => {
        let steps = this.args.model.steps ?? [];
        let lowerText = text.toLowerCase();
        let matchedLabel: string | null = null;

        for (let step of steps) {
          let conditions = step.predicate?.conditions ?? [];
          for (let cond of conditions) {
            if (hasText(cond.textContains) && lowerText.includes(normalizeText(cond.textContains))) {
              matchedLabel = step.label ?? null;
              break;
            }
          }
          if (matchedLabel) break;
        }

        let responseText: string;
        if (matchedLabel) {
          responseText = `Observation logged at ${timestamp}. Matched schedule block: ${matchedLabel}. Block marked as documented.`;
        } else {
          responseText = `Observation logged at ${timestamp}. No schedule block matched — recorded as general note.`;
        }

        this.localMessages = [
          ...this.localMessages,
          {
            id: `ai-${Date.now()}`,
            initials: 'AI',
            author: 'AI Classification',
            sentAt: timestamp,
            text: responseText,
            tone: 'ai',
            isOwn: false,
            isBot: true,
            attachmentIndices: [],
          },
        ];
        this._messagesVersion++;

        this.scrollToBottom();
      }, delay);
    };

    <template>
      <div class='wf-layout' {{on 'click' this.preventCardOpen}}>

        {{! ── Conversation column ── }}
        <main class='conv-pane'>
          <header class='conv-header'>
            <div class='conv-header-left'>
              <span class='conv-avatar'>{{@model.studentInitials}}</span>
              <div class='conv-header-info'>
                <span class='conv-title'>{{@model.title}}</span>
                <span class='conv-sub'>{{@model.dateLabel}} · {{@model.gradeLabel}}</span>
              </div>
              <span class={{concat 'cat-pill ' @model.categoryTone}}>{{@model.category}}</span>
            </div>
            <div class='conv-header-actions'>
              {{#if this.isReplaying}}
                <div class='replay-pill'>
                  <span class='replay-pill-pct'>{{this.workflowState.progressPercent}}%</span>
                  <span class='replay-pill-copy'>{{this.replayStatusText}}</span>
                </div>
              {{/if}}
              <button
                type='button'
                class={{if this.isReplaying 'icon-btn replaying' 'icon-btn'}}
                aria-label={{if this.isReplaying 'Stop replay' 'Replay day'}}
                {{on 'click' this.startReplay}}
              >
                {{#if this.isReplaying}}
                  <svg width='14' height='14' viewBox='0 0 24 24' fill='currentColor' stroke='none'><rect x='6' y='6' width='12' height='12' rx='2'/></svg>
                {{else}}
                  <svg width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polygon points='5 3 19 12 5 21 5 3'/></svg>
                {{/if}}
              </button>
            </div>
          </header>

          <div class='message-stream' id={{this._streamId}} {{on 'scroll' this.handleStreamScroll}}>
            {{#each this.activeMessages as |msg|}}
              {{#if msg.isBot}}
                <div class={{if (eq msg.tone 'ai') 'msg-row bot ai-msg' 'msg-row bot'}}>
                  <div class={{if (eq msg.tone 'ai') 'bot-bar ai-bar' 'bot-bar'}}></div>
                  <div class='msg-body bot-body'>
                    <div class='msg-meta'>
                      <span class={{if (eq msg.tone 'ai') 'msg-author ai-author' 'msg-author bot-author'}}>
                        {{#if (eq msg.tone 'ai')}}
                          <svg width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='12' r='10'/><path d='M8 14s1.5 2 4 2 4-2 4-2'/><line x1='9' y1='9' x2='9.01' y2='9'/><line x1='15' y1='9' x2='15.01' y2='9'/></svg>
                          AI Classification
                        {{else}}
                          <svg width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M12 2L2 7l10 5 10-5-10-5z'/><path d='M2 17l10 5 10-5'/><path d='M2 12l10 5 10-5'/></svg>
                          System
                        {{/if}}
                      </span>
                      <span class='msg-time'>{{msg.sentAt}}</span>
                    </div>
                    <div class={{if (eq msg.tone 'ai') 'msg-text ai-text' 'msg-text bot-text'}}>{{msg.text}}</div>
                    {{#each msg.attachmentIndices as |attIdx|}}
                      {{#let (get (get @fields.attachments attIdx) 'linkedCard') as |LinkedCard|}}
                        {{#let (get @model.attachments attIdx) as |att|}}
                          <div class='msg-attachment-card att-quoted'>
                            <div class='att-card'>
                              <div class='att-card-body att-no-nav'>
                                <LinkedCard @format="embedded" />
                              </div>
                              {{#if att.ctaLabel}}
                                <div class='att-cta'>
                                  <span class='att-cta-text'>{{att.ctaLabel}}</span>
                                  <div class='att-cta-nav'><LinkedCard @format="atom" /></div>
                                </div>
                              {{/if}}
                            </div>
                          </div>
                        {{/let}}
                      {{/let}}
                    {{/each}}
                  </div>
                </div>
              {{else}}
                <div class='msg-row'>
                  <div class={{concat 'msg-avatar ' msg.tone}}>{{msg.initials}}</div>
                  <div class='msg-body'>
                    <div class='msg-meta'>
                      <span class='msg-author'>{{msg.author}}</span>
                      <span class='msg-time'>{{msg.sentAt}}</span>
                    </div>
                    <div class='msg-text'>{{msg.text}}</div>
                    {{#each msg.attachmentIndices as |attIdx|}}
                      {{#let (get (get @fields.attachments attIdx) 'linkedCard') as |LinkedCard|}}
                        {{#let (get @model.attachments attIdx) as |att|}}
                          <div class='msg-attachment-card'>
                            <div class='att-card'>
                              <div class='att-card-body att-no-nav'>
                                <LinkedCard @format="embedded" />
                              </div>
                              {{#if att.ctaLabel}}
                                <div class='att-cta'>
                                  <span class='att-cta-text'>{{att.ctaLabel}}</span>
                                  <div class='att-cta-nav'><LinkedCard @format="atom" /></div>
                                </div>
                              {{/if}}
                            </div>
                          </div>
                        {{/let}}
                      {{/let}}
                    {{/each}}
                  </div>
                </div>
              {{/if}}
            {{/each}}
            {{#if this.showTyping}}
              <div class='msg-row typing-row'>
                <div class={{concat 'msg-avatar ' this.typingTone}}>{{this.typingInitials}}</div>
                <div class='msg-body'>
                  <div class='msg-meta'>
                    <span class='msg-author'>{{this.typingAuthor}}</span>
                  </div>
                  <div class='msg-text typing-bubble'>
                    <span class='typing-dot'></span>
                    <span class='typing-dot'></span>
                    <span class='typing-dot'></span>
                  </div>
                </div>
              </div>
            {{/if}}
          </div>

          <div class='composer'>
            <button type='button' class='composer-attach' aria-label='Attach evidence'>
              <svg width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48'/></svg>
            </button>
            <div class='composer-field'>
              <textarea
                class='composer-input'
                rows='1'
                placeholder={{if @model.composerPlaceholder @model.composerPlaceholder 'Log an observation...'}}
                value={{this.draftMessage}}
                {{on 'input' this.handleInput}}
                {{on 'keydown' this.handleKeydown}}
              ></textarea>
            </div>
            <button
              type='button'
              class={{if this.draftMessage 'composer-send active' 'composer-send'}}
              aria-label='Send'
              {{on 'click' this.sendMessage}}
            >
              <svg width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><line x1='22' y1='2' x2='11' y2='13'/><polygon points='22 2 15 22 11 13 2 9 22 2'/></svg>
            </button>
          </div>
        </main>

        {{! ── Right sidebar ── }}
        <aside class='ctx-pane'>
          <header class='ctx-header'>
            <span class='ctx-title'>{{@model.studentName}}'s Day</span>
            <span class='ctx-date'>{{@model.dateLabel}}</span>
          </header>

          <div class='ctx-progress'>
            <div class='donut-wrap'>
              <div
                class={{concat 'donut ' @model.progressTone}}
                style={{concat '--pct:' this.workflowState.progressPercent ';'}}
                data-replaying={{if this.isReplaying 'true' 'false'}}
              >
                <span class='donut-pct'>{{this.workflowState.progressPercent}}%</span>
                <span class='donut-sub'>documented</span>
              </div>
            </div>
          </div>

          <div class='ctx-steps'>
            <div class='ctx-section-label'>Schedule Blocks</div>
            {{#each this.workflowState.steps as |step|}}
              <div class={{concat 'step-row ' step.status}}>
                <div class='step-icon-wrap'>
                  {{#if (eq step.status 'completed')}}
                    <div class='step-icon completed'>
                      <svg width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='3'><polyline points='20 6 9 17 4 12'/></svg>
                    </div>
                  {{else if (eq step.status 'current')}}
                    <div class='step-icon current'><div class='step-dot'></div></div>
                  {{else}}
                    <div class='step-icon upcoming'><div class='step-dot-empty'></div></div>
                  {{/if}}
                </div>
                <span class='step-label'>{{step.label}}</span>
              </div>
            {{/each}}
          </div>

          {{#if this.activityLog.length}}
            <div class='ctx-activity'>
              <div class='ctx-section-label'>Activity Log</div>
              {{#each this.activityLog as |entry|}}
                <div class='activity-entry'>
                  <span class='activity-time'>{{entry.time}}</span>
                  <span class='activity-text'>{{entry.text}}</span>
                </div>
              {{/each}}
            </div>
          {{/if}}

          <div class='ctx-participants'>
            <div class='ctx-section-label'>Team</div>
            {{#each @model.participants as |p|}}
              <div class='participant-row'>
                <div class={{concat 'part-avatar ' p.tone}}>{{p.initials}}</div>
                <div class='part-info'>
                  <div class='part-name'>{{p.name}}</div>
                  <div class='part-role'>{{p.role}}</div>
                </div>
              </div>
            {{/each}}
          </div>
        </aside>

      </div>

      <style scoped>
        @property --pct {
          syntax: '<number>';
          inherits: false;
          initial-value: 0;
        }

        .wf-layout {
          --c-dark: #0f1117;
          --c-white: #ffffff;
          --c-surface: #f7f8fa;
          --c-border: #e4e7ed;
          --c-text: #1a1f2e;
          --c-muted: #6b7280;
          --c-accent: #2a9d8f;
          --c-accent-bg: rgba(42, 157, 143, 0.1);
          --c-ai: #0aad82;
          --c-ai-bg: rgba(10, 173, 130, 0.08);
          --font: ui-sans-serif, system-ui, -apple-system, 'Segoe UI', sans-serif;

          display: grid;
          grid-template-columns: minmax(0, 1fr) 280px;
          height: 100%;
          width: 100%;
          font-family: var(--font);
          font-size: 14px;
          line-height: 1.5;
          overflow: hidden;
        }

        /* ── Conversation column ── */
        .conv-pane { background: var(--c-white); display: flex; flex-direction: column; border-right: 1px solid var(--c-border); overflow: hidden; }

        .conv-header {
          display: flex; align-items: center; justify-content: space-between;
          padding: 12px 18px; border-bottom: 1px solid var(--c-border);
          background: #fff; flex-shrink: 0;
        }
        .conv-header-left { display: flex; align-items: center; gap: 10px; min-width: 0; }
        .conv-avatar {
          width: 36px; height: 36px; border-radius: 10px;
          background: #7c5fc4; color: #fff;
          display: flex; align-items: center; justify-content: center;
          font-size: 12px; font-weight: 800; flex-shrink: 0;
        }
        .conv-header-info { display: flex; flex-direction: column; min-width: 0; }
        .conv-title { font-size: 14px; font-weight: 700; color: var(--c-text); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .conv-sub { font-size: 11px; color: var(--c-muted); }
        .conv-header-actions { display: flex; align-items: center; gap: 4px; flex-shrink: 0; }
        .replay-pill {
          display: flex; align-items: center; gap: 8px; max-width: 280px;
          padding: 6px 10px; border-radius: 999px;
          background: var(--c-accent-bg); color: var(--c-accent);
        }
        .replay-pill-pct { font-size: 11px; font-weight: 800; flex-shrink: 0; }
        .replay-pill-copy { font-size: 11px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        .cat-pill { font-size: 10px; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; padding: 3px 8px; border-radius: 5px; }
        .cat-pill.iep { background: rgba(224, 93, 80, 0.12); color: #e05d50; }
        .cat-pill.plan504 { background: rgba(192, 139, 48, 0.12); color: #c08b30; }
        .cat-pill.gened { background: rgba(42, 157, 143, 0.12); color: #2a9d8f; }

        .icon-btn {
          width: 30px; height: 30px; border-radius: 7px; border: none;
          background: transparent; color: var(--c-muted);
          display: flex; align-items: center; justify-content: center;
          cursor: pointer; transition: background 0.15s;
        }
        .icon-btn:hover { background: var(--c-surface); color: var(--c-text); }
        .icon-btn.replaying { background: var(--c-accent-bg); color: var(--c-accent); }
        .icon-btn.replaying:hover { background: rgba(42, 157, 143, 0.18); }

        /* ── Message stream ── */
        .message-stream {
          flex: 1; overflow-y: auto; padding: 20px 18px 12px;
          display: flex; flex-direction: column; gap: 18px;
          scrollbar-width: thin; scrollbar-color: #e4e7ed transparent;
        }

        .msg-row { display: flex; align-items: flex-start; gap: 10px; animation: msgFadeIn 0.25s ease-out; }

        .msg-avatar {
          width: 32px; height: 32px; border-radius: 50%;
          display: flex; align-items: center; justify-content: center;
          font-size: 11px; font-weight: 800; flex-shrink: 0;
          background: #6b7280; color: #fff;
        }
        .msg-avatar.teacher { background: #2a9d8f; }
        .msg-avatar.aide { background: #7c5fc4; }
        .msg-avatar.therapist { background: #c08b30; }
        .msg-avatar.self { background: #dbeafe; color: #1e40af; }

        .msg-body { max-width: 520px; min-width: 0; }
        .msg-meta { display: flex; align-items: baseline; gap: 8px; margin-bottom: 4px; }
        .msg-author { font-size: 12px; font-weight: 700; color: var(--c-text); }
        .msg-time { font-size: 11px; color: var(--c-muted); }

        .msg-text {
          font-size: 13.5px; line-height: 1.55; color: #2d3452;
          background: var(--c-surface); border-radius: 0 12px 12px 12px;
          padding: 10px 13px; white-space: pre-wrap;
        }

        /* Bot / system messages */
        .msg-row.bot { display: flex; align-items: flex-start; gap: 0; }
        .bot-bar { width: 3px; min-height: 100%; background: #94a3b8; border-radius: 3px; flex-shrink: 0; margin-right: 10px; }
        .bot-body { max-width: 100%; }
        .bot-author { display: inline-flex; align-items: center; gap: 4px; color: #64748b !important; }
        .bot-text { background: rgba(148, 163, 184, 0.08) !important; border-radius: 8px !important; font-size: 13px !important; color: #64748b !important; font-style: italic; }

        /* AI classification messages — green accent */
        .ai-bar { background: var(--c-ai) !important; }
        .ai-author { display: inline-flex; align-items: center; gap: 4px; color: var(--c-ai) !important; }
        .ai-text { background: var(--c-ai-bg) !important; border-radius: 8px !important; font-size: 13px !important; color: #065f46 !important; font-style: italic; }

        /* Attachment cards */
        .msg-attachment-card { margin-top: 8px; max-width: 380px; }
        .att-quoted { zoom: 0.65; }
        .att-card { border: 1px solid #e4e7ed; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.07); background: #fff; }
        .att-card-body { overflow: hidden; }
        .att-no-nav { pointer-events: none; }
        .att-card .att-cta {
          position: relative; display: block; width: 100%; border: none; border-top: 1px solid #e4e7ed;
          background: #3d4152; color: #fff; font-size: 12.5px; font-weight: 600;
          padding: 10px 16px; cursor: pointer; transition: background 0.15s;
          text-align: center; letter-spacing: 0.02em;
        }
        .att-card .att-cta:hover { background: var(--c-accent); }
        .att-cta-text { position: relative; z-index: 1; pointer-events: none; }
        .att-cta-nav { position: absolute; inset: 0; opacity: 0; z-index: 2; overflow: hidden; }

        /* ── Composer ── */
        .composer {
          display: flex; align-items: center; gap: 8px;
          padding: 12px 14px; border-top: 1px solid var(--c-border);
          background: #fff; flex-shrink: 0;
        }
        .composer-attach {
          width: 34px; height: 34px; border-radius: 50%;
          border: 1px solid var(--c-border); background: var(--c-surface);
          color: var(--c-muted); display: flex; align-items: center; justify-content: center;
          cursor: pointer; flex-shrink: 0; transition: border-color 0.15s, color 0.15s;
        }
        .composer-attach:hover { border-color: var(--c-accent); color: var(--c-accent); }
        .composer-field { flex: 1; min-width: 0; background: var(--c-surface); border: 1px solid var(--c-border); border-radius: 20px; padding: 8px 14px; }
        .composer-input { width: 100%; border: none; background: transparent; resize: none; outline: none; font: inherit; font-size: 13.5px; color: var(--c-text); line-height: 1.45; }
        .composer-input::placeholder { color: #9ca3af; }
        .composer-send {
          width: 34px; height: 34px; border-radius: 50%; border: none;
          background: var(--c-border); color: #9ca3af;
          display: flex; align-items: center; justify-content: center;
          cursor: pointer; flex-shrink: 0; transition: background 0.15s, color 0.15s;
        }
        .composer-send.active { background: var(--c-accent); color: #fff; }

        /* ── Right sidebar ── */
        .ctx-pane { background: var(--c-surface); display: flex; flex-direction: column; overflow: hidden; }
        .ctx-header { padding: 14px 16px; border-bottom: 1px solid var(--c-border); background: #fff; flex-shrink: 0; display: flex; justify-content: space-between; align-items: baseline; }
        .ctx-title { font-size: 13px; font-weight: 700; color: var(--c-text); }
        .ctx-date { font-size: 11px; color: var(--c-muted); }

        .ctx-progress {
          padding: 20px 16px 16px; display: flex; justify-content: center;
          border-bottom: 1px solid var(--c-border); background: #fff;
        }
        .donut-wrap { display: flex; align-items: center; justify-content: center; }
        .donut {
          --pct: 0; --ring-c: var(--c-accent); --track-c: #e8ecf4;
          width: 110px; height: 110px; border-radius: 50%;
          background: radial-gradient(closest-side, #fff 72%, transparent 74%), conic-gradient(var(--ring-c) calc(var(--pct) * 1%), var(--track-c) 0);
          display: flex; flex-direction: column; align-items: center; justify-content: center;
          transition: --pct 420ms cubic-bezier(0.22, 1, 0.36, 1);
          box-shadow: 0 10px 28px rgba(15, 23, 42, 0.06);
        }
        .donut.iep { --ring-c: #e05d50; }
        .donut.plan504 { --ring-c: #c08b30; }
        .donut.gened { --ring-c: var(--c-accent); }
        .donut[data-replaying='true'] { animation: donutBreathe 3.2s ease-in-out infinite; }
        .donut-pct { font-size: 20px; font-weight: 800; color: var(--c-text); line-height: 1; }
        .donut-sub { font-size: 10px; color: var(--c-muted); letter-spacing: 0.04em; }

        .ctx-steps { padding: 16px; border-bottom: 1px solid var(--c-border); background: #fff; }
        .ctx-section-label { font-size: 10px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; color: var(--c-muted); margin-bottom: 10px; }

        .step-row { display: flex; align-items: center; gap: 10px; padding: 6px 0; font-size: 12.5px; }
        .step-icon-wrap { flex-shrink: 0; }
        .step-icon { width: 18px; height: 18px; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
        .step-icon.completed { background: var(--c-accent); color: #fff; }
        .step-icon.current { border: 2px solid var(--c-accent); background: transparent; }
        .step-icon.upcoming { border: 2px solid var(--c-border); background: transparent; }
        .step-dot { width: 6px; height: 6px; border-radius: 50%; background: var(--c-accent); }
        .step-dot-empty { width: 6px; height: 6px; border-radius: 50%; background: var(--c-border); }
        .step-label { color: var(--c-muted); }
        .step-row.completed .step-label { color: var(--c-muted); text-decoration: line-through; opacity: 0.7; }
        .step-row.current .step-label { color: var(--c-text); font-weight: 700; }

        .ctx-activity { padding: 16px; border-bottom: 1px solid var(--c-border); background: #fff; max-height: 180px; overflow-y: auto; }
        .activity-entry { display: flex; align-items: baseline; gap: 8px; padding: 3px 0; font-size: 11.5px; }
        .activity-time { flex-shrink: 0; font-size: 10px; font-weight: 600; color: var(--c-muted); min-width: 52px; }
        .activity-text { color: var(--c-text); line-height: 1.35; min-width: 0; }

        .ctx-participants { padding: 16px; background: #fff; flex: 1; overflow-y: auto; }
        .participant-row { display: flex; align-items: center; gap: 10px; padding: 7px 0; }
        .part-avatar {
          width: 32px; height: 32px; border-radius: 50%;
          display: flex; align-items: center; justify-content: center;
          font-size: 11px; font-weight: 800; flex-shrink: 0;
          background: #6b7280; color: #fff;
        }
        .part-avatar.teacher { background: #2a9d8f; }
        .part-avatar.aide { background: #7c5fc4; }
        .part-avatar.therapist { background: #c08b30; }
        .part-info { min-width: 0; }
        .part-name { font-size: 12.5px; font-weight: 700; color: var(--c-text); }
        .part-role { font-size: 11.5px; color: var(--c-muted); }

        /* ── Typing indicator ── */
        .typing-row { animation: msgFadeIn 0.2s ease-out; }
        .typing-bubble { display: flex !important; align-items: center; gap: 4px; padding: 10px 16px !important; }
        .typing-dot {
          width: 7px; height: 7px; border-radius: 50%;
          background: #9ca3af;
          animation: typingBounce 1.4s ease-in-out infinite;
        }
        .typing-dot:nth-child(2) { animation-delay: 0.2s; }
        .typing-dot:nth-child(3) { animation-delay: 0.4s; }

        @keyframes typingBounce {
          0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
          30% { transform: translateY(-4px); opacity: 1; }
        }
        @keyframes donutBreathe {
          0%, 100% { transform: scale(1); }
          50% { transform: scale(1.018); }
        }
        @keyframes msgFadeIn {
          from { opacity: 0; transform: translateY(8px); }
          to { opacity: 1; transform: translateY(0); }
        }

        .message-stream::-webkit-scrollbar, .ctx-participants::-webkit-scrollbar { width: 4px; }
        .message-stream::-webkit-scrollbar-thumb, .ctx-participants::-webkit-scrollbar-thumb { background: var(--c-border); border-radius: 4px; }

        @media (max-width: 800px) {
          .wf-layout { grid-template-columns: 1fr; }
          .ctx-pane { display: none; }
        }
      </style>
    </template>
  };

  // ── Fitted: Dark tile card ──

  static fitted = class Fitted extends Component<typeof StudentDayWorkflow> {
    get workflowState(): WorkflowResolution {
      return resolveWorkflowState(this.args.model);
    }

    get hasUnread(): boolean {
      return (this.args.model.unreadCount ?? 0) > 0;
    }

    get participantNames(): string {
      return (this.args.model.participants ?? [])
        .map((p: ParticipantField) => p.name ?? '')
        .filter(Boolean)
        .join(', ');
    }

    <template>
      <div class='wf-fitted'>
        <div class='fitted-top'>
          <div class='fit-time-row'>
            {{#if this.hasUnread}}
              <span class='unread-badge'>{{@model.unreadCount}}</span>
            {{/if}}
            <span class='fit-time'>{{@model.dateLabel}}</span>
          </div>
          <span class={{concat 'fit-cat ' @model.categoryTone}}>{{@model.category}}</span>
        </div>
        <div class='fit-student'>
          <span class='fit-initials'>{{@model.studentInitials}}</span>
          <span class='fit-name'>{{@model.studentName}}</span>
        </div>
        <div class='fit-title'>{{@model.title}}</div>
        <div class='fit-preview'>{{@model.preview}}</div>
        <div class='fit-bottom'>
          <div class='fit-people'>
            <svg class='fit-people-icon' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.8'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'/><circle cx='9' cy='7' r='4'/><path d='M23 21v-2a4 4 0 0 0-3-3.87'/><path d='M16 3.13a4 4 0 0 1 0 7.75'/></svg>
            <span class='fit-names'>{{this.participantNames}}</span>
          </div>
          <div
            class={{concat 'fit-ring ' @model.progressTone}}
            style={{concat '--pct:' this.workflowState.progressPercent ';'}}
          ></div>
        </div>
      </div>

      <style scoped>
        .wf-fitted {
          width: 100%; height: 100%; box-sizing: border-box;
          background: linear-gradient(160deg, #10131a, #1a2030 55%, #0c3b34);
          color: #e8eaf0; padding: 14px 16px;
          display: flex; flex-direction: column;
          font-family: ui-sans-serif, system-ui, -apple-system, 'Segoe UI', sans-serif;
          overflow: hidden;
        }
        .fitted-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
        .fit-time-row { display: flex; align-items: center; gap: 7px; }
        .unread-badge {
          width: 18px; height: 18px; border-radius: 50%;
          background: #ef4444; color: #fff;
          font-size: 10px; font-weight: 800; line-height: 1;
          display: inline-flex; align-items: center; justify-content: center;
        }
        .fit-time { font-size: 11px; color: rgba(255,255,255,0.45); }
        .fit-cat {
          font-size: 9px; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase;
          padding: 2px 7px; border-radius: 4px; flex-shrink: 0;
        }
        .fit-cat.iep { background: rgba(224, 93, 80, 0.18); color: #f0978f; }
        .fit-cat.plan504 { background: rgba(192, 139, 48, 0.18); color: #e8c06a; }
        .fit-cat.gened { background: rgba(42, 157, 143, 0.18); color: #5ecfbe; }
        .fit-student { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
        .fit-initials {
          width: 28px; height: 28px; border-radius: 8px;
          background: #7c5fc4; color: #fff;
          display: flex; align-items: center; justify-content: center;
          font-size: 10px; font-weight: 800; flex-shrink: 0;
        }
        .fit-name { font-size: 13.5px; font-weight: 700; color: #f0f2f7; }
        .fit-title { font-size: 12px; font-weight: 600; color: rgba(255,255,255,0.6); margin-bottom: 4px; line-height: 1.35; }
        .fit-preview {
          font-size: 11.5px; color: rgba(255,255,255,0.38);
          margin-bottom: 10px; line-height: 1.4;
          display: -webkit-box; -webkit-line-clamp: 2;
          -webkit-box-orient: vertical; overflow: hidden;
        }
        .fit-bottom { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-top: auto; }
        .fit-people { display: flex; align-items: center; gap: 6px; min-width: 0; flex: 1; }
        .fit-people-icon { color: rgba(255,255,255,0.3); flex-shrink: 0; }
        .fit-names { font-size: 11px; color: rgba(255,255,255,0.38); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .fit-ring {
          --pct: 0; --ring-c: #2a9d8f; --track-c: rgba(255,255,255,0.1);
          width: 32px; height: 32px; border-radius: 50%; flex-shrink: 0;
          background: radial-gradient(closest-side, #10131a 64%, transparent 66%), conic-gradient(var(--ring-c) calc(var(--pct) * 1%), var(--track-c) 0);
        }
        .fit-ring.iep { --ring-c: #e05d50; }
        .fit-ring.plan504 { --ring-c: #c08b30; }
        .fit-ring.gened { --ring-c: #2a9d8f; }
      </style>
    </template>
  };

  // ── Embedded ──

  static embedded = class Embedded extends Component<typeof StudentDayWorkflow> {
    get workflowState(): WorkflowResolution {
      return resolveWorkflowState(this.args.model);
    }

    <template>
      <div class='wf-embed'>
        <span class='embed-initials'>{{@model.studentInitials}}</span>
        <span class={{concat 'embed-cat ' @model.categoryTone}}>{{@model.category}}</span>
        <span class='embed-title'>{{@model.studentName}}</span>
        <div class='embed-ring-wrap'>
          <div
            class={{concat 'embed-ring ' @model.progressTone}}
            style={{concat '--pct:' this.workflowState.progressPercent ';'}}
          ></div>
          <span class='embed-pct'>{{this.workflowState.progressPercent}}%</span>
        </div>
      </div>

      <style scoped>
        .wf-embed {
          display: flex; align-items: center; gap: 8px; padding: 10px 14px;
          background: linear-gradient(135deg, #10131a, #202739); color: #f0f2f7;
          border-radius: 10px; font-family: ui-sans-serif, system-ui, -apple-system, sans-serif;
        }
        .embed-initials {
          width: 24px; height: 24px; border-radius: 6px;
          background: #7c5fc4; color: #fff;
          display: flex; align-items: center; justify-content: center;
          font-size: 9px; font-weight: 800; flex-shrink: 0;
        }
        .embed-cat {
          font-size: 9px; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase;
          padding: 2px 6px; border-radius: 4px; flex-shrink: 0;
        }
        .embed-cat.iep { background: rgba(224, 93, 80, 0.18); color: #f0978f; }
        .embed-cat.plan504 { background: rgba(192, 139, 48, 0.18); color: #e8c06a; }
        .embed-cat.gened { background: rgba(42, 157, 143, 0.18); color: #5ecfbe; }
        .embed-title { font-size: 13px; font-weight: 700; flex: 1; min-width: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .embed-ring-wrap { display: flex; align-items: center; gap: 4px; flex-shrink: 0; }
        .embed-ring {
          --pct: 0; --ring-c: #2a9d8f; --track-c: rgba(255,255,255,0.1);
          width: 20px; height: 20px; border-radius: 50%;
          background: radial-gradient(closest-side, #10131a 65%, transparent 67%), conic-gradient(var(--ring-c) calc(var(--pct) * 1%), var(--track-c) 0);
        }
        .embed-ring.iep { --ring-c: #e05d50; }
        .embed-ring.plan504 { --ring-c: #c08b30; }
        .embed-ring.gened { --ring-c: #2a9d8f; }
        .embed-pct { font-size: 10px; color: rgba(255,255,255,0.5); }
      </style>
    </template>
  };
}
