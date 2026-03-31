import {
  CardDef,
  field,
  contains,
  Component,
} from 'https://cardstack.com/base/card-api';
import StringField from 'https://cardstack.com/base/string';
import UserIcon from '@cardstack/boxel-icons/user';

// Staff entity - teachers, assistants, and support specialists
export class Staff extends CardDef {
  static displayName = 'Staff';
  static icon = UserIcon;

  @field name = contains(StringField);
  @field role = contains(StringField);
  @field initials = contains(StringField);
  @field avatar = contains(StringField);
  @field color = contains(StringField);

  @field title = contains(StringField, {
    computeVia: function (this: Staff) {
      return this.name ?? 'Unnamed Staff';
    },
  });

  static isolated = class Isolated extends Component<typeof Staff> {
    get safeName() {
      return this.args.model?.name ?? 'Unnamed Staff';
    }

    get safeInitials() {
      return this.args.model?.initials ?? '??';
    }

    get safeRole() {
      return this.args.model?.role ?? 'Staff';
    }

    get accentColor() {
      switch (this.args.model?.color) {
        case 'coral': return '#e05d50';
        case 'teal': return '#2a9d8f';
        case 'purple': return '#7c5fc4';
        case 'amber': return '#c08b30';
        default: return '#5c5650';
      }
    }

    <template>
      <article class='staff-profile'>
        <div class='profile-header'>
          {{#if @model.avatar}}
            <div class='avatar-large'>
              <img src={{@model.avatar}} alt='{{this.safeName}}' />
            </div>
          {{else}}
            <div class='initials-large' style='background-color: {{this.accentColor}}'>
              {{this.safeInitials}}
            </div>
          {{/if}}
          <div class='header-info'>
            <h1 class='staff-name'>{{this.safeName}}</h1>
            <span class='role-badge' style='background-color: {{this.accentColor}}'>
              {{this.safeRole}}
            </span>
          </div>
        </div>
        <section class='profile-details'>
          <div class='detail-row'><span class='detail-label'>Name</span><span class='detail-value'><@fields.name /></span></div>
          <div class='detail-row'><span class='detail-label'>Role</span><span class='detail-value'><@fields.role /></span></div>
          <div class='detail-row'><span class='detail-label'>Initials</span><span class='detail-value'><@fields.initials /></span></div>
        </section>
      </article>
      <style scoped>
        .staff-profile { max-width: 32rem; margin: 0 auto; padding: 1.5rem; display: flex; flex-direction: column; gap: 1.5rem; }
        .profile-header { display: flex; align-items: center; gap: 1.5rem; padding-bottom: 1.5rem; border-bottom: 2px solid var(--border, #e8e4e0); }
        .avatar-large { width: 6rem; height: 6rem; border-radius: 50%; overflow: hidden; flex-shrink: 0; }
        .avatar-large img { width: 100%; height: 100%; object-fit: cover; }
        .initials-large { width: 6rem; height: 6rem; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 1.5rem; font-weight: 700; flex-shrink: 0; }
        .header-info { display: flex; flex-direction: column; gap: 0.5rem; }
        .staff-name { font-size: 1.5rem; font-weight: 700; margin: 0; }
        .role-badge { display: inline-block; padding: 0.25rem 0.75rem; border-radius: 1rem; color: white; font-weight: 600; font-size: 0.75rem; width: fit-content; }
        .profile-details { display: flex; flex-direction: column; gap: 0.75rem; }
        .detail-row { display: grid; grid-template-columns: 6rem 1fr; gap: 1rem; padding: 0.5rem; border-radius: 6px; background: var(--muted, #f8f8f8); }
        .detail-label { font-weight: 600; color: var(--muted-foreground, #6c6a81); font-size: 0.875rem; }
      </style>
    </template>
  };

  static embedded = class Embedded extends Component<typeof Staff> {
    get safeName() {
      return this.args.model?.name ?? 'Unknown';
    }

    get safeInitials() {
      return this.args.model?.initials ?? '??';
    }

    get safeRole() {
      return this.args.model?.role ?? 'Staff';
    }

    get accentColor() {
      switch (this.args.model?.color) {
        case 'coral': return '#e05d50';
        case 'teal': return '#2a9d8f';
        case 'purple': return '#7c5fc4';
        case 'amber': return '#c08b30';
        default: return '#5c5650';
      }
    }

    <template>
      <div class='staff-embedded'>
        <div class='initials-badge' style='background-color: {{this.accentColor}}'>
          {{this.safeInitials}}
        </div>
        <div class='staff-info'>
          <div class='staff-name'>{{this.safeName}}</div>
          <div class='staff-role'>{{this.safeRole}}</div>
        </div>
      </div>
      <style scoped>
        .staff-embedded { display: flex; align-items: center; gap: 0.5rem; padding: 0.5rem; background-color: var(--card); border: 1px solid var(--border); border-radius: 8px; height: 100%; }
        .initials-badge { flex-shrink: 0; width: 2.25rem; height: 2.25rem; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 0.75rem; font-weight: 700; }
        .staff-name { font-weight: 700; font-size: 0.8125rem; }
        .staff-role { font-size: 0.6875rem; color: var(--muted-foreground, #6c6a81); }
      </style>
    </template>
  };

  static fitted = class Fitted extends Component<typeof Staff> {
    get safeName() {
      return this.args.model?.name ?? 'Unknown';
    }

    get safeInitials() {
      return this.args.model?.initials ?? '??';
    }

    get accentColor() {
      switch (this.args.model?.color) {
        case 'coral': return '#e05d50';
        case 'teal': return '#2a9d8f';
        case 'purple': return '#7c5fc4';
        case 'amber': return '#c08b30';
        default: return '#5c5650';
      }
    }

    <template>
      <div class='fitted-container'>
        <div class='tile'>
          <div class='initials-circle' style='background-color: {{this.accentColor}}'>{{this.safeInitials}}</div>
          <div class='fitted-name'>{{this.safeName}}</div>
        </div>
      </div>
      <style scoped>
        .fitted-container { container-type: size; width: 100%; height: 100%; }
        .tile { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 0.5rem; padding: 1rem; background-color: var(--card); border: 1px solid var(--border); border-radius: 8px; height: 100%; }
        .initials-circle { width: 3.5rem; height: 3.5rem; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 1rem; font-weight: 700; }
        .fitted-name { font-weight: 700; font-size: 0.875rem; text-align: center; }
      </style>
    </template>
  };

  static atom = class Atom extends Component<typeof Staff> {
    <template>
      <span class='staff-atom'>
        <span class='atom-initials'>{{@model.initials}}</span>
        <span class='atom-name'><@fields.name /></span>
      </span>
      <style scoped>
        .staff-atom { display: inline-flex; align-items: center; gap: 0.25rem; padding: 0.125rem 0.375rem; background: #e8f6f4; border-radius: 4px; }
        .atom-initials { font-size: 0.625rem; font-weight: 700; color: #2a9d8f; }
        .atom-name { font-size: 0.8125rem; font-weight: 500; color: #2a9d8f; }
      </style>
    </template>
  };
}
