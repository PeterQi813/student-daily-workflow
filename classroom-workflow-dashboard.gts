import {
  CardDef,
  Component,
  contains,
  linksToMany,
  field,
} from 'https://cardstack.com/base/card-api';
import StringField from 'https://cardstack.com/base/string';
import { fn, get } from '@ember/helper';
import { on } from '@ember/modifier';
import { tracked } from '@glimmer/tracking';
import { eq } from '@cardstack/boxel-ui/helpers';
// Master-detail classroom dashboard for daily student workflows

export class ClassroomWorkflowDashboard extends CardDef {
  static displayName = 'Classroom Workflow Dashboard';
  static prefersWideFormat = true;

  @field dashboardTitle = contains(StringField);
  @field classroomName = contains(StringField);
  @field dateLabel = contains(StringField);
  @field workflows = linksToMany(CardDef);
  @field cardTitle = contains(StringField, {
    computeVia: function (this: ClassroomWorkflowDashboard) {
      return this.dashboardTitle ?? 'Classroom Dashboard';
    },
  });

  // ── Isolated: Left nav + right content ──

  static isolated = class Isolated extends Component<typeof ClassroomWorkflowDashboard> {
    @tracked selectedIndex = 0;

    selectWorkflow = (index: number, event: Event) => {
      event.preventDefault();
      event.stopPropagation();
      this.selectedIndex = index;
    };

    <template>
      <div class='dash-layout'>

        {{! ── Left nav ── }}
        <nav class='nav-pane'>
          <header class='nav-header'>
            <div class='nav-icon'>
              <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5'>
                <path d='M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z'/>
                <path d='M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z'/>
              </svg>
            </div>
            <div class='nav-header-info'>
              <span class='nav-title'>{{if @model.dashboardTitle @model.dashboardTitle 'Daily Workflows'}}</span>
              <span class='nav-sub'>{{@model.classroomName}} · {{@model.dateLabel}}</span>
            </div>
            <span class='nav-count'>{{@model.workflows.length}}</span>
          </header>

          <div class='nav-search'>
            <svg class='nav-search-icon' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'>
              <circle cx='11' cy='11' r='8'/><path d='m21 21-4.35-4.35'/>
            </svg>
            <span class='nav-search-text'>Search students...</span>
          </div>

          <div class='nav-list'>
            {{#each @model.workflows as |wf index|}}
              <button
                type='button'
                class={{if (eq index this.selectedIndex) 'nav-item active' 'nav-item'}}
                {{on 'click' (fn this.selectWorkflow index)}}
              >
                {{#let (get @fields.workflows index) as |WfField|}}
                  <WfField @format="fitted" />
                {{/let}}
              </button>
            {{/each}}
          </div>
        </nav>

        {{! ── Right content ── }}
        <main class='content-pane'>
          {{#if @model.workflows.length}}
            {{#let (get @fields.workflows this.selectedIndex) as |SelectedWf|}}
              <SelectedWf @format="isolated" />
            {{/let}}
          {{else}}
            <div class='empty-state'>
              <div class='empty-icon'>
                <svg width='32' height='32' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.5'>
                  <path d='M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z'/>
                  <path d='M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z'/>
                </svg>
              </div>
              <div class='empty-title'>No student workflows yet</div>
              <div class='empty-sub'>Link student day workflows to get started</div>
            </div>
          {{/if}}
        </main>

      </div>

      <style scoped>
        .dash-layout {
          --c-nav-bg: #141820;
          --c-border: rgba(255, 255, 255, 0.06);
          --font: ui-sans-serif, system-ui, -apple-system, 'Segoe UI', sans-serif;

          display: grid;
          grid-template-columns: 300px minmax(0, 1fr);
          height: 100%;
          width: 100%;
          font-family: var(--font);
          overflow: hidden;
        }

        .nav-pane {
          background: var(--c-nav-bg);
          border-right: 1px solid var(--c-border);
          display: flex;
          flex-direction: column;
          overflow: hidden;
        }

        .nav-header {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 14px 16px 10px;
          flex-shrink: 0;
        }
        .nav-icon {
          width: 30px; height: 30px; border-radius: 8px;
          background: linear-gradient(135deg, #2a9d8f, #1e8a7e);
          display: flex; align-items: center; justify-content: center;
          color: #fff; flex-shrink: 0;
        }
        .nav-header-info { flex: 1; min-width: 0; }
        .nav-title { font-size: 14px; font-weight: 700; color: #e8eaf0; display: block; }
        .nav-sub { font-size: 11px; color: rgba(255,255,255,0.4); }
        .nav-count {
          background: rgba(42, 157, 143, 0.2);
          color: #2a9d8f;
          font-size: 11px; font-weight: 700;
          padding: 2px 8px; border-radius: 99px;
          min-width: 20px; text-align: center;
        }

        .nav-search {
          display: flex; align-items: center; gap: 8px;
          margin: 0 12px 8px; padding: 7px 10px;
          background: rgba(255,255,255,0.04);
          border: 1px solid rgba(255,255,255,0.06);
          border-radius: 6px; flex-shrink: 0;
        }
        .nav-search-icon { color: rgba(255,255,255,0.3); flex-shrink: 0; }
        .nav-search-text { font-size: 12px; color: rgba(255,255,255,0.25); }

        .nav-list {
          flex: 1; overflow-y: auto; padding: 0;
          display: flex; flex-direction: column; gap: 0;
          scrollbar-width: thin; scrollbar-color: rgba(255,255,255,0.1) transparent;
        }

        .nav-item {
          display: block; width: 100%; border: none;
          border-left: 3px solid transparent;
          border-bottom: 1px solid var(--c-border);
          background: transparent; padding: 0; margin: 0;
          cursor: pointer; border-radius: 0;
          overflow: hidden; text-align: left;
          min-height: 160px;
          transition: border-color 0.12s, background 0.15s;
        }
        .nav-item > * {
          pointer-events: none;
          border: none !important; border-radius: 0 !important;
          box-shadow: none !important; margin: 0 !important; overflow: hidden;
        }
        .nav-item > * > * {
          border: none !important; border-radius: 0 !important;
          box-shadow: none !important; margin: 0 !important;
        }
        .nav-item:hover { background: rgba(255,255,255,0.03); }
        .nav-item.active { border-left-color: #2a9d8f; background: rgba(42, 157, 143, 0.06); }

        .content-pane { background: #ffffff; overflow: hidden; }
        .content-pane > * {
          border: none !important; border-radius: 0 !important;
          box-shadow: none !important;
          width: 100%; height: 100%; overflow: hidden;
        }
        .content-pane > * > * {
          border: none !important; border-radius: 0 !important;
          box-shadow: none !important;
          width: 100%; height: 100%; overflow: hidden;
        }

        .empty-state {
          display: flex; flex-direction: column; align-items: center;
          justify-content: center; height: 100%; color: #9ca3af; gap: 8px;
        }
        .empty-icon { opacity: 0.3; }
        .empty-title { font-size: 16px; font-weight: 600; color: #6b7280; }
        .empty-sub { font-size: 13px; }
      </style>
    </template>
  };

  // ── Fitted ──

  static fitted = class Fitted extends Component<typeof ClassroomWorkflowDashboard> {
    <template>
      <div class='df'>
        <div class='df-icon'>
          <svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5'>
            <path d='M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z'/>
            <path d='M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z'/>
          </svg>
        </div>
        <div class='df-copy'>
          <div class='df-title'>{{if @model.dashboardTitle @model.dashboardTitle 'Dashboard'}}</div>
          <div class='df-count'>{{@model.workflows.length}} students</div>
        </div>
      </div>

      <style scoped>
        .df {
          width: 100%; height: 100%; box-sizing: border-box;
          display: flex; align-items: center; gap: 10px;
          background: linear-gradient(160deg, #10131a, #202739 55%, #0c3b34);
          color: #f8fbff; padding: 14px; border-radius: 12px;
          font-family: ui-sans-serif, system-ui, -apple-system, sans-serif;
        }
        .df-icon {
          width: 36px; height: 36px; border-radius: 10px;
          background: linear-gradient(135deg, #2a9d8f, #1e8a7e);
          display: flex; align-items: center; justify-content: center;
          color: #fff; flex-shrink: 0;
        }
        .df-title { font-size: 14px; font-weight: 800; }
        .df-count { font-size: 12px; opacity: 0.6; }
      </style>
    </template>
  };

  // ── Embedded ──

  static embedded = class Embedded extends Component<typeof ClassroomWorkflowDashboard> {
    <template>
      <div class='de'>
        <div class='de-icon'>
          <svg width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5'>
            <path d='M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z'/>
            <path d='M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z'/>
          </svg>
        </div>
        <span class='de-title'>{{if @model.dashboardTitle @model.dashboardTitle 'Dashboard'}}</span>
        <span class='de-count'>{{@model.workflows.length}}</span>
      </div>

      <style scoped>
        .de {
          display: flex; align-items: center; gap: 8px; padding: 10px 14px;
          background: linear-gradient(135deg, #10131a, #202739); color: #f0f2f7;
          border-radius: 10px; font-family: ui-sans-serif, system-ui, -apple-system, sans-serif;
        }
        .de-icon {
          width: 28px; height: 28px; border-radius: 7px;
          background: linear-gradient(135deg, #2a9d8f, #1e8a7e);
          display: flex; align-items: center; justify-content: center;
          color: #fff; flex-shrink: 0;
        }
        .de-title { font-size: 13px; font-weight: 700; flex: 1; }
        .de-count { font-size: 11px; opacity: 0.5; }
      </style>
    </template>
  };
}
