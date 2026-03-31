import {
  FieldDef,
  field,
  contains,
  Component,
} from 'https://cardstack.com/base/card-api';
import StringField from 'https://cardstack.com/base/string';
import NumberField from 'https://cardstack.com/base/number';

// AI-generated classification suggestion for activity entries
export class AiTagSuggestion extends FieldDef {
  static displayName = 'AI Tag Suggestion';

  @field suggestedType = contains(StringField);
  @field suggestedBlock = contains(StringField);
  @field suggestedGoal = contains(StringField);
  @field confidence = contains(NumberField);
  @field reasoning = contains(StringField);
  @field accepted = contains(StringField);

  static embedded = class Embedded extends Component<typeof AiTagSuggestion> {
    get safeType() { return this.args.model?.suggestedType ?? 'Unknown'; }
    get safeBlock() { return this.args.model?.suggestedBlock ?? ''; }
    get safeGoal() { return this.args.model?.suggestedGoal ?? ''; }
    get confidencePct() { return this.args.model?.confidence ?? 0; }
    get safeStatus() { return this.args.model?.accepted ?? 'pending'; }

    get typeColor() {
      switch (this.safeType.toLowerCase()) {
        case 'academic': return '#e05d50';
        case 'social': return '#7c5fc4';
        case 'behavioral': return '#c08b30';
        default: return '#5c5650';
      }
    }

    get typeBgColor() {
      switch (this.safeType.toLowerCase()) {
        case 'academic': return '#fdf0ee';
        case 'social': return '#f4f0fa';
        case 'behavioral': return '#fdf6e8';
        default: return '#f5f2ef';
      }
    }

    get statusClass() {
      switch (this.safeStatus) {
        case 'accepted': return 'accepted';
        case 'rejected': return 'rejected';
        case 'edited': return 'edited';
        default: return 'pending';
      }
    }

    get confidenceLabel() {
      if (this.confidencePct >= 80) return 'High';
      if (this.confidencePct >= 50) return 'Medium';
      return 'Low';
    }

    <template>
      <div class='ai-suggestion {{this.statusClass}}'>
        <div class='ai-header'>
          <div class='ai-icon'>
            <svg width='12' height='12' viewBox='0 0 12 12' fill='currentColor'><circle cx='6' cy='6' r='5'/></svg>
            <span class='ai-label'>AI Suggestion</span>
          </div>
          <span class='confidence {{this.confidenceLabel}}'>{{this.confidencePct}}%</span>
        </div>
        <div class='ai-tags'>
          <span class='type-pill' style='background: {{this.typeBgColor}}; color: {{this.typeColor}}'>{{this.safeType}}</span>
          {{#if this.safeBlock}}
            <span class='block-ref'>{{this.safeBlock}}</span>
          {{/if}}
          {{#if this.safeGoal}}
            <span class='goal-ref'>→ {{this.safeGoal}}</span>
          {{/if}}
        </div>
        {{#if @model.reasoning}}
          <div class='reasoning'>{{@model.reasoning}}</div>
        {{/if}}
        <div class='ai-status-row'>
          <span class='status-badge {{this.statusClass}}'>{{this.safeStatus}}</span>
        </div>
      </div>
      <style scoped>
        .ai-suggestion {
          display: flex;
          flex-direction: column;
          gap: 0.375rem;
          padding: 0.625rem;
          background: #e8f6f4;
          border: 1px solid rgba(42, 157, 143, 0.2);
          border-radius: 8px;
        }
        .ai-suggestion.accepted { border-color: rgba(42, 157, 143, 0.4); }
        .ai-suggestion.rejected { background: #f5f2ef; border-color: rgba(224, 93, 80, 0.2); opacity: 0.6; }
        .ai-suggestion.edited { background: #f4f0fa; border-color: rgba(124, 95, 196, 0.2); }

        .ai-header { display: flex; align-items: center; justify-content: space-between; }
        .ai-icon { display: flex; align-items: center; gap: 0.25rem; color: #2a9d8f; }
        .ai-label { font-size: 0.5625rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; }
        .confidence { font-size: 0.625rem; font-weight: 600; }
        .confidence.High { color: #2a9d8f; }
        .confidence.Medium { color: #c08b30; }
        .confidence.Low { color: #e05d50; }

        .ai-tags { display: flex; gap: 0.375rem; align-items: center; flex-wrap: wrap; }
        .type-pill { font-size: 0.5625rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; padding: 0.125rem 0.375rem; border-radius: 4px; }
        .block-ref { font-size: 0.6875rem; color: #5c5650; font-weight: 500; }
        .goal-ref { font-size: 0.6875rem; color: #7c5fc4; font-weight: 500; }

        .reasoning { font-size: 0.6875rem; color: #5c5650; font-style: italic; line-height: 1.4; }

        .ai-status-row { display: flex; gap: 0.25rem; }
        .status-badge { font-size: 0.5625rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; padding: 0.125rem 0.375rem; border-radius: 3px; }
        .status-badge.pending { background: #fdf6e8; color: #c08b30; }
        .status-badge.accepted { background: #e8f6f4; color: #2a9d8f; }
        .status-badge.rejected { background: #fdf0ee; color: #e05d50; }
        .status-badge.edited { background: #f4f0fa; color: #7c5fc4; }
      </style>
    </template>
  };
}
