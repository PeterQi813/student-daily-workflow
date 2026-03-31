import {
  CardDef,
  Component,
  field,
  contains,
  containsMany,
  linksTo,
} from 'https://cardstack.com/base/card-api';
import StringField from 'https://cardstack.com/base/string';
import BooleanField from 'https://cardstack.com/base/boolean';
import { GradeLevel } from './enums';
import { StudentTag, Alert } from './shared-fields';
import { Staff } from './staff';
// Student entity - daily ops view with identity, status, and support flags

export class Student extends CardDef {
  static displayName = 'Student';

  @field firstName = contains(StringField);
  @field lastName = contains(StringField);
  @field preferredName = contains(StringField);
  @field gradeLevel = contains(GradeLevel);
  @field photoUrl = contains(StringField);

  @field location = contains(StringField);
  @field locationDetail = contains(StringField);

  @field hasIEP = contains(BooleanField);
  @field has504 = contains(BooleanField);
  @field hasAllergy = contains(BooleanField);
  @field hasMedication = contains(BooleanField);

  @field tags = containsMany(StudentTag);
  @field alerts = containsMany(Alert);
  @field supportStaff = linksTo(Staff);

  // Computed fields
  @field displayName = contains(StringField, {
    computeVia: function (this: Student) {
      const name = this.preferredName || this.firstName || '';
      const lastInitial = this.lastName ? this.lastName.charAt(0) + '.' : '';
      return `${name} ${lastInitial}`.trim() || 'Unknown Student';
    },
  });

  @field fullName = contains(StringField, {
    computeVia: function (this: Student) {
      return `${this.firstName || ''} ${this.lastName || ''}`.trim() || 'Unknown Student';
    },
  });

  @field initials = contains(StringField, {
    computeVia: function (this: Student) {
      const first = (this.firstName || '').charAt(0).toUpperCase();
      const last = (this.lastName || '').charAt(0).toUpperCase();
      return `${first}${last}` || '??';
    },
  });

  @field name = contains(StringField, {
    computeVia: function (this: Student) {
      return this.fullName || 'Unknown Student';
    },
  });

  @field shortName = contains(StringField, {
    computeVia: function (this: Student) {
      return this.displayName || 'Unknown';
    },
  });

  @field grade = contains(StringField, {
    computeVia: function (this: Student) {
      const val = this.gradeLevel?.value;
      return val ? `${val} Grade` : '';
    },
  });

  @field avatar = contains(StringField, {
    computeVia: function (this: Student) {
      return this.photoUrl || '';
    },
  });

  @field tagSummary = contains(StringField, {
    computeVia: function (this: Student) {
      const icons: string[] = [];
      if (this.hasIEP) icons.push('IEP');
      if (this.has504) icons.push('504');
      if (this.hasAllergy) icons.push('Allergy');
      if (this.hasMedication) icons.push('Meds');
      return icons.join(' · ');
    },
  });

  @field title = contains(StringField, {
    computeVia: function (this: Student) {
      return this.fullName || 'Unnamed Student';
    },
  });

  static isolated = class Isolated extends Component<typeof this> {
    <template>
      <article class='student-isolated'>
        <header class='student-header'>
          <div class='student-avatar'>
            {{#if @model.photoUrl}}
              <img src={{@model.photoUrl}} alt={{@model.displayName}} class='photo' />
            {{else}}
              <div class='avatar-placeholder'>
                <span class='avatar-initials'>{{@model.initials}}</span>
              </div>
            {{/if}}
          </div>
          <div class='student-identity'>
            <h1 class='name'>{{@model.fullName}}</h1>
            {{#if @model.preferredName}}
              <span class='preferred'>"{{@model.preferredName}}"</span>
            {{/if}}
            <span class='meta'>
              {{#if @model.grade}}{{@model.grade}}{{/if}}
              {{#if @model.location}} · {{@model.location}}{{/if}}
            </span>
            <div class='tag-list'>
              {{#each @model.tags as |tag|}}
                <span class='tag' style='background: {{tag.color}}20; color: {{tag.color}}'>{{tag.label}}</span>
              {{/each}}
            </div>
          </div>
        </header>

        {{#if @model.alerts.length}}
          <section class='section'>
            <h2 class='section-label'>Alerts</h2>
            <@fields.alerts />
          </section>
        {{/if}}

      </article>
      <style scoped>
        .student-isolated { max-width: 800px; margin: 0 auto; padding: 1.5rem; }
        .student-header { display: flex; gap: 1.5rem; align-items: flex-start; padding-bottom: 1.5rem; border-bottom: 1px solid #e8e4e0; margin-bottom: 1.5rem; }
        .student-avatar { width: 80px; height: 80px; flex-shrink: 0; }
        .photo { width: 80px; height: 80px; border-radius: 12px; object-fit: cover; }
        .avatar-placeholder { width: 80px; height: 80px; background: #7c5fc4; border-radius: 12px; display: flex; align-items: center; justify-content: center; }
        .avatar-initials { color: #fff; font-size: 1.5rem; font-weight: 600; }
        .student-identity { flex: 1; display: flex; flex-direction: column; gap: 0.375rem; }
        .name { font-size: 1.5rem; font-weight: 700; margin: 0; }
        .preferred { font-size: 0.875rem; color: #7c5fc4; font-style: italic; }
        .meta { font-size: 0.875rem; color: #8a8279; }
        .tag-list { display: flex; gap: 0.25rem; flex-wrap: wrap; margin-top: 0.25rem; }
        .tag { display: inline-flex; padding: 0.125rem 0.5rem; font-size: 0.6875rem; font-weight: 600; border-radius: 4px; }
        .section { margin-bottom: 1.5rem; padding: 1rem; background: #f8f8f8; border-radius: 10px; }
        .section-label { font-size: 0.6875rem; font-weight: 500; text-transform: uppercase; letter-spacing: 0.08em; color: #8a8279; margin: 0 0 0.75rem 0; }
        .current-activity { font-size: 1rem; color: #1a1816; margin: 0; }
        .progress-bar { height: 8px; background: #ebe7e3; border-radius: 4px; overflow: hidden; }
        .progress-fill { height: 100%; background: #2a9d8f; border-radius: 4px; }
        .progress-pct { font-size: 0.875rem; font-weight: 700; color: #1a1816; margin-top: 0.25rem; display: block; }
      </style>
    </template>
  };

  static embedded = class Embedded extends Component<typeof this> {
    get safeName() { return this.args.model?.shortName ?? this.args.model?.name ?? 'Unknown'; }
    get safeAvatar() { return this.args.model?.avatar ?? ''; }
    get safeTags() { return this.args.model?.tags ?? []; }
    get safeLocation() { return this.args.model?.location ?? 'In Classroom'; }

    get locationColor() {
      switch (this.safeLocation) {
        case 'In Classroom': return '#2a9d8f';
        case 'At Specialists': return '#c08b30';
        case 'Absent': return '#e05d50';
        default: return '#8a8279';
      }
    }

    <template>
      <div class='student-embedded'>
        <div class='avatar-wrapper'>
          {{#if this.safeAvatar}}
            <img src={{this.safeAvatar}} alt='{{this.safeName}}' />
          {{else}}
            <div class='avatar-placeholder'>
              <span class='avatar-initials'>{{@model.initials}}</span>
            </div>
          {{/if}}
          <span class='status-dot' style='background-color: {{this.locationColor}}'></span>
        </div>
        <div class='info'>
          <div class='name'>{{this.safeName}}</div>
          <div class='badges'>
            {{#each this.safeTags as |tag|}}
              <span class='tag'>{{tag.label}}</span>
            {{/each}}
          </div>
        </div>
      </div>
      <style scoped>
        .student-embedded { display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem; background-color: var(--card); border: 1px solid var(--border); border-radius: 8px; height: 100%; }
        .avatar-wrapper { position: relative; flex-shrink: 0; width: 2.25rem; height: 2.25rem; }
        .avatar-wrapper img { width: 100%; height: 100%; border-radius: 50%; object-fit: cover; }
        .avatar-placeholder { width: 100%; height: 100%; background: linear-gradient(135deg, #e8e4f0 0%, #d4cce8 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center; }
        .avatar-initials { color: #7c5fc4; font-size: 0.75rem; font-weight: 700; }
        .status-dot { position: absolute; bottom: -1px; right: -1px; width: 0.625rem; height: 0.625rem; border-radius: 50%; border: 2px solid var(--card, white); }
        .info { flex: 1; min-width: 0; }
        .name { font-weight: 700; font-size: 0.8125rem; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .badges { display: flex; gap: 0.25rem; }
        .tag { font-size: 0.5625rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.06em; padding: 0.0625rem 0.3125rem; border-radius: 3px; background: rgba(224, 93, 80, 0.1); color: #e05d50; }
        .mini-progress { flex-shrink: 0; }
        .mini-pct { font-size: 0.75rem; font-weight: 700; color: #2a9d8f; }
      </style>
    </template>
  };

  static fitted = class Fitted extends Component<typeof this> {
    get safeName() { return this.args.model?.shortName ?? this.args.model?.name ?? 'Unknown'; }
    get safeAvatar() { return this.args.model?.avatar ?? ''; }
    get safeLocation() { return this.args.model?.location ?? 'In Classroom'; }

    get locationColor() {
      switch (this.safeLocation) {
        case 'In Classroom': return '#2a9d8f';
        case 'At Specialists': return '#c08b30';
        case 'Absent': return '#e05d50';
        default: return '#8a8279';
      }
    }

    <template>
      <div class='fitted-container'>
        <div class='tile'>
          <div class='avatar-fitted'>
            {{#if this.safeAvatar}}
              <img src={{this.safeAvatar}} alt='{{this.safeName}}' />
            {{else}}
              <div class='avatar-placeholder'>
                <span class='avatar-initials'>{{@model.initials}}</span>
              </div>
            {{/if}}
          </div>
          <div class='fitted-name'>{{this.safeName}}</div>
          <span class='location-dot' style='background-color: {{this.locationColor}}'></span>
        </div>
      </div>
      <style scoped>
        .fitted-container { container-type: size; width: 100%; height: 100%; }
        .tile { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 0.25rem; padding: 1rem; background-color: var(--card); border: 1px solid var(--border); border-radius: 8px; height: 100%; }
        .avatar-fitted { width: 4rem; height: 4rem; border-radius: 50%; overflow: hidden; }
        .avatar-fitted img { width: 100%; height: 100%; object-fit: cover; }
        .avatar-placeholder { width: 100%; height: 100%; background: linear-gradient(135deg, #e8e4f0 0%, #d4cce8 100%); display: flex; align-items: center; justify-content: center; }
        .avatar-initials { color: #7c5fc4; font-size: 1.25rem; font-weight: 700; }
        .fitted-name { font-weight: 700; font-size: 0.875rem; text-align: center; }
        .location-dot { width: 0.5rem; height: 0.5rem; border-radius: 50%; }
      </style>
    </template>
  };

  static atom = class Atom extends Component<typeof this> {
    <template>
      <span class='student-atom'>
        <span class='atom-avatar'>
          {{#if @model.photoUrl}}
            <img src={{@model.photoUrl}} alt='' class='atom-photo' />
          {{else}}
            <span class='atom-initials'>{{@model.initials}}</span>
          {{/if}}
        </span>
        <span class='atom-name'><@fields.firstName /> <@fields.lastName /></span>
      </span>
      <style scoped>
        .student-atom { display: inline-flex; align-items: center; gap: 0.25rem; padding: 0.125rem 0.375rem 0.125rem 0.125rem; background: #f4f0fa; border-radius: 4px; }
        .atom-avatar { width: 18px; height: 18px; border-radius: 4px; overflow: hidden; flex-shrink: 0; display: flex; align-items: center; justify-content: center; background: #7c5fc4; }
        .atom-photo { width: 18px; height: 18px; object-fit: cover; }
        .atom-initials { color: white; font-size: 0.5rem; font-weight: 700; }
        .atom-name { font-size: 0.8125rem; font-weight: 500; color: #7c5fc4; white-space: nowrap; }
      </style>
    </template>
  };
}
