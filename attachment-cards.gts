import {
  CardDef,
  Component,
  field,
  contains,
  linksTo,
} from 'https://cardstack.com/base/card-api';
import StringField from 'https://cardstack.com/base/string';
import NumberField from 'https://cardstack.com/base/number';
// Domain-specific attachment cards for student workflow

// ── Goal Progress Card ──
// Tracks mastery progress on a specific IEP/504 goal

export class GoalProgressCard extends CardDef {
  static displayName = 'Goal Progress';

  @field goalTitle = contains(StringField);
  @field domain = contains(StringField);
  @field currentMastery = contains(NumberField);
  @field previousMastery = contains(NumberField);
  @field targetMastery = contains(NumberField);
  @field trialResult = contains(StringField);
  @field sessionNote = contains(StringField);
  @field linkedGoal = linksTo(CardDef);
  @field cardTitle = contains(StringField, {
    computeVia: function (this: GoalProgressCard) {
      return this.goalTitle ?? 'Goal Progress';
    },
  });

  static isolated = class Isolated extends Component<typeof GoalProgressCard> {
    get domainColor() {
      switch (this.args.model.domain) {
        case 'Math': return '#e05d50';
        case 'Reading': return '#c08b30';
        case 'Social': return '#7c5fc4';
        case 'Behavioral': return '#c08b30';
        case 'Motor': return '#2a9d8f';
        case 'Communication': return '#5c8fc4';
        default: return '#5c5650';
      }
    }

    get delta() {
      let curr = this.args.model.currentMastery ?? 0;
      let prev = this.args.model.previousMastery ?? 0;
      return curr - prev;
    }

    get deltaLabel() {
      let d = this.delta;
      if (d > 0) return `+${d}%`;
      if (d < 0) return `${d}%`;
      return '0%';
    }

    get deltaClass() {
      if (this.delta > 0) return 'positive';
      if (this.delta < 0) return 'negative';
      return 'neutral';
    }

    <template>
      <article class='gp-isolated'>
        <header class='gp-header'>
          <span class='gp-domain' style='background: {{this.domainColor}}'>{{@model.domain}}</span>
          <span class='gp-delta {{this.deltaClass}}'>{{this.deltaLabel}}</span>
        </header>
        <h1 class='gp-title'>{{@model.goalTitle}}</h1>
        <div class='gp-progress'>
          <div class='gp-progress-header'>
            <span class='gp-label'>Mastery</span>
            <span class='gp-value'>{{@model.currentMastery}}%</span>
          </div>
          <div class='gp-bar'>
            <div class='gp-fill' style='width: {{@model.currentMastery}}%; background: {{this.domainColor}}'></div>
            <div class='gp-target' style='left: {{@model.targetMastery}}%'></div>
          </div>
          <div class='gp-bar-labels'>
            <span>Previous: {{@model.previousMastery}}%</span>
            <span>Target: {{@model.targetMastery}}%</span>
          </div>
        </div>
        {{#if @model.trialResult}}
          <div class='gp-detail'>
            <span class='gp-detail-label'>Trial Result</span>
            <span>{{@model.trialResult}}</span>
          </div>
        {{/if}}
        {{#if @model.sessionNote}}
          <div class='gp-detail'>
            <span class='gp-detail-label'>Session Note</span>
            <span>{{@model.sessionNote}}</span>
          </div>
        {{/if}}
        {{#if @model.linkedGoal}}
          <div class='gp-linked-goal'>
            <span class='gp-detail-label'>Linked Goal</span>
            <@fields.linkedGoal @format="embedded" />
          </div>
        {{/if}}
      </article>
      <style scoped>
        .gp-isolated { max-width: 400px; padding: 1.25rem; display: flex; flex-direction: column; gap: 1rem; }
        .gp-header { display: flex; align-items: center; justify-content: space-between; }
        .gp-domain { padding: 0.1875rem 0.625rem; border-radius: 1rem; color: #fff; font-size: 0.6875rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
        .gp-delta { font-size: 0.875rem; font-weight: 700; }
        .gp-delta.positive { color: #2a9d8f; }
        .gp-delta.negative { color: #e05d50; }
        .gp-delta.neutral { color: #8a8279; }
        .gp-title { font-size: 1.125rem; font-weight: 700; margin: 0; color: #1a1816; }
        .gp-progress { display: flex; flex-direction: column; gap: 0.375rem; }
        .gp-progress-header { display: flex; justify-content: space-between; align-items: baseline; }
        .gp-label { font-size: 0.625rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: #8a8279; }
        .gp-value { font-size: 1.125rem; font-weight: 700; }
        .gp-bar { position: relative; height: 6px; background: #ebe7e3; border-radius: 3px; }
        .gp-fill { height: 100%; border-radius: 3px; transition: width 0.3s ease; }
        .gp-target { position: absolute; top: -2px; width: 2px; height: calc(100% + 4px); background: #1a1816; border-radius: 1px; }
        .gp-bar-labels { display: flex; justify-content: space-between; font-size: 0.6875rem; color: #8a8279; }
        .gp-detail { display: flex; flex-direction: column; gap: 0.25rem; padding: 0.625rem; background: #f8f8f8; border-radius: 8px; font-size: 0.875rem; color: #1a1816; }
        .gp-detail-label { font-size: 0.625rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; color: #8a8279; }
        .gp-linked-goal { display: flex; flex-direction: column; gap: 0.5rem; }
      </style>
    </template>
  };

  static embedded = class Embedded extends Component<typeof GoalProgressCard> {
    get domainColor() {
      switch (this.args.model.domain) {
        case 'Math': return '#e05d50';
        case 'Reading': return '#c08b30';
        case 'Social': return '#7c5fc4';
        case 'Behavioral': return '#c08b30';
        case 'Motor': return '#2a9d8f';
        case 'Communication': return '#5c8fc4';
        default: return '#5c5650';
      }
    }

    get delta() {
      let curr = this.args.model.currentMastery ?? 0;
      let prev = this.args.model.previousMastery ?? 0;
      return curr - prev;
    }

    get deltaLabel() {
      let d = this.delta;
      if (d > 0) return `+${d}%`;
      if (d < 0) return `${d}%`;
      return '0%';
    }

    get deltaClass() {
      if (this.delta > 0) return 'positive';
      if (this.delta < 0) return 'negative';
      return 'neutral';
    }

    <template>
      <div class='gp-embed'>
        <div class='gp-embed-top'>
          <span class='gp-embed-domain' style='background: {{this.domainColor}}'>{{@model.domain}}</span>
          <span class='gp-embed-pct'>{{@model.currentMastery}}%</span>
          <span class='gp-embed-delta {{this.deltaClass}}'>{{this.deltaLabel}}</span>
        </div>
        <div class='gp-embed-title'>{{@model.goalTitle}}</div>
        <div class='gp-embed-bar'>
          <div class='gp-embed-fill' style='width: {{@model.currentMastery}}%; background: {{this.domainColor}}'></div>
        </div>
        {{#if @model.sessionNote}}
          <div class='gp-embed-note'>{{@model.sessionNote}}</div>
        {{/if}}
      </div>
      <style scoped>
        .gp-embed { display: flex; flex-direction: column; gap: 6px; padding: 10px 12px; background: #fff; border: 1px solid #e8e4e0; border-radius: 10px; }
        .gp-embed-top { display: flex; align-items: center; gap: 6px; }
        .gp-embed-domain { padding: 2px 6px; border-radius: 999px; color: #fff; font-size: 9px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
        .gp-embed-pct { font-size: 14px; font-weight: 700; color: #1a1816; margin-left: auto; }
        .gp-embed-delta { font-size: 11px; font-weight: 700; }
        .gp-embed-delta.positive { color: #2a9d8f; }
        .gp-embed-delta.negative { color: #e05d50; }
        .gp-embed-delta.neutral { color: #8a8279; }
        .gp-embed-title { font-size: 12px; font-weight: 600; color: #1a1816; line-height: 1.3; }
        .gp-embed-bar { height: 4px; background: #ebe7e3; border-radius: 2px; }
        .gp-embed-fill { height: 100%; border-radius: 2px; }
        .gp-embed-note { font-size: 11px; color: #5c5650; line-height: 1.35; }
      </style>
    </template>
  };

  static fitted = class Fitted extends Component<typeof GoalProgressCard> {
    get domainColor() {
      switch (this.args.model.domain) {
        case 'Math': return '#e05d50';
        case 'Reading': return '#c08b30';
        case 'Social': return '#7c5fc4';
        default: return '#5c5650';
      }
    }

    <template>
      <div class='gp-fit'>
        <span class='gp-fit-domain' style='color: {{this.domainColor}}'>{{@model.domain}}</span>
        <span class='gp-fit-title'>{{@model.goalTitle}}</span>
        <span class='gp-fit-pct'>{{@model.currentMastery}}%</span>
      </div>
      <style scoped>
        .gp-fit { display: flex; align-items: center; gap: 6px; padding: 6px 10px; width: 100%; height: 100%; box-sizing: border-box; }
        .gp-fit-domain { font-size: 9px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.06em; flex-shrink: 0; }
        .gp-fit-title { font-size: 12px; font-weight: 600; color: #1a1816; flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .gp-fit-pct { font-size: 13px; font-weight: 700; color: #1a1816; flex-shrink: 0; }
      </style>
    </template>
  };
}

// ── Behavior Incident Card ──
// Documents behavioral incidents using ABC model

export class BehaviorIncidentCard extends CardDef {
  static displayName = 'Behavior Incident';

  @field incidentType = contains(StringField);
  @field severity = contains(StringField);
  @field antecedent = contains(StringField);
  @field behavior = contains(StringField);
  @field consequence = contains(StringField);
  @field duration = contains(StringField);
  @field cardTitle = contains(StringField, {
    computeVia: function (this: BehaviorIncidentCard) {
      let type = this.incidentType ?? 'Incident';
      let sev = this.severity ?? '';
      return sev ? `${type} (${sev})` : type;
    },
  });

  static isolated = class Isolated extends Component<typeof BehaviorIncidentCard> {
    get severityColor() {
      switch (this.args.model.severity) {
        case 'High': return '#e05d50';
        case 'Medium': return '#c08b30';
        case 'Low': return '#2a9d8f';
        default: return '#8a8279';
      }
    }

    <template>
      <article class='bi-isolated'>
        <header class='bi-header'>
          <span class='bi-type'>{{@model.incidentType}}</span>
          <span class='bi-severity' style='color: {{this.severityColor}}; background: {{this.severityColor}}18'>{{@model.severity}}</span>
          {{#if @model.duration}}
            <span class='bi-duration'>{{@model.duration}}</span>
          {{/if}}
        </header>
        <div class='bi-abc'>
          {{#if @model.antecedent}}
            <div class='bi-section'>
              <span class='bi-label'>A — Antecedent</span>
              <span class='bi-text'>{{@model.antecedent}}</span>
            </div>
          {{/if}}
          {{#if @model.behavior}}
            <div class='bi-section'>
              <span class='bi-label'>B — Behavior</span>
              <span class='bi-text'>{{@model.behavior}}</span>
            </div>
          {{/if}}
          {{#if @model.consequence}}
            <div class='bi-section'>
              <span class='bi-label'>C — Consequence</span>
              <span class='bi-text'>{{@model.consequence}}</span>
            </div>
          {{/if}}
        </div>
      </article>
      <style scoped>
        .bi-isolated { max-width: 400px; padding: 1.25rem; display: flex; flex-direction: column; gap: 1rem; }
        .bi-header { display: flex; align-items: center; gap: 0.5rem; }
        .bi-type { font-size: 1rem; font-weight: 700; color: #1a1816; }
        .bi-severity { font-size: 0.6875rem; font-weight: 700; padding: 0.1875rem 0.5rem; border-radius: 4px; text-transform: uppercase; letter-spacing: 0.05em; }
        .bi-duration { font-size: 0.8125rem; color: #8a8279; margin-left: auto; }
        .bi-abc { display: flex; flex-direction: column; gap: 0.75rem; }
        .bi-section { padding: 0.625rem; background: #f8f8f8; border-radius: 8px; display: flex; flex-direction: column; gap: 0.25rem; }
        .bi-label { font-size: 0.625rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: #8a8279; }
        .bi-text { font-size: 0.875rem; color: #1a1816; line-height: 1.5; }
      </style>
    </template>
  };

  static embedded = class Embedded extends Component<typeof BehaviorIncidentCard> {
    get severityColor() {
      switch (this.args.model.severity) {
        case 'High': return '#e05d50';
        case 'Medium': return '#c08b30';
        case 'Low': return '#2a9d8f';
        default: return '#8a8279';
      }
    }

    <template>
      <div class='bi-embed'>
        <div class='bi-embed-top'>
          <span class='bi-embed-type'>{{@model.incidentType}}</span>
          <span class='bi-embed-sev' style='color: {{this.severityColor}}'>{{@model.severity}}</span>
        </div>
        {{#if @model.behavior}}
          <div class='bi-embed-desc'>{{@model.behavior}}</div>
        {{/if}}
        {{#if @model.duration}}
          <div class='bi-embed-dur'>Duration: {{@model.duration}}</div>
        {{/if}}
      </div>
      <style scoped>
        .bi-embed { display: flex; flex-direction: column; gap: 4px; padding: 10px 12px; background: #fff; border: 1px solid #e8e4e0; border-radius: 10px; border-left: 3px solid #c08b30; }
        .bi-embed-top { display: flex; align-items: center; justify-content: space-between; }
        .bi-embed-type { font-size: 12px; font-weight: 700; color: #1a1816; }
        .bi-embed-sev { font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
        .bi-embed-desc { font-size: 11.5px; color: #5c5650; line-height: 1.35; }
        .bi-embed-dur { font-size: 10px; color: #8a8279; }
      </style>
    </template>
  };

  static fitted = class Fitted extends Component<typeof BehaviorIncidentCard> {
    get severityColor() {
      switch (this.args.model.severity) {
        case 'High': return '#e05d50';
        case 'Medium': return '#c08b30';
        case 'Low': return '#2a9d8f';
        default: return '#8a8279';
      }
    }

    <template>
      <div class='bi-fit'>
        <span class='bi-fit-sev' style='background: {{this.severityColor}}'>{{@model.severity}}</span>
        <span class='bi-fit-type'>{{@model.incidentType}}</span>
      </div>
      <style scoped>
        .bi-fit { display: flex; align-items: center; gap: 6px; padding: 6px 10px; width: 100%; height: 100%; box-sizing: border-box; }
        .bi-fit-sev { font-size: 8px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.06em; color: #fff; padding: 2px 6px; border-radius: 3px; flex-shrink: 0; }
        .bi-fit-type { font-size: 12px; font-weight: 600; color: #1a1816; flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
      </style>
    </template>
  };
}

// ── Assessment Result Card ──
// Stores a specific assessment score/result

export class AssessmentResultCard extends CardDef {
  static displayName = 'Assessment Result';

  @field assessmentName = contains(StringField);
  @field domain = contains(StringField);
  @field score = contains(StringField);
  @field percentage = contains(NumberField);
  @field benchmark = contains(StringField);
  @field notes = contains(StringField);
  @field cardTitle = contains(StringField, {
    computeVia: function (this: AssessmentResultCard) {
      let name = this.assessmentName ?? 'Assessment';
      let score = this.score ?? '';
      return score ? `${name}: ${score}` : name;
    },
  });

  static isolated = class Isolated extends Component<typeof AssessmentResultCard> {
    get benchmarkColor() {
      switch (this.args.model.benchmark) {
        case 'Exceeds': return '#2a9d8f';
        case 'Proficient': return '#2a9d8f';
        case 'Approaching': return '#c08b30';
        case 'Below': return '#e05d50';
        default: return '#8a8279';
      }
    }

    get domainColor() {
      switch (this.args.model.domain) {
        case 'Math': return '#e05d50';
        case 'Reading': return '#c08b30';
        case 'Social': return '#7c5fc4';
        default: return '#5c5650';
      }
    }

    <template>
      <article class='ar-isolated'>
        <header class='ar-header'>
          <span class='ar-domain' style='background: {{this.domainColor}}'>{{@model.domain}}</span>
          <span class='ar-benchmark' style='color: {{this.benchmarkColor}}; background: {{this.benchmarkColor}}18'>{{@model.benchmark}}</span>
        </header>
        <h1 class='ar-title'>{{@model.assessmentName}}</h1>
        <div class='ar-score-row'>
          <span class='ar-score'>{{@model.score}}</span>
          {{#if @model.percentage}}
            <span class='ar-pct'>({{@model.percentage}}%)</span>
          {{/if}}
        </div>
        {{#if @model.notes}}
          <div class='ar-notes'>{{@model.notes}}</div>
        {{/if}}
      </article>
      <style scoped>
        .ar-isolated { max-width: 400px; padding: 1.25rem; display: flex; flex-direction: column; gap: 1rem; }
        .ar-header { display: flex; align-items: center; gap: 0.5rem; }
        .ar-domain { padding: 0.1875rem 0.625rem; border-radius: 1rem; color: #fff; font-size: 0.6875rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; }
        .ar-benchmark { font-size: 0.6875rem; font-weight: 700; padding: 0.1875rem 0.5rem; border-radius: 4px; text-transform: uppercase; letter-spacing: 0.05em; }
        .ar-title { font-size: 1.125rem; font-weight: 700; margin: 0; color: #1a1816; }
        .ar-score-row { display: flex; align-items: baseline; gap: 0.5rem; }
        .ar-score { font-size: 1.5rem; font-weight: 700; color: #1a1816; }
        .ar-pct { font-size: 1rem; color: #8a8279; }
        .ar-notes { font-size: 0.875rem; color: #5c5650; line-height: 1.5; padding: 0.625rem; background: #f8f8f8; border-radius: 8px; }
      </style>
    </template>
  };

  static embedded = class Embedded extends Component<typeof AssessmentResultCard> {
    get benchmarkColor() {
      switch (this.args.model.benchmark) {
        case 'Exceeds': return '#2a9d8f';
        case 'Proficient': return '#2a9d8f';
        case 'Approaching': return '#c08b30';
        case 'Below': return '#e05d50';
        default: return '#8a8279';
      }
    }

    <template>
      <div class='ar-embed'>
        <div class='ar-embed-top'>
          <span class='ar-embed-name'>{{@model.assessmentName}}</span>
          <span class='ar-embed-score'>{{@model.score}}</span>
        </div>
        <div class='ar-embed-bottom'>
          <span class='ar-embed-bench' style='color: {{this.benchmarkColor}}'>{{@model.benchmark}}</span>
          {{#if @model.notes}}
            <span class='ar-embed-note'>{{@model.notes}}</span>
          {{/if}}
        </div>
      </div>
      <style scoped>
        .ar-embed { display: flex; flex-direction: column; gap: 4px; padding: 10px 12px; background: #fff; border: 1px solid #e8e4e0; border-radius: 10px; border-left: 3px solid #5c8fc4; }
        .ar-embed-top { display: flex; align-items: center; justify-content: space-between; }
        .ar-embed-name { font-size: 12px; font-weight: 700; color: #1a1816; }
        .ar-embed-score { font-size: 14px; font-weight: 700; color: #1a1816; }
        .ar-embed-bottom { display: flex; align-items: center; gap: 6px; }
        .ar-embed-bench { font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; flex-shrink: 0; }
        .ar-embed-note { font-size: 11px; color: #5c5650; line-height: 1.3; }
      </style>
    </template>
  };

  static fitted = class Fitted extends Component<typeof AssessmentResultCard> {
    <template>
      <div class='ar-fit'>
        <span class='ar-fit-name'>{{@model.assessmentName}}</span>
        <span class='ar-fit-score'>{{@model.score}}</span>
      </div>
      <style scoped>
        .ar-fit { display: flex; align-items: center; justify-content: space-between; gap: 6px; padding: 6px 10px; width: 100%; height: 100%; box-sizing: border-box; }
        .ar-fit-name { font-size: 12px; font-weight: 600; color: #1a1816; flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .ar-fit-score { font-size: 13px; font-weight: 700; color: #1a1816; flex-shrink: 0; }
      </style>
    </template>
  };
}
