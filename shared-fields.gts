import {
  FieldDef,
  field,
  contains,
  Component,
} from 'https://cardstack.com/base/card-api';
import StringField from 'https://cardstack.com/base/string';
import { TagType } from './enums';

// ─── StudentTag ───
export class StudentTag extends FieldDef {
  static displayName = 'Student Tag';

  @field label = contains(StringField);
  @field color = contains(StringField);
  @field tagType = contains(TagType);

  static embedded = class Embedded extends Component<typeof this> {
    <template>
      <div class='tag' style='background: {{@model.color}}20; color: {{@model.color}};'>
        <span class='tag-label'><@fields.label /></span>
      </div>
      <style scoped>
        .tag {
          display: inline-flex;
          align-items: center;
          padding: 0.1875rem 0.5rem;
          font-size: 0.6875rem;
          font-weight: 600;
          border-radius: 4px;
          letter-spacing: 0.02em;
        }
      </style>
    </template>
  };
}

// ─── Alert ───
export class Alert extends FieldDef {
  static displayName = 'Alert';

  @field alertType = contains(StringField);
  @field urgency = contains(StringField);
  @field message = contains(StringField);
  @field detail = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    get safeType() {
      return this.args.model?.alertType ?? 'Info';
    }

    get safeMessage() {
      return this.args.model?.message ?? '';
    }

    get isUrgent() {
      return this.args.model?.urgency === 'Urgent';
    }

    get bgColor() {
      if (this.isUrgent) return 'rgba(224, 93, 80, 0.08)';
      return 'rgba(138, 130, 121, 0.06)';
    }

    get borderColor() {
      if (this.isUrgent) return 'rgba(224, 93, 80, 0.2)';
      return 'rgba(138, 130, 121, 0.15)';
    }

    <template>
      <div class='alert-row' style='background: {{this.bgColor}}; border-color: {{this.borderColor}}'>
        <div class='alert-content'>
          <span class='alert-type'>{{this.safeType}}</span>
          <span class='alert-message'>{{this.safeMessage}}</span>
          {{#if @model.detail}}
            <span class='alert-detail'>{{@model.detail}}</span>
          {{/if}}
        </div>
      </div>
      <style scoped>
        .alert-row {
          display: flex;
          align-items: flex-start;
          gap: 0.5rem;
          padding: 0.5rem 0.625rem;
          border-radius: 8px;
          border: 1px solid;
        }
        .alert-content {
          display: flex;
          flex-wrap: wrap;
          gap: 0.25rem 0.5rem;
          align-items: baseline;
        }
        .alert-type {
          font-size: 0.6875rem;
          font-weight: 700;
          text-transform: uppercase;
          letter-spacing: 0.08em;
          color: #e05d50;
        }
        .alert-message {
          font-size: 0.8125rem;
          color: #1a1816;
          font-weight: 500;
        }
        .alert-detail {
          font-size: 0.6875rem;
          color: #8a8279;
          font-weight: 500;
        }
      </style>
    </template>
  };
}

// ─── ParentInfo ───
export class ParentInfo extends FieldDef {
  static displayName = 'Parent Info';

  @field firstName = contains(StringField);
  @field lastName = contains(StringField);
  @field relationship = contains(StringField);
  @field email = contains(StringField);
  @field phone = contains(StringField);

  static embedded = class Embedded extends Component<typeof this> {
    <template>
      <div class='parent'>
        <div class='parent-row'>
          <div class='field-col'><span class='field-label'>Name</span><@fields.firstName /> <@fields.lastName /></div>
          <div class='field-col'><span class='field-label'>Relationship</span><@fields.relationship /></div>
        </div>
        <div class='parent-row'>
          <div class='field-col'><span class='field-label'>Phone</span><@fields.phone /></div>
          <div class='field-col'><span class='field-label'>Email</span><@fields.email /></div>
        </div>
      </div>
      <style scoped>
        .parent { display: flex; flex-direction: column; gap: 0.375rem; padding: 0.625rem; background: #fffdfb; border: 1px solid #ebe7e3; border-radius: 8px; }
        .parent-row { display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; }
        .field-col { display: flex; flex-direction: column; gap: 0.125rem; }
        .field-label { font-size: 0.625rem; font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em; color: #8a8279; }
      </style>
    </template>
  };
}
