// Student Daily Workflow — Shared Enums
import {
  FieldDef,
  field,
  contains,
  Component,
} from 'https://cardstack.com/base/card-api';
import StringField from 'https://cardstack.com/base/string';

// ─── Grade Level ───
export class GradeLevel extends FieldDef {
  static displayName = 'Grade Level';
  @field value = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    <template>
      <span class='grade'><@fields.value /></span>
      <style scoped>
        .grade {
          font-size: 0.875rem;
          font-weight: 500;
          color: var(--muted-foreground, #6c6a81);
        }
      </style>
    </template>
  };
}

// ─── Entry Type ───
// Academic | Social | Behavioral | CurriculumNote | Observation
export class EntryType extends FieldDef {
  static displayName = 'Entry Type';
  @field value = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    get colorClass(): string {
      const map: Record<string, string> = {
        academic: 'coral',
        social: 'purple',
        behavioral: 'amber',
        curriculumnote: 'teal',
        observation: 'neutral',
      };
      return map[this.args.model.value?.toLowerCase() ?? ''] ?? 'neutral';
    }

    <template>
      <span class='entry-type {{this.colorClass}}'><@fields.value /></span>
      <style scoped>
        .entry-type {
          display: inline-flex;
          padding: 0.1875rem 0.5rem;
          font-size: 0.6875rem;
          font-weight: 600;
          border-radius: 4px;
          text-transform: capitalize;
        }
        .entry-type.coral { background: #fdf0ee; color: #e05d50; }
        .entry-type.purple { background: #f4f0fa; color: #7c5fc4; }
        .entry-type.amber { background: #fdf6e8; color: #c08b30; }
        .entry-type.teal { background: #e8f6f4; color: #2a9d8f; }
        .entry-type.neutral { background: #f5f2ef; color: #5c5650; }
      </style>
    </template>
  };
}

// ─── Block Domain ───
// Math | Reading | Social | Behavioral | Motor | Communication | General
export class BlockDomain extends FieldDef {
  static displayName = 'Block Domain';
  @field value = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    get colorClass(): string {
      const map: Record<string, string> = {
        math: 'coral',
        reading: 'amber',
        social: 'purple',
        behavioral: 'amber',
        motor: 'teal',
        communication: 'blue',
        general: 'neutral',
      };
      return map[this.args.model.value?.toLowerCase() ?? ''] ?? 'neutral';
    }

    <template>
      <span class='domain {{this.colorClass}}'><@fields.value /></span>
      <style scoped>
        .domain {
          display: inline-flex;
          padding: 0.1875rem 0.5rem;
          font-size: 0.6875rem;
          font-weight: 600;
          border-radius: 4px;
          text-transform: capitalize;
        }
        .domain.coral { background: #fdf0ee; color: #e05d50; }
        .domain.purple { background: #f4f0fa; color: #7c5fc4; }
        .domain.amber { background: #fdf6e8; color: #c08b30; }
        .domain.teal { background: #e8f6f4; color: #2a9d8f; }
        .domain.blue { background: #edf2fa; color: #4a7cc4; }
        .domain.neutral { background: #f5f2ef; color: #5c5650; }
      </style>
    </template>
  };
}

// ─── Block Status ───
// Done | Current | Upcoming | Skipped
export class BlockStatus extends FieldDef {
  static displayName = 'Block Status';
  @field value = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    get colorClass(): string {
      const map: Record<string, string> = {
        done: 'done',
        current: 'current',
        upcoming: 'upcoming',
        skipped: 'skipped',
      };
      return map[this.args.model.value?.toLowerCase() ?? ''] ?? 'upcoming';
    }

    <template>
      <span class='status {{this.colorClass}}'><@fields.value /></span>
      <style scoped>
        .status {
          display: inline-flex;
          padding: 0.125rem 0.375rem;
          font-size: 0.625rem;
          font-weight: 600;
          border-radius: 3px;
          text-transform: uppercase;
          letter-spacing: 0.03em;
        }
        .status.done { background: #e8f6f4; color: #2a9d8f; }
        .status.current { background: #fdf0ee; color: #e05d50; }
        .status.upcoming { background: #f5f2ef; color: #8a8279; }
        .status.skipped { background: #f5f2ef; color: #b0a89f; }
      </style>
    </template>
  };
}

// ─── Day Status ───
// planned | in-progress | completed | absent
export class DayStatus extends FieldDef {
  static displayName = 'Day Status';
  @field value = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    get colorClass(): string {
      const map: Record<string, string> = {
        planned: 'planned',
        'in-progress': 'active',
        completed: 'completed',
        absent: 'absent',
      };
      return map[this.args.model.value?.toLowerCase() ?? ''] ?? 'planned';
    }

    <template>
      <span class='day-status {{this.colorClass}}'><@fields.value /></span>
      <style scoped>
        .day-status {
          display: inline-flex;
          padding: 0.1875rem 0.5rem;
          font-size: 0.6875rem;
          font-weight: 600;
          border-radius: 4px;
          text-transform: capitalize;
        }
        .day-status.planned { background: #f5f2ef; color: #5c5650; }
        .day-status.active { background: #fdf0ee; color: #e05d50; }
        .day-status.completed { background: #e8f6f4; color: #2a9d8f; }
        .day-status.absent { background: #f5f2ef; color: #b0a89f; }
      </style>
    </template>
  };
}

// ─── AI Suggestion Status ───
// pending | accepted | rejected | edited
export class AiSuggestionStatus extends FieldDef {
  static displayName = 'AI Suggestion Status';
  @field value = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    get colorClass(): string {
      const map: Record<string, string> = {
        pending: 'pending',
        accepted: 'accepted',
        rejected: 'rejected',
        edited: 'edited',
      };
      return map[this.args.model.value?.toLowerCase() ?? ''] ?? 'pending';
    }

    <template>
      <span class='ai-status {{this.colorClass}}'><@fields.value /></span>
      <style scoped>
        .ai-status {
          display: inline-flex;
          padding: 0.125rem 0.375rem;
          font-size: 0.625rem;
          font-weight: 600;
          border-radius: 3px;
          text-transform: uppercase;
          letter-spacing: 0.03em;
        }
        .ai-status.pending { background: #fdf6e8; color: #c08b30; }
        .ai-status.accepted { background: #e8f6f4; color: #2a9d8f; }
        .ai-status.rejected { background: #fdf0ee; color: #e05d50; }
        .ai-status.edited { background: #f4f0fa; color: #7c5fc4; }
      </style>
    </template>
  };
}

// ─── Alert Urgency ───
export class AlertUrgency extends FieldDef {
  static displayName = 'Alert Urgency';
  @field value = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    <template>
      <span class='urgency'><@fields.value /></span>
      <style scoped>
        .urgency { font-size: 0.75rem; font-weight: 500; color: #5c5650; text-transform: capitalize; }
      </style>
    </template>
  };
}

// ─── Tag Type ───
export class TagType extends FieldDef {
  static displayName = 'Tag Type';
  @field value = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    <template><span><@fields.value /></span></template>
  };
}
